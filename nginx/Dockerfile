FROM nginx:1.21.4-alpine

MAINTAINER stanzhou "m@sq.mk"

ARG ALPINE_REPO=https://mirrors.aliyun.com
ARG URL_PREFIX=

ENV NGINX_VERSION 1.21.4
ENV MORE_HEADER_MODULE_VERSION 0.33
ENV TIMEZONE Asia/Shanghai
ENV LUAJIT_LIB=/usr/lib

RUN ver=$(cat /etc/alpine-release | awk -F '.' '{printf "%s.%s", $1, $2;}') \
  && repos=/etc/apk/repositories \
  && mv -f ${repos} ${repos}_bk \
  && echo "${URL_PREFIX}${ALPINE_REPO}/alpine/v${ver}/main" > ${repos} \
  && echo "${URL_PREFIX}${ALPINE_REPO}/alpine/v${ver}/community" >> ${repos} \
  && echo "@edge ${URL_PREFIX}${ALPINE_REPO}/alpine/edge/main" >> ${repos} \
  && echo "@testing ${URL_PREFIX}${ALPINE_REPO}/alpine/edge/testing" >> ${repos} \
  && apk add --no-cache tzdata \
  && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
  && echo "${TIMEZONE}" > /etc/timezone \
       \
  && set -xe \
  && NPROC=$(getconf _NPROCESSORS_ONLN) \
  && apk add --no-cache  --virtual .build-deps \
    shadow gettext-dev libzip libzip-dev \
      \
# 更改配置
  && usermod -u 82 nginx \
#  && groupmod -g 82 nginx \
  && apk add --no-cache --virtual .build-deps \
      gcc \
      libc-dev \
      git \
      make \
      automake \
      autoconf \
      libtool \
      linux-headers \
      openssl-dev \
      pcre-dev \
      zlib-dev \
      curl \
      gnupg \
      libxslt-dev \
      gd-dev \
      geoip-dev \
      perl-dev \
      libedit-dev \
      bash \
      alpine-sdk \
      findutils \
  && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
  #geoip2
  && git clone --recursive https://github.com/maxmind/libmaxminddb.git \
  && git clone --recursive https://github.com/leev/ngx_http_geoip2_module.git \
  && mkdir -p /usr/src \
  && tar -zxC /usr/src -f nginx.tar.gz \
  && rm nginx.tar.gz \
  #geoip2
  && cp -r ./libmaxminddb /usr/src \
  && cp -r ./ngx_http_geoip2_module /usr/src \
  && rm -rf libmaxminddb \
  && rm -rf ngx_http_geoip2_module \
  #more header module
  && curl -fSL https://github.com/openresty/headers-more-nginx-module/archive/v$MORE_HEADER_MODULE_VERSION.tar.gz -o headers-more-nginx-module.tar.gz \
  && tar -zxC /usr/src -f headers-more-nginx-module.tar.gz \
  && rm headers-more-nginx-module.tar.gz \
   #echo nginx module
  && curl -fSL https://github.com/openresty/echo-nginx-module/archive/v0.62.tar.gz -o echo-nginx-module.tar.gz \
  && tar -zxC /usr/src -f echo-nginx-module.tar.gz \
  && rm echo-nginx-module.tar.gz \
  \


  && apk del .build-deps \
  && rm -rf /var/cache/apk/* \
  && rm -rf /usr/local/src/* \
