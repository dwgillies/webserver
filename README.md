# Fibonacci Webserver

This is my first crack at a RESTful fibonacci webserver.  The repo can build and start a docker container than starts the web server using the makefile.  To use the web server, try one of the URLs below:

* http://127.0.0.1:2468/                    # should give an error {"error":"api endpoint undefined: /"}
* http://127.0.0.1:2468/api/fibonacci       # gives an error {"error":"argument n not found"}
* http://127.0.0.1:2468/api/fibonacci?n=a   # gives an error {"error":"a is not an integer"}
* http://127.0.0.1:2468/api/fibonacci?n=10  # gives a correct answer {"fib":"34"}
