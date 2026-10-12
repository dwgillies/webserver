DOCKER_USER=systembuilder22
IMAGE=nicetry

.PHONY: all install clean js build run cleanup nuke push pull

all:	install js build

# everything (express, typescript, @types/*) comes from package.json into
# ./node_modules; no -g and no sudo
install:
	npm install

clean:
	rm -rf node_modules package-lock.json

js:	main.js App.js

# tsc reads tsconfig.json; with file names on the command line it would ignore
# it. npx runs the project's pinned typescript, not the global one.
main.js App.js &: main.ts App.ts tsconfig.json
	npx tsc -p .

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
