FROM php:8.0-fpm-alpine
MAINTAINER stanzhou "m@sq.mk"

#ARG ALPINE_REPO=http://dl-cdn.alpinelinux.org
ARG ALPINE_REPO=https://mirrors.aliyun.com
ARG URL_PREFIX=
#mac上此处设置貌似无效，可以设置 deamon.json 里的 dns 项
#ARG PROXY_DNS=10.1.0.251


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
        \
	&& apk add --no-cache tzdata \
	&& ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
	&& echo "${TIMEZONE}" > /etc/timezone \
        \
        && set -xe \
	&& NPROC=$(getconf _NPROCESSORS_ONLN) \
## proxy_dns
#	&& cat /etc/resolv.conf > /etc/resolv.conf.bak \
#	&& echo 'nameserver ${PROXY_DNS}' >> /etc/resolv.conf \
# phar
        && mkdir ${PHP_PHAR_DIR} \
        && EXPECTED_SIGNATURE=$(curl -fsSL ${URL_PREFIX}https://composer.github.io/installer.sig) \
        && php -r "copy('${URL_PREFIX}https://getcomposer.org/installer', 'composer-setup.php');" \
        && ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');") \
        && if [ "${EXPECTED_SIGNATURE}" != "${ACTUAL_SIGNATURE}" ]; then \
                >&2 echo 'ERROR: Invalid installer signature'; \
                exit 1; \
        fi \
        && php composer-setup.php --install-dir=${PHP_PHAR_DIR} --filename=composer \
        && rm composer-setup.php \
        && chmod +x ${PHP_PHAR_DIR}/composer \
        \
# 安装扩展
  && install-php-extensions bcmath exif opcache pcntl sockets calendar\
     gettext zip gd gmp \
     mysqli pdo_mysql \
     imagick mcrypt \
     redis mongodb \
     xdebug \
     \
  && rm -f /usr/bin/install-php-extensions \
# xdebug 配置
	&& echo "" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.default_enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.remote_enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.max_nesting_level=1000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo ";xdebug.remote_host = 10.10.10.1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo ";xdebug.remote_host = 10.0.2.2" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.remote_port = 9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.remote_autostart=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.remote_connect_back = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.idekey = \"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#  && rm -r /tmp/xdebug \
# swoole
    && apk add --no-cache --virtual .build-deps \
            linux-headers \
            zlib-dev \
    \
    && curl -fsSL "${URL_PREFIX}https://pecl.php.net/get/swoole" -o swoole.tgz \
    && mkdir -p /tmp/swoole \
    && tar -xf swoole.tgz -C /tmp/swoole --strip-components=1 \
    && rm swoole.tgz \
    && docker-php-ext-configure /tmp/swoole --enable-swoole \
    && docker-php-ext-install -j${NPROC} /tmp/swoole \
    && rm -r /tmp/swoole \
	\
# 增加supervisor
	&& apk add --no-cache supervisor \
##composer
#	&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
# end
	&& apk del -f .build-deps \
#	&& cat /etc/resolv.conf.bak > /etc/resolv.conf \
#	&& rm -f /etc/resolv.conf.bak \
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /usr/local/src/* \
	&& mv -f ${repos}_bk ${repos}
