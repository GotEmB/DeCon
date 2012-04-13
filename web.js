var express = require('express');
var server = express.createServer(
	express.logger(),
	express.static(__dirname + '/public')
);

server.get('/*', function (req, res) {
	res.send('You hack me?<br>Fus-Ro-Dah!');
});

var port = process.env.PORT || 3000;
server.listen(port, function() {
	console.log("Listening on port " + port);
});