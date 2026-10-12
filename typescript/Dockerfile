# this Dockerfile acknowledges:
#   https://github.com/zachdeibert/docker-images/blob/master/software/typescript/Dockerfile
#   https://github.com/prakhar1989/docker-curriculum/blob/master/flask-app/Dockerfile

FROM node:22-slim

LABEL maintainer="Don Gillies <dwgillies@gmail.com>"

WORKDIR /srv/webserver/typescript

# Express hides stack traces from clients only in production mode
ENV NODE_ENV=production

# install runtime dependencies (express) locally so require() can find them
COPY package.json ./
RUN npm install --omit=dev

# the .js files are compiled from the .ts sources by 'make js'
COPY *.js ./

EXPOSE 80

CMD ["node", "./main.js"]

# start container
# docker run -p 2468:80 systembuilder22/nicetry:latest
