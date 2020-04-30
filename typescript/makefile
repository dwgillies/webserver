USER=systembuilder22
IMAGE=nicetry

all:	install js build

install:
	npm install -g typescript
	npm install --no-optional nodemon
	npm install -g express

js:
	tsc main.ts
	tsc app.ts

build:
	docker build -t ${USER}/${IMAGE} .

run:
	docker run -p 2468:80 ${USER}/${IMAGE}:latest
