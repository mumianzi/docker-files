FROM mumianzi/php:8.0-fpm-alpine
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
	&& ln -sf /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2 \
	&& ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
	&& echo "${TIMEZONE}" > /etc/timezone \
         \
  && set -xe \
 	&& NPROC=$(getconf _NPROCESSORS_ONLN) \
  && apk upgrade --no-cache \
  && apk add --no-cache --upgrade \
           bash \
           curl \
           git \
           mercurial \
           openssh \
           openssl \
           p7zip \
           subversion \
           unzip \
           zip \
  && install-php-extensions \
           bz2 \
           zip \
 	\
  && cd / \
  && composer create-project composer/satis:dev-main \
  && cd /satis \
  && composer install \
          --no-interaction \
          --no-ansi \
          --no-scripts \
          --no-plugins \
          --no-dev \
          --prefer-dist \
          --no-progress \
          --classmap-authoritative \
 # end \
  && chown -Rf www-data:www-data /satis \
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /usr/local/src/* \
	&& mv -f ${repos}_bk ${repos}

COPY run-sleep.sh /satis/bin/
WORKDIR /satis
