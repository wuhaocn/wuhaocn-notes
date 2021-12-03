---
title: Akka系统介绍

categories:
- network

tag:
- akka

---

## 1.概述
     Akka是一个开发库和运行环境，可以用于构建高并发、分布式、可容错、事件驱动的基于JVM的应用。
### 1.1 akka特性

- **易于构建并行和分布式应用 （Simple Concurrency & Distribution）**

      比较容易构建分布式应用

- **可靠性（Resilient by Design）**

      系统具备自愈能力，在本地/远程都有监护。

- **高性能（High Performance）**

      在单机中每秒可发送50000000个消息。内存占用小，1GB内存中可保存2500000个actors。

- **弹性,无中心（Elastic — Decentralized）**

      自适应的负责均衡，路由，分区，配置

- **可扩展（Extensible）**

      可以使用Akka 扩展包进行扩展。
### 1.2 主要模块

- **akka-actors**
   - akka的核心，一个用于并发和分发的模型
- **akka-stream**
   - 一种直观而安全的方式来实现异步、非阻塞的回压流处理。
- **akka-http**
   - 现代的、快速的、异步的、流的HTTP服务器和客户端。
- **akka-cluster**
   - 通过在多个节点上分布您的系统来获得弹性和弹性。
- **akka-sharding**
   - 根据用户的身份，在集群中分配您的参与者。
- **Distributed Data**
   - 最终一致，高度读取和写入可用，低延迟数据
- **Akka Persistence**
   - 为参与者的事件包允许他们在重新启动后到达相同的状态。(持久化)
- **Akka Management**
   - 在云系统上运行Akka系统的扩展（k8s，aws，…）
- **Alpakka**
   - Akka流连接器用于集成其他技术
### 1.3 优劣势

-  优势
   - **事件驱动模型(Event-driven model)**

      Actor 通过响应消息来执行工作。Actor 之间的通信是异步的，允许 Actor 发送消息并继续自己的工作，而不是阻塞等待响应。

   - **强隔离原则(Strong isolation principles)**

     与 Java 中的常规对象不同，Actor 在调用的方法方面，没有一个公共 API。相反，它的公共 API 是通过 Actor 处理的消息来定义的。这可以防止 Actor 之间共享状态；观察另一个 Actor 状态的唯一方法是向其发送请求状态的消息。

   - **位置透明(Location transparency)**

     系统通过工厂方法构造 Actor 并返回对实例的引用。因为位置无关紧要，所以 Actor 实例可以启动、停止、移动和重新启动，以向上和向下扩展以及从意外故障中恢复。

   - **轻量级(Lightweight)**

                 每个实例只消耗几百个字节，这实际上允许数百万并发 Actor 存在于一个应用程序中。

- 劣势
   - **维护成本相对较高**
      - **排查问题修复问题困难**
   - **问题排查困难**
      - **部分模式下消息送达的不可预知**
## 2.Akka概念
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1638373668944-5b054630-e01a-4993-a157-76af327aca1a.png#clientId=ue0a8fca9-7636-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=303&id=ub36bfd98&margin=%5Bobject%20Object%5D&name=image.png&originHeight=434&originWidth=939&originalType=binary&ratio=1&rotation=0&showTitle=false&size=48691&status=done&style=none&taskId=u307b35c7-a62a-41a1-9f52-0098b3b0aee&title=&width=654.5)

- Akka的关键要素
   - FSM: Actor状态维护
   - MailBox：消息队列
   - 派发器：线程调度
   - 序列化：java，pb
   - 网络传输：netty
- 部分日志
```java

access-app
enequeue send.msg: Thread[default-remote-dispatcher-15,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue518854215 ActorSelectionMessage({"method":"simple_app","headers":{},"timeSign":1638372980972,"appMessage":"msg_access_to_app","appId":10000,"targetResourceId":"test-target-id"},Vector(user, NodeAvatar),false)
dequeue send.msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue518854215 ActorSelectionMessage({"method":"simple_app","headers":{},"timeSign":1638372980972,"appMessage":"msg_access_to_app","appId":10000,"targetResourceId":"test-target-id"},Vector(user, NodeAvatar),false)
enequeue send.msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1962688179 ActorSelectionMessage({"method":"simple_app","headers":{},"timeSign":1638372980972,"appMessage":"msg_access_to_app","appId":10000,"targetResourceId":"test-target-id"},Vector(user, NodeAvatar),false)
dequeue send.msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1962688179 ActorSelectionMessage({"method":"simple_app","headers":{},"timeSign":1638372980972,"appMessage":"msg_access_to_app","appId":10000,"targetResourceId":"test-target-id"},Vector(user, NodeAvatar),false)
enequeue msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1722048285 InboundPayload(size = 397 bytes)
dequeue msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1722048285 InboundPayload(size = 397 bytes)
enequeue msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1539873324 {"method":"simple_app","headers":{},"timeSign":1638372980972,"appMessage":"msg_app_return_to_access","appId":10000,"targetResourceId":"test-target-id"}
dequeue msg: Thread[default-dispatcher-28,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1539873324 {"method":"simple_app","headers":{},"timeSign":1638372980972,"appMessage":"msg_app_return_to_access","appId":10000,"targetResourceId":"test-target-id"}


enequeue send.msg: Thread[default-remote-dispatcher-7,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue518854215 ActorSelectionMessage({"method":"simple_app","headers":{},"timeSign":1638372990978,"appMessage":"msg_access_to_app","appId":10000,"targetResourceId":"test-target-id"},Vector(user, NodeAvatar),false)
dequeue send.msg: Thread[default-remote-dispatcher-7,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue518854215 ActorSelectionMessage({"method":"simple_app","headers":{},"timeSign":1638372990978,"appMessage":"msg_access_to_app","appId":10000,"targetResourceId":"test-target-id"},Vector(user, NodeAvatar),false)
enequeue send.msg: Thread[default-remote-dispatcher-7,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1962688179 ActorSelectionMessage({"method":"simple_app","headers":{},"timeSign":1638372990978,"appMessage":"msg_access_to_app","appId":10000,"targetResourceId":"test-target-id"},Vector(user, NodeAvatar),false)
dequeue send.msg: Thread[default-remote-dispatcher-7,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1962688179 ActorSelectionMessage({"method":"simple_app","headers":{},"timeSign":1638372990978,"appMessage":"msg_access_to_app","appId":10000,"targetResourceId":"test-target-id"},Vector(user, NodeAvatar),false)
enequeue msg: Thread[default-remote-dispatcher-7,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1722048285 InboundPayload(size = 397 bytes)
dequeue msg: Thread[default-remote-dispatcher-7,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1722048285 InboundPayload(size = 397 bytes)
enequeue msg: Thread[default-remote-dispatcher-7,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1859244097 {"method":"simple_app","headers":{},"timeSign":1638372990978,"appMessage":"msg_app_return_to_access","appId":10000,"targetResourceId":"test-target-id"}
dequeue msg: Thread[.default-dispatcher-28,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1859244097 {"method":"simple_app","headers":{},"timeSign":1638372990978,"appMessage":"msg_app_return_to_access","appId":10000,"targetResourceId":"test-target-id"}


app-access
enequeue msg: Thread[default-remote-dispatcher-13,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue2012634163 InboundPayload(size = 462 bytes)
dequeue msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue2012634163 InboundPayload(size = 462 bytes)
enequeue msg: Thread[SandBox-akka.actor.default-dispatcher-36,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1334187884 {"method":"simple_app","headers":{},"timeSign":1638372980972,"targetResourceId":"test-target-id","appMessage":"msg_access_to_app","appId":10000}
dequeue msg: Thread[SandBox-akka.actor.default-dispatcher-34,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1334187884 {"method":"simple_app","headers":{},"timeSign":1638372980972,"targetResourceId":"test-target-id","appMessage":"msg_access_to_app","appId":10000}
enequeue msg: Thread[SandBox-akka.actor.default-dispatcher-34,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue360110022 {"method":"simple_app","headers":{},"timeSign":1638372980972,"targetResourceId":"test-target-id","appMessage":"msg_access_to_app","appId":10000}
dequeue msg: Thread[SandBox-akka.actor.default-dispatcher-36,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue360110022 {"method":"simple_app","headers":{},"timeSign":1638372980972,"targetResourceId":"test-target-id","appMessage":"msg_access_to_app","appId":10000}
enequeue send.msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1624011765 {"method":"simple_app","headers":{},"timeSign":1638372980972,"targetResourceId":"test-target-id","appMessage":"msg_app_return_to_access","appId":10000}
dequeue send.msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1624011765 {"method":"simple_app","headers":{},"timeSign":1638372980972,"targetResourceId":"test-target-id","appMessage":"msg_app_return_to_access","appId":10000}
enequeue send.msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue787426676 {"method":"simple_app","headers":{},"timeSign":1638372980972,"targetResourceId":"test-target-id","appMessage":"msg_app_return_to_access","appId":10000}
dequeue send.msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue787426676 {"method":"simple_app","headers":{},"timeSign":1638372980972,"targetResourceId":"test-target-id","appMessage":"msg_app_return_to_access","appId":10000}


enequeue msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue2012634163 InboundPayload(size = 462 bytes)
dequeue msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue2012634163 InboundPayload(size = 462 bytes)
enequeue msg: Thread[SandBox-akka.actor.default-dispatcher-34,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue464599832 {"method":"simple_app","headers":{},"timeSign":1638372990978,"targetResourceId":"test-target-id","appMessage":"msg_access_to_app","appId":10000}
dequeue msg: Thread[SandBox-akka.actor.default-dispatcher-2,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue464599832 {"method":"simple_app","headers":{},"timeSign":1638372990978,"targetResourceId":"test-target-id","appMessage":"msg_access_to_app","appId":10000}
enequeue msg: Thread[SandBox-akka.actor.default-dispatcher-2,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1322027443 {"method":"simple_app","headers":{},"timeSign":1638372990978,"targetResourceId":"test-target-id","appMessage":"msg_access_to_app","appId":10000}
dequeue msg: Thread[SandBox-akka.actor.default-dispatcher-34,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1322027443 {"method":"simple_app","headers":{},"timeSign":1638372990978,"targetResourceId":"test-target-id","appMessage":"msg_access_to_app","appId":10000}
enequeue send.msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1624011765 {"method":"simple_app","headers":{},"timeSign":1638372990978,"targetResourceId":"test-target-id","appMessage":"msg_app_return_to_access","appId":10000}
dequeue send.msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue1624011765 {"method":"simple_app","headers":{},"timeSign":1638372990978,"targetResourceId":"test-target-id","appMessage":"msg_app_return_to_access","appId":10000}
enequeue send.msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue787426676 {"method":"simple_app","headers":{},"timeSign":1638372990978,"targetResourceId":"test-target-id","appMessage":"msg_app_return_to_access","appId":10000}
dequeue send.msg: Thread[default-remote-dispatcher-5,5,main] que:class akka.dispatch.UnboundedMailbox$MessageQueue787426676 {"method":"simple_app","headers":{},"timeSign":1638372990978,"targetResourceId":"test-target-id","appMessage":"msg_app_return_to_access","appId":10000}


```
```java
//收消息
if (msg.message() instanceof IInnerMessage){
	
}
//发消息
if (msg.message() instanceof EndpointManager.Send){
 
}
//payload数据
if (msg.message() instanceof AssociationHandle.InboundPayload){
}

```
### 2.1 Akka-Actor


   - actor类型(path+uid)
      - (/)根actor
      - (/user)用户actor,业务开发使用
         - system.actorOf(),user根路径
         - context.actorOf(),用户actor创建子路径
      - (system)系统actor

![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1636973123748-bbcf6b2d-9fca-4e10-ada7-34baccf040b6.png#clientId=u538a7a7c-0aa3-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=214&id=u8fb619d2&margin=%5Bobject%20Object%5D&name=image.png&originHeight=271&originWidth=691&originalType=binary&ratio=1&rotation=0&showTitle=false&size=25093&status=done&style=none&taskId=u3bb17349-7736-44c7-8cea-5882390f0e8&title=&width=544.5)

   - 生命周期
      - actorOf
         - 创建actor
      - preStart
         - actor对象创建调用，只调用一次
      - preRestart
         - 调用postRestart，actor异常触发
      - stop
         - 调用postStop，actor异常触发   ![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1636975711263-2e77e27c-88a0-4544-8c6b-acc8cc9f419d.png#clientId=u1490d631-30c1-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=161&id=ub3dedcaa&margin=%5Bobject%20Object%5D&name=image.png&originHeight=161&originWidth=621&originalType=binary&ratio=1&rotation=0&showTitle=false&size=17057&status=done&style=none&taskId=u14235e5b-dc24-40b7-b398-a26748767af&title=&width=621)



   - 收发消息
      - receive
         - 接收消息
            - 接收队列
            - 分发器
         - 消息应答
            - 发送方noSender模式
               - 无法回复，回复会出现死信
            - 发送方携带Sender模式
               - getSender()模式:依赖actor上下文，重启积压消息无法送达
               - actorSelection(getSender().Path)模式,选择新的uid，重启积压消息可送达
      - ask
         - 处理模型
            - 异步处理
            - 同步应答
         - 处理流程
            - CompletableFuture<Object> c = new CompletableFuture<>();
            - AskableActorSelection askAble = new AskableActorSelection(akkaSelection);
            - askAble.ask(xxx).onComplete{c.complete(xxx)}
      - tell
         - 处理模型
            - 无业务返回应答,收消息成功Ack
         - 处理流程
            - actorSelection(path).tell(xxx)
            - getSender().tell(xxx)
      - forward
         - 特性
            - 转发消息
            - 携带发送者
         - 场景
            - router模式下转发消息
   - 调度器(分发器)
      - Dispatcher:
         - 一个基于事件的调度程序,它将一组 Actor 绑定到线程池，如果未指定调度器,则使用默认调度器。 
         - 可共享性：Unlimited
         - 邮箱：任意，为每个 Actor 创建一个
         - 用例：默认调度器，Bulkheading
         - 驱动：java.util.concurrent.ExecutorService。使用fork-join-executor、thread-pool-executor或akka.dispatcher.ExecutorServiceConfigurator的FQCN指定的executor。
      - PinnedDispatcher：
         - 这个调度器为每个使用它的 Actor 指定唯一的线程；即每个 Actor 将拥有自己的线程池，池中只有一个线程。 
         - 可共享性：None
         - 邮箱：任意，为每个 Actor 创建一个
         - 用例：Bulkheading
         - 驱动：任何akka.dispatch.ThreadPoolExecutorConfigurator。默认情况下为thread-pool-executor。
      - CallingThreadDispatcher：
         - 此调度器仅在当前调用的线程上运行。这个调度器不创建任何新的线程，但是它可以从不同的线程并发地用于同一个 Actor。有关详细信息和限制，请参阅「[CallingThreadDispatcher](https://doc.akka.io/docs/akka/current/testing.html#callingthreaddispatcher)」。 
         - 可共享性：Unlimited
         - 邮箱：任意，为每个 Actor 创建一个（按需）
         - 用例：Testing
         - 驱动：调用线程（duh）
   - 容错(错误处理)
      - 监督策略
         - OneForOneStrategy
            - 默认（推荐），父Actor只对出问题的子actor进行处理
         - AllForOneStrategy
            - 父Actor对出问题的子actor以及他的所有兄弟节点进行处理
         - 异常处理
            - 继续（resume） ：Actor 继续处理下一条消息；
            - 停止（stop） ：停 止 Actor，不再做任何操作；
            - 重启（restart） ：新建一个 Actor，代替原来的 Actor；
            - 向上反映（escalate） ：将异常信息传递给下一个监督者。
         - 默认监督策略
            - ActorInitializationException将停止失败的子 Actor
            - ActorKilledException将停止失败的子 Actor
            - DeathPactException将停止失败的子 Actor
            - Exception将重新启动失败的子 Actor
            - 其他类型的Throwable将向上反映到父级 Actor
            - 如果异常一直升级到根守护者，它将以与上面定义的默认策略相同的方式处理它。
   - 邮箱
      - UnboundedMailbox
         - 默认邮箱
         - 底层是一个java.util.concurrent.ConcurrentLinkedQueue
         - 阻塞: 否
         - 有界: 否
         - 配置名称："unbounded" 或 "akka.dispatch.UnboundedMailbox"
      - SingleConsumerOnlyUnboundedMailbox
         - 底层是一个非常高效的多生产者单消费者队列，不能被用于BalancingDispatcher
         - 阻塞: 否
         - 有界: 否
         - 配置名称："akka.dispatch.SingleConsumerOnlyUnboundedMailbox"
      - BoundedMailbox
         - 底层是一个java.util.concurrent.LinkedBlockingQueue
         - 阻塞: 是
         - 有界: 是
         - 配置名称："bounded" 或 "akka.dispatch.BoundedMailbox"
      - UnboundedPriorityMailbox
         - 底层是一个java.util.concurrent.PriorityBlockingQueue
         - 阻塞: 是
         - 有界: 否
         - 配置名称："akka.dispatch.UnboundedPriorityMailbox"
      - BoundedPriorityMailbox
         - 底层是一个 java.util.PriorityBlockingQueue包装为akka.util.BoundedBlockingQueue
         - 阻塞: 是
         - 有界: 是
         - 配置名称："akka.dispatch.BoundedPriorityMailbox"



   - 路由
      - router也是一种actor 类型
         - 它路由到来的消息到其他的actors,其他那些actors就叫做routees(被路由对象)
      - 路由策略
         - **akka.routing._RoundRobinRoutingLogic_**_ _  轮询
         - **akka.routing._RandomRoutingLogic    _**随机
         - **akka.routing._SmallestMailboxRoutingLogic _**_  _空闲
         - **akka.routing._BroadcastRoutingLogic_**   广播
         - **akka.routing.ScatterGatherFirstCompletedRoutingLogic**   分散聚集 
         - **akka.routing.**_**TailChoppingRoutingLogic    **  _尾部断续 
         - **akka.routing._ConsistentHashingRoutingLogic_**_    _一致性哈希

![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1638374205217-0fe366e3-c14d-49a1-8ff8-94b64b2bdc0b.png#clientId=ueb19e70b-2dcd-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=232&id=u03785fab&margin=%5Bobject%20Object%5D&name=image.png&originHeight=463&originWidth=915&originalType=binary&ratio=1&rotation=0&showTitle=false&size=402506&status=done&style=none&taskId=u6e3eca0f-789c-4889-a708-4ae3b32f40f&title=&width=457.5)

   - FSM(状态机)
      - State(S) x Event(E) -> Actions (A), State(S’)
      - 如果我们处于状态S，并且事件E发生，那么我们应该执行操作A，并向状态S’过渡。
   - 持久化(Persistence)
      - 类型
         - 内存堆日志
         - 本机文件系统快照存储
         - LevelDB
      - 消息投递策略（通过相应配置实现）
         - at-most-once 意味着每条应用了这种机制的消息会被投递0次或1次。可以说这条消息可能会丢失。
         - at-least-once 意味着每条应用了这种机制的消息潜在的存在多次投递尝试并保证至少会成功一次。就是说这条消息可能会重复但是不会丢失。
         - exactly-once 意味着每条应用了这种机制的消息只会向接收者准确的发送一次。换言之，这种消息既不会丢失也不会重复
### 2.3 Akka-Remote

- 状态
   - 空闲(**Idle**)
      - 无通信关联
   - 活跃(**Active**)
      - 发送消息或者入站连接成功
   - 被守护(**Gated**)
      - 远程链路通信失败(akka.remote.retry-gate-closed-for 参数控制时间),被守护状态可转换为空闲状态
   - 被隔离(Quarantined)
      - 通信失败无法恢复时会转换为(Quarantined)状态

        ![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1637833072247-ecbc24c2-fffe-45be-b1ab-89ba390ceb67.png#clientId=u867bba6f-fc5e-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=325&id=ua73eb7cb&margin=%5Bobject%20Object%5D&name=image.png&originHeight=404&originWidth=671&originalType=binary&ratio=1&rotation=0&showTitle=false&size=77315&status=done&style=none&taskId=u297b68f1-7f84-4ca9-9490-87044592de9&title=&width=540.5)

- 序列化
   - Akka 提供了内置的支持序列化以及的扩展, 你可以使用内置的序列化功能，也可以扩展
      - 配置
         - akka.actor.serializers.java="akka.serialization.JavaSerializer"
         - ​

   - 内置序列化
      - akka.serialization.JavaSerializer
      - akka.remote.serialization.ProtobufSerializer
   - 外部扩展
      - 自定义序列化
      - io.altoo.akka.serialization.kryo.KryoSerializer
- 网络
   - netty
      - tcp
      - udp



## 3.主要流程
### 3.1 发送消息

- 向远端发送消息分为两类：getSender().tell; actorSelection.tell();
   - getSender().tell,复用原有id，重启后原有消息会丢失，接受放会转变成deadletter
   - actorSelection.tell()，基于路径和地址选用消息，id为有效id发送成功不会造成消息丢失

![akka收发消息.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1638067967308-5da4efe0-c608-4bd6-9b3f-70470e10b594.png#clientId=u6c111e97-433a-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=771&id=ueea30d76&margin=%5Bobject%20Object%5D&name=akka%E6%94%B6%E5%8F%91%E6%B6%88%E6%81%AF.png&originHeight=771&originWidth=1271&originalType=binary&ratio=1&rotation=0&showTitle=false&size=76071&status=done&style=none&taskId=u482910c2-7d29-4f8f-b467-d97f035ceac&title=&width=1271)
### 3.2 接受消息

- 业务触发

![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1638195910458-92620128-96f5-47bf-9b94-6983b0fb4bfc.png#clientId=u0fc0bfff-2796-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=347&id=u5cb6d5c2&margin=%5Bobject%20Object%5D&name=image.png&originHeight=442&originWidth=809&originalType=binary&ratio=1&rotation=0&showTitle=false&size=67385&status=done&style=none&taskId=uc16999a4-adbf-4ac9-807e-489330bca81&title=&width=635.5)

- 网络传递

![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1638425177060-950087bb-b7e3-4011-b22c-18a2b5edc8ac.png#clientId=u14d0452d-45cc-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=538&id=ud257ce90&margin=%5Bobject%20Object%5D&name=image.png&originHeight=761&originWidth=902&originalType=binary&ratio=1&rotation=0&showTitle=false&size=77644&status=done&style=none&taskId=u1a4e5712-d621-4148-a229-f6da0c0e576&title=&width=638)
## 4.注意事项

- 异常处理
   - 业务侧捕获异常，异常产生可能会造成actor重启或者关闭，期间出现消息丢失
- 发送消息
   - 确保不丢消息的情况下
      - 同步：可以采用ask同步，加重试
      - 异步：可采用ask异步，加重试
   - 提高吞吐量
      - 采用tell模式
   - 携带发送者转发
      - forward
   - 消息回复
      - 建议用actorSelection.tell回复，可以保证重启后消息不丢失。
- 网络
   - 关闭链接复用，在重启的特定的情况下会存在链接与actor关联失败情况
- 死信处理
   - 监控系统消息发送或者接受失败，可观察现有信息送达状态，降低无效的资源消耗及错误逻辑，发现潜在问题
   - 解决系统中非重启出现的deadletter
- 线程处理
   - actor并发处理，减少公共成员变量访问
- Actor状态管理
   - 非特殊需要禁止管理远程actor状态，错误操作可能造成对端akkaSystem异常
## 参考


[https://zhuanlan.zhihu.com/p/38662453](https://zhuanlan.zhihu.com/p/38662453)
[https://doc.akka.io/docs/akka/current/remoting.html#lifecycle-and-failure-recovery-model](https://doc.akka.io/docs/akka/current/remoting.html#lifecycle-and-failure-recovery-model)
[https://www.cnblogs.com/tankaixiong/p/11225259.html](https://www.cnblogs.com/tankaixiong/p/11225259.html)
[http://doc.yonyoucloud.com/doc/akka-doc-cn/2.3.6/scala/book/chapter1/01_what_is_akka.html](http://doc.yonyoucloud.com/doc/akka-doc-cn/2.3.6/scala/book/chapter1/01_what_is_akka.html)
