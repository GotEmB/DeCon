# Fluent Stuff
Array::select = (fun) ->
	ret = []
	@forEach (item) -> ret.push fun(item)
	ret

Array::where = (fun) ->
	ret = []
	@forEach (item) -> ret.push item if fun(item) is true
	ret

Array::first = (fun) ->
	if @length is 0
		null
	else if fun
		@where(fun).first()
	else
		@[0]

Array::last = (fun) ->
	if @length is 0
		null
	else if fun
		@where(fun).last()
	else
		@[@length - 1]

Array::contains = (item) -> @where((x) -> x is item).length > 0

Array::any = (fun) -> @where(fun).length > 0

Array::sum = (fun) ->
	return @where(fun).sum() if fun
	ret = 0
	@forEach (x) -> ret += x
	ret

Array::except = (arr) ->
	ret = [];
	@forEach (x) -> ret.push x unless arr.contains x
	ret

Array::flatten = ->
	ret = [];
	@forEach (x) -> x.forEach (y) -> ret.push y
	ret

Array::selectMany = (fun) ->
	@select(fun).flatten()

Array::groupBy = (fun) ->
	g1 = @select (x) ->
		key: fun x
		value: x
	while g1.length isnt 0
		g2 = g1.where (x) -> x.key is g1.first().key
		g1 = g1.except g1.where (x) -> x.key is g1.first().key
		key: g2.first().key
		values: g2.select (x) -> x.value

Array::orderBy = (fun) ->
	ret = @select (x) -> x
	ret.sort (a, b) -> fun(a) - fun(b)
	ret

Array::orderByDesc = (fun) ->
	ret = @select (x) -> x
	ret.sort (a, b) -> fun(b) - fun(a)
	ret

# Number Formatter
pad2 = (number) ->
     (if number < 10 then '0' else '') + number

# JSON extension
JSON.parseWithDate = (json) ->
	reISO = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/
	reMsAjax = /^\/Date\((d|-|.*)\)\/$/
	JSON.parse json, (key, value) ->
		if typeof value is "string"
			a = reISO.exec(value)
			return new Date(Date.UTC(+a[1], +a[2] - 1, +a[3], +a[4], +a[5], +a[6])) if a
			a = reMsAjax.exec(value)
			if a
				b = a[1].split(/[-,.]/)
				return new Date(+b[0])
		value

# Entry Point
$ ->
	$("#login-form").dialog
		autoOpen: false
		show: "fade"
		hide: "fade"
		height: 240
		width: 400
		modal: true
		resizable: false
		buttons:
			Login: -> fLogin
				teamname: $("#login_teamname").val()
				password: Crypto.MD5 $("#login_password").val(),
			Cancel: -> $("#login-form").dialog "close"

	$("#login-button").button().click -> if $(this).text() is "Login" then $("#login-form").dialog "open" else fLogout()
	$("#ranking-box").click fScoreboard
	$("#ranking-box").hover (-> $(this).addClass "ui-state-hover"), -> $(this).removeClass "ui-state-hover"
	$("#ranking-box").mousedown -> $(this).addClass "ui-state-focus"
	$("#ranking-box").mouseup -> $(this).removeClass "ui-state-focus"
	$("#problems-contents div:last-child").addClass "ui-corner-bottom"
	$("#scoreboard-data tr th").addClass "ui-widget ui-widget-header"
	$("#scoreboard-data tr td").addClass "ui-widget ui-widget-content"
	
	fState()

fState = -> $.get "state", (d) ->
	if d.loggedin
		$("#ranking-box div:first-child").text d.team
		$("#ranking-box div:last-child").text if d.rank is "Unranked" then "Unranked" else "##{d.rank}"
		$("#login-button span.ui-button-text").text "Logout"
	else	
		$("#ranking-box div:first-child").html "<center>Scoreboard</center>"
		$("#login-button span.ui-button-text").text "Login"
	$("#timeleft-box div:first-child").text "Time Left"
	fTimeleft JSON.parseWithDate "\"#{d.roundends}\""
	fProblems()

fTimeleft = (roundEnds) ->
	d = new Date roundEnds - new Date()
	if d > 0
		$("#timeleft-box div:last-child").text "#{pad2 d.getHours()}:#{pad2 d.getMinutes()}:#{pad2 d.getSeconds()}"
		setTimeout (-> fTimeleft roundEnds), 1000
	else
		$("#timeleft-box div:last-child").text "00:00:00"

fLogin = (auth) -> $.get "login", auth, (d) ->
	if d.success
		$("#ranking-box div:first-child").text $("#login_teamname").val()
		$("#ranking-box div:last-child").text if d.rank is "Unranked" then "Unranked" else "##{d.rank}"
		$("#login-form").dialog "close"
		$("#login-button span.ui-button-text").text "Logout"
		fProblems()
	else
		$.jAlert "Invalid Teamname / Password!", "error"

fLogout = -> $.get "logout", (d) ->
	$("#ranking-box div:first-child").html "<center>Scoreboard</center>"
	$("#ranking-box div:last-child").text ""
	$("#login-button span.ui-button-text").text "Login"
	unless d.success
		$.jAlert "There are no active sessions.", "highlight"

fProblems = -> $.get "problems", (d) ->
	d = d.sort()
	$("#problems-contents").html ""
	$("#problems-contents").append "<div><span>#{i + 1}</span><span>#{d[i].title}</span>#{if d[i].done then "<span class='tickmark'>&#10004;</span>" else ""}" for i in [0...d.length]
	$("#problems-contents div").addClass "ui-button ui-widget ui-widget-content ui-state-normal ui-button-text-only"
	$("#problems-contents div").click -> fProblem $(this).children("span:nth-child(2)").text()
	$("#problems-contents div").hover (-> $(this).addClass "ui-state-hover"), -> $(this).removeClass "ui-state-hover"
	$("#problems-contents div").mousedown -> $(this).addClass "ui-state-focus"
	$("#problems-contents div").mouseup -> $(this).removeClass "ui-state-focus"
	$("#problems-contents").prepend "<div class='ui-widget ui-widget-content ui-corner-bottom'></div>"

fProblem = (p) -> $.get "problems/#{p}", (d) ->
	$("#problem-header span:first-child").text p
	$("#problem-header span:nth-child(2)").text "#{d.points} Point#{if d.points is 1 then "" else "s"}"
	$("#problem-container").html ""
	$("#problem-container").append "<div class='desc'>#{d.description}</div>"
	if $("#login-button").text() is "Logout"
		$("#problem-container").append "<div id='editables-accordion'></div>"
		for ed in d.editables
			$("#editables-accordion").append """
				<h3>
					<a>#{ed.file}</a>
				</h3>
				<div class='ace-tabs'>
					<div class='ace-container'></div>
					<div class='ace-container'></div>
					<div class='ace-tabbar' id='#{ed.file}_oe'>
						<input type='radio' id='#{ed.file}_o' name='#{ed.file}_oe' /><label for='#{ed.file}_o'>Original</label>
						<input type='radio' id='#{ed.file}_e' name='#{ed.file}_oe' /><label for='#{ed.file}_e'>Edited</label>
						<span class='status'></span>
					</div>
				</div>
				"""
			original = ace.edit($("#editables-accordion div.ace-tabs").last().children("div.ace-container")[0])
			original.getSession().setMode new (require("ace/mode/#{ed.language}").Mode)
			original.setShowPrintMargin false
			original.getSession().setUseWrapMode true
			original.setReadOnly true
			original.getSession().setValue ed.data_original
			$($("#editables-accordion div.ace-tabs").last().children("div.ace-container")[0]).hide()
			editor = ace.edit($("#editables-accordion div.ace-tabs").last().children("div.ace-container")[1])
			editor.getSession().setMode new (require("ace/mode/#{ed.language}").Mode)
			editor.setShowPrintMargin false
			editor.getSession().setUseWrapMode true
			editor.getSession().setValue ed.data_edited
			saveStatus = $("#editables-accordion div.ace-tabs").last().children("div.ace-tabbar").children("span.status")
			saveStatus.hide()
			editor.getSession().on 'change', ->
				clearTimeout editor.saveTimeout if editor.saveTimeout
				editor.saveTimeout = setTimeout (->
					saveStatus.show()
					saveStatus.text "Saving..."
					$.post "problems/#{p}/update",
						file: ed.file
						data: editor.getSession().getValue(),
						(d) ->
							saveStatus.text if d.success then "Saved" else "Error Saving!"
							setTimeout (-> saveStatus.fadeOut 2000), 3000 if d.success
				), 5000
			$("#editables-accordion div.ace-tabs").last().children("div.ace-tabbar").children("input")[1].checked = true
			$("#editables-accordion div.ace-tabs").last().children("div.ace-tabbar").buttonset()
			$("input[name='#{ed.file}_oe']").change -> $("#editables-accordion div.ace-tabs").last().children("div.ace-container").toggle()
		$("#editables-accordion").accordion collapsible: true
	$("#scoreboard-box").hide()
	$("#problem-box").show()
	$("#editables-accordion div.ace-tabs").height $("#problem-container").height() * 0.5 if $("#login-button").text() is "Logout"

fScoreboard = -> $.get "scoreboard", (d) ->
	d = d.sort (a, b) -> a.rank - b.rank
	$("#scoreboard-data thead tr").html ""
	$("#scoreboard-data thead tr").append "<th>#{h}</th>" for h in ["Rank", "Success Kid", "Score", "Penalty"]
	$("#scoreboard-data thead tr").append "<th>#{h}</th>" for h in [1..$("#problems-contents div span:nth-child(2)").length]	
	$("#scoreboard-data tbody").html ""
	d.forEach (t) ->
		$("#scoreboard-data tbody").append "<tr></tr>"
		t.penalty = JSON.parseWithDate "\"#{t.penalty}\""
		t.penalty = "#{pad2 t.penalty.getHours()}:#{pad2 t.penalty.getMinutes()}:#{pad2 t.penalty.getSeconds()}"
		$("#scoreboard-data tbody tr:last-child").append "<td>#{h}</td>" for h in [t.rank, t.team, t.score, t.penalty]
		$("#scoreboard-data tbody tr:last-child").append "<td#{if t.problemsdone.any((x) -> x.problem is h.textContent and x.done) then "" else " style=\"color: transparent\""}><span class='tickmark'>&#10004;</span></td>" for h in $("#problems-contents div span:nth-child(2)").select (j) -> $(j)
	$("#scoreboard-data tr th").addClass "ui-widget ui-widget-header"
	$("#scoreboard-data tr td").addClass "ui-widget ui-widget-content"
	$("#problem-box").hide()
	$("#scoreboard-box").show()