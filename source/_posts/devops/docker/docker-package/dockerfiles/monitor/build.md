```
docker stop ubuntu-test
docker rm ubuntu-test
docker run --name ubuntu-test --privileged=true   -itd ubuntu:18.04
```

```
wget https://releases.hashicorp.com/consul/1.6.3/consul_1.6.3_linux_amd64.zip
unzip consul_1.6.3_linux_amd64.zip 
./consul agent -server -data-dir=/tmp/consul -bootstrap -advertise=$LOCAL_IP

wget https://github.com/prometheus/prometheus/releases/download/v2.29.2/prometheus-2.29.2.linux-amd64.tar.gz
tar -xzvf prometheus-2.29.2.linux-amd64.tar.gz 

wget https://dl.grafana.com/oss/release/grafana_6.0.0-beta1_amd64.deb 
dpkg -i grafana_6.0.0-beta1_amd64.deb
apt-get -f install
dpkg -i grafana_6.0.0-beta1_amd64.deb




docker commit 2fcd5466e2ff wuhaocn/monitor:1.0.0
docker tag wuhaocn/monitor:1.0.0 wuhaocn/monitor:1.0.0
docker push wuhaocn/monitor:1.0.0

9090
8500
3000



docker stop monitor-test
docker rm monitor-test
docker run --name monitor-test --privileged=true -p 19090:9090  -p 13000:3000   -p 18500:8500   -itd wuhaocn/monitor:18.04