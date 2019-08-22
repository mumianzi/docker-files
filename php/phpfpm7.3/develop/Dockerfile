FROM php:7.3-fpm-alpine
MAINTAINER stanzhou "m@sq.mk"

#ARG ALPINE_REPO=http://dl-cdn.alpinelinux.org
ARG ALPINE_REPO=https://mirrors.aliyun.com
ARG URL_PREFIX=
#ARG PROXY_DNS=10.222.0.1


ENV PHP_PHAR_DIR="${PHP_INI_DIR}/phar"
ENV PATH="${PATH}:${PHP_PHAR_DIR}"
ENV TIMEZONE="Asia/Shanghai"

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
# ext
	&& docker-php-ext-install -j${NPROC} \
		bcmath \
		exif \
		opcache \
		pcntl \
		sockets \
	\
# gettext
	&& apk add --no-cache --virtual .build-deps \
		gettext-dev \
	&& apk add --no-cache \
		libintl \
	&& docker-php-ext-install -j${NPROC} gettext \
	\
# zip
	&& apk add --no-cache --virtual .build-deps \
		zlib-dev \
		libzip-dev\
	&& apk add --no-cache libzip \
	&& docker-php-ext-install -j${NPROC}  zip\
	\
# gd
	&& apk add --no-cache --virtual .build-deps \
		libpng-dev \
		freetype-dev \
		libjpeg-turbo-dev \
	&& apk add --no-cache \
		libpng \
		libjpeg-turbo \
		freetype \
		libmcrypt-dev \
	&& docker-php-ext-configure gd \
		--with-freetype-dir=/usr/include/ \
		--with-png-dir=/usr/include/ \
		--with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j${NPROC} gd \
	\
# mysqli
	&& docker-php-ext-configure mysqli \
		--with-mysql=/usr/bin/mysql_config  \
		--with-mysqli=mysqlnd \
		--with-pdo-mysql=mysqlnd \
	&& docker-php-ext-install -j${NPROC} mysqli \
	\
# pdo
	&& docker-php-ext-install -j${NPROC} pdo \
	\
# pdo_mysql
	&& docker-php-ext-install -j${NPROC} pdo_mysql \
	\
# imagick
	&& apk add --no-cache --virtual .build-deps \
		libtool \
		imagemagick-dev \
	&& apk add --no-cache \
            imagemagick \
    && curl -fsSL "${URL_PREFIX}https://pecl.php.net/get/imagick" -o imagick.tgz \
    && mkdir -p /tmp/imagick \
    && tar -xf imagick.tgz -C /tmp/imagick --strip-components=1 \
    && rm imagick.tgz \
    && docker-php-ext-install /tmp/imagick \
    && rm -r /tmp/imagick \
	\
# mcrypt
    && curl -fsSL "${URL_PREFIX}https://pecl.php.net/get/mcrypt" -o mcrypt.tgz \
    && mkdir -p /tmp/mcrypt \
    && tar -xf mcrypt.tgz -C /tmp/mcrypt --strip-components=1 \
    && rm mcrypt.tgz \
    && docker-php-ext-install -j${NPROC} /tmp/mcrypt \
    && rm -r /tmp/mcrypt \
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
# redis
    && curl -fsSL "${URL_PREFIX}https://pecl.php.net/get/redis" -o redis.tgz \
    && mkdir -p /tmp/redis \
    && tar -xf redis.tgz -C /tmp/redis --strip-components=1 \
    && rm redis.tgz \
    && docker-php-ext-install -j${NPROC} /tmp/redis \
    && rm -r /tmp/redis \
# xdebug
    && curl -fsSL "${URL_PREFIX}https://pecl.php.net/get/xdebug" -o xdebug.tar.gz \
    && mkdir -p /tmp/xdebug \
    && tar -xf xdebug.tar.gz -C /tmp/xdebug --strip-components=1 \
    && rm xdebug.tar.gz \
    && docker-php-ext-install -j${NPROC} /tmp/xdebug \
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
    && rm -r /tmp/xdebug \
# mongodb
    && apk add --no-cache --virtual .build-deps \
            openssl-dev \
    && curl -fsSL "${URL_PREFIX}https://pecl.php.net/get/mongodb" -o mongodb.tar.gz \
    && mkdir -p /tmp/mongodb \
    && tar -xf mongodb.tar.gz -C /tmp/mongodb --strip-components=1 \
    && rm mongodb.tar.gz \
    && docker-php-ext-install -j${NPROC} /tmp/mongodb \
    && rm -r /tmp/mongodb \
	\
##composer
#	&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
# end
	&& apk del -f .build-deps \
#	&& cat /etc/resolv.conf.bak > /etc/resolv.conf \
#	&& rm -f /etc/resolv.conf.bak \
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /usr/local/src/* \
	&& mv -f ${repos}_bk ${repos}
