FROM alpine:3
MAINTAINER stan "m@sq.mk"

ARG ALPINE_REPO=https://mirrors.aliyun.com
ARG URL_PREFIX=

ENV RPC_LISTEN_PORT 6800
ENV BT_LISTEN_PORT 51413
ENV DHT_LISTEN_PORT 51415

ENV TIMEZONE Asia/Shanghai

RUN ver=$(cat /etc/alpine-release | awk -F '.' '{printf "%s.%s", $1, $2;}') \
	&& repos=/etc/apk/repositories \
        && mv -f ${repos} ${repos}_bk \
	&& echo "${URL_PREFIX}${ALPINE_REPO}/alpine/v${ver}/main" > ${repos} \
	&& echo "${URL_PREFIX}${ALPINE_REPO}/alpine/v${ver}/community" >> ${repos} \
        \
	&& apk add --no-cache tzdata \
	&& ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
	&& echo "${TIMEZONE}" > /etc/timezone \
        \
	&& apk add --no-cache --virtual .build-deps build-base curl \
	&& apk add --no-cache --virtual .persistent-deps ca-certificates gnutls-dev expat-dev sqlite-dev c-ares-dev \
	&& cd /tmp \
  && ARIA2_VERSION=`curl "https://github.com/aria2/aria2/releases/latest" | sed -n 's/^.*tag\/release-\(.*\)".*/\1/p'` \
  && curl -fSL https://github.com/aria2/aria2/releases/download/release-${ARIA2_VERSION}/aria2-${ARIA2_VERSION}.tar.xz -o aria2.tar.xz \
  && tar xJf aria2.tar.xz \
  && cd /tmp/aria2-${ARIA2_VERSION} \
  && sed -i 's/1, 16/1, -1/g' src/OptionHandlerFactory.cc \
  && ./configure \
  && make -j $(getconf _NPROCESSORS_ONLN) \
  && make install \
  && apk del .build-deps \
  && mkdir -p /etc/aria2 \
	&& mkdir -p /downloads \
  && rm -rf /tmp

  deluser xfs && \
  addgroup -g 33 -S www-data && adduser -u 33 -D -S -G www-data www-data

EXPOSE $RPC_LISTEN_PORT $BT_LISTEN_PORT $DHT_LISTEN_PORT

CMD ["/usr/local/bin/aria2c", "--conf-path=/etc/aria2/aria2.conf"]
