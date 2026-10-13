# this Dockerfile acknowledges:
#   https://github.com/zachdeibert/docker-images/blob/master/software/typescript/Dockerfile
#   https://github.com/prakhar1989/docker-curriculum/blob/master/flask-app/Dockerfile

FROM node:22-slim

LABEL maintainer="Don Gillies <dwgillies@gmail.com>"

WORKDIR /srv/webserver/typescript

# Express hides stack traces from clients only in production mode
ENV NODE_ENV=production

# install runtime dependencies (express) locally so require() can find them;
# npm ci installs exactly what package-lock.json lists
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# the .js files are compiled from the .ts sources by 'make js'
COPY *.js ./

EXPOSE 80

# run as the image's unprivileged node user (UID 1000), not root; Docker 20.10+
# lets non-root processes bind ports below 1024 inside a container
USER node

CMD ["node", "./main.js"]

# start container
# docker run -p 2468:80 systembuilder22/nicetry:latest
