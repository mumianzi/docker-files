FROM openjdk:17-bullseye
MAINTAINER stanzhou "m@sq.mk"

#ARG ALPINE_REPO=http://dl-cdn.alpinelinux.org
ARG ALPINE_REPO=https://mirrors.aliyun.com
ARG URL_PREFIX=
ARG PROXY_DNS=10.1.0.251

ENV TIMEZONE="Asia/Shanghai"

RUN apt update && apt install inetutils-ping
