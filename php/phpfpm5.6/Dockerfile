FROM php:5.6-fpm-alpine
MAINTAINER dishuostecli "dishuostecli@zhen22.com"

ARG ALPINE_REPO=http://mirrors.ustc.edu.cn
ARG URL_PREFIX=

ENV PHP_PHAR_DIR="${PHP_INI_DIR}/phar"
ENV PATH="${PATH}:${PHP_PHAR_DIR}"
ENV TIMEZONE="Asia/Shanghai" \
        IMAGICK_VERSION="3.4.3" \
        IMAGICK_SHA1="810ec3e932efb3298e285158c72312134b6f8279" \
        GEARAMN_ID="cb67bb8f7551de280593ceb561bd4faf2d60ebe3" \
        GEARMAN_SHA1="78bc039c168c680b2c5fa4a1441bca6bd81f771c" \
        SWOOLE_VERSION="1.9.5" \
        SWOOLE_SHA1="7f3cefd1991cc5514bbba19db7358346b82aeeb3" \
        REDIS_VERSION="2.2.8" \
        REDIS_SHA1="909e04a0770006b7a407d06245af8d9d18268507" \
        MONGO_VERSION="1.6.14" \
        MONGO_SHA1="ceb59e08ee2e71dda23ba5c0989fd5172dea107d" \
        XDEBUG_VERSION="2.5.1" \
        XDEBUG_SHA1="0efb4fd7b2c3f6b3130db0145492a56df41f7c55" 

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
	&& docker-php-ext-install -j${NPROC} zip \
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
	&& docker-php-ext-configure gd \
		--with-freetype-dir=/usr/include/ \
		--with-png-dir=/usr/include/ \
		--with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j${NPROC} gd \
	\
# mcrypt
	&& apk add --no-cache --virtual .build-deps \
		libmcrypt-dev \
	&& apk add --no-cache \
		libmcrypt \
	&& docker-php-ext-install -j${NPROC} mcrypt \
	\
# mysqli
	&& docker-php-ext-configure mysqli \
		--with-mysql=/usr/bin/mysql_config  \
		--with-mysqli=mysqlnd \
		--with-pdo-mysql=mysqlnd \
	&& docker-php-ext-install -j${NPROC} mysqli \
	&& docker-php-ext-install -j${NPROC} mysql \
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
        && curl -fsSL "${URL_PREFIX}https://github.com/mkoppanen/imagick/archive/${IMAGICK_VERSION}.tar.gz" -o imagick.tar.gz \
	&& echo "${IMAGICK_SHA1} *imagick.tar.gz" | sha1sum -c - \
        && mkdir -p /tmp/imagick \
        && tar -xf imagick.tar.gz -C /tmp/imagick --strip-components=1 \
        && rm imagick.tar.gz \
        && docker-php-ext-install /tmp/imagick \
        && rm -r /tmp/imagick \
	\
# swoole
        && apk add --no-cache --virtual .build-deps \
                linux-headers \
                zlib-dev \
        \
        && curl -fsSL "${URL_PREFIX}https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz" -o swoole.tar.gz \
        && echo "${SWOOLE_SHA1} *swoole.tar.gz" | sha1sum -c - \
        && mkdir -p /tmp/swoole \
        && tar -xf swoole.tar.gz -C /tmp/swoole --strip-components=1 \
        && rm swoole.tar.gz \
        && docker-php-ext-configure /tmp/swoole --enable-swoole \
        && docker-php-ext-install -j${NPROC} /tmp/swoole \
        && rm -r /tmp/swoole \
# redis
        && curl -fsSL "${URL_PREFIX}https://github.com/phpredis/phpredis/archive/${REDIS_VERSION}.tar.gz" -o redis.tar.gz \
	&& echo "${REDIS_SHA1} *redis.tar.gz" | sha1sum -c - \
        && mkdir -p /tmp/redis \
        && tar -xf redis.tar.gz -C /tmp/redis --strip-components=1 \
        && rm redis.tar.gz \
        && docker-php-ext-install -j${NPROC} /tmp/redis \
        && rm -r /tmp/redis \
#gearman
	&&  apk add --no-cache --virtual .build-deps gearman-dev gearman-libs gcc autoconf g++ zlib-dev make  \
          --repository ${URL_PREFIX}${ALPINE_REPO}/alpine/edge/community \
         --repository ${URL_PREFIX}${ALPINE_REPO}/alpine/edge/main \
         --repository ${URL_PREFIX}${ALPINE_REPO}/alpine/edge/testing \
        && pecl install gearman && docker-php-ext-enable gearman \
        && apk del --force gearman-dev gcc autoconf g++ zlib-dev make \
# xdebug
#         && curl -fsSL "${URL_PREFIX}https://xdebug.org/files/xdebug-${XDEBUG_VERSION}.tgz" -o xdebug.tar.gz \
# 	&& echo "${XDEBUG_SHA1} *xdebug.tar.gz" | sha1sum -c - \
#         && mkdir -p /tmp/xdebug \
#         && tar -xf xdebug.tar.gz -C /tmp/xdebug --strip-components=1 \
#         && rm xdebug.tar.gz \
#         && docker-php-ext-install -j${NPROC} /tmp/xdebug \
# 	&& echo "" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
# 	&& echo "xdebug.default_enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
# 	&& echo "xdebug.remote_enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
# 	&& echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
# 	&& echo "xdebug.max_nesting_level=1000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
# 	&& echo ";xdebug.remote_host = 10.10.10.1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
# 	&& echo ";xdebug.remote_host = 10.0.2.2" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
# 	&& echo "xdebug.remote_port = 9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
# 	&& echo "xdebug.remote_autostart=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
# 	&& echo "xdebug.remote_connect_back = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
# 	&& echo "xdebug.idekey = \"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#         && rm -r /tmp/xdebug \
# mongo legacy
        && apk add --update \
                libressl-dev@edge \
        && curl -fsSL "${URL_PREFIX}https://github.com/mongodb/mongo-php-driver-legacy/archive/${MONGO_VERSION}.tar.gz" -o mongo.tar.gz \
	&& echo "${MONGO_SHA1} *mongo.tar.gz" | sha1sum -c - \
        && mkdir -p /tmp/mongo \
        && tar -xf mongo.tar.gz -C /tmp/mongo --strip-components=1 \
        && rm mongo.tar.gz \
        && docker-php-ext-install -j${NPROC} /tmp/mongo \
	&& apk del --force libressl-dev \
        && rm -r /tmp/mongo \
# git
	&& apk --update add git openssh \
    && rm -rf /var/lib/apt/lists/* \
    && rm /var/cache/apk/* \
# end
    && mv -f ${repos}_bk ${repos}
