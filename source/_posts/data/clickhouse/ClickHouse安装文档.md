## 1.系统要求
ClickHouse可以在任何具有x86_64，AArch64或PowerPC64LE CPU架构的Linux，FreeBSD或Mac OS X上运行。
```java
grep -q sse4_2 /proc/cpuinfo && echo "SSE 4.2 supported" || echo "SSE 4.2 not supported"
```
## 2.系统结构

![](https://cdn.nlark.com/yuque/0/2022/jpeg/804884/1658143515241-a523d62b-3af6-4633-916c-3fc65dd948a1.jpeg)
## 3.安装
### 3.1 单机安装
#### 3.1.1 yum安装
```java
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://packages.clickhouse.com/rpm/clickhouse.repo
sudo yum install -y clickhouse-server clickhouse-client

sudo /etc/init.d/clickhouse-server start
clickhouse-client # or "clickhouse-client --password" if you set up a password.
```
#### 3.1.2 tar安装
```java
LATEST_VERSION=$(curl -s https://packages.clickhouse.com/tgz/stable/ | \
    grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort -V -r | head -n 1)
export LATEST_VERSION

case $(uname -m) in
  x86_64) ARCH=amd64 ;;
  aarch64) ARCH=arm64 ;;
  *) echo "Unknown architecture $(uname -m)"; exit 1 ;;
esac

for PKG in clickhouse-common-static clickhouse-common-static-dbg clickhouse-server clickhouse-client
do
  curl -fO "https://packages.clickhouse.com/tgz/stable/$PKG-$LATEST_VERSION-${ARCH}.tgz" \
    || curl -fO "https://packages.clickhouse.com/tgz/stable/$PKG-$LATEST_VERSION.tgz"
done

exit 0

tar -xzvf "clickhouse-common-static-$LATEST_VERSION-${ARCH}.tgz" \
  || tar -xzvf "clickhouse-common-static-$LATEST_VERSION.tgz"
sudo "clickhouse-common-static-$LATEST_VERSION/install/doinst.sh"

tar -xzvf "clickhouse-common-static-dbg-$LATEST_VERSION-${ARCH}.tgz" \
  || tar -xzvf "clickhouse-common-static-dbg-$LATEST_VERSION.tgz"
sudo "clickhouse-common-static-dbg-$LATEST_VERSION/install/doinst.sh"

tar -xzvf "clickhouse-server-$LATEST_VERSION-${ARCH}.tgz" \
  || tar -xzvf "clickhouse-server-$LATEST_VERSION.tgz"
sudo "clickhouse-server-$LATEST_VERSION/install/doinst.sh"
sudo /etc/init.d/clickhouse-server start

tar -xzvf "clickhouse-client-$LATEST_VERSION-${ARCH}.tgz" \
  || tar -xzvf "clickhouse-client-$LATEST_VERSION.tgz"
sudo "clickhouse-client-$LATEST_VERSION/install/doinst.sh"
```
#### 3.1.3.配置

- 外网访问
- 用户名密码
### 3.2 集群安装
#### 3.2.1 zookeeper安装

- 注线上需采用非docker安装
```java
docker stop zookeeper
docker rm zookeeper
docker run --privileged=true -d --name zookeeper --publish 2181:2181  -d zookeeper:3.5
docker update zookeeper --restart=always
```

- 配置 zkEnv.sh
```
 ##zkEnv.sh 文件配置
 ZOO_LOG4J_PROP="ERROR,CONSOLE"
```

- 配置zoo.cfg
```
## 配置自动清理
autopurge.purgeInterval 这个参数指定了清理频率，单位是小时，需要填写一个1或更大的整数，默认是0，表示不开启自己清理功能。
autopurge.snapRetainCount 这个参数和上面的参数搭配使用，这个参数指定了需要保留的文件数目。默认是保留3个。

autopurge.snapRetainCount=20  
autopurge.purgeInterval=48 
```
#### 3.2.2 clickhouse安装
```java
# 下载安装
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://packages.clickhouse.com/rpm/clickhouse.repo
sudo yum install -y clickhouse-server clickhouse-client

# 关闭防火墙
systemctl stop firewalld.service
systemctl status firewalld.service

```
#### 3.2.3 集群配置
| 机器 | 分片 | 副本 |  |
| --- | --- | --- | --- |
| 10.41.1.199 | 1 | 1 |  |
| 10.41.0.114 | 1 | 2 |  |
| 10.41.0.158 | 2 | 1 |  |

- user.xml(配置用户)
   - [users.xml](https://rongcloud.yuque.com/attachments/yuque/0/2022/xml/804884/1660557438970-43a7148e-419e-4a72-9aea-a3cfaac189c2.xml?_lake_card=%7B%22src%22%3A%22https%3A%2F%2Frongcloud.yuque.com%2Fattachments%2Fyuque%2F0%2F2022%2Fxml%2F804884%2F1660557438970-43a7148e-419e-4a72-9aea-a3cfaac189c2.xml%22%2C%22name%22%3A%22users.xml%22%2C%22size%22%3A1090%2C%22type%22%3A%22text%2Fxml%22%2C%22ext%22%3A%22xml%22%2C%22source%22%3A%22%22%2C%22status%22%3A%22done%22%2C%22mode%22%3A%22title%22%2C%22download%22%3Afalse%2C%22taskId%22%3A%22u56456c13-9a55-4485-9ebf-e2ccc2bef2b%22%2C%22taskType%22%3A%22transfer%22%2C%22id%22%3A%22ucbffb4d4%22%2C%22card%22%3A%22file%22%7D)
- config.xml(配置集群)
   - [114-config.xml](https://rongcloud.yuque.com/attachments/yuque/0/2022/xml/804884/1660557439105-357df00d-27fb-4b38-ab8f-c9204eb3ecd0.xml?_lake_card=%7B%22src%22%3A%22https%3A%2F%2Frongcloud.yuque.com%2Fattachments%2Fyuque%2F0%2F2022%2Fxml%2F804884%2F1660557439105-357df00d-27fb-4b38-ab8f-c9204eb3ecd0.xml%22%2C%22name%22%3A%22114-config.xml%22%2C%22size%22%3A10843%2C%22type%22%3A%22text%2Fxml%22%2C%22ext%22%3A%22xml%22%2C%22source%22%3A%22%22%2C%22status%22%3A%22done%22%2C%22mode%22%3A%22title%22%2C%22download%22%3Afalse%2C%22taskId%22%3A%22uc4417792-d24a-4206-94f5-14dd7b844a0%22%2C%22taskType%22%3A%22transfer%22%2C%22id%22%3A%22u70813c3e%22%2C%22card%22%3A%22file%22%7D)[158-config.xml](https://rongcloud.yuque.com/attachments/yuque/0/2022/xml/804884/1660557439217-2a2aa1f8-e2d4-4611-b791-fad2f542feb5.xml?_lake_card=%7B%22src%22%3A%22https%3A%2F%2Frongcloud.yuque.com%2Fattachments%2Fyuque%2F0%2F2022%2Fxml%2F804884%2F1660557439217-2a2aa1f8-e2d4-4611-b791-fad2f542feb5.xml%22%2C%22name%22%3A%22158-config.xml%22%2C%22size%22%3A10843%2C%22type%22%3A%22text%2Fxml%22%2C%22ext%22%3A%22xml%22%2C%22source%22%3A%22%22%2C%22status%22%3A%22done%22%2C%22mode%22%3A%22title%22%2C%22download%22%3Afalse%2C%22taskId%22%3A%22u4c98aa2a-eba6-4726-878f-d0ae9bee9ac%22%2C%22taskType%22%3A%22transfer%22%2C%22id%22%3A%22u6b82e008%22%2C%22card%22%3A%22file%22%7D)[199-config.xml](https://rongcloud.yuque.com/attachments/yuque/0/2022/xml/804884/1660557439323-8fbbb35c-e466-4703-a214-a8719a9dd90b.xml?_lake_card=%7B%22src%22%3A%22https%3A%2F%2Frongcloud.yuque.com%2Fattachments%2Fyuque%2F0%2F2022%2Fxml%2F804884%2F1660557439323-8fbbb35c-e466-4703-a214-a8719a9dd90b.xml%22%2C%22name%22%3A%22199-config.xml%22%2C%22size%22%3A10843%2C%22type%22%3A%22text%2Fxml%22%2C%22ext%22%3A%22xml%22%2C%22source%22%3A%22%22%2C%22status%22%3A%22done%22%2C%22mode%22%3A%22title%22%2C%22download%22%3Afalse%2C%22taskId%22%3A%22u3903b64a-2051-457b-b841-0b1122a070d%22%2C%22taskType%22%3A%22transfer%22%2C%22id%22%3A%22u45a9c066%22%2C%22card%22%3A%22file%22%7D)
- 修改存储路径
```
#先停库
systemctl stop clickhouse-server.service 

mkdir /data1/clickhouse/
chown -R clickhouse:clickhouse /data1/clickhouse/
yes | cp -rf /var/lib/clickhouse /data1/clickhouse/

systemctl restart clickhouse-server.service 

systemctl status clickhouse-server.service 

# 备注 采用 service  clickhouse-server stop/restart 可能出错

```

- 需修改的配置
```
<!-- 删除较大的数据 -->
<max_table_size_to_drop>0</max_table_size_to_drop>

<!-- 插入限制 -->
<merge_tree>
  <parts_to_delay_insert>600</parts_to_delay_insert>
  <parts_to_throw_insert>600</parts_to_throw_insert>
  <max_delay_to_insert>2</max_delay_to_insert>
  <max_suspicious_broken_parts>5</max_suspicious_broken_parts>
</merge_tree>


```
### 3.3.操作台

- 数据库
   - 使用mysql5.7,创建数据库：clickvisual
```java
docker stop mysql3336
docker rm mysql3336
docker run --privileged=true --name mysql3336 -p 3336:3306 -e MYSQL_ROOT_PASSWORD=root -d mysql:5.7.19
docker update mysql3336 --restart=always


```

- 应用
```java
wget https://github.com/clickvisual/clickvisual/releases/download/v0.3.2-rc1/clickvisual-v0.3.2-rc1-linux-amd64.tar.gz

tar -xzvf clickvisual-v0.3.2-rc1-linux-amd64.tar.gz
```

- 修改配置
```java
dsn = "root:root@tcp(127.0.0.1:3336)/clickvisual?charset=utf8mb4&collation=utf8mb4_general_ci&parseTime=True&loc=Local&readTimeout=1s&timeout=1s&writeTimeout=3s"
rootURL = "http://localhost:19001"
    
```
       [https://clickvisual.gocn.vip/clickvisual/02install/install-introduce.html](https://clickvisual.gocn.vip/clickvisual/02install/install-introduce.html)

## 5.使用
### 5.1 本地表测试
```java
CREATE DATABASE IF NOT EXISTS devloglocal


CREATE TABLE IF NOT EXISTS devloglocal.applog
(

    `timestamp` DateTime,
    `observedTimestamp` DateTime,
    `traceId` String,
    `spanId` String,
    `severityText` String,
    `severityNumber` Int32,
    `instrumentationScope` String,
    `body` String,
    `resource_names` Array(String),
    `resource_values` Array(String),
    `attribute_names` Array(String),
    `attribute_values` Array(String)
)
ENGINE = MergeTree
PARTITION BY timestamp
ORDER BY timestamp
SETTINGS index_granularity = 8192;


INSERT INTO devloglocal.applog
(`timestamp`, observedTimestamp, traceId, spanId, severityText, severityNumber, instrumentationScope, body, resource_names, resource_values, attribute_names, attribute_values)
VALUES(1658217082, 1658217082, '3232', '3232', 'INFO ', 9, 'org.example.logdemo.LogTest', ' test', ['instance','service','namespace','region'], ['10.3.12.55','app','biz','idc'], ['app','session'], ['3232','32']);


SELECT * FROM  devloglocal.applog limit 0, 10
```
### 5.2 集群测试
```java
CREATE DATABASE IF NOT EXISTS devlog on cluster enic_cluster

DROP DATABASE devloglocal on cluster enic_cluster

CREATE TABLE IF NOT EXISTS devlog.applogrep on cluster enic_cluster
(

    `timestamp` DateTime,
    `observedTimestamp` DateTime,
    `traceId` String,
    `spanId` String,
    `severityText` String,
    `severityNumber` Int32,
    `instrumentationScope` String,
    `body` String,
    `resource_names` Array(String),
    `resource_values` Array(String),
    `attribute_names` Array(String),
    `attribute_values` Array(String)
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/devlog/applogrep', '{replica}')
PARTITION BY timestamp
ORDER BY timestamp
SETTINGS index_granularity = 8192;

create table devlog.applogrep_cluster on cluster enic_cluster
(
    `timestamp` DateTime,
    `observedTimestamp` DateTime,
    `traceId` String,
    `spanId` String,
    `severityText` String,
    `severityNumber` Int32,
    `instrumentationScope` String,
    `body` String,
    `resource_names` Array(String),
    `resource_values` Array(String),
    `attribute_names` Array(String),
    `attribute_values` Array(String)
)engine = Distributed(enic_cluster, devlog, applogrep, hiveHash(traceId));

SELECT `timestamp`, observedTimestamp, traceId, spanId, severityText, severityNumber, instrumentationScope, body, resource_names, resource_values, attribute_names, attribute_values
FROM devlog.applogrep_cluster;
```
### 5.3 其他命令
```java
create table devlog.applog_cluster on cluster enic_cluster
(
    `timestamp` DateTime,
    `observedTimestamp` DateTime,
    `traceId` String,
    `spanId` String,
    `severityText` String,
    `severityNumber` Int32,
    `instrumentationScope` String,
    `body` String,
    `resource_names` Array(String),
    `resource_values` Array(String),
    `attribute_names` Array(String),
    `attribute_values` Array(String)
)engine = Distributed(enic_cluster, devlog, applog, hiveHash(traceId));

Distributed(集群名称,库名,本地表名,分片键)
    
show tables;




SELECT COUNT(*)  FROM devlog.applog_cluster;


select * from system.clusters
```
## 6.官方文档

- [https://clickhouse.com/docs/zh/getting-started/install/](https://clickhouse.com/docs/zh/getting-started/install/)
