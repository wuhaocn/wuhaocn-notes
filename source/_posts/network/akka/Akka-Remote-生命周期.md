---
title: Akka-Remote-生命周期

categories:
- network

tag:
- akka

---


## 1.概述
     Remote模式下，网络链接的生命周期往往影响着对应Actor的生命周期，那么网络链接的生命周期是怎么样的呢，详细可参考下图。
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1637833127832-ef6f79a7-b3e0-43e8-863d-ac8c216590c1.png#clientId=u829361a7-232f-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=384&id=u351c9798&margin=%5Bobject%20Object%5D&name=image.png&originHeight=404&originWidth=671&originalType=binary&ratio=1&rotation=0&showTitle=false&size=77315&status=done&style=none&taskId=u16e8e192-7c61-4c46-93aa-8c1a9b497b7&title=&width=638.5)
## 2.状态介绍
      每一个与远程系统的链路都是四个状态之一：**空闲、活跃、被守护、被隔离。**

- **空闲（Idle）**

远程系统的某个地址没有任何通信之前其关联状态就是Idle（空闲）。

- **活跃（Active）**

当第一条消息试图发送给远程系统或入站链接被接受，链路的状态就被转化为Active（活跃），
这也意味着两个系统有消息的接收或者发送，而且目前为止也没有发生任何失败。

- **被守护（Gated）**

当一个通信失败，或者两个系统间的链接丢失，链路的状态就会变成Gated（被守护）。
在被守护状态，系统不会试图去链接远程系统主机，所有出站消息都会被丢弃。
链路处于Gated状态的时间是通过 akka.remote.retry-gate-closed-for 参数控制的，
当超过这个时间，链路状态会重新转化成Idle（空闲）。
**Gate 是单边的，这也就意味着这期间无论何时当远程系统的入站链接被接受，**
**都会被自动转化成Active（活跃）状态**，通信被立即重用。

- **被隔离（Quarantined）**

当通信失败，且无法恢复时，由于参与系统的状态不一致，远程系统就会变成Quarantined（被隔离）状态。
与Gate不同，被隔离是永久的，它会一直持续到其中一个系统被重启。
重启之后，通信可以被重新恢复，链路状态重新变成Active（活跃）。
## 3.状态流转
其实remote的链路状态也比较容易理解，当没有建立连接时，就处于空闲状态；
有入站链接请求或消息发送时，如果连接建立成功，则变成活跃状态；
活跃状态时，如果发生通信失败且不是致命错误，比如网络中断，就会转到被守护状态；
被守护状态下，在指定时间内，如果网络正常，且收到了成功的入站链接请求，则重新恢复到活跃状态，
若超过指定守护时间则转化到空闲状态；
在活跃状态下，如果发生灾难性、不可恢复的错误，
比如系统消息传递失败或收到MemberRemoved事件，则该链路被隔离，直到远程系统重启后，
收到成功的入站或出站链接，则重新转换到活跃状态。
被守护、被隔离都是应对网络故障的，但分别对应可恢复和不可恢复。
被守护期间还有一定的时间阈值，该阈值内还有机会编程活跃状态。
## 4.实例
### 4.1 Akka Cluster节点Quarantined问题
    之前开发了一套基于akka cluster的调度|负载均衡系统，运行了半年均较稳定，但最近有节点两次down掉。由于没有太多经验，第一次down掉时经验主义地以为是内存吃紧导致程序异常（由于计算资源紧张，很多服务混布，内存确实非常紧张，时常有类似故障），第二次仔细检查了日志发现如下日志：
```java
[WARN] [03/17/2018 21:51:38.769] [cluster-akka.remote.default-remote-dispatcher-91] [akka.remote.Remoting] Tried to associate with unreachable remote address [akka.tcp://cluster@10.104.3.35:7712]. Address is now gated for 5000 ms, all messages to this address will be delivered to dead letters. Reason: [The remote system has quarantined this system. No further associations to the remote system are possible until this system is restarted.]
```
     同时在其它正常的节点上有如下日志
```java
	
[INFO] [03/13/2018 21:36:12.659] [cluster-akka.remote.default-remote-dispatcher-35339] [akka.remote.Remoting] Quarantined address [akka.tcp://cluster@10.104.3.36:7712] is still unreachable or has not been restarted. Keeping it quarantined.
```
    同时master上还有记录
```java
ERROR] [03/17/2018 21:51:37.662] [cluster-akka.remote.default-remote-dispatcher-127527] [akka.remote.Remoting] Association to [akka.tcp://cluster@10.104.3.36:7712] with UID [1258718596] irrecoverably failed. Quarantining address.
java.util.concurrent.TimeoutException: Remote system has been silent for too long. (more than 48.0 hours)
        at akka.remote.ReliableDeliverySupervisor$$anonfun$idle$1.applyOrElse(Endpoint.scala:383)
        at akka.actor.Actor.aroundReceive(Actor.scala:517)
        at akka.actor.Actor.aroundReceive$(Actor.scala:515)
        at akka.remote.ReliableDeliverySupervisor.aroundReceive(Endpoint.scala:203)
        at akka.actor.ActorCell.receiveMessage(ActorCell.scala:527)
        at akka.actor.ActorCell.invoke(ActorCell.scala:496)
        at akka.dispatch.Mailbox.processMailbox(Mailbox.scala:257)
        at akka.dispatch.Mailbox.run(Mailbox.scala:224)
        at akka.dispatch.Mailbox.exec(Mailbox.scala:234)
        at akka.dispatch.forkjoin.ForkJoinTask.doExec(ForkJoinTask.java:260)
        at akka.dispatch.forkjoin.ForkJoinPool$WorkQueue.runTask(ForkJoinPool.java:1339)
        at akka.dispatch.forkjoin.ForkJoinPool.runWorker(ForkJoinPool.java:1979)
        at akka.dispatch.forkjoin.ForkJoinWorkerThread.run(ForkJoinWorkerThread.java:107)
[03/17/2018 21:51:37.749] [cluster-akka.actor.default-dispatcher-105] [akka.tcp://cluster@10.104.3.35:7712/system/cluster/core/daemon] Cluster Node [akka.tcp://cluster@10.104.3.35:7712] - Marking node as TERMINATED [akka.tcp://cluster@10.104.3.36:7712], due to quarantine. Node roles [dc-default]

```
#### 4.1.1 什么是quarantine
      字面意思是隔离，(题外话：这个单词‘隔离’含义的起源是有典故的）， 那么大致猜测是GC或者网络抖动导致集群认为此节点不健康，被驱逐。于是检索了一下资料。
akka cluster如果判定某节点会损害集群健康，就会把它隔离，可能的原因有如下三种：

1. System message delivery failure 系统消息传递失败
1. Remote DeathWatch trigger 远程死亡监控触发
1. Cluster MemberRemoved event 集群移除节点
#### 4.1.2 解决办法
       根据akka的文档，可以调整akka.cluster.failure-detector.threshold来设定判定阈值，来避免因为偶然拉动而导致的误判，但也不宜过大。另外，为了避免cluster系统与业务线程竞争，可为其设置单独的线程池. 在配置中增加
```java
akka.cluster.use-dispatcher = cluster-dispatcher
cluster-dispatcher {
  type = "Dispatcher"
  executor = "fork-join-executor"
  fork-join-executor {
    parallelism-min = 2
    parallelism-max = 4
  }
}
```
akka.cluster.use-dispatcher的默认配置为空。
最后，以上办法都无法保证节点永远不down，最好的方式还是做好容错。
## 5.参考
    [Akka源码分析-Remote-网络链接生命周期](https://www.cnblogs.com/gabry/p/9394507.html)
    [https://doc.akka.io/docs/akka/current/remoting.html#lifecycle-and-failure-recovery-model](https://doc.akka.io/docs/akka/current/remoting.html#lifecycle-and-failure-recovery-model)
