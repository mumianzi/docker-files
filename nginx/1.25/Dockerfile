FROM --platform=${TARGETPLATFORM} nginx:1-alpine

MAINTAINER stanzhou "m@sq.mk"

ARG ALPINE_REPO=https://mirrors.aliyun.com
ARG URL_PREFIX=

ENV NGINX_VERSION 1.25.0
ENV MORE_HEADER_MODULE_VERSION 0.34
ENV ECHO_NGINX_MODULE_VERSION 0.63
ENV TIMEZONE Asia/Shanghai
ENV LUAJIT_LIB=/usr/lib

RUN ver=$(cat /etc/alpine-release | awk -F '.' '{printf "%s.%s", $1, $2;}') \
  && repos=/etc/apk/repositories \
  && mv -f ${repos} ${repos}_bk \
  && echo "${URL_PREFIX}${ALPINE_REPO}/alpine/v${ver}/main" > ${repos} \
  && echo "${URL_PREFIX}${ALPINE_REPO}/alpine/v${ver}/community" >> ${repos} \
#  && echo "@edge ${URL_PREFIX}${ALPINE_REPO}/alpine/edge/main" >> ${repos} \
#  && echo "@testing ${URL_PREFIX}${ALPINE_REPO}/alpine/edge/testing" >> ${repos} \
  && apk add --no-cache tzdata \
  && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
  && echo "${TIMEZONE}" > /etc/timezone \
       \
  && set -xe \
  && NPROC=$(getconf _NPROCESSORS_ONLN) \
  && CONFIG="\
     --prefix=/etc/nginx \
      --sbin-path=/usr/sbin/nginx \
      --modules-path=/usr/lib/nginx/modules \
      --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/var/log/nginx/error.log \
      --http-log-path=/var/log/nginx/access.log \
      --pid-path=/var/run/nginx.pid \
      --lock-path=/var/run/nginx.lock \
      --http-client-body-temp-path=/var/cache/nginx/client_temp \
      --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
      --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
      --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
      --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
      --with-perl_modules_path=/usr/lib/perl5/vendor_perl \
      --user=nginx \
      --group=nginx \
      --with-compat \
      --with-file-aio \
      --with-threads \
      --with-http_addition_module \
      --with-http_auth_request_module \
      --with-http_dav_module \
      --with-http_flv_module \
      --with-http_gunzip_module \
      --with-http_gzip_static_module \
      --with-http_mp4_module \
      --with-http_random_index_module \
      --with-http_realip_module \
      --with-http_secure_link_module \
      --with-http_slice_module \
      --with-http_ssl_module \
      --with-http_stub_status_module \
      --with-http_sub_module \
      --with-http_v2_module \
      --with-mail \
      --with-mail_ssl_module \
      --with-http_v3_module \
      --with-stream \
      --with-stream_realip_module \
      --with-stream_ssl_module \
      --with-stream_ssl_preread_module \
      --with-cc-opt='-I/usr/local/include' \
      --with-ld-opt='-Wl,--as-needed,-O1,--sort-common' \
      --add-dynamic-module=/usr/src/headers-more-nginx-module-$MORE_HEADER_MODULE_VERSION \
      --add-dynamic-module=/usr/src/echo-nginx-module-$ECHO_NGINX_MODULE_VERSION \
      --add-dynamic-module=/usr/src/ngx_http_geoip2_module \
        " \
  && apk add --no-cache --virtual .build-deps \
    	shadow \
      gcc \
      libc-dev \
      git \
      make \
      automake \
      autoconf \
      libtool \
      linux-headers \
      openssl-dev \
      pcre2-dev \
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
#      libressl-dev \
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
  && curl -fSL https://github.com/openresty/echo-nginx-module/archive/v$ECHO_NGINX_MODULE_VERSION.tar.gz -o echo-nginx-module.tar.gz \
  && tar -zxC /usr/src -f echo-nginx-module.tar.gz \
  && rm echo-nginx-module.tar.gz \
  \
  #install
  && export CFLAGS="-O2" \
      CPPFLAGS="-O2" \
      LDFLAGS="-O2" \
  && cd /usr/src/libmaxminddb \
  && ./bootstrap \
  && ./configure \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && make install \
  && cd /usr/src/nginx-$NGINX_VERSION \
  && ./configure $CONFIG \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && cp -f /usr/src/nginx-$NGINX_VERSION/objs/*.so /usr/lib/nginx/modules/ \
#  && cp -f /usr/src/nginx-$NGINX_VERSION/objs/ngx_http_headers_more_filter_module.so /usr/lib/nginx/modules/ \
#  && cp -f /usr/src/nginx-$NGINX_VERSION/objs/ngx_http_geoip2_module.so /usr/lib/nginx/modules/ \
#  && cp -f /usr/src/nginx-$NGINX_VERSION/objs/ngx_stream_geoip2_module.so /usr/lib/nginx/modules/ \
  && cp -f /usr/src/nginx-$NGINX_VERSION/objs/nginx /usr/sbin/nginx \
# 更改配置
  && usermod -u 82 nginx \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/* \
  && rm -rf /usr/local/src/* \
  && rm -rf /usr/src/*
