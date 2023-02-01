FROM php:8.2-fpm-alpine
MAINTAINER stanzhou "m@sq.mk"

#ARG ALPINE_REPO=http://dl-cdn.alpinelinux.org
ARG ALPINE_REPO=https://mirrors.aliyun.com
ARG URL_PREFIX=
ARG PROXY_DNS=10.1.0.251

ENV DEFAULT_COMPOSER_VER=2.5.1
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
	&& echo "@testing ${URL_PREFIX}${ALPINE_REPO}/alpine/edge/testing" >> ${repos} \
  && apk add --no-cache tzdata libzip \
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
  && apk add --no-cache --virtual .build-deps \
          shadow gettext-dev \
          libpng libpng-dev gmp-dev libjpeg-turbo-dev libzip-dev \
# 安装扩展 \
#  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install bcmath exif opcache pcntl zip gd gmp mysqli pdo_mysql gettext \
  && install-php-extensions imagick sockets \
     redis yaml \
     \
  && rm -f /usr/bin/install-php-extensions \
# 更改配置
	&& usermod -u 82 www-data \
	&& groupmod -g 82 www-data \
  #socks 不便于水平扩展
#  && mkdir /socks \
#  && chown www-data:www-data /socks \
#  && sed -i 's/^listen = 9000$/listen = \/socks\/php-fpm\.sock/g' /usr/local/etc/php-fpm.d/zz-docker.conf \
#  && sed -i '$a listen\.mode = 0660' /usr/local/etc/php-fpm.d/zz-docker.conf \
  && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
  && sed -i 's/^disable_functions =$/disable_functions = exec,shell_exec,system,curl_multi_exec,parse_ini_file,show_source/g' /usr/local/etc/php/php.ini \
  \
  && apk del .build-deps \
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /usr/local/src/* \
	&& mv -f ${repos}_bk ${repos}
