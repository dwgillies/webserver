"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
// Creates and configures an ExpressJS web server.
class App {
    // ref to Express instance
    express;
    //Run configuration methods on the Express instance.
    constructor() {
        this.express = (0, express_1.default)();
        this.routes();
    }
    // fibonacci(n) returns the n'th fibonacci number.
    // It doesn't handle negative fibonacci's; it returns zero to avoid infinite loops.
    static fibonacci(n) {
        if (n <= 1) {
            return (0);
        }
        else if (n == 2) {
            return (1);
        }
        else {
            return (this.fibonacci(n - 1) + this.fibonacci(n - 2));
        }
    }
    // Process a request for a fibonacci number
    static handleFibonacci(req, res) {
        let arg_map = req.query;
        let json;
        let statusCode;
        if ('n' in arg_map) {
            const n = arg_map.n;
            if (typeof n !== 'string') {
                // ?n=1&n=2 parses to an array and ?n[x]=1 to an object
                statusCode = 400; // bad request
                json = JSON.stringify({ 'error': 'n must be a single integer' });
            }
            else if (/^-?[0-9]+$/.test(n)) { // leading zeros are fine: 007 is 7
                statusCode = 200;
                json = JSON.stringify({ 'fib': App.fibonacci(Number(n)).toString() });
            }
            else {
                statusCode = 400; // bad request
                json = JSON.stringify({ 'error': n + ' is not an integer' });
            }
        }
        else {
            statusCode = 400; // bad request
            json = JSON.stringify({ 'error': 'argument n not found' });
        }
        res.writeHead(statusCode, { "Content-Type": "application/json" });
        res.end(json);
        console.log('GET', req.url, '->', json);
    }
    // Load balancer health check; not logged, since it is polled every few seconds
    static handleHealth(req, res) {
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ 'status': 'ok' }));
    }
    // Process undefined api calls
    static handleDefault(req, res) {
        res.statusCode = 404;
        res.setHeader('Content-Type', 'text/plain');
        res.end(JSON.stringify({ 'error': 'api endpoint undefined: ' + req.url }));
        console.log('GET', req.url, '->', 'undefined');
    }
    // Configure API endpoints.
    routes() {
        let router = express_1.default.Router();
        router.get('/api/fibonacci', App.handleFibonacci);
        router.get('/health', App.handleHealth);
        router.get('/', App.handleDefault);
        this.express.use('/', router);
    }
}
exports.default = new App().express;
