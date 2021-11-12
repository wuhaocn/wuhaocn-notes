---
title: 镜像的导出和导入

categories:
- devops

tag:
- docker
---

## 1. 镜像的导出和导入
### 1.1.镜像的保存
```java
[root@k8s-master ~]# docker images
REPOSITORY                                        TAG                 IMAGE ID            CREATED             SIZE
nginx                                             latest              ae513a47849c        2 months ago        109MB
debian                                            jessie              4eb8376dc2a3        2 months ago        127MB
rabbitmq                                          3.6.8               8cdcbee37f62        15 months ago       179MB

[root@k8s-master tmp]# docker save ae513a47849c > nginx-save.tar
[root@k8s-master tmp]# ls -lh
total 108M
-rw-r--r-- 1 root root 108M Jul  4 09:32 nginx-save.tar
```
另一种写法
```java
docker save -o nginx-save.tar ae513a47849c
```


### 1.2.镜像的导入
可以将导出的nginx-save.tar包传到需要的docker主机上面，然后执行导入命令.
```java
[root@k8s-master tmp]# ls -lh
total 108M
-rw-r--r-- 1 root root 108M Jul  4 09:32 nginx-save.tar
[root@k8s-master tmp]# docker load < nginx-save.tar 
82b81d779f83: Loading layer [==================================================>]  54.21MB/54.21MB
7ab428981537: Loading layer [==================================================>]  3.584kB/3.584kB
Loaded image ID: sha256:ae513a47849c895a155ddfb868d6ba247f60240ec8495482eca74c4a2c13a881
```
另一种种写法：
```java
docker load -i nginx-save.tar
```


## 2.容器的导出和导入
### 2.1.容器的导出
```java
[root@k8s-master tmp]# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
220aee82cfea        tomcat:7            "catalina.sh run"   9 seconds ago       Up 7 seconds        8080/tcp            tomcat7
docker export -o mysql-`date +%Y%m%d`.tar 220aee82cfea
```
### 2.2.容器的导入
```java
docker import  my_ubuntu_v3.tar runoob/ubuntu:v4  
```


镜像和容器 导出和导入的区别:

- 镜像导入 是复制的过程
- 容器导入 是将当前容器 变成一个新的镜像

save 和 export区别：

- save 保存镜像所有的信息-包含历史
- export 只导出当前的信息
