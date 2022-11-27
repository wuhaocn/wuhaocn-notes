## 1.概述
### 1.1 概念说明

- 数据扩容：clickhouse分为分布式表和本地表，需统一使用分布式表
- 数据容灾：clickhouse具备分片和副本概念：根据业务需要创建分片和副本
- 数据过期：clickhouse创建数据表时需设置过期
- 索引：经常查询的字段需创建索引
- 查询：查询需携带时间范围，并且添加索引，如果不满足查询较慢
   - 至少差别几百倍（10亿条数据，携带索引为40-50毫秒，不带索引为5-6秒）
### 1.2 使用文档

- 携带索引
```
DROP  table  devlog.applogrep1 on cluster enic_cluster
DROP  table  devlog.applogrep_cluster1 on cluster enic_cluster
CREATE TABLE devlog.applogrep1 on cluster enic_cluster
(
    `timestamp` DateTime,
    `observedTimestamp` DateTime,
    `traceId` String,
    `spanId` String,
    `severityText` String,
    `severityNumber` Int32,
    `appKey` String,
    `instrumentationScope` String,
    `body` String,
    `resource_names` Array(String),
    `resource_values` Array(String),
    `attribute_names` Array(String),
    `attribute_values` Array(String),
     INDEX traceId_idx (traceId) TYPE minmax GRANULARITY 32,
     INDEX appKey_idx (appKey) TYPE minmax GRANULARITY 32
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/devlog/applogrep1', '{replica}')
PARTITION BY toYYYYMMDD(timestamp)
ORDER BY timestamp
TTL timestamp + INTERVAL 2 DAY
SETTINGS index_granularity = 8192;

create table devlog.applogrep_cluster1 on cluster enic_cluster
(
    `timestamp` DateTime,
    `observedTimestamp` DateTime,
    `traceId` String,
    `spanId` String,
    `appKey` String,
    `severityText` String,
    `severityNumber` Int32,
    `instrumentationScope` String,
    `body` String,
    `resource_names` Array(String),
    `resource_values` Array(String),
    `attribute_names` Array(String),
    `attribute_values` Array(String)
)engine = Distributed(enic_cluster, devlog, applogrep1, hiveHash(traceId));
```

- 不带索引
```
DROP DATABASE devlog on cluster enic_cluster
CREATE DATABASE IF NOT EXISTS devlog on cluster enic_cluster
DROP TABLE  devlog.applogrep on cluster enic_cluster
CREATE TABLE IF NOT EXISTS devlog.applogrep on cluster enic_cluster
(

    `timestamp` DateTime,
    `observedTimestamp` DateTime,
    `traceId` String,
    `spanId` String,
    `severityText` String,
    `severityNumber` Int32,
    `appKey` String,
    `instrumentationScope` String,
    `body` String,
    `resource_names` Array(String),
    `resource_values` Array(String),
    `attribute_names` Array(String),
    `attribute_values` Array(String)
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/devlog/applogrep', '{replica}')
PARTITION BY toYYYYMMDD(timestamp)
ORDER BY timestamp
TTL timestamp + INTERVAL 10 DAY
SETTINGS index_granularity = 8192;

DELETE TABLE  devlog.applogrep_cluster on cluster enic_cluster
create table devlog.applogrep_cluster on cluster enic_cluster
(
    `timestamp` DateTime,
    `observedTimestamp` DateTime,
    `traceId` String,
    `spanId` String,
    `appKey` String,
    `severityText` String,
    `severityNumber` Int32,
    `instrumentationScope` String,
    `body` String,
    `resource_names` Array(String),
    `resource_values` Array(String),
    `attribute_names` Array(String),
    `attribute_values` Array(String)
)engine = Distributed(enic_cluster, devlog, applogrep, hiveHash(traceId));

DELETE TABLE  devlog.applogrep_cluster on cluster enic_cluster

SELECT `timestamp`, observedTimestamp, traceId, spanId, severityText, severityNumber, instrumentationScope, body, resource_names, resource_values, attribute_names, attribute_values
FROM devlog.applogrep_cluster;
```
### 1.3 常见错误

- ZooKeeper differs in primary key
```
Clickhouse彻底删除表, drop表后重新创建报错，
Code: 342, Existing table metadata in ZooKeeper differs in primary key


解决方式：在zookeeper上删除表
# 进入zookeeper/bin，使用zkCli.sh脚本客户端登录zookeeper
./zkCli.sh -server 127.0.0.1:2181
# 删除clickhouse表节点, 老版本使用rmr删除
deleteall /clickhouse/${db_name}/tables/01/${table_name}
# 其中${db_name}为待删除表所在数据库名，${table_name}为待删除表名。可使用ls可查看其子节点
ls /clickhouse

```
## 2.查询语法

- 查询语法
```

SELECT `timestamp`, observedTimestamp, traceId, spanId, appKey, severityText, severityNumber, instrumentationScope, body, resource_names, resource_values, attribute_names, attribute_values
FROM devlog.applogrep_cluster1 WHERE timestamp > '2022-07-27 14:50:21' and timestamp < '2022-07-27 16:20:21' and traceId = '1658908701861' ;

```
