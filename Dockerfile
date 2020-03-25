FROM ubuntu:latest
LABEL maintainer="brunokazuaki@gmail.com"

RUN apt-get update && apt-get install vim nginx -y

EXPOSE 80/tcp
