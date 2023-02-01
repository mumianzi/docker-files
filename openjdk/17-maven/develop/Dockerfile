FROM maven:3-openjdk-17-slim
MAINTAINER stanzhou "m@sq.mk"

ARG URL_PREFIX=
ARG PROXY_DNS=10.1.0.251

ENV TIMEZONE="Asia/Shanghai"

#RUN apt update && apt install iputils-ping
RUN apt update && apt install -y iputils-ping \
    && apt autoremove

