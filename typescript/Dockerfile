# this Dockerfile acknowledges:
#   https://github.com/zachdeibert/docker-images/blob/master/software/typescript/Dockerfile
#   https://github.com/prakhar1989/docker-curriculum/blob/master/flask-app/Dockerfile

FROM node:12.16

MAINTAINER Don Gillies <dwgillies@gmail.com>

COPY . /srv/webserver/typescript
WORKDIR /srv/webserver/typescript

RUN npm install -g typescript

# not sure how to set up the searchpath for nodemon
# so install inlocal directory.
RUN npm install --no-optional --save-dev nodemon
RUN npm install -g express --save

EXPOSE 80

CMD ["node", "./main.js"]

# start container
# docker run -p 2468:80 systembuilder22/nicetry:latest
