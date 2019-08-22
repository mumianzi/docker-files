FROM mumianzi/php:7.3-fpm-alpine
MAINTAINER stanzhou "m@sq.mk"

#ARG ALPINE_REPO=http://dl-cdn.alpinelinux.org
#ARG ALPINE_REPO=https://mirrors.aliyun.com

# supervisor
RUN  apk add --no-cache supervisor \
	&& apk del -f .build-deps \
##	&& cat /etc/resolv.conf.bak > /etc/resolv.conf \
##    && rm -f /etc/resolv.conf.bak
  && rm -rf /var/cache/apk/* \
  && rm -rf /usr/local/src/*

ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-n","-c","/etc/supervisord.conf"]
