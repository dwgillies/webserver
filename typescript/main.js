"use strict";
exports.__esModule = true;
var http = require("http");
var App_1 = require("./App");
var port = process.env.PORT || "80";
var hello = "HELLO BLUESCAPE";
App_1["default"].set('port', port);
//create a server and pass our Express app to it.
var server = http.createServer(App_1["default"]);
server.listen(port);
server.on('listening', onListening);
//function to note that Express is listening
function onListening() {
    console.log("Listening on port " + port);
}
