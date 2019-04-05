FROM centos:7
MAINTAINER stanzhou m@sq.mk

#设置entrypoint和letsencrypt映射到www文件夹下持久化
COPY entrypoint.sh /entrypoint.sh

#更新系统
RUN yum -y update \
    && yum -y install wget \
    && mkdir -p /www/letsencrypt \
    && ln -s /www/letsencrypt /etc/letsencrypt \
    && rm -f /etc/init.d \
    && mkdir /www/init.d \
    && ln -s /www/init.d /etc/init.d \
    #安装宝塔
    && wget -O install.sh http://download.bt.cn/install/install_6.0.sh \
    && sh install.sh \
    && chmod +x /entrypoint.sh

CMD /entrypoint.sh
EXPOSE 8888 888 21 20 443 80

HEALTHCHECK --interval=5s --timeout=3s CMD curl -fs http://localhost/ || exit 1
