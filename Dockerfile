FROM node:24-alpine

RUN apk add --no-cache ffmpeg chromaprint curl

RUN npm install -g n8n@2.42.2 --legacy-peer-deps

WORKDIR /home/node
USER node

EXPOSE 5678

CMD ["n8n", "start"]
