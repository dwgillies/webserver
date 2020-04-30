var http = require('http');
var url = require('url');
var util = require('util');

// fibonacci(n) returns the n'th fibonacci number.
// It doesn't handle negative fibonacci's; just avoids infinite loops.
const fibonacci = (n) => {
    if (n <= 1) {
        return (0);
    }
    else if (n == 2) {
        return (1);
    }
    else {
        return (fibonacci(n - 1) + fibonacci(n - 2));
    }
}
;
// requestHandler is the main webserver request-reply function.
var requestHandler = function (req, res) {
    if (req.url.startsWith("/api/fibonacci")) {
        var arg_map = url.parse(req.url, true).query;
        var json;
        var statusCode;
        if ('n' in arg_map) {
            if (arg_map.n === parseInt(arg_map.n, 10).toString(10)) {
                statusCode = 200;
                json = JSON.stringify({
                    'fib': fibonacci(arg_map.n)
                });
            }
            else {
                statusCode = 400; // bad request
                json = JSON.stringify({
                    'error': util.format('%s is not an integer', arg_map.n)
                });
            }
        }
        else {
            statusCode = 400; // bad request
            json = JSON.stringify({
                'error': 'argument n not found'
            });
        }
        res.writeHead(statusCode, { "Content-Type": "application/json" });
        res.end(json);
        console.log('GET', req.url, '->', json);
    }
    else if (req.url.startsWith("/favicon.ico")) {
        res.statusCode = 200;
        res.setHeader('Content-Type', 'text/plain');
        res.end('');
        console.log('GET', req.url, '->', '');
    }
    else {
        res.statusCode = 200;
        res.setHeader('Content-Type', 'text/plain');
        res.end('Hello World');
        console.log('GET', req.url, '->', 'Hello World');
    }
};

// begin main
if (process.argv.length < 4) {
    console.log("TooFewArgs(need 4): ".concat(process.argv.join(' ')));
    throw "ArgumentError";
}
hostname = process.argv[2];
port = process.argv[3];

var server = http.createServer(requestHandler);
server.listen(port, hostname, function () {
    console.log("Server running at http://" + hostname + ":" + port + "/");
});
