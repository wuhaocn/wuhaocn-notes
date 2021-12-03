---
title: Akka-Cluster原理分析

categories:
- network

tag:
- akka

---

## 1. 概述
     Akka remoting是Peer-to-Peer的，所以基于remote功能的cluster是一个去中心化的分布式集群。
Akka Cluster将多个JVM连接整合在一起，实现消息地址的透明化和统一化使用管理，集成一体化的消息驱动系统。最终目的是将一个大型程序分割成若干子程序，部署到很多JVM上去实现程序的分布式并行运算（单机也可以起很多节点构成集群）。更重要的是, Akka Cluster集群构建与Actor编程没有直接的联系，集群构建是在ActorSystem层面上，实现了Actor消息地址的透明化，无需考虑目标运行环节是否分布式，可以按照正常的Actor编程模式进行开发。我们知道，分布式集群是由若干节点组成的，那么节点的发现及状态管理是分布式系统一个比较重要的任务。Akka Cluster中将节点的生命周期划分为：
[![](https://cdn.nlark.com/yuque/0/2021/png/804884/1634640556096-7864b5b3-0b57-4cb2-a8d7-0162dedcd781.png#clientId=ue5ae84ed-39d6-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=ufeec3256&margin=%5Bobject%20Object%5D&originHeight=343&originWidth=500&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=none&taskId=u9d635c75-98c2-4f5a-9d85-28b8fa2397f&title=)](http://edisonxu.com/images/2018/10/member-states.png)

- **joining** - 当尝试加入集群时的初始状态
- **up** - 加入集群后的正常状态
- **leaving / exiting** - 节点退出集群时的中间状态
- **down** - 集群无法感知某节点后，将其标记为down
- **removed** - 从集群中被删除，以后也无法再加入集群

其实当参数akka.cluster.allow-weakly-up-members启用时(默认是启用的)，还有个weakly up，它是用于集群出现分裂时，集群无法收敛，则leader无法将状态置为up的临时状态。这个后面再解释。
图中还有两个特殊的名词：

- **fd*** - 这个表示akka的错误检测机制Faiulre Detector被触发后，将节点标记为unreachable
- **unreachable*** - unreachable不是一个真正的节点状态，更多的像是一个flag，用来描述集群无法与该节点进行通讯。当错误检测机制侦测到这个节点又能正常通讯时，会移除这个flag。

市面上大多数产品的分布式管理一般用的是注册中心机制，例如zk、consul或etcd。其实是节点把自己的信息注册到所使用的注册中心里，而master通过接受注册中心的通知得知新节点信息。显然本质上是一种master/slave的架构。这种架构有两个问题：

1. master节点一般是单一的，一旦挂了影响就比较大（所以很多master都采用了HA机制），也就是所谓的系统单点故障；
1. 通常节点的地址发现是要走master去获取的，当系统并发大时，master节点就可能成为性能瓶颈，即单点性能瓶颈。

Akka可能就是考虑这两点，采用了P2P的模式，这样任何一个节点都可以作为”master”，任何的节点都可以用来寻找其他节点地址。那它是怎么做到的呢？答案是[Gossip](http://en.wikipedia.org/wiki/Gossip_protocol)协议和CRDT。
## 2.Akka Gossip
### 2.1.基本介绍
#### 2.1.1.Gossip协议
    Gossip协议简单来说，就是病毒式的将信息扩散到整个集群，无法确定何时完成完全扩散，但最终是会到达完全扩散状态的（最终一致性），即收敛。具体介绍可以参考我转载的一片文章——[P2P 网络核心技术：Gossip 协议](http://edisonxu.com/2018/11/02/gossip.html)，这里就不再重复叙述，着重介绍下Akka是怎么使用Gossip的。
#### 2.1.2.CRDT
P2P的分布式系统中，理论上每个节点都能处理外部的请求，以及向其他节点发送请求。而系统中存在的共享变量，可能在同一时间会被两个不同节点的请求用到，即并发安全问题。一般解决方案是队列或自旋，后者本质上还是一种变相的队列。排队就牵扯到两个问题：

1. “谁先来的”

很多人下意识会觉得用时间戳就可以了嘛，但在分布式集群中，每个节点如果是一台单独的服务器，那么每个节点的时间戳未必相同（比如未开启Ntp）。

1. “同时来的怎么办”

就像git，能merge就merge，不能merge就解决冲突。
CRDT就是用于解决解决分布式事件的先后顺序及merge问题的数据结构的简称，即Conflict-Free Replicated Data Types的缩写，它的作用是保证最终一致性，出处参阅[这份论文](http://hal.upmc.fr/docs/00/55/55/88/PDF/techreport.pdf)。白话文 [谈谈CRDT](http://liyu1981.github.io/what-is-CRDT/) 和[CRDT介绍](https://lfwen.site/2018/06/09/crdt-counter/)这两篇文章讲的通俗易懂，多的就不再重复了。
Akka中节点的状态就是一个特殊的CRDT，使用向量时钟Vector Clock实现方案，关于向量时钟Vector Clock可以参见我转发的这篇文章[Vector Clock/Version Clock](http://edisonxu.com/clocks)。
Akka的gossip协议发送的具体内容如下：

```
final case class Gossip(
  members:    immutable.SortedSet[Member], // sorted set of members with their status, sorted by address
  overview:   GossipOverview                       = GossipOverview(),
  version:    VectorClock                          = VectorClock(), // vector clock version
  tombstones: Map[UniqueAddress, Gossip.Timestamp] = Map.empty
)
final case class GossipOverview(
  seen:         Set[UniqueAddress] = Set.empty,
  reachability: Reachability       = Reachability.empty
)
class Reachability private (
  val records:  immutable.IndexedSeq[Reachability.Record],
  val versions: Map[UniqueAddress, Long]
)
```

- **members** 存放该节点知道的其他节点
- **seen** 已经收到本次gossip的节点们，每个节点当接受到一个新的gossip消息时，会把自己放到seen里面，作为响应返回给发送者
- **reachability** 这个由错误检测机制Faiulre Detector的心跳模块来维护，用来判断节点是否存活。正常情况下records应该是空的，当有节点处于Unreachable时，才会有记录加到records里。
- **version** 向量时钟，用于冲突检测和处理
#### 2.1.3.种子节点 SeedNode
SeendNode一般是提前配置好的一组节点。它用于接受其他节点（可以是种子节点）的加入集群的请求。不同节点，在Akka Cluster中启动时会有不同的逻辑：

- 如果是种子节点，并且是排序后的种子节点数组中**排第一**的，它会在一个规定的时间内(默认5秒)去尝试加入已存在的集群，即发送InitJoin消息到其他种子节点。如果未能成功加入，则自己将**创建一个新的Cluster**。
- 如果是种子节点，但并不是数组中排第一的，则会向其他种子节点发送InitJoin消息，如果失败将不断重试，直到能成功加入**第一个返回响应的已加入集群的种子节点**对应的Cluster。
- 如果是普通节点，则会向其他种子节点发送InitJoin消息，如果失败将不断重试，直到能成功加入**第一个返回响应的已加入集群的种子节点**对应的Cluster。

这里有一点值得注意，为什么是加入第一个返回响应的种子节点所在的集群？这个问题后面再解释。
## 3.过程详解
下面用一个简单的场景来解释整个交互过程，假定我们有两个节点n1和n2，其中n1是种子节点。我们让n2先启动。
[![](https://cdn.nlark.com/yuque/0/2021/png/804884/1634640555862-e792d563-5efe-4b7d-b944-8a881612e188.png#clientId=ue5ae84ed-39d6-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=u6af8fcee&margin=%5Bobject%20Object%5D&originHeight=2203&originWidth=1183&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=none&taskId=u8237b388-ef54-4d92-bf52-5f1a3e062be&title=)](http://edisonxu.com/images/2018/10/gossip-process.png)
上图中的T0、T1表示时间轴，但只是为了方便将步骤拆解，便于理解。其中T4和T5并没有必然的时间前后关系，这里只是假定T4在前，步骤基本是类似的，T5在前也只是稍有不同。
#T0、T1时刻只是为了表明n2在启动时，如果没有种子节点响应，则会一直等待重试
#T2时刻种子节点自己新建一个集群，由于新集群只有它自己，members和seen是一样的，所以把自己作为集群的leader。
#### 3.1.leader

- Gossip协议中没有leader选举过程
- leader只是一个角色，任何节点均可以是leader
- leader的确定非常简单：**集群收敛后，当前members队列按IP进行排序，排第一位置的节点就是整个集群的leader**
- leader并非一直不变，如果集群有新节点加入或某节点退出，导致发生Gossip过程，收敛后都会重新确定leader
- leader的职责是更新节点在集群中的状态以及将集群的成员移入或移出集群

注意，这里有个地方容易被误解：“n1和n2构成一个集群，不是在T5才收敛吗？怎么在T2就确定leader了？”
其实当第一个种子节点新建cluster时，由于只有它一个，即seen和members里内容一样，它判断当前集群已收敛，就把自己当作leader了。所以才有了T2_2和T4。
#T3时刻是n1响应n2的InitJoin请求，具体交互过程如下：
[![](https://cdn.nlark.com/yuque/0/2021/png/804884/1634640555875-9a054789-d57a-4311-b6f9-8bdca2798653.png#clientId=ue5ae84ed-39d6-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=u9ab04293&margin=%5Bobject%20Object%5D&originHeight=504&originWidth=711&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=none&taskId=u3a23d908-0c64-4373-b291-a07b093a28d&title=)](http://edisonxu.com/images/2018/10/gossip-interact.png)
#T3_0种子节点收到n2的Join消息后，会做两件事：

1. 更新当前Gossip的向量时钟；
1. 清空当前Gossip的seen队列，然后把自己加进去。（后续发起Gossip交互时，会优先选择那些没在seen队列中的成员）

#T4时刻因为作为fd能正常与n2进行心跳，n1作为leader就被通知将n2提升为Up状态
#T5时刻是一个CRDT的对比过程，对比两个Goissp的version，即VectorClock，比较的结果有三种：

- **Same**: 相同，则进行seen队列合并就可以了
- **Before**: 本地新，则向对端发送本地的Gossip，本地不变
- **After**: 对端新，则更新本地的Gossip。如果对端的Gossip的seen里没有包含本地，则将自己添加到seen里发送给对端，以减少一次两者间的Gossip交互。

#T5时刻最后集群达到了收敛
#### 3.2 Gossip 收敛
从上面的图里可以看到节点初始化时会把自己加入到members里，回传回去，同时，节点在收到新的Gossip时，会把自己加入到seen里面。那么，在一开始，members和seen中的节点数是不同的。
当Gossip传递的消息被整个集群都消化掉的时候，可以称作当前集群的Gossip收敛。靠以下条件判断Gossip收敛：

- 集群中不存在unreachable的节点，或者unreachable的节点应该均处于down或exiting状态
- 正常节点均处于up或leaving状态，且members里的节点都在seen里，即集群中所有的节点都收到过该Gossip
## 4.代码演示
说了那么多文字，Akka Cluster提供了监控ClusterEvent的方法，我们可以用代码来校验下上面的知识。
添加依赖
```
<dependency>
    <groupId>com.typesafe.akka</groupId>
    <artifactId>akka-cluster_2.12</artifactId>
    <version>2.5.17</version>
</dependency>
```


首先编写application.conf配置文件

```
akka {
  actor {
    provider = "cluster"
  }
  remote {
    netty.tcp {
      hostname = "127.0.0.1"
      port = 0
    }
    artery {
      enabled = on
      canonical.hostname = "127.0.0.1"
      canonical.port = 0
    }
  }

  cluster {
    seed-nodes = [
      "akka://ClusterSystem@127.0.0.1:2552",
      "akka://ClusterSystem@127.0.0.1:2551"
    ]
  }
}
```
然后，编写Actor

```
public class SimpleClusterListener extends AbstractActor {

    LoggingAdapter log = Logging.getLogger(getContext().system(), this);
    Cluster cluster = Cluster.get(getContext().system());

    //subscribe to cluster changes


    @Override
    public void preStart() throws Exception {
        cluster.subscribe(self(), ClusterEvent.initialStateAsEvents(), ClusterEvent.MemberEvent.class, ClusterEvent.UnreachableMember.class);
        log.info("I'm about to start! Code: {} ", getSelf().hashCode());
    }

    @Override
    public void postStop() throws Exception {
        cluster.unsubscribe(self());
    }

    @Override
    public Receive createReceive() {
        return receiveBuilder()
                .match(ClusterEvent.MemberUp.class, mUp->log.info("Member is Up: {}", mUp.member()))
                .match(ClusterEvent.UnreachableMember.class, mUnreachable->log.info("Member detected as unreachable: {}", mUnreachable.member()))
                .match(ClusterEvent.MemberRemoved.class, mRemoved->log.info("Member is Removed: {}", mRemoved.member()))
                .match(ClusterEvent.LeaderChanged.class, msg->log.info("Leader is changed: {}", msg.getLeader()))
                .match(ClusterEvent.RoleLeaderChanged.class, msg->log.info("RoleLeader is changed: {}", msg.getLeader()))
                .match(ClusterEvent.MemberEvent.class, event->{}) //ignore
                .build();
    }
}
```
最后是启动类

```
public class App 
{
    public static void main( String[] args )
    {
        if(args.length==0)
            startup(new String[] {"2551", "2552", "0"});
        else
            startup(args);
    }

    public static void startup(String[] ports){
        ExecutorService pool = Executors.newFixedThreadPool(ports.length);
        for(String port : ports){
            pool.submit(()->{
            // Using input port to start multiple instances
                Config config = ConfigFactory.parseString(
                        "akka.remote.netty.tcp.port=" + port + "\n" +
                                "akka.remote.artery.canonical.port=" + port)
                        .withFallback(ConfigFactory.load());

                // Create an Akka system
                ActorSystem system = ActorSystem.create("ClusterSystem", config);

                // Create an
                system.actorOf(Props.create(SimpleClusterListener.class), "ClusterListener");
            });
        }
    }
}
```
这里设置了2552和2551两个种子节点，及一个随机端口启动的普通节点。**故意在配置中把2552放到2551前面去。**
带参数2551作为端口启动程序，命名为Node1，启动后，可以看到它会不断尝试连接提供的种子节点中排第一的2552

```
[WARN] [11/07/2018 17:15:13.823] [ClusterSystem-akka.actor.default-dispatcher-5] [akka://ClusterSystem@127.0.0.1:2551/system/cluster/core/daemon/joinSeedNodeProcess-1] Couldn't join seed nodes after [2] attempts, will try again. seed-nodes=[akka://ClusterSystem@127.0.0.1:2552]
[WARN] [11/07/2018 17:15:18.835] [ClusterSystem-akka.actor.default-dispatcher-10] [akka://ClusterSystem@127.0.0.1:2551/system/cluster/core/daemon/joinSeedNodeProcess-1] Couldn't join seed nodes after [3] attempts, will try again. seed-nodes=[akka://ClusterSystem@127.0.0.1:2552]
```
这时带参数2552启动程序，命名为Node2，命令行会打印

```
[WARN] [11/07/2018 17:15:13.823] [ClusterSystem-akka.actor.default-dispatcher-5] [akka://ClusterSystem@127.0.0.1:2551/system/cluster/core/daemon/joinSeedNodeProcess-1] Couldn't join seed nodes after [2] attempts, will try again. seed-nodes=[akka://ClusterSystem@127.0.0.1:2552]
[WARN] [11/07/2018 17:15:18.835] [ClusterSystem-akka.actor.default-dispatcher-10] [akka://ClusterSystem@127.0.0.1:2551/system/cluster/core/daemon/joinSeedNodeProcess-1] Couldn't join seed nodes after [3] attempts, will try again. seed-nodes=[akka://ClusterSystem@127.0.0.1:2552]
```
Node [akka://ClusterSystem@127.0.0.1:2552] is JOINING itself (with roles [dc-default]) and forming new cluster 说明作为排第一的种子节点，它创建了集群并把自己加了进去。
Cluster Node [akka://ClusterSystem@127.0.0.1:2552] dc [default] is the new leader 说明2552变成了leader。
Node [akka://ClusterSystem@127.0.0.1:2551] is JOINING, roles [dc-default] 2551在尝试加入集群
Leader is moving node [akka://ClusterSystem@127.0.0.1:2551] to [Up] 2551成功加入了集群，状态变为Up
Cluster Node [akka://ClusterSystem@127.0.0.1:2552] dc [default] is no longer the leader 集群变化导致新一轮Goissp收敛后，leader重新选取，2551的IP比2552小，被选为新的leader。
可以从Node1的命令行看到证据：

```

[INFO] [11/07/2018 17:18:25.755] [ClusterSystem-akka.actor.default-dispatcher-9] [akka.cluster.Cluster(akka://ClusterSystem)] Cluster Node [akka://ClusterSystem@127.0.0.1:2551] - Cluster Node [akka://ClusterSystem@127.0.0.1:2551] dc [default] is the new leader

```
我们再起一个参数为2900的，命名为Node3，等到正常启动，三个Node状态都为Up。

- 2552是集群的创建者
- 2551是集群的leader

此时，我们把2552重启，会看到2551的命令行中出现Leader is removing unreachable node [akka://ClusterSystem@127.0.0.1:2552]，等2552完全启动时，可以看到Welcome from [akka://ClusterSystem@127.0.0.1:2551]说明2552向2551发送的加入集群的消息，2551给它发送了Welcome消息。2552不再自己创建新的集群。有兴趣的可以在关闭2552的情况下重启node3.
## 5.进阶
其实本来这部分应该放在上面，但是一上来讲理论非常不好消化，至少我个人是如此。所以，我宁愿把好理解的交互步骤放前面，把一些知识点穿插在里面，最后再把无法放进去的干巴巴的理论放最后。
### 5.1.Akka对于Gossip的优化

- 如果gossiper(gossip的发送者)和recipient(goissp的接收者)拥有相同版本的Gossip(recipient已包含在seen列表里，并且version也与gossiper的完全一致)，这时Gossip的状态不用再发回给gossiper，减少交互。
- akka使用的是push-pull类型gossip的变种，它每次发送的是一个digest值，而非真正的value，recipient收到后先比较版本，只有当它的版本较低时，才会去向gossiper请求真正的值。
- 默认情况下，集群每1秒进行一次gossip，但如果seen里的节点数少于整个集群1/2，则集群每秒钟会进行3轮gossip，以加速收敛。
- 在未收敛时，gossiper在选择目标节点时是随机的但带有偏向性(biased gossip)。gossiper会选择在当前版本下不在seen里的节点去交换gossip，并且选择的比例系数较高(经验值400个节点下配置为0.8)。该系数会随着轮数增加而减少，以防止单节点同时间收到过多的gossip请求。recipient对于gossip请求也是放到mailbox里的，在mailbox队列较长时，会移除较早的请求。
- 当收敛后，目标节点的选择就完全是随机的了，而且只发送非常小的gossip状态的消息。一旦集群发生变化，就会回到上一条所述的带有偏向性的biased gossip。
### 5.2.Failure Detector机制

- 职责是定期检查集群中节点是否可用
- 是[The Phi Accrual Failure Detector](https://pdfs.semanticscholar.org/11ae/4c0c0d0c36dc177c1fff5eb84fa49aa3e1a8.pdf)的实现，是一种解耦了观察与行为的增量式错误检测器。它不会简单的判断节点是否可用，而是通过收集各种数据计算出phi值，通过与设定好的threshold进行对比，判断是否出现错误。
- 每个节点会根据集群节点的hash有序环确定临近的几个节点进行监控（默认是5个），方便跨机房进行监控，保证集群节点的全覆盖。目标节点每1秒向这些节点发送心跳。
- 只要有一个monitor认为某节点是unreachable状态，那么该节点就会被集群认为是unreachable
- 被标记为unreachable的节点，只有在所有的monitor都认为它是reachable时，它才会被重新认为是reachable，leader会重新改变它的状态
### 5.3.网络分区与集群分区
当网络出现异常，比如一个跨两地机房的集群，机房间的网络断了。这时：

- 原创建集群的种子节点所在的集群，会重新发起biased gossip，直至收敛，确认新的leader，被隔开的那部分节点会被认为是unreachable而最终被踢掉
- 被隔开的那部分节点，会重新发起biased gossip，其中排序在最前面的种子节点会创建一个新的集群，并产生新的leader。原集群中的那部分失联节点会被认为是unreachable而最终被从新集群踢掉
- 两个集群最终都恢复正常能对外提供服务，即原来的一个集群在无人干涉的情况下，分裂成了两个集群
- 当网络恢复后，两个集群会重新发起biased gossip，尝试融合，恢复成一个大集群。
## 6.总结
由此可见，从设计上来说，Akka Cluster是完全去中心化，无单点故障和单点性能瓶颈的，具有天然的分布式容错性和可扩容性。
​

## 参考
[http://edisonxu.com/2018/11/07/akka-cluster.html](http://edisonxu.com/2018/11/07/akka-cluster.html)
