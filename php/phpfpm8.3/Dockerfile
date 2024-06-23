FROM --platform=${TARGETPLATFORM} php:8.3-fpm-alpine
MAINTAINER stanzhou "m@sq.mk"

ARG ALPINE_REPO=https://dl-cdn.alpinelinux.org
#ARG ALPINE_REPO=https://mirrors.aliyun.com
ARG URL_PREFIX=
ARG PROXY_DNS=10.1.0.251

ENV DEFAULT_COMPOSER_VER=2.7.6
ENV PHP_PHAR_DIR="${PHP_INI_DIR}/phar"
ENV PATH="${PATH}:${PHP_PHAR_DIR}"
ENV TIMEZONE="Asia/Shanghai"

#扩展安装脚本
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/

RUN ver=$(cat /etc/alpine-release | awk -F '.' '{printf "%s.%s", $1, $2;}') \
	&& repos=/etc/apk/repositories \
	&& mv -f ${repos} ${repos}_bk \
	&& echo "${URL_PREFIX}${ALPINE_REPO}/alpine/v${ver}/main" > ${repos} \
	&& echo "${URL_PREFIX}${ALPINE_REPO}/alpine/v${ver}/community" >> ${repos} \
	&& echo "@edge ${URL_PREFIX}${ALPINE_REPO}/alpine/edge/main" >> ${repos} \
#	&& echo "@testing ${URL_PREFIX}${ALPINE_REPO}/alpine/edge/testing" >> ${repos} \
  && apk add --no-cache tzdata libzip php-curl \
#	&& ln -sf /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2 \
	&& ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
	&& echo "${TIMEZONE}" > /etc/timezone \
        \
  && set -xe \
  && NPROC=$(getconf _NPROCESSORS_ONLN) \
# phar composer
  && mkdir ${PHP_PHAR_DIR} \
# 政治化版 \
  && COMPOSER_VER=`curl -s https://api.github.com/repos/composer/composer/releases/latest | grep "tag_name"  | head -n 1 | cut -d '"' -f4` \
  && COMPOSER_VER=${COMPOSER_VER:-${DEFAULT_COMPOSER_VER}} \
  && curl -fsSL https://github.com/composer/composer/releases/download/${COMPOSER_VER}/composer.phar  -o ${PHP_PHAR_DIR}/composer \
# 非政治化版本 \
#  && curl -fsSL https://github.com/open-composer/composer/releases/download/2.2.9/composer.phar -o ${PHP_PHAR_DIR}/composer \
  && chmod +x ${PHP_PHAR_DIR}/composer \
    \
#  && apk add --no-cache --virtual .build-deps \
#          shadow gettext-dev \
#          libpng libpng-dev gmp-dev libjpeg-turbo-dev libzip-dev freetype-dev \
# 安装扩展  # laravel 必须bcmath pdo_mysql，其他基础镜像已有 \
#imagick 和 gd 都是图片处理，但imagick会导致image体积太大，所以不安装imagick了 \
#  && docker-php-ext-configure gd --with-freetype --with-jpeg \
#  && docker-php-ext-install bcmath exif opcache pcntl zip gd gmp mysqli pdo_mysql gettext \
  && install-php-extensions bcmath exif opcache pcntl zip gd gmp pdo_mysql gettext \
    sockets redis yaml \
     \
  && rm -f /usr/bin/install-php-extensions \
## mongodb 支持3.6版本以下扩展
#  && apk add --no-cache --virtual .build-deps linux-headers curl-dev openssl openssl-dev \
#  && curl -fsSL "${URL_PREFIX}https://pecl.php.net/get/mongodb-1.12.1.tgz" -o mongodb.tgz \
#  && mkdir -p /tmp/mongodb \
#  && tar -xf mongodb.tgz -C /tmp/mongodb --strip-components=1 \
#  && rm -f mongodb.tgz \
#  && docker-php-ext-configure /tmp/mongodb --enable-mongodb --with-mongodb-ssl=auto \
#  && docker-php-ext-install -j${NPROC} /tmp/mongodb \
#  && mv /usr/local/lib/php/extensions/no-debug-non-zts-20220829/mongodb.so /usr/local/lib/php/extensions/no-debug-non-zts-20220829/mongodb.old.so \
#  #先禁用，需要时再启用，
#  && sed -i 's/^/;/' /usr/local/etc/php/conf.d/docker-php-ext-mongodb.ini \
#  && rm -rf /tmp/mongodb \
#    \
# mongodb 最新版本
  && apk add --no-cache --virtual .build-deps linux-headers curl-dev openssl openssl-dev \
  && curl -fsSL "${URL_PREFIX}https://pecl.php.net/get/mongodb" -o mongodb.tgz \
  && mkdir -p /tmp/mongodb \
  && tar -xf mongodb.tgz -C /tmp/mongodb --strip-components=1 \
  && rm -f mongodb.tgz \
  && docker-php-ext-configure /tmp/mongodb --enable-mongodb --with-mongodb-ssl=auto \
  && docker-php-ext-install -j${NPROC} /tmp/mongodb \
  #先禁用，需要时再启用，
  && sed -i 's/^/;/' /usr/local/etc/php/conf.d/docker-php-ext-mongodb.ini \
  && rm -rf /tmp/mongodb \
    \
# xdebug
  && curl -fsSL "${URL_PREFIX}https://pecl.php.net/get/xdebug" -o xdebug.tgz \
  && mkdir -p /tmp/xdebug \
  && tar -xf xdebug.tgz -C /tmp/xdebug --strip-components=1 \
  && rm -f xdebug.tgz \
  && docker-php-ext-configure /tmp/xdebug --enable-xdebug \
  && docker-php-ext-install -j${NPROC} /tmp/xdebug \
  #先禁用，需要时再启用，
  && sed -i 's/^/;/' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && rm -rf /tmp/xdebug \
  \
# xdebug 配置
  && echo "" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo "xdebug.mode=debug,develop,trace" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo "xdebug.max_nesting_level=1000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo ";xdebug.remote_host = 10.10.10.1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo ";xdebug.remote_host = 10.0.2.2" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo "xdebug.client_port = 9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo "xdebug.idekey = \"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
# 更改配置 \
  && apk add --no-cache --virtual .build-deps shadow \
	&& usermod -u 82 www-data \
	&& groupmod -g 82 www-data \
    \
  && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
  && sed -i 's/^disable_functions =$/disable_functions = exec,shell_exec,system,curl_multi_exec,parse_ini_file,show_source/g' /usr/local/etc/php/php.ini \
  \
  && apk del .build-deps \
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /usr/local/src/* \
	&& rm -rf /usr/src/* \
	&& mv -f ${repos}_bk ${repos}
