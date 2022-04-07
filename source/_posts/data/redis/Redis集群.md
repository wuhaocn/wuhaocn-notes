---
title: RedisCluster介绍

categories:
- redis

tag:
- redis
---


### 一、基本定义

RedisCluster是Redis的集群实现，内置数据自动分片机制，集群内部将所有的key映射到16384个Slot中，
集群中的每个RedisInstance负责其中的一部分的Slot的读写。
集群客户端连接集群中任一Redis Instance即可发送命令，当RedisInstance收到自己不负责的Slot的请求时，
会将负责请求Key所在Slot的Redis Instance地址返回给客户端，客户端收到后自动将原请求重新发往这个地址，对外部透明。
一个Key到底属于哪个Slot由crc16(key)%16384决定。
关于负载均衡，集群的Redis Instance之间可以迁移数据，以Slot为单位，但不是自动的，需要外部命令触发。
关于集群成员管理，集群的节点(Redis Instance)和节点之间两两定期交换集群内节点信息并且更新，从发送节点的角度看，这些信息包括：集群内有哪些节点，
IP和PORT是什么，节点名字是什么，节点的状态(比如OK，PFAIL，FAIL，后面详述)是什么，包括节点角色(master或者slave)等。
关于可用性，集群由N组主从RedisInstance组成。主可以没有从，但是没有从意味着主宕机后主负责的Slot读写服务不可用。一个主可以有多个从，主宕机时，
某个从会被提升为主，具体哪个从被提升为主，协议类似于Raft，参见这里。如何检测主宕机？RedisCluster采用quorum+心跳的机制。
从节点的角度看，节点会定期给其他所有的节点发送Ping，cluster-node-timeout(可配置，秒级)时间内没有收到对方的回复，
则单方面认为对端节点宕机，将该节点标为PFAIL状态。通过节点之间交换信息收集到quorum个节点都认为这个节点为PFAIL，则将该节点标记为FAIL，
并且将其发送给其他所有节点，其他所有节点收到后立即认为该节点宕机。从这里可以看出，主宕机后，至少cluster-node-timeout时间内该主所负责的Slot的读写服务不可用。


### 二、集群搭建过程（3主3从）-手动

准备节点
配置节点后，启动单个节点，此时每个节点都是单独处在一个集群中
节点握手（假设 6379 与 6380 握手）
命令：cluster meet ip port
过程：
节点 6379 本地创建 6380 节点信息对象，并发送 meet 消息
节点 6380 接收到 meet 消息后，保存节点 6379 的节点信息并回复 pong 消息（此时握手成功）
之后节点 6379 和节点 6380 彼此定期通过 ping/pong 消息进行正常的节点通信
在 cluster 内的任一节点执行 cluster meet 命令加入新节点。握手状态会通过消息在集群内传播（gossip 协议），这样其他节点会自动发现新节点并发起握手流程
为主节点分配槽
命令：cluster addslots {0...5460}
注意：主节点尽量选择不同 IP
为主节点分配从节点
从节点作用：复制主节点 slot 信息和相关的数据；故障转移
命令：在从节点上执行 cluster replicate {master-nodeId}
尽可能保证主从节点不在同一个机器上

### 三、集群搭建过程（3 主 3 从）- 自动

第十二章 redis-cluster 搭建（redis-3.2.5）

### 四、节点通信

gossip 协议：节点之间彼此不断通信交换信息，一段时间后所有节点都会知道集群完整的信息。
通信过程：
cluster 中的每个 node 都会单独开辟一个 TCP 通道（通信端口号在基础端口号上加 10000，例如 16379），用于节点之间彼此通信
每个节点在固定周期内通过特定规则选择几个节点发送 ping 消息
接收到 ping 消息的节点用 pong 消息作为响应
### 五、请求路由

根据 key 计算 slot：计算一个 key 在哪个 slot 上，公式 slot=CRC16(key)&16383
根据 slot 查找 slot 所在节点：集群内每个节点都知道所有节点的 slot 信息（相当于节点的本地缓存），根据 slot 可以直接找出所在的 node
如果 slot 所在的节点正好是接受命令的当前节点，那么直接执行；如果不是，返回 MOVED slot ip port（之后客户端要再去连接该机器，再执行命令）
智能客户端：

客户端本地会缓存一份 hashmap<slot, node>，MOVED slot ip port 可以用来帮助缓存的刷新

### 参考

https://sq.163yun.com/blog/article/224981988104458240
