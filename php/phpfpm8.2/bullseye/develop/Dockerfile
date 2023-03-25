FROM mumianzi/php:8.2-fpm-bullseye
MAINTAINER stanzhou "m@sq.mk"

ARG URL_PREFIX=
#mac上此处设置貌似无效，可以设置 deamon.json 里的 dns 项
#ARG PROXY_DNS=10.1.0.251

#扩展安装脚本
#COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/

RUN set -xe; \
	NPROC=$(getconf _NPROCESSORS_ONLN); \
  \
# 安装扩展 \
  sed -i 's/^disable_functions = exec,shell_exec,system,curl_multi_exec,parse_ini_file,show_source$/disable_functions = /g' /usr/local/etc/php/php.ini; \
      \
  curl -sSLf \
            -o /usr/local/bin/install-php-extensions \
            https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions; \
  chmod +x /usr/local/bin/install-php-extensions; \
  install-php-extensions xdebug mongodb; \
#     \
  rm -f /usr/local/bin/install-php-extensions; \
# xdebug
	\
# xdebug 配置
	echo "" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.mode=debug,develop,trace" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.max_nesting_level=1000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo ";xdebug.remote_host = 10.10.10.1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo ";xdebug.remote_host = 10.0.2.2" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.client_port = 9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo "xdebug.idekey = \"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
	\
# end \
  sed -i 's/^disable_functions =/disable_functions = exec,shell_exec,system,curl_multi_exec,parse_ini_file,show_source/g' /usr/local/etc/php/php.ini; \
      \
	rm -rf /var/lib/apt/lists/*; \
  rm -rf /usr/local/src/*; \
  rm -rf /tmp/pear;
