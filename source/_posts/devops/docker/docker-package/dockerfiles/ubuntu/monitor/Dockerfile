# ubuntu
FROM ubuntu:18.04

# MAINTAINER
MAINTAINER wuhaocn@126.com
VOLUME ["/tmp"]
# RUN apt-get update
# RUN apt-get -y install vim
# RUN apt-get -y install net-tools
# 下载文件 https://github.com/prometheus/prometheus/releases/download/v2.34.0/prometheus-2.34.0.linux-amd64.tar.gz  解压
ADD grafana /usr/local/grafana
# 下载文件 https://dl.grafana.com/enterprise/release/grafana-enterprise-8.4.5.linux-amd64.tar.gz 解压
ADD prometheus /usr/local/prometheus

ADD entrypoint.sh /usr/local/entrypoint.sh

ENTRYPOINT [ "/usr/local/entrypoint.sh" ]