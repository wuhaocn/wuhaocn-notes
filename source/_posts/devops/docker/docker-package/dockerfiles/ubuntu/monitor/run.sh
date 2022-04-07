
docker stop monitor
docker rm monitor
docker run --name monitor --privileged=true -p 9090:9090  -p 3000:3000  -d wuhaocn/monitor:1.0


