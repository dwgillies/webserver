import * as http from 'http';
import App from './App';

const port : string  = process.env.PORT || "80";
const hello : string = "HELLO BLUESCAPE";

App.set('port', port);

//create a server and pass our Express app to it.
const server = http.createServer(App);

// keep idle connections open longer than the load balancer's 60s idle
// timeout, so Node never closes a connection the ALB is about to reuse
// (which shows up as a random 502)
server.keepAliveTimeout = 65 * 1000;
server.headersTimeout = 66 * 1000;   // must be longer than keepAliveTimeout

server.listen(port);
server.on('listening', onListening);

// as PID 1 in a container, node ignores SIGTERM unless it handles it, so
// docker stop would wait 10s and then kill it; stop accepting connections
// and exit once in-flight requests finish
function shutdown(signal: string): void {
  console.log(`${signal} received, shutting down`);
  server.close(() => process.exit(0));
}
process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

//function to note that Express is listening
function onListening(): void {
  console.log(`Listening on port `+port);
}
