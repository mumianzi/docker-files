FROM mumianzi/php:8.4-fpm-alpine
#FROM --platform=${TARGETPLATFORM} mumianzi/php:8.4-fpm-alpine
LABEL maintainer="stanzhou m@sq.mk"

#mac上此处设置貌似无效，可以设置 deamon.json 里的 dns 项
#ARG PROXY_DNS=10.1.0.251

RUN  apk add --no-cache supervisor \
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /usr/local/src/* \
