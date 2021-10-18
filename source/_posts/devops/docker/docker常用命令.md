---
title: docker常用命令

categories:
- devops

tag:
- docker
---
## 组合命令
* 模糊删除镜像
```
docker rmi --force `docker images | grep java | awk '{print $3}'`
```

* 删除停止容器

```
docker rm `docker ps -a -q`
```

* 停止/启动容器

```
docker start $(docker ps -a | awk '{ print $1}' | tail -n +2)
docker stop $(docker ps -a  | awk '{ print $1}' | tail -n +2)
```

* 提交容器

```

docker commit 81a82e9b5ac2 wuhaocn/java-im:8

docker tag wuhaocn/java-im:8 wuhaocn/java-im:8

docker push wuhaocn/java-im:8

```

## 常用命令

### 容器生命周期管理

* run

```
运行容器
docker run -p 80:80 -v /data:/data -d nginx:latest 
```

* start/stop/restart

```

启动/停止/重启容器
docker start myrunoob

```

* kill

```

杀死容器
docker kill -s KILL myrunoob

```
* rm

```

删除容器
docker rm -f myrunoob1 myrunoob2

```

* pause/unpause

```
暂停数据库容器myrunoob提供服务
docker pause myrunoob
```

* create

```
使用docker镜像nginx:latest创建一个容器,并将容器命名为myrunoob
docker create  --name myrunoob  nginx:latest 
```

* exec

```
通过 exec 命令对指定的容器执行 bash:
docker exec -it 9df70f9a0714 /bin/bash
```
### 容器操作

* ps

```
列出容器
runoob@runoob:~$ docker ps
CONTAINER ID   IMAGE          COMMAND                ...  PORTS                    NAMES
09b93464c2f7   nginx:latest   "nginx -g 'daemon off" ...  80/tcp, 443/tcp          myrunoob

```
* inspect

```
获取镜像mysql:5.6的元信息。
docker inspect mysql:5.6
```

* top
```
查看容器mymysql的进程信息。
docker top mymysql
查看所有运行容器的进程信息。
for i in  `docker ps |grep Up|awk '{print $1}'`;do echo \ &&docker top $i; done
```

* attach
```
容器mynginx将访问日志指到标准输出，连接到容器查看访问信息。
docker attach --sig-proxy=false mynginx
```

* events

```
显示docker 2016年7月1日后的所有事件。
docker events  --since="1467302400"
显示docker 镜像为mysql:5.6 2016年7月1日后的相关事件。
docker events -f "image"="mysql:5.6" --since="1467302400" 
```

* logs

```
跟踪查看容器mynginx的日志输出。
docker logs -f mynginx
查看容器mynginx从2016年7月1日后的最新10条日志。
docker logs --since="2016-07-01" --tail=10 mynginx

```
* wait

```
docker wait : 阻塞运行直到容器停止，然后打印出它的退出代码。

docker wait CONTAINER

```

* export

```
将id为a404c6c174a2的容器按日期保存为tar文件。

runoob@runoob:~$ docker export -o mysql-`date +%Y%m%d`.tar a404c6c174a2
runoob@runoob:~$ ls mysql-`date +%Y%m%d`.tar
mysql-20160711.tar
```

* port

```
查看容器mynginx的端口映射情况。

docker port mymysql
3306/tcp -> 0.0.0.0:3306

```
### 容器rootfs命令
* commit
```
将容器a404c6c174a2 保存为新的镜像,并添加提交人信息和说明信息。
docker commit -a "runoob.com" -m "my apache" a404c6c174a2  mymysql:v1
简化参考
docker commit faa474c052c6 java-sctp:8
```

* cp

```
将主机/www/runoob目录拷贝到容器96f7f14e99ab的/www目录下。

docker cp /www/runoob 96f7f14e99ab:/www/
```

* diff

```
查看容器mymysql的文件结构更改。

runoob@runoob:~$ docker diff mymysql
A /logs
A /mysql_data
C /run
C /run/mysqld
A /run/mysqld/mysqld.pid
A /run/mysqld/mysqld.sock
C /tmp

```
### 镜像仓库

* login
```
登陆到Docker Hub

docker login -u 用户名 -p 密码
```

* pull
```
从Docker Hub下载java最新版镜像。

docker pull java
```

* push

```
上传本地镜像myapache:v1到镜像仓库中。

docker push myapache:v1
```

* search

```
从 Docker Hub 查找所有镜像名包含 java，并且收藏数大于 10 的镜像

docker search -f stars=10 java

```

### 本地镜像管理

* images
```
查看本地镜像列表。

runoob@runoob:~$ docker images
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
mymysql                 v1                  37af1236adef        5 minutes ago       329 MB
```

* rmi

```
强制删除本地镜像 runoob/ubuntu:v4。    

docker rmi -f runoob/ubuntu:v4
Untagged: runoob/ubuntu:v4
```

* tag

```
将镜像ubuntu:15.10标记为 runoob/ubuntu:v3 镜像。

docker tag ubuntu:15.10 runoob/ubuntu:v3
```

* build

```
使用当前目录的 Dockerfile 创建镜像，标签为 runoob/ubuntu:v1。

docker build -t runoob/ubuntu:v1 . 
```

* history

```
查看本地镜像runoob/ubuntu:v3的创建历史。

root@runoob:~# docker history runoob/ubuntu:v3
IMAGE             CREATED           CREATED BY                                      SIZE      COMMENT
4e3b13c8a266      3 months ago      /bin/sh -c #(nop) CMD ["/bin/bash"]             0 B                 
<missing>         3 months ago      /bin/sh -c sed -i 's/^#\s*\(deb.*universe\)$/   1.863 kB            
<missing>         3 months ago      /bin/sh -c set -xe   && echo '#!/bin/sh' > /u   701 B               
<missing>         3 months ago      /bin/sh -c #(nop) ADD file:43cb048516c6b80f22   136.3 MB
```

* save

```
将镜像 runoob/ubuntu:v3 生成 my_ubuntu_v3.tar 文档

runoob@runoob:~$ docker save -o my_ubuntu_v3.tar runoob/ubuntu:v3
runoob@runoob:~$ ll my_ubuntu_v3.tar
-rw------- 1 runoob runoob 142102016 Jul 11 01:37 my_ubuntu_v3.ta

```

* load

```
导入镜像：
$ docker load < busybox.tar.gz
Loaded image: busybox:latest
```

* import

```
A:export/import 是根据容器来导出镜像（因此没有镜像的历史记录）而 save/load 操作的对象是镜像
B:export/import 镜像的历史记录再导后无法进行回滚操作，而save/load镜像有完整的历史记录可以回滚
docker import : 从归档文件中创建镜像。
docker import  my_ubuntu_v3.tar runoob/ubuntu:v4  
```

### 系统信息

* info

```
$ docker info
Containers: 12
Images: 41
Storage Driver: aufs
 Root Dir: /var/lib/docker/aufs
 Backing Filesystem: extfs
 Dirs: 66
 Dirperm1 Supported: false
Execution Driver: native-0.2
Logging Driver: json-file
Kernel Version: 3.13.0-32-generic
Operating System: Ubuntu 14.04.1 LTS
CPUs: 1
Total Memory: 1.954 GiB
Name: iZ23mtq8bs1Z
ID: M5N4:K6WN:PUNC:73ZN:AONJ:AUHL:KSYH:2JPI:CH3K:O4MK:6OCX:5OYW
```

* version

```
显示 Docker 版本信息。

$ docker version
Client:
 Version:      1.8.2
 API version:  1.20
 Go version:   go1.4.2
 Git commit:   0a8c2e3
 Built:        Thu Sep 10 19:19:00 UTC 2015
 OS/Arch:      linux/amd64
Server:
 Version:      1.8.2
 API version:  1.20
 Go version:   go1.4.2
 Git commit:   0a8c2e3
 Built:        Thu Sep 10 19:19:00 UTC 2015
 OS/Arch:      linux/amd64
```