FROM mumianzi/php:7.1-fpm-alpine
MAINTAINER stanzhou "stanzhou@zhen22.com"

# supervisor
RUN  apk add --no-cache supervisor \
	&& apk del -f .build-deps \
##	&& cat /etc/resolv.conf.bak > /etc/resolv.conf \
##    && rm -f /etc/resolv.conf.bak
  && rm -rf /var/cache/apk/* \
  && rm -rf /usr/local/src/*

ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-n","-c","/etc/supervisord.conf"]
