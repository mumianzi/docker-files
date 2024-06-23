FROM alpine:3.6
MAINTAINER stanzhou "stanzhou@zhen22.com"

ARG ALPINE_REPO=https://mirrors.aliyun.com
ARG URL_PREFIX=

ENV PHP_PHAR_DIR="${PHP_INI_DIR}/phar"
ENV PATH="${PATH}:${PHP_PHAR_DIR}"
ENV TIMEZONE="Asia/Shanghai" \
        GEARMAND_VERSION="1.1.8"\
        GEARMAN_USER=gearman \
        GEARMAN_GROUP=gearman \
        ETC_DIR=/etc/gearman \
        GEARMAN_HOME=/var/lib/${GEARMAN_USER}

RUN ver=$(cat /etc/alpine-release | awk -F '.' '{printf "%s.%s", $1, $2;}') \
	&& repos=/etc/apk/repositories \
        && mv -f ${repos} ${repos}_bk \
	&& echo "${URL_PREFIX}${ALPINE_REPO}/alpine/v${ver}/main" > ${repos} \
	&& echo "${URL_PREFIX}${ALPINE_REPO}/alpine/v${ver}/community" >> ${repos} \
 # && echo "${URL_PREFIX}${ALPINE_REPO}/alpine/edge/community" >> ${repos} \
#  && echo "${URL_PREFIX}${ALPINE_REPO}/alpine/edge/main" >> ${repos} \
  && echo "${URL_PREFIX}${ALPINE_REPO}/alpine/edge/testing" >> ${repos} \
        \
	&& apk add --no-cache tzdata \
	&& ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
	&& echo "${TIMEZONE}" > /etc/timezone \
        \
        && set -xe \
	&& NPROC=$(getconf _NPROCESSORS_ONLN) \
        \
	&& apk add --no-cache --virtual .build-deps \
		 curl g++ libc-dev boost-dev gperf libevent-dev util-linux-dev hiredis-dev libressl-dev sqlite-dev libmemcached-dev \
  && curl -fsSL "${URL_PREFIX}https://launchpad.net/gearmand/1.2/1.1.8/+download/gearmand-${GEARMAND_VERSION}.tar.gz" -o gearman.tar.gz \
  && mkdir -p /tmp/gearman \
  && tar -xf gearman.tar.gz -C /tmp/gearman --strip-components=1 \
  && rm gearman.tar.gz \
  && cd /tmp/gearman/ \
  && ./configure && make && make install \
  && rm -r /tmp/gearman \
  && rm -rf /var/lib/apt/lists/* \
  && rm /var/cache/apk/* \
# end
  && mv -f ${repos}_bk ${repos} \
EXPOSE 4730/tcp


ENTRYPOINT ["/sbin/entrypoint"]
CMD ["/sbin/su-exec", "${GEARMAN_USER}:${GEARMAN_GROUP}", "/usr/sbin/gearmand", "--log-file", "stderr"]
