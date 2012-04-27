childProcess = require("child_process").spawn
fs = require("fs.extra")
md5 = require("MD5")
Sync = require("sync")
require("coffee-script")
require("./fluent")
path = require("path")
emoticon = require("./emoticon")

# Dot The Dot
dtd = (str) -> str.replace ".", "[dot]"
tdt = (str) -> str.replace "[dot]", "."

# server.get "/problems/:p/run/:dcase"
exports.run = (req, res, next, problems, db) ->
	p = req.params.p
	dcase = req.params.dcase
	folder = "sandbox/" + md5 req.session.teamname + req.params.p + req.params.dcase + (new Date()).getTime()
	fs.mkdir.sync null, folder, "0777"
	problemFolder = (@t1 = db.Problems).findOne.sync(@t1, problem: req.params.p)
	fs.writeFile.sync null, "#{folder}/#{tdt x.key}", x.value for x in problemFolder[req.params.dcase].before.toDictionary()
	((@t1 = db.FileDump).find.sync @t1,
		team: req.session.teamname
		problem: req.params.p
	).forEach (x) -> fs.writeFile.sync null, "#{folder}/#{x.file}", x.data
	cop = ""
	fs.writeFile.sync null, "#{folder}/stdout", ""
	for job in problems[req.params.p].jobs.toDictionary()
		cop += "Compiling #{tdt job.key}\n"
		switch job.value
			when "gcc" then cip = fGcc.sync null, tdt(job.key), folder
			when "g++" then cip = fGpp.sync null, tdt(job.key), folder
			when "obj-c" then cip = fObjC.sync null, tdt(job.key), folder
			when "cs" then cip = fNcs.sync null, tdt(job.key), folder
			when "vb" then cip = fNvb.sync null, tdt(job.key), folder
			when "fs" then cip = fNfs.sync null, tdt(job.key), folder
			when "java" then cip = fJava.sync null, tdt(job.key), folder
			when "php" then cip = fPhp.sync null, tdt(job.key), folder
			when "python" then cip = fPy.sync null, tdt(job.key), folder
			when "emoticon" then cip = fEmo.sync null, tdt(job.key), folder
		cop += cip.debug
	ck = (x.value is fs.readFile.sync null, "#{folder}/#{tdt x.key}", "utf8" for x in problemFolder[dcase].after.toDictionary()).all((x) -> x is true)
	req.ret = 
		success: ck
		output: cop
		folder: folder
		problemFolder: problemFolder
	return

fGcc = (file, folder, callback) ->	
	cop = ""
	c1 = childProcess "gcc", [file], cwd: folder
	c1.stdout.on "data", (d) -> cop += "Compiler Out: " + d
	c1.stderr.on "data", (d) -> cop += "Compiler Err: " + d
	c1.on "exit", ->
		c2 = childProcess "./a.out", [], cwd: folder
		c2.stdin.end fs.readFile.sync null, "#{folder}/stdin", "utf8" if (path.existsSync "#{folder}/stdin")
		c2.stdout.on "data", (d) -> fs.createWriteStream("#{folder}/stdout", flags: 'a').end d
		c2.stderr.on "data", (d) ->  cop += "Runtime Err: " + d
		c2.on "exit", ->
			callback null,
				success: cop is ""
				debug: cop

fGpp = (file, folder, callback) ->	
	cop = ""
	c1 = childProcess "g++", [file], cwd: folder
	c1.stdout.on "data", (d) -> cop += "Compiler Out: " + d
	c1.stderr.on "data", (d) -> cop += "Compiler Err: " + d
	c1.on "exit", ->
		c2 = childProcess "./a.out", [], cwd: folder
		c2.stdin.end fs.readFile.sync null, "#{folder}/stdin", "utf8" if (path.existsSync "#{folder}/stdin")
		c2.stdout.on "data", (d) -> fs.createWriteStream("#{folder}/stdout", flags: 'a').end d
		c2.stderr.on "data", (d) ->  cop += "Runtime Err: " + d
		c2.on "exit", ->
			callback null,
				success: cop is ""
				debug: cop

fObjC = (file, folder, callback) ->	
	cop = ""
	c1 = childProcess "g++", ["-framework", "foundation", file], cwd: folder
	c1.stdout.on "data", (d) -> cop += "Compiler Out: " + d
	c1.stderr.on "data", (d) -> cop += "Compiler Err: " + d
	c1.on "exit", ->
		c2 = childProcess "./a.out", [], cwd: folder
		c2.stdin.end fs.readFile.sync null, "#{folder}/stdin", "utf8" if (path.existsSync "#{folder}/stdin")
		c2.stdout.on "data", (d) -> fs.createWriteStream("#{folder}/stdout", flags: 'a').end d
		c2.stderr.on "data", (d) ->  cop += "Runtime Err: " + d
		c2.on "exit", ->
			callback null,
				success: cop is ""
				debug: cop

fNcs = (file, folder, callback) ->	
	cop = ""
	c1 = childProcess "mcs", [file], cwd: folder
	c1.stdout.on "data", (d) -> cop += "Compiler Out: " + d
	c1.stderr.on "data", (d) -> cop += "Compiler Err: " + d
	c1.on "exit", ->
		c2 = childProcess "mono", ["*.exe"], cwd: folder
		c2.stdin.end fs.readFile.sync null, "#{folder}/stdin", "utf8" if (path.existsSync "#{folder}/stdin")
		c2.stdout.on "data", (d) -> fs.createWriteStream("#{folder}/stdout", flags: 'a').end d
		c2.stderr.on "data", (d) ->  cop += "Runtime Err: " + d
		c2.on "exit", ->
			callback null,
				success: cop is ""
				debug: cop

fNvb = (file, folder, callback) ->	
	cop = ""
	c1 = childProcess "vbnc", [file], cwd: folder
	c1.stdout.on "data", (d) -> cop += "Compiler Out: " + d
	c1.stderr.on "data", (d) -> cop += "Compiler Err: " + d
	c1.on "exit", ->
		c2 = childProcess "mono", ["*.exe"], cwd: folder
		c2.stdin.end fs.readFile.sync null, "#{folder}/stdin", "utf8" if (path.existsSync "#{folder}/stdin")
		c2.stdout.on "data", (d) -> fs.createWriteStream("#{folder}/stdout", flags: 'a').end d
		c2.stderr.on "data", (d) ->  cop += "Runtime Err: " + d
		c2.on "exit", ->
			callback null,
				success: cop is ""
				debug: cop

fNfs = (file, folder, callback) ->	
	cop = ""
	c1 = childProcess "fsc", [file], cwd: folder
	c1.stdout.on "data", (d) -> cop += "Compiler Out: " + d
	c1.stderr.on "data", (d) -> cop += "Compiler Err: " + d
	c1.on "exit", ->
		c2 = childProcess "mono", ["*.exe"], cwd: folder
		c2.stdin.end fs.readFile.sync null, "#{folder}/stdin", "utf8" if (path.existsSync "#{folder}/stdin")
		c2.stdout.on "data", (d) -> fs.createWriteStream("#{folder}/stdout", flags: 'a').end d
		c2.stderr.on "data", (d) ->  cop += "Runtime Err: " + d
		c2.on "exit", ->
			callback null,
				success: cop is ""
				debug: cop

fJava = (file, folder, callback) ->	
	cop = ""
	c1 = childProcess "java", [file], cwd: folder
	c1.stdout.on "data", (d) -> cop += "Compiler Out: " + d
	c1.stderr.on "data", (d) -> cop += "Compiler Err: " + d
	c1.on "exit", ->
		c2 = childProcess "./a.out", [], cwd: folder
		c2.stdin.end fs.readFile.sync null, "#{folder}/stdin", "utf8" if (path.existsSync "#{folder}/stdin")
		c2.stdout.on "data", (d) -> fs.createWriteStream("#{folder}/stdout", flags: 'a').end d
		c2.stderr.on "data", (d) ->  cop += "Runtime Err: " + d
		c2.on "exit", ->
			callback null,
				success: cop is ""
				debug: cop

fPhp = (file, folder, callback) ->	
	cop = ""
	c1 = childProcess "php", [file], cwd: folder
	c1.stdin.end fs.readFile.sync null, "#{folder}/stdin", "utf8" if (path.existsSync "#{folder}/stdin")
	c1.stdout.on "data", (d) -> fs.createWriteStream("#{folder}/stdout", flags: 'a').end d
	c1.stderr.on "data", (d) -> cop += "Runtime Err: " + d
	c1.on "exit", ->
		callback null,
			success: cop is ""
			debug: cop

fPy = (file, folder, callback) ->	
	cop = ""
	c1 = childProcess "python", [file], cwd: folder
	c1.stdin.end fs.readFile.sync null, "#{folder}/stdin", "utf8" if (path.existsSync "#{folder}/stdin")
	c1.stdout.on "data", (d) -> fs.createWriteStream("#{folder}/stdout", flags: 'a').end d
	c1.stderr.on "data", (d) -> cop += "Runtime Err: " + d
	c1.on "exit", ->
		callback null,
			success: cop is ""
			debug: cop

fEmo = (file, folder, callback) ->
	cop = ""
	code = new Emoticon.Parser fs.readFile.sync null, "#{folder}/#{file}", "utf8"
	config =
	  input: (cb) -> cb fs.readFile.Sync null, "#{folder}/stdin", "utf8" if (path.existsSync "#{folder}/stdin")
	  print: (d) -> fs.createWriteStream("#{folder}/stdout", flags: 'a').end d
	  result: (d) -> cop += "Result: " + d
	  logger: (d) -> cop += "Log: " + d
	  source: code
	interpreter = new Emoticon.Interpreter config
	interpreter.run()
	setTimeout (->
		callback null,
			success: cop is ""
			debug: cop
	), 2000
	