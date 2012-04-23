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
			Login: ->
				$.get "login",
					teamname: $("#login_teamname").val()
					password: Crypto.MD5 $("#login_password").val(),
					(x) ->
						d = JSON.parse x
						if d.success
							$("#ranking-box div:first-child").text $("#login_teamname").val()
							$("#ranking-box div:last-child").text "\##{d.rank}"
							$("#login-form").dialog "close"
						else
							$.jAlert "Invalid Teamname / Password!", "error"
			Cancel: ->
				$("#login-form").dialog "close"

	$("#login-button").button().click -> $("#login-form").dialog "open"
	
	$("#ranking-box").hover (-> $(this).addClass "ui-state-hover"), -> $(this).removeClass "ui-state-hover"
	$("#ranking-box").mousedown -> $(this).addClass "ui-state-focus"
	$("#ranking-box").mouseup -> $(this).removeClass "ui-state-focus"
	
	$("#problems-contents div").hover (-> $(this).addClass "ui-state-hover"), -> $(this).removeClass "ui-state-hover"
	$("#problems-contents div").mousedown -> $(this).addClass "ui-state-focus"
	$("#problems-contents div").mouseup -> $(this).removeClass "ui-state-focus"
	$("#problems-contents div:last-child").addClass "ui-corner-bottom"
	$("#scoreboard-data tr th").addClass "ui-widget ui-widget-header"
	$("#scoreboard-data tr td").addClass "ui-widget ui-widget-content"
	
	$("#problem-box").toggle()