DOCKER_USER=systembuilder22
IMAGE=nicetry

.PHONY: all install clean js build run cleanup nuke push pull

all:	install js build

install:
	npm install -g typescript
	npm install --no-optional nodemon
	npm install -g express

clean:
	npm uninstall -g typescript
	npm uninstall --no-optional nodemon
	npm uninstall -g express
	rm package-lock.json

js:	main.js App.js

main.js: main.ts
	tsc main.ts
App.js: app.ts
	tsc app.ts

build:
	docker build -t ${DOCKER_USER}/${IMAGE} .

run:
	docker run -p 2468:80 ${DOCKER_USER}/${IMAGE}:latest

# xargs -r skips docker rm when there is nothing to remove
cleanup:
	docker ps -a -q -f status=exited | xargs -r docker rm

# force-remove every container, running or stopped
nuke:
	docker ps -a -q | xargs -r docker rm -f

push:
	docker push ${DOCKER_USER}/${IMAGE}

pull:
	docker pull ${DOCKER_USER}/${IMAGE}
