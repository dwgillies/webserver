# Fibonacci Webserver

This is my first crack at a RESTful fibonacci webserver.  The repo can build and start a docker container than starts the web server using the makefile.  To use the web server, try one of the URLs below:

* http://127.0.0.1:2468/                    # gives an error {"error":"api endpoint undefined: /"}
* http://127.0.0.1:2468/api/fibonacci       # gives an error {"error":"argument n not found"}
* http://127.0.0.1:2468/api/fibonacci?n=a   # gives an error {"error":"a is not an integer"}
* http://127.0.0.1:2468/api/fibonacci?n=10  # gives a correct answer {"fib":"34"}

## Some thoughts

* I decided to have checked-in versions of the javascript compilations of the code.  I could have kept them out of the repo with .gitignore but since stack traces include the javascript line numbers and code the repo is more searchable this way. Also sometimes preprocessors have errors and you have to edit the compiled stuff, a disadvantage of preprocessors.

* I made sure that the container would build and run without the /node_modules directory.  It is currently going into the container and then being overwritten by an install and I'm looking for ways to avoid that duplication.

* I found a tool to trim part of /node_modules but would like to know of a better way to thin it down.

* This is my first time writing a Dockerfile from scratch.
