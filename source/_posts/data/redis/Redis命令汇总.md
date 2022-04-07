---
title: Redis命令汇总

categories:
- redis

tag:
- redis
---

## 1.Key（键）

命令                           | 描述            | 示例                            |  备注
------------                  |--------------   |----------                      |  -----
DEL                           |                 |                                |     
DUMP                          |                 |                                |
EXISTS                          |                 |                                |
EXPIRE                          |                 |                                |
EXPIREAT                          |                 |                                |
KEYS                          |                 |                                |
MIGRATE                          |                 |                                |
MOVE                          |                 |                                |
OBJECT                          |                 |                                |
PERSIST                          |                 |                                |
PEXPIRE
PEXPIREAT                          |                 |                                |     
PTTL                          |                 |                                |     
RANDOMKEY                          |                 |                                |     
RENAME                          |                 |                                |     
RENAMENX                          |                 |                                |     
RESTORE                          |                 |                                |     
SORT                          |                 |                                |     
TTL                          |                 |                                |     
TYPE                          |                 |                                |     
SCAN                          |                 |                                |

## 2.String(字符串)

命令                           | 描述            | 示例                            |  备注
------------                  |--------------   |----------                      |  -----
APPEND                         |                 |                                |
BITCOUNT                         |                 |                                |
BITOP                         |                 |                                |
DECR                         |                 |                                |
DECRBY                         |                 |                                |
GET                         |                 |                                |
GETBIT                         |                 |                                |
GETRANGE                         |                 |                                |
GETSET                         |                 |                                |
INCR                         |                 |                                |
INCRBY                         |                 |                                |
INCRBYFLOAT                         |                 |                                |
MGET                         |                 |                                |
MSET                         |                 |                                |
MSETNX                         |                 |                                |
PSETEX                         |                 |                                |
SET                         |                 |                                |
SETBIT                         |                 |                                |
SETEX                         |                 |                                |
SETNX                         |                 |                                |
SETRANGE                         |                 |                                |
STRLEN                         |                 |                                |

## 3.Hash(哈希表)

命令                           | 描述            | 示例                            |  备注
------------                  |--------------   |----------                      |  -----
HDEL                         |                 |                                |
HEXISTS                         |                 |                                |
HGET                         |                 |                                |
HGETALL                         |                 |                                |
HINCRBY                         |                 |                                |
HINCRBYFLOAT                         |                 |                                |
HKEYS                         |                 |                                |
HLEN                         |                 |                                |
HMGET                         |                 |                                |
HMSET                         |                 |                                |
HSET                         |                 |                                |
HSETNX                         |                 |                                |
HVALS                         |                 |                                |
HSCAN                         |                 |                                |

## 4.List（列表）

命令                           | 描述            | 示例                            |  备注
------------                  |--------------   |----------                      |  -----
BLPOP                        |                 |                                |
BRPOP                        |                 |                                |
BRPOPLPUSH                        |                 |                                |
LINDEX                        |                 |                                |
LINSERT                        |                 |                                |
LLEN                        |                 |                                |
LPOP                        |                 |                                |
LPUSH                        |                 |                                |
LPUSHX                        |                 |                                |
LRANGE                        |                 |                                |
LREM                        |                 |                                |
LSET                        |                 |                                |
LTRIM                        |                 |                                |
RPOP                        |                 |                                |
RPOPLPUSH                        |                 |                                |
RPUSH                        |                 |                                |
RPUSHX                        |                 |                                |

## 5.Set（集合）

命令                           | 描述            | 示例                            |  备注
------------                  |--------------   |----------                      |  -----
SADD                        |                 |                                |
SCARD                        |                 |                                |
SDIFF                        |                 |                                |
SDIFFSTORE                        |                 |                                |
SINTER                        |                 |                                |
SINTERSTORE                        |                 |                                |
SISMEMBER                        |                 |                                |
SMEMBERS                        |                 |                                |
SMOVE                        |                 |                                |
SPOP                        |                 |                                |
SRANDMEMBER                        |                 |                                |
SREM                        |                 |                                |
SUNION                        |                 |                                |
SUNIONSTORE                        |                 |                                |
SSCAN                        |                 |                                |

## 6.SortedSet（有序集合）

命令                           | 描述                       | 示例                            |  备注
------------                  |-----------------          |----------                      |  -----
ZADD                          |                           |                                |
ZCARD                         |                 |                                |
ZCOUNT                        |                 |                                |
ZINCRBY                       |                             |                                |
ZRANGE                        | 有序集合按(索引)score递增(小—>大) | ZRANGE salary 1 2 WITHSCORES                  | ZRANGE key start stop [WITHSCORES]
ZRANGEBYSCORE                 | 有序集合按(分数)score递增(小->大) | ZRANGEBYSCORE salary -inf +inf WITHSCORES     | ZRANGEBYSCORE key min max [WITHSCORES] [LIMIT offset count]
ZRANK                         | 有序集合中member排名(小-大)      | ZRANK salary tom   (0开始计数)                 | ZRANK key member
ZREM                          |                 |                                |
ZREMRANGEBYRANK               |                 |                                |
ZREMRANGEBYSCORE              |                 |                                |
ZREVRANGE                     |                 |                                |
ZREVRANGEBYSCORE              | 有序集合按score递减(大->小) | ZREVRANGEBYSCORE salary 10000 2000            | ZREVRANGEBYSCORE key max min [WITHSCORES] [LIMIT offset count]
ZREVRANK                      |                 |                                |
ZSCORE                        |                 |                                |
ZUNIONSTORE                   |                 |                                |
ZINTERSTORE                   |                 |                                |
ZSCAN                         |                 |                                |

## 7.Pub/Sub（发布/订阅）

命令                           | 描述            | 示例                            |  备注
------------                  |--------------   |----------                      |  -----
PSUBSCRIBE                    |                 |                                |
PUBLISH                    |                 |                                |
PUBSUB                    |                 |                                |
PUNSUBSCRIBE                    |                 |                                |
SUBSCRIBE                    |                 |                                |
UNSUBSCRIBE                    |                 |                                |

## 8.Transaction（事务）

命令                           | 描述            | 示例                            |  备注
------------                  |--------------   |----------                      |  -----
DISCARD                    |                 |                                |
EXEC                    |                 |                                |
MULTI                    |                 |                                |
UNWATCH                    |                 |                                |
WATCH                    |                 |                                |

## 9.Script（脚本）

命令                           | 描述            | 示例                            |  备注
------------                  |--------------   |----------                      |  -----
EVAL                          |                 |                                |
EVALSHA                       |                 |                                |
SCRIPT EXISTS                 |                 |                                |
SCRIPT FLUSH                  |                 |                                |
SCRIPT KILL                   |                 |                                |
SCRIPT LOAD                   |                 |                                |
## 10.Connection（连接）

命令                           | 描述            | 示例                            |  备注
------------                  |--------------   |----------                      |  -----
AUTH                   |                 |                                |
ECHO                   |                 |                                |
PING                   |                 |                                |
QUIT                   |                 |                                |
SELECT                   |                 |                                |

## 11.Server（服务器）

命令                           | 描述            | 示例                            |  备注
------------                  |--------------   |----------                      |  -----
BGREWRITEAOF                    |                 |                                |
BGSAVE                    |                 |                                |
CLIENT GETNAME                    |                 |                                |
CLIENT KILL                    |                 |                                |
CLIENT LIST                    |                 |                                |
CLIENT SETNAME                    |                 |                                |
CONFIG GET                    |                 |                                |
CONFIG RESETSTAT                    |                 |                                |
CONFIG REWRITE                    |                 |                                |
CONFIG SET                    |                 |                                |
DBSIZE                    |                 |                                |
DEBUG OBJECT                    |                 |                                |
DEBUG SEGFAULT                    |                 |                                |
FLUSHALL                    |                 |                                |
FLUSHDB                    |                 |                                |
INFO                    |                 |                                |
LASTSAVE                    |                 |                                |
MONITOR                    |                 |                                |
PSYNC                    |                 |                                |
SAVE                    |                 |                                |
SHUTDOWN                    |                 |                                |
SLAVEOF                    |                 |                                |
SLOWLOG                    |                 |                                |
SYNC                    |                 |                                |
TIME                      |                 |                                |

## 12.Cluster(集群)
命令                           | 描述            | 示例                            |  备注
------------                  |--------------   |----------                      |  -----
CLUSTER HELP                  | 支持命令及描述     |  CLUSTER HELP                  |   
CLUSTER ADDSLOTS              | 为当前节点分配槽位  | CLUSTER ADDSLOTS 0 5          |
CLUSTER BUMPEPOCH             | 推进集群配置纪元    | CLUSTER BUMPEPOCH             |
CLUSTER COUNT-failure-reports | 返回的失败报告数量  | CLUSTER COUNT-failure-reports node-id |
CLUSTER COUNTKEYSINSLOT       | 返回<槽位>中的键数  |  CLUSTER COUNTKEYSINSLOT 1    |  
CLUSTER DELSLOTS              | 删除当前节点的槽位信息| CLUSTER DELSLOTS 2 5        |
CLUSTER FAILOVER              | 集群故障转移       | CLUSTER FAILOVER             |
CLUSTER FORGET                | 删除节点          | CLUSTER FORGET node-id      |
CLUSTER GETKEYSINSLOT         | 返回当前节点存储在slot中的键名 |  CLUSTER GETKEYSINSLOT 1000 3 |
CLUSTER FLUSHSLOTS            | 删除当前节点自己的槽位信息     | CLUSTER FLUSHSLOTS |
CLUSTER INFO                  | 返回集群信息                | CLUSTER INFO    |
CLUSTER KEYSLOT               | 返回的哈希槽                | CLUSTER KEYSLOT 1 |
CLUSTER MEET                  | 将节点连接到一个工作集群       | CLUSTER MEET 10.3.4.111 7001 |
CLUSTER MYID                  | 返回当前节点ID               | CLUSTER MYID   |
CLUSTER NODES                 | 返回集群节点信息              | CLUSTER NODES  |
CLUSTER REPLICATE             | 将当前节点配置为副本              | CLUSTER REPLICATE node-id |
CLUSTER RESET                 | 重置当前节点              | CLUSTER RESET   |
CLUSTER SETSLOT               | 修改接受节点中哈希槽的状态  | CLUSTER SETSLOT 1  MIGRATING node-id|
CLUSTER REPLICAS              | 返回节点REPLICAS         | CLUSTER REPLICAS node-id |
CLUSTER SET-CONFIG-EPOCH      | 修改接受节点中哈希槽的状态  | CLUSTER SET-CONFIG-EPOCH 1|
CLUSTER SLOTS                 | 返回节点槽位                | CLUSTER SLOTS     | 