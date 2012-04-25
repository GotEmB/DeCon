# Load Modules
express = require("express")
url = require("url")
db = require("mongojs").connect(process.env.MONGOLAB_URI, [ "Teams", "FileDump" ])
md5 = require("MD5")
fs = require("fs.extra")
md = require("github-flavored-markdown")
Sync = require("sync")
expressCoffee = require("express-coffee")
cron = require("cron")
http = require("http")
cluster = require("cluster")
request = require("request")
mongoStore = require("connect-mongo")(express);

# Global Vars
problems = undefined
roundStart = undefined
roundEnd = undefined
port = undefined
server = undefined
useCluster = false

# Fluent Stuff
Object::toDictionary = ->
	ret = []
	for key of this
		if key isnt "__proto__" and key isnt "toDictionary"
			ret.push
				key: key
				value: this[key]
	ret

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

# Setup workers
if cluster.isMaster and useCluster
	console.log "Worker started with pid #{cluster.fork().pid}" for [1..4]
	cluster.on "death", (x) ->
		console.log "Worker #{x.pid} died"
	return

# Root Fiber
Sync ->
	# Create and Setup Server
	server = express.createServer(
		express.cookieParser(),
		express.session
			key: "auth.sid"
			secret: "badampam-pshh!h34uhif3"
			store: ((c) -> st = new mongoStore process.env.MONGOLAB_URI, -> c null, st).sync null
		express.bodyParser())

	# Entry Point
	server.use (req, res, next) ->
		console.log "Worker #{process.env.NODE_WORKER_ID}: Request URL: #{req.url}"
		req.url = "/index.html" if req.url is "/"
		next()

	# Static Server priority
	server.use expressCoffee path: "#{__dirname}/public"
	server.use express.static "#{__dirname}/public", (err) -> console.log "Static: #{err}"
	server.use server.router

	# New Request -> New Fiber
	server.get "/*", (req, res, next) -> Sync -> next()

	# Get State
	server.get "/state", (req, res, next) ->
		if req.session.auth
			score = JSON.parseWithDate(request.sync(null, "#{process.env.HOST}/scoreboard")[1]).first((x) -> x.team is req.session.teamname)
			res.send
				loggedin: true
				team: req.session.teamname
				rank: if score then score.rank else "Unranked"
				roundends: roundEnd
		else
			res.send
				loggedin: false
				roundends: roundEnd

	# Problems (Guest)
	server.get "/problems", (req, res, next) ->
		req.ret = problems.toDictionary().select (x) -> title: x.key
		next()

	# Problem Statement (Guest)
	server.get "/problems/:p", (req, res, next) ->
		req.ret = {}
		p = problems[req.params.p]
		req.ret.description = md.parse fs.readFileSync "problems/#{p.folder}/description.md", "utf8"
		req.ret.points = p.points
		next()

	# Scoreboard
	server.get "/scoreboard", (req, res, next) ->
		tret = (@t1 = db.Teams).find.sync(t1).select (x) ->
			team: x.teamname
			problemsdone: problems.toDictionary().select (y) ->
				problem: y.key
				done: x.problemsdone.toDictionary().any (z) -> z.key is y.key
			score: x.problemsdone.toDictionary().select((y) -> problems[y.key].points).sum()
			penalty: new Date x.problemsdone.toDictionary().select((y) -> (y.value.getTime() - roundStart.getTime()) * (1.0 / problems[y.key].points)).sum()
		req.ret = tret.where((x) -> x.score isnt 0).groupBy((x) -> x.score).orderByDesc((x) -> x.key).selectMany((x) -> x.values.orderBy((y) -> y.penalty))
		team.rank = i + 1 for team, i in req.ret
		res.send req.ret

	# Authentication
	server.get "/*", (req, res, next) ->
		setUpFileDump = (teamname) ->
			for problemTitle of problems
				if problemTitle isnt "__proto__" and problemTitle isnt "toDictionary"
					problems[problemTitle].editable.forEach (fileName) ->
						if (@t1 = db.FileDump.find(
							team: teamname
							problem: problemTitle
							file: fileName
						)).count.sync(@t1) is 0
							(@t2 = db.FileDump).save.sync @t2,
								team: teamname
								problem: problemTitle
								file: fileName
								data: fs.readFileSync "problems/#{problems[problemTitle].folder}/editable/#{fileName}", "utf8"
		lurl = url.parse(req.url, true)
		if lurl.pathname is "/logout"
			if req.session.auth
				req.session.destroy()
				res.send JSON.stringify
					success: true
					message: "You will be remembered."
			else
				res.send JSON.stringify
					success: false
					message: "Who ARE you?"
		else if lurl.pathname is "/login"
			value = (@t1 = db.Teams.find
				teamname: req.query.teamname
				password: req.query.password
			).count.sync @t1
			if value is 1
				req.session.auth = true
				req.session.teamname = req.query.teamname
				setUpFileDump req.query.teamname
				score = JSON.parseWithDate(request.sync(null, "#{process.env.HOST}/scoreboard")[1]).first((x) -> x.team is req.session.teamname)
				req.ret =
					success: true
					rank: if score then score.rank else "Unranked"
				res.send req.ret
			else
				res.send success: false
		else if req.session and req.session.auth is true
			next()
		else if req.ret
			res.send req.ret
		else
			res.send "Who d'ya think you are?<br>403! Joor-Zah-Frul !!!"

	# Problems (User)
	server.get "/problems", (req, res, next) ->
		teaminfo = (@t1 = db.Teams).find.sync(@t1, teamname: req.session.teamname).first()
		req.ret.forEach (x) ->
			x.done = teaminfo.problemsdone.toDictionary().any (y) -> y.key is x.title
		res.send req.ret

	# Problem Statement (User)
	server.get "/problems/:p", (req, res, next) ->
		stdiop = (file) ->
			if file is "stdout"
				"Standard Output"
			else "Standard Input" if file is "stdin"
		editables = (@t1 = db.FileDump).find.sync @t1,
			team: req.session.teamname
			problem: req.params.p
		req.ret.editables = []
		editables.forEach (x) ->
			req.ret.editables.push
				file: stdiop x.file
				data: x.data
				language: problems[req.params.p].files[x.file]
		if problems[req.params.p].sample
			req.ret.sample = []
			fs.readdir.sync(null, "problems/#{problems[req.params.p].folder}/sample/before").forEach (x) ->
				req.ret.sample.push
					file: stdiop x
					data_before: fs.readFile.sync null, "problems/#{problems[req.params.p].folder}/sample/before/#{x}", "utf8"
					language: problems[req.params.p].files[x]
			fs.readdir.sync(null, "problems/#{problems[req.params.p].folder}/sample/after").forEach (x) ->
				if req.ret.sample.any((y) -> y.file) is x
					req.ret.sample.first((y) -> y.file is x).data_after = fs.readFile.sync null, "problems/#{problems[req.params.p].folder}/sample/after/#{x}", "utf8"
				else
					req.ret.sample.push
						file: stdiop x
						data_after: fs.readFile.sync null, "problems/#{problems[req.params.p].folder}/sample/after/#{x}", "utf8"
						language: problems[req.params.p].files[x]
		res.send req.ret

	# Run
	server.get "/problems/:p/run/:dcase", (req, res, next) ->
		folder = "sandbox/" + md5 req.session.teamname + req.params.p + req.params.dcase + (new Date()).getTime()
		fs.mkdir.sync null, folder, "0777"
		fs.readdir.sync(null, "problems/#{problems[req.params.p].folder}/#{req.params.dcase}/before").forEach (x) ->
			fs.copy.sync null, "problems/#{problems[req.params.p].folder}/#{req.params.dcase}/before/#{x}", "#{folder}/#{x}"
		((@t1 = db.FileDump).find.sync @t1,
			team: req.session.teamname
			problem: req.params.p
		).forEach (x) -> fs.writeFile.sync null, "#{folder}/#{x.file}", x.data
		res.send "Sandbox @ #{folder}"

	# 404
	server.get "/*", (req, res) -> res.send "You hack me bro?<br>404! Fus-Ro-Dah !!!"

	# Start Server...
	newRound = ->
		pindex = JSON.parseWithDate(fs.readFile.sync(null, "problems/index.json", "utf8")).first((x) -> x.start <= new Date() and x.end >= new Date())
		problems = pindex.problems
		roundStart = pindex.start
		roundEnd = pindex.end
		nextRound = new cron.CronJob roundEnd, newRound
		nextRound.start()
	newRound()
	port = process.env.PORT or 5000
	server.listen port, -> console.log "Worker #{process.env.NODE_WORKER_ID}: Listening on port #{port}"