USER=systembuilder22
IMAGE=nicetry

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
	docker build -t ${USER}/${IMAGE} .

run:
	docker run -p 2468:80 ${USER}/${IMAGE}:latest
