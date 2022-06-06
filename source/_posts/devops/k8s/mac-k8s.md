## mac安装k8s

安装k8s大致有2种方式，minikube和Docker Desktop上，本文采用后者，前者见minikube安装k8s

### 环境

一个小坑，原来本机已经安装docker 2.3.0，然后点击check for updates最高只检查到2.3.1，但是docker管网已经2.3.7，
以为大部分安装都参考https://github.com/gotok8s/k8s-docker-desktop-for-mac 里面k8s版本为1.18.8 
对应docker 2.3.6.0（如果不按照这个对应关系，则需要找docker对应的k8s的镜像的地址，github上提了issue等待反馈）

### 安装

#### 拉取k8s镜像

但是由于众所周知的原因, 国内的网络下不能很方便的下载 Kubernetes 集群所需要的镜像, 导致集群启用失败. 这里提供了一个简单的方法, 
利用 GitHub Actions 实现 k8s.gcr.io 上 kubernetes 依赖镜像自动同步到 Docker Hub 上指定的仓库中。 
通过 load_images.sh 将所需镜像从 Docker Hub 的同步仓库中取回，并重新打上原始的tag. 镜像对应关系文件可以查看: images.

```
第一步 克隆详细

git clone https://github.com/gotok8s/k8s-docker-desktop-for-mac.git

第二步 进入 k8s-docker-desktop-for-mac项目，拉取镜像

./load_images.sh

第三步 打开docker 配置页面，enable k8s。需要等k8s start一会

```

如果安装成功，则会显示kubernetes running

```
验证
$ kubectl cluster-info
$ kubectl get nodes
$ kubectl describe node

```


#### 安装 Kubernetes Dashboard

```
部署 Kubernetes Dashboard
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml
#开启本机访问代理
$ kubectl proxy

创建Dashboard管理员用户并用token登陆
# 创建 ServiceAccount kubernetes-dashboard-admin 并绑定集群管理员权限
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

# 获取登陆 token
$ kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep kubernetes-dashboard-admin | awk '{print $1}')

```


通过下面的连接访问 Dashboard: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

输入上一步获取的token, 验证并登陆。


作者：waterWang001
链接：https://www.jianshu.com/p/a6abdc6f76e1
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

