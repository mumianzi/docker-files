FROM alpine:3.9

MAINTAINER stanzhou "m@sq.mk"

ENV NGINX_VERSION 1.16.0

RUN GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \
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
        --with-stream \
        --with-stream_realip_module \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-cc-opt='-I/usr/local/include' \
        --with-ld-opt='-L/usr/local/lib' \
        --add-dynamic-module=/usr/src/ngx_http_geoip2_module \
        --add-module=/usr/src/lua-nginx-module-0.10.15 \
        --add-module=/usr/src/ngx_devel_kit-0.3.0 \
        " \
    && addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
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
    && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
    && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
    #lua脚本支持
    && git clone --recursive  http://luajit.org/git/luajit-2.0.git \
    && curl -fSL https://github.com/openresty/lua-nginx-module/archive/v0.10.15.tar.gz  -o lua-nginx-module.tar.gz \
    && curl -fSL https://github.com/simplresty/ngx_devel_kit/archive/v0.3.0.tar.gz  -o ngx_devel_kit.tar.gz \
    #geoip2
    && git clone --recursive https://github.com/maxmind/libmaxminddb.git \
    && git clone --recursive https://github.com/leev/ngx_http_geoip2_module.git \
    && export GNUPGHOME="$(mktemp -d)" \
    && found=''; \
    for server in \
        ha.pool.sks-keyservers.net \
        hkp://keyserver.ubuntu.com:80 \
        hkp://p80.pool.sks-keyservers.net:80 \
        pgp.mit.edu \
    ; do \
        echo "Fetching GPG key $GPG_KEYS from $server"; \
        gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
    done; \
    test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
    gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
    && rm -r "$GNUPGHOME" nginx.tar.gz.asc \
    && mkdir -p /usr/src \
    && tar -zxC /usr/src -f nginx.tar.gz \
    && rm nginx.tar.gz \
    #geoip2
    && cp -r ./libmaxminddb /usr/src \
    && cp -r ./ngx_http_geoip2_module /usr/src \
    && rm -rf libmaxminddb \
    && rm -rf ngx_http_geoip2_module \
    #lua
    && cp -r ./luajit-2.0 /usr/src \
    && tar -zxC /usr/src -f lua-nginx-module.tar.gz \
    && tar -zxC /usr/src -f ngx_devel_kit.tar.gz \
    && rm lua-nginx-module.tar.gz \
    && rm ngx_devel_kit.tar.gz \
    && export LUAJIT_LIB=/usr/local/lib \
    && export LUAJIT_INC=/usr/local/include/luajit-2.0 \
    && cd /usr/src/luajit-2.0 \
    && make && make install \
    && mkdir /etc/ld.so.conf.d \
    && echo '/usr/local/lib' >> /etc/ld.so.conf.d/lua.conf \
#    && ldconfig \
    && cd /usr/src \
    && rm -rf luajit-2.0 \
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
    && make install \
    && mkdir -p /usr/share/nginx/html/ \
    && install -m644 html/index.html /usr/share/nginx/html/ \
    && install -m644 html/50x.html /usr/share/nginx/html/ \
    && strip /usr/sbin/nginx* \
    && strip /usr/lib/nginx/modules/*.so \
    && rm -rf /usr/src/nginx-$NGINX_VERSION \
    && rm -rf /usr/src/libmaxminddb \
    && rm -rf /usr/src/ngx_http_geoip2_module \
    && rm -rf /usr/src/lua-nginx-module-0.10.15 \
    && rm -rf /usr/src/ngx_devel_kit-0.3.0 \
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    && runDeps="$( \
        scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache --virtual .nginx-rundeps $runDeps \
    && apk --no-cache add tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && addgroup -Sg 82 www-data 2>/dev/null \
    && addgroup nginx www-data 2>/dev/null \
    && apk del .build-deps \
    && apk del .gettext \
    && mv /tmp/envsubst /usr/local/bin/

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
