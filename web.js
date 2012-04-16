var express = require('express');
var url = require('url');
var db = require('mongojs').connect(process.env.MONGOLAB_URI, ['Teams', 'FileDump']);
var md5 = require('MD5');
var fs = require('fs');
var md = require('node-markdown').Markdown;
var Sync = require('sync');

//Global Vars
var problems;

//FluentQueryJS
Object.prototype.toDictionary = function () {
	var ret = [];
	for (var key in this)
		if (key != "__proto__" && key != "toDictionary")
			ret.push({key: key, value: this[key]});
	return ret;
}

Array.prototype.select = function (fun) {
	var ret = [];
	this.forEach(function (item) {
		ret.push(fun(item));
	});
	return ret;
}

Array.prototype.where = function (fun) {
	var ret = [];
	this.forEach(function (item) {
		if (fun(item) == true)
			ret.push(item);
	});
	return ret;
}

Array.prototype.first = function (fun) {
	if (!fun)
		return this[0];
	var ret = this.where(fun);
	if (ret.length != 0)
		return ret[0];
	else
		return null;
}

Array.prototype.contains = function (item) {
	return this.where(function (x) {return x == item;}) > 0;
}

//JSON.parseWithDate
JSON.parseWithDate = function(json) {
	var reISO = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/;
	var reMsAjax = /^\/Date\((d|-|.*)\)\/$/;
	return JSON.parse(json, function(key, value) {
		if (typeof value === 'string') {
			var a = reISO.exec(value);
			if (a)
				return new Date(Date.UTC(+a[1], +a[2] - 1, +a[3], +a[4], +a[5], +a[6]));
			a = reMsAjax.exec(value);
			if (a) {
				var b = a[1].split(/[-,.]/);
				return new Date(+b[0]);
			}
		}
		return value;
	});
};

//db.Teams.save({teamname: "Code Kangaroos", password: md5("Camelroos" + "hb7gyfw")});

var server = express.createServer(
	express.logger(),
	express.cookieParser(),
	express.session({key: "auth.sid", secret: 'badampam-pshh!h34uhif3'}),
	express.bodyParser(),
	express.static(__dirname + '/public')
);

//New Request -> New Fiber
server.get('/*', function(req, res, next) {
	Sync(function () {
		next();
	})
});

//Problem List (Guest)
server.get('/problems', function (req, res, next) {
	req.ret = [];
	for (var key in problems)
		if (key != '__proto__')
			req.ret.push({title: key});
	next();
});

//Problem Statement (Guest)
server.get('/problems/:p', function (req, res, next) {
	req.ret = {};
	var p = problems[req.params.p];
	req.ret.description = md(fs.readFileSync('problems/' + p.folder + '/description.md', 'utf8'));
	req.ret.points = p.points;
	next();
});

//Authentication
server.get('/*', function (req, res, next) {
	var lurl = url.parse(req.url, true);
	if (lurl.pathname == "/logout")
	{
		req.session.destroy();
		res.send("You will be remembered.");
	}
	else if (lurl.pathname == "/login") {
		var value = (this.t1 = db.Teams.find({teamname: decodeURIComponent(req.query.teamname), password: decodeURIComponent(req.query.password)})).count.sync(this.t1);
		if (value == 1)
		{
			req.session.auth = true;
			req.session.teamname = decodeURIComponent(req.query.teamname);
			setUpFileDump(decodeURIComponent(req.query.teamname));
			res.send("A new beginning.");
		}
		else
			res.send("You trick me bro?<br>403! Joor-Zah-Frul !!!");
	}
	else if (req.session && req.session.auth == true)
		next();
	else if (req.ret)
		res.send(JSON.stringify(req.ret));
	else
		res.send("Who d'ya think you are?<br>403! Joor-Zah-Frul !!!");
});

function setUpFileDump(teamname) {
	for (var problemTitle in problems)
		if (problemTitle != '__proto__' && problemTitle != 'toDictionary')
			problems[problemTitle].editable.forEach(function (fileName) {
				if ((this.t1 = db.FileDump.find({team: teamname, problem: problemTitle, file: fileName})).count.sync(this.t1) == 0)
					(this.t2 = db.FileDump).save.sync(this.t2, {team: teamname, problem: problemTitle, file: fileName, data: fs.readFileSync('problems/' + problems[problemTitle].folder + '/editable/' + fileName, 'utf8')});
			});
}

//Problem List (User)
server.get('/problems', function (req, res, next) {
	var teaminfo = (this.t1 = db.Teams).find.sync(this.t1, {teamname: req.session.teamname}).first();
	req.ret.forEach(function (x) {x.done = teaminfo.problemsdone.contains(x.title);});
	res.send(JSON.stringify(req.ret));
});

//Problem Statement (User)
server.get('/problems/:p', function (req, res, next) {
	function stdiop(file) {
		if (file == 'stdout')
			return "Standard Output";
		else if (file == "stdin")
			return "Standard Input";
	}
	var editables = (this.t1 = db.FileDump).find.sync(this.t1, {team: req.session.teamname, problem: req.params.p});
	req.ret.editables = [];
	editables.forEach(function (x) {
		req.ret.editables.push({
			file: stdiop(x.file),
			data: x.data,
			language: problems[req.params.p].files[x.file]
		});
	});
	req.ret.stock = [];
	fs.readdir.sync(null, 'problems/' + problems[req.params.p].folder + '/test/before').forEach(function (x) {
		req.ret.stock.push({
			file: stdiop(x),
			data: fs.readFile.sync(null, 'problems/' + problems[req.params.p].folder + '/test/before/' + x, 'utf8'),
			language: problems[req.params.p].files[x]
		});
	});
	res.send(JSON.stringify(req.ret));
});

//404
server.get('/*', function (req, res) {
	res.send('You hack me bro?<br>404! Fus-Ro-Dah !!!');
});

//Start the server...
Sync(function () {
	problems = JSON.parseWithDate(fs.readFile.sync(null, 'problems/index.json', 'utf8')).first(function (x) {return x.start <= new Date() && x.end >= new Date();}).problems;
	//ToDo: Start timer to end of round here.
	
	var port = process.env.PORT || 5000;
	server.listen(port, function() {
		console.log("Listening on port " + port);
	});
})