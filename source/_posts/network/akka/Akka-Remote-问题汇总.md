---
title: Akka-Remote-问题汇总

categories:
- network

tag:
- akka

---

## 1.use-passive-connections bug


bug：[https://github.com/akka/akka/issues/24393](https://github.com/akka/akka/issues/24393)
​

```java
put("akka.remote.use-passive-connections", "on");
//这个改为100主要是为了提高问题复现概率
put("akka.remote.retry-gate-closed-for", 100);
```
 在双向链路通道时，由于采用连接复用会造成一端发送另外一端收不到
```java
put("akka.remote.use-passive-connections", "off");
```


相关错误日志
```java
0930 10:22:14,996:DeadLetter:13 message: Disassociated [akka.tcp://msg@10.3.1.241:1235] -> [akka.tcp://cmp@10.3.1.241:1238]
0930 10:22:15,181:DeadLetter:13 message: Associated [akka.tcp://msg@10.3.1.241:1235] <- [akka.tcp://cmp@10.3.1.241:1238]
0930 10:22:15,182:DeadLetter:13 message: Disassociated [akka.tcp://msg@10.3.1.241:1235] -> [akka.tcp://cmp@10.3.1.241:1238]
```
