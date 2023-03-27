FROM php:8.2-fpm-bullseye
MAINTAINER stanzhou "m@sq.mk"

ARG URL_PREFIX=
ARG PROXY_DNS=10.1.0.251

ENV DEFAULT_COMPOSER_VER=2.5.5
ENV PHP_PHAR_DIR="${PHP_INI_DIR}/phar"
ENV PATH="${PATH}:${PHP_PHAR_DIR}"
ENV TIMEZONE="Asia/Shanghai"

#扩展安装脚本
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/

RUN ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
	&& echo "${TIMEZONE}" > /etc/timezone \
        \
  && set -xe \
  && NPROC=$(getconf _NPROCESSORS_ONLN); \
# phar composer
  mkdir ${PHP_PHAR_DIR}; \
## 政治化版 \
  COMPOSER_VER=`curl -s https://api.github.com/repos/composer/composer/releases/latest | grep "tag_name"  | head -n 1 | cut -d '"' -f4`; \
  COMPOSER_VER=${COMPOSER_VER:-${DEFAULT_COMPOSER_VER}}; \
  curl -fsSL https://github.com/composer/composer/releases/download/${COMPOSER_VER}/composer.phar  -o ${PHP_PHAR_DIR}/composer; \
## 非政治化版本 \
##  && curl -fsSL https://github.com/open-composer/composer/releases/download/2.2.9/composer.phar -o ${PHP_PHAR_DIR}/composer \
  chmod +x ${PHP_PHAR_DIR}/composer; \
#    \
#  apt-get update; \
#  apt-get install -y --no-install-recommends \
#          zlib1g-dev libzip-dev libpng-dev libjpeg-dev libyaml-dev libgmp-dev libfreetype-dev libmagickwand-dev libzstd-dev; \
# 安装扩展 \
#  docker-php-ext-configure gd --with-freetype --with-jpeg; \
#  docker-php-ext-install bcmath exif opcache pcntl zip gd gmp mysqli pdo_mysql gettext sockets; \
  install-php-extensions bcmath exif opcache pcntl zip gd gmp pdo_mysql gettext \
      sockets redis yaml; \
       \
  rm -f /usr/local/bin/install-php-extensions; \
  curl -fsSL "${URL_PREFIX}https://pecl.php.net/get/mongodb" -o mongodb.tgz; \
  mkdir -p /tmp/mongodb; \
  tar -xf mongodb.tgz -C /tmp/mongodb --strip-components=1; \
  rm -f mongodb.tgz; \
  docker-php-ext-configure /tmp/mongodb --enable-mongodb; \
  docker-php-ext-install -j${NPROC} /tmp/mongodb; \
  #先禁用，需要时再启用，
  sed -i 's/^/;/' /usr/local/etc/php/conf.d/docker-php-ext-mongodb.ini; \
  rm -rf /tmp/mongodb; \
    \
# xdebug
  curl -fsSL "${URL_PREFIX}https://pecl.php.net/get/xdebug" -o xdebug.tgz; \
  mkdir -p /tmp/xdebug; \
  tar -xf xdebug.tgz -C /tmp/xdebug --strip-components=1; \
  rm -f xdebug.tgz; \
  docker-php-ext-configure /tmp/xdebug --enable-xdebug; \
  docker-php-ext-install -j${NPROC} /tmp/xdebug; \
  #先禁用，需要时再启用，
  sed -i 's/^/;/' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
  rm -rf /tmp/xdebug; \
  \
# xdebug 配置
  echo "" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
  echo "xdebug.mode=debug,develop,trace" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
  echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
  echo "xdebug.max_nesting_level=1000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
  echo ";xdebug.remote_host = 10.10.10.1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
  echo ";xdebug.remote_host = 10.0.2.2" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
  echo "xdebug.client_port = 9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
  echo "xdebug.idekey = \"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
## 更改配置
	usermod -u 82 www-data; \
	groupmod -g 82 www-data; \
  cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini; \
  sed -i 's/^disable_functions =$/disable_functions = exec,shell_exec,system,curl_multi_exec,parse_ini_file,show_source/g' /usr/local/etc/php/php.ini; \
  \
  rm -rf /var/lib/apt/lists/*; \
	rm -rf /usr/local/src/*; \
  rm -rf /tmp/pear;
#	mv -f ${repos}_bk ${repos}

