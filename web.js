var express = require('express');
var url = require('url');
var db = require('mongojs').connect(process.env.MONGOLAB_URI, ['Teams', 'FileDump']);
var md5 = require('MD5');
var fs = require('fs');
var md = require('node-markdown').Markdown;
var Sync = require('sync');

var problems;

//db.Teams.save({teamname: "Code Kangaroos", password: md5("Camelroos" + "hb7gyfw")});

var server = express.createServer(
	express.logger(),
	express.cookieParser(),
	express.session({key: "auth.sid", secret: 'badampam-pshh!h34uhif3'}),
	express.bodyParser(),
	express.static(__dirname + '/public')
);

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
	Sync(function () {
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
				res.send("You think you can trick me?<br>403! Joor-Zah-Frul !!!");
		}
		else if (req.session && req.session.auth == true)
			next();
		else if (req.ret)
			res.send(JSON.stringify(req.ret));
		else
			res.send("Who d'ya think you are?<br>403! Joor-Zah-Frul !!!");
	})
});

function setUpFileDump(teamname) {
	for (var problemTitle in problems)
		if (problemTitle != '__proto__')
			problems[problemTitle].editable.forEach(function (fileName) {
				if ((this.t1 = db.FileDump.find({team: teamname, problem: problemTitle, file: fileName})).count.sync(this.t1) == 0)
					(this.t2 = db.FileDump).save.sync(this.t2, {team: teamname, problem: problemTitle, file: fileName, data: fs.readFileSync('problems/' + problems[problemTitle].folder + '/editable/' + fileName, 'utf8')});
			});
}

//Problem List (User)
server.get('/problems', function (req, res, next) {
	res.send(JSON.stringify(req.ret));
});

//Problem Statement (User)
server.get('/problems/:p', function (req, res, next) {
	res.send(JSON.stringify(req.ret));
});

//404
server.get('/*', function (req, res) {
	res.send('You hack me?<br>404! Fus-Ro-Dah !!!');
});

//Start...
Sync(function () {
	problems = JSON.parse(fs.readFile.sync(null, 'problems/index.json', 'utf8'));
	
	var port = process.env.PORT || 5000;
	server.listen(port, function() {
		console.log("Listening on port " + port);
	});
})