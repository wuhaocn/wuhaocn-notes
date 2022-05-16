## 1.镜像使用

### 1.1.镜像安装
docker stop monitor
docker rm monitor
docker run --name monitor --privileged=true -p 9090:9090  -p 3000:3000  -d wuhaocn/monitor:1.0

```
root@9852cf5a3339:/# cat /usr/local/prometheus/prometheus.yml 
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]

  - job_name: 'mapplication'
    metrics_path: /
    static_configs:
            - targets: ['192.168.3.41:8901']
```

### 1.2.容器配置

docker exec -it monitor bash

配置修改地址
*  /usr/local/grafana
```
root@f23762ac5af0:/usr/local/grafana/conf# ll
total 136
drwxr-xr-x 3 root root  4096 Mar 31 12:35 ./
drwxr-xr-x 1 root root  4096 Apr  7 02:09 ../
-rw-r--r-- 1 root root 56590 Mar 31 12:35 defaults.ini
-rw-r--r-- 1 root root  2270 Mar 31 12:35 ldap.toml
-rw-r--r-- 1 root root  1045 Mar 31 12:35 ldap_multiple.toml
drwxr-xr-x 7 root root  4096 Mar 31 12:35 provisioning/
-rw-r--r-- 1 root root 57840 Mar 31 12:35 sample.ini
```
* /usr/local/prometheus

```
root@f23762ac5af0:/usr/local/prometheus# ll
total 197396
drwxr-xr-x 4 root root      4096 Apr  7 02:09 ./
drwxr-xr-x 1 root root      4096 Apr  7 02:16 ../
-rw-r--r-- 1 root root      6148 Apr  7 01:46 .DS_Store
-rw-r--r-- 1 root root     11357 Mar 15 15:30 LICENSE
-rw-r--r-- 1 root root      3773 Mar 15 15:30 NOTICE
drwxr-xr-x 2 root root      4096 Mar 15 15:30 console_libraries/
drwxr-xr-x 2 root root      4096 Mar 15 15:30 consoles/
-rwxr-xr-x 1 root root 105137495 Mar 15 15:21 prometheus*
-rw-r--r-- 1 root root       934 Apr  6 06:11 prometheus.yml
-rwxr-xr-x 1 root root  96946761 Mar 15 15:23 promtool*
      
```

### 1.3 配置生效

修改后重启配置


## 2.镜像构建
### 2.1.基础镜像
docker stop ubuntu-test
docker rm ubuntu-test
docker run --name ubuntu-test --privileged=true   -itd ubuntu:18.04


### 2.2.prometheus + grafana

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
* prometheus.service
```

root@b0e746f65da8:/usr/local/grafana/bin# cat /etc/systemd/system/prometheus.service
[Unit]
Description=prometheus
After=network.target
[Service]
Type=simple
User=prometheus
ExecStart=/usr/local/prometheus/prometheus --config.file=/usr/local/prometheus/prometheus.yml --storage.tsdb.path=/home/data/prometheus/data
Restart=on-failure
[Install]
WantedBy=multi-user.target
```
* grafana.service
```
root@b0e746f65da8:/boot# cat /etc/systemd/system/grafana.service 
[Service]
ExecStart=/usr/local/grafana/bin/grafana-server --config=/usr/local/grafana/conf/defaults.ini  --homepath=/usr/local/grafana

[Install]
WantedBy=multi-user.target

[Unit]
Description=Grafana
After=network.target

```


