## 基础镜像
docker stop ubuntu-test
docker rm ubuntu-test
docker run --name ubuntu-test --privileged=true   -itd ubuntu:18.04


## prometheus + grafana

https://github.com/prometheus/prometheus/releases/download/v2.34.0/prometheus-2.34.0.linux-amd64.tar.gz

https://dl.grafana.com/enterprise/release/grafana-enterprise-8.4.5.linux-amd64.tar.gz

docker cp prometheus-2.34.0.linux-amd64.tar.gz b0e746f65da8:/home/soft/prometheus-2.34.0.linux-amd64.tar.gz
docker cp grafana-enterprise-8.4.5.linux-amd64.tar.gz b0e746f65da8:/home/soft/grafana-enterprise-8.4.5.linux-amd64.tar.gz

tar -zxvf prometheus-2.34.0.linux-amd64.tar.gz
tar -zxvf grafana-enterprise-8.4.5.linux-amd64.tar.gz

mkdir /home/data/
mkdir /home/data/prometheus
mkdir /home/data/grafana

root@b0e746f65da8:/home/soft# mv prometheus-2.34.0.linux-amd64/ prometheus/
root@b0e746f65da8:/home/soft# mv grafana-8.4.5 grafana

