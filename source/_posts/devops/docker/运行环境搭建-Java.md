---
title: 一体化环境搭建

categories:
- devops

tag:
- docker
- java
---



## 基础 jar

```
docker stop japp
docker rm japp
docker run --name japp --privileged=true -p 3337:3306 -e MYSQL_ROOT_PASSWORD=coral@2018 -d mysql:5.7.19
```

## 安装扩展 java redis

```
apt-key del 5072E1F5
apt-get update
apt-key adv --keyserver keyserver.ubuntu.com --recv 8C718D3B5072E1F5
apt-get update
ls
cd /root
ls
cd jdk1.8.0_251/
ls
cd ..
vim /etc/profile
apt-get install vim
vim /etc/profile
source /etc/profile
java -v
java -version
apt-get install redis-server
ls
```


## 打包推送

```
docker commit e9c1ad83b80a wuhaocn/javaapp:8

docker tag wuhaocn/javaapp:8 wuhaocn/javaapp:8

docker push wuhaocn/javaapp:8
```


## 运行
```
docker stop japp
docker rm japp
docker run --name japp --privileged=true -p 3337:3306 16379:6379 -d wuhaocn/javaapp:8
```