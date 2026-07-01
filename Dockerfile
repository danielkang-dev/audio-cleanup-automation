FROM node:20-alpine

RUN apk add --no-cache ffmpeg chromaprint curl

RUN npm install -g n8n --legacy-peer-deps

WORKDIR /home/node
USER node

EXPOSE 5678

CMD ["n8n", "start"]
