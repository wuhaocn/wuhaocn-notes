docker stop monitor-test
docker rm monitor-test
docker run --name monitor-test --privileged=true  -p 13000:3000 -p 18500:8500  -p 19090:9090 -itd wuhaocn/monitor:1.0.0

docker commit 81a82e9b5ac2 wuhaocn/monitor:1.0.0

docker tag wuhaocn/monitor:1.0.0 wuhaocn/monitor:1.0.0

docker push wuhaocn/monitor:1.0.0
