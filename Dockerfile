FROM node:18-alpine

WORKDIR /app

COPY ./src /app

RUN yarn install

EXPOSE 8080

ENTRYPOINT [ "node", "server.js" ]