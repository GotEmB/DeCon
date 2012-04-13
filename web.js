var express = require('express');
var url = require('url');
var db = require('mongojs').connect('mongodb://decon-admin:YUSoConfused?@ds031867.mongolab.com:31867/decon', ['Teams']);
var md5 = require('MD5');

//db.Teams.save({teamname: "Code Kangaroos", password: md5("Camelroos" + "hb7gyfw")});

var server = express.createServer(
	express.logger(),
	express.cookieParser(),
	express.session({key: "auth.sid", secret: 'badampam-pshh!h34uhif3' }),
	express.bodyParser(),
	express.static(__dirname + '/public')
);

//Authentication
server.get('/*', function (req, res, next) {
	var lurl = url.parse(req.url, true);
	if (lurl.pathname == "/logout")
	{
		req.session.destroy();
		res.send("You will be remembered.");
	}
	else if (req.session && req.session.auth == true)
		next();
	else if (lurl.pathname == "/login") {
		db.Teams.find({teamname: decodeURIComponent(req.query.teamname), password: decodeURIComponent(req.query.password)}).count(function (err, value) {
			if (value == 1)
			{
				req.session.auth = true;
				res.send("A new beginning.");
			}
			else
				res.send("You think you can trick me?<br>403! Joor-Zah-Frul !!!");
		});
	}
	else
		res.send("Who d'ya think you are?<br>403! Joor-Zah-Frul !!!");
});

//404
server.get('/*', function (req, res) {
	res.send('You hack me?<br>404! Fus-Ro-Dah !!!');
});

var port = process.env.PORT || 3000;
server.listen(port, function() {
	console.log("Listening on port " + port);
});