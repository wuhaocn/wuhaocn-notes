

docker commit 281bcc444fb0 wuhaocn/monitor:1.0.2
docker tag wuhaocn/monitor:1.0.2 wuhaocn/monitor:1.0.2
docker push wuhaocn/monitor:1.0.2

docker stop monitor-test
docker rm monitor-test
docker run --name monitor-test --privileged=true  -p 13000:3000 -p 18500:8500  -p 19090:9090 -itd wuhaocn/monitor:1.0.2 bash /monitor/start.sh




wget https://github.com/prometheus/node_exporter/releases/download/v1.3.0/node_exporter-1.3.0.darwin-amd64.tar.gz

http://127.0.0.1:9100/metrics



curl -X PUT -d '{"id": "nodeInfo","name": "nodeInfo","address": "10.3.1.226","port": 9100,"tags": ["dev"],"checks": [{"http": "http://10.3.1.226:9100/","interval": "5s"}]}'     http://localhost:18500/v1/agent/service/register

