---
title: Akka-Cluster-Bug分析

categories:
- network

tag:
- akka

---

## 1.概述
      Akka这样一个scala世界里的明星，给我们提供了各种各样吸引人的功能和特性，尤其在分布式、高并发领域。但就像任何其他优秀的框架，它的实现也必然会有其复杂性，在Roland Kuhn(Akka Tech Lead)的带领下,Akka的实现原理吸收了各个领域内成熟、领先的理论。尤其是Akka里cluster的实现，更是体现了非常多的优秀理论和实战经验。
但由于它目前还处在实验阶段，在使用过程中还是会有可能碰到这样或那样的问题，下面就以Akka 2.3为例，详细分析我们碰到的一个bug。
### 1.1. 场景描述
     集群里有两台机器SeedNode1(10.10.10.110) 和 SeedNode2(10.10.10.220)，Akka的配置文件application.conf里相关配置如下:
```java
seed-nodes = ["akka.tcp://ClusterSystem@10.10.10.110:2551","akka.tcp://ClusterSystem@10.10.10.220:2552"]
```
     我们先启动SeedNode1，等一会启动SeedNode2，发现SeedNode2和SeedNode1的TCP链路是连上了，但就是无法正常进行工作。但如果先让SeedNode2先启动，然后再启动SeedNode1，则没有问题，集群可正常启动。
     为了更好方便大家理解，下面先介绍一下cluster和remote的相关实现细节，这样才能前后串起来。
## 2.cluster的启动
    要使用一个cluster首先要启动它，所以我们先从启动这个步骤的实现开始进行分析。Akka集群的启动首先就是要启动一种叫做种子节点(SeedNode)的节点们。只有种子节点启动成功，其他节点才能选择任意一个种子节点加入集群。
种子节点默认可配置多个，它们之间没有任何区别，种子节点的启动分以下几种情况：

- 某种子节点启动，它首先判断自己的ip是否在种子节点配置列表中，如果在并且是第一个，则它在一个规定时间内(默认是5秒)，向其他种子节点发送‘InitJoin’消息，如果有确认消息返回，则加入第一个返回确认的种子节点所在的cluster中，否则，它自己将创建一个新的cluster。(这些任务由FirstSeedNodeProcess这个Actor完成，任务完成后它就销毁自己)
- 某种子节点启动，它首先判断自己的ip是否在种子节点配置中，但不是第一个，则它向其他种子节点发送消息，如果在一个规定时间内(默认是5秒)没有收到任何确认消息，则它将不断重试，直到有一个种子节点返回正确的确认消息，然后就加入这个种子节点所在的cluster中。(这里注意以下，它不会自己创建一个新cluster)。(这些任务由JoinSeedNodeProcess这个Actor完成，任务完成后它就销毁自己)

从上面的分析，我们可以得出下面的一些结论：

- 一个集群第一次启动成功，那一定是种子节点配置列表中排在第一位的节点，由它来创建出集群。但是随着时间的推移，排在第一的种子节点有可能重启了，那这个时候，它将首选加入到其他种子节点去。
- 一个种子节点可以加入任何一个其他节点，不用非得都加到排第一位的节点上。

​

下面我们举例说明，有种子节点1、2、3：

-  1. seed2启动, 但是没有收到seed1 或seed3的确认。
- 2. seed3启动，没有收到seed1 的确认消息(seed2处在’inactive’状态)。
- 3. seed1 启动，创建cluster并加入到自己中。
- 4. seed2 重试加入过程，收到seed1的确认, 加入到seed1。
- 5. seed3重试加入过程，先收到seed2的确认, 加入到seed2。

​

## 3.remote通讯链路的上行、下行实现  
### 3.1 上行路径(listen启动的全过程)
 由于上行路径较复杂，所以画了几张图辅助说明：

- **建立listen
**![](https://cdn.nlark.com/yuque/0/2021/png/804884/1634640719729-01508534-1678-4587-a475-381fc4e4fd50.png#clientId=uc7b47e68-58d0-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=u182b737d&margin=%5Bobject%20Object%5D&originHeight=604&originWidth=909&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=none&taskId=ud639e871-4ab7-4457-be2b-b3f8117b0b3&title=)**

- 接收新链路请求
![](https://cdn.nlark.com/yuque/0/2021/png/804884/1634640720756-05386b47-2280-47ad-a514-1a00b4f82d89.png#clientId=uc7b47e68-58d0-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=u71953ac3&margin=%5Bobject%20Object%5D&originHeight=605&originWidth=931&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=none&taskId=u0817ce41-de38-40f6-b006-2cc57acdeca&title=)
- 接收新链路处于等待握手状态

**![](https://cdn.nlark.com/yuque/0/2021/png/804884/1634640719950-de40b42e-5182-402f-afae-d94cb0d59307.png#clientId=uc7b47e68-58d0-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=u916cdcf0&margin=%5Bobject%20Object%5D&originHeight=674&originWidth=874&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=none&taskId=u865ea1b0-8ee2-4b52-9b87-93da18929b1&title=)****                                                (**接收一个新链路处于等待握手状态**)**
​


- _**​**_可以把Remoting这个非常重要的类作为通讯模块的入口，它在启动的时候(start方法里)会向           EndpointManager这个Actor发送Listen消息，启动底层通讯NettyTransport的listen操作。

​


- **_​_**由AkkaProtocolTransport类来包一层NettyTransport，所以，先调用的是AkkaProtocolTransport的listen方法，这个方法里产生一个upstreamListenerPromise，这个promise最后会被成赋值为ActorAssociationEventListener(EndpointManager的实例)，而这个promise的作用是为了设置AkkaProtocolManager的associationListener属性为EndpointManager的实例。

​


- _**​**_NettyTransport在linsten过程中，会返回一个associationListenerPromise，这个promise会通过调用interceptListen方法而被赋值ActorAssociationEventListener(AkkaProtocolManager的实例)。

而这个promise有两个作用：

- 把建立起来的通讯Channel(监听端口的)置为可读状态(setReadable)，以便接收后续进入的消息。
- 作为TcpServerHandler的构造参数传入(_associationListenerFuture)，TcpServerHandler实例(它其实是

netty里SimpleChannelUpstreamHandler的一个扩展)里最重要的方法是onConnect这个回调方法。当有外部链接建立成功，onConnect方法会被调用，紧接着会调用initInbound方法，然后在该promise处等待，直到promise被成功赋值。
​


- _**​**_当上面initInbound方法里的promise被成功唤醒，它就会调用init方法。

​


- _**​**_init方法里首先会创建一个TcpAssociationHandle实例(包含一个readHandlerPromise），这个Promise在这里等待被唤醒(它被后面7处的操作唤醒而设置channel(新链接的)置为可读状态(setReadable)，同时在netty中注册该channel的listen为ProtocolStateActor实例)，然后会向AkkaProtocolManager实例发送InboundAssociation消息(这个消息里包含一个TcpAssociationHandle实例)。

​


- _**​**_AkkaProtocolManager实例收到InboundAssociation消息，创建一个ProtocolStateActor实例(调用inboundProps构造方法)，这个实例的构造函数里包含两个重要的参数TcpAssociationHandle实例、EndpointManager的实例；

​


- _**​**_ProtocolStateActor实例的这种构造方法会把TcpAssociationHandle实例里的readHandlerPromise设置值而唤醒它。

​


- _**​**_ProtocolStateActor实例初始化后会等待在接受握手的状态中(WaitHandshake)，这个时候如果接收到网络报文，decode后发现是Associate消息，则调用notifyInboundHandler方法。在这个方法中会向EndpointManager实例发送InboundAssociation(new AkkaProtocolHandle(...))消息，notifyInboundHandler方法也创建了一个readHandlerPromise,它作为参数放在发往EndpointManager实例的消息里，然后等待被赋值。

​


- _**​**_EndpointManager实例收到InboundAssociation消息后，根据addressToWritable(EndpointPolicy规则的集合)进行一些必要的判断，如果符合要求则调用createAndRegisterEndpoint方法，这个方法最主要是创建EndpointWriter实例并注册这个实例。不符合则进行相关动作，如保存这个InboundAssociation消息，等待后续条件合适再处理。

​


- _**​**_在创建EndpointWriter实例的preStart方法里，判断是否已经存在AkkaProtocolHandle实例，如果已经存在则创建一个EndpointReader实例，并把它作为值设置给步骤7里的readHandlerPromise，使readHandlerPromise这个Promise的future被唤醒。

​


- _**​**_ProtocolStateActor实例的readHandlerPromise被唤醒后，会向自己发送一条HandleListenerRegistered(EndpointReader实例)的消息，接收到这个消息后，它会修改自己状态机里的状态数据为ListenerReady。后续所有接受的网络数据包就会被正常的decode和分发了。

​

### 3.2.下行路径
作为发送端(client)，当seed节点A向seed节点B发送InitJoin消息时，调用链如下：

- _**​**_向处在accepting状态中的EndpointManager实例发送'Send(message, senderOption, recipientRef, _)'

​


- _**​**_EndpointManager实例调用createAndRegisterWritingEndpoint方法，创建一个ReliableDeliverySupervisor实例(在EndpointWriter实例之上封了一层，以加强可靠性)。

并且向addressToWritable这个HashMap里添加一条记录。
​


- _**​**_ReliableDeliverySupervisor实例会创建一个EndpointWriter实例，在其preStart方法里，由于传入的AkkaProtocolHandle为None，所以会调用transport.associate(remoteAddress, ...)，同时EndpointWriter实例进入Initializing状态。

​


- _**​**_上面的transport是AkkaProtocolTransport实例，它会向AkkaProtocolManager实例的发送一个AssociateUnderlyingRefuseUid消息

​


- _**​**_AkkaProtocolManager实例收到AssociateUnderlyingRefuseUid消息后，调用createOutboundStateActor方法，该方法调用ProtocolStateActor.outboundProps的构造方法。

​


- _**​**_ProtocolStateActor实例的outboundProps构造方法，会调用NettyTransport实例的associate方法，它会调用NettyFutureBridge(bootstrap.connect(socketAddress)进行真正的网络连接。

​


- _**​**_如果无法成功建立连接，则向外发送异常，这个异常会最终被EndpointManager实例捕获。

​


- **​**EndpointManager实例捕获异常后，根据异常情况进行处理，如果是链接失败异常则调用markAsFailed修改addressToWritable相关配置。

​


- **​**如果成功建立连接，则InitJoin消息会发送对对方机器。

​

**3）bug具体原因分析**
通过上面的cluster集群启动过程的分析和remoting的实现过程，可以用来具体分析一下我们的问题场景。 我们是先启动SeedNode1，它启动后会调用remoting的下行路径向SeedNode2发送 ’InitJoin‘消息，它在发送几次后，还没收到响应则自己创建了集群。等我们再启动SeedNode2的时候，SeedNode2会向SeedNode1发起链接，走的是SeedNode1的上行路径，于是bug发生了。
它具体原因就在下行链路的处理环节8###中没有捕获ConnectException异常，也就没有对addressToWritable相关配置进行调整。这就使得上行链路的处理环节9###无法正常往下进行。
该bug在今年4月份被修复，2.3.2及其之后的版本都没有问题，具体修复请查看[https://github.com/akka/akka/commit/672e7f947c9d4e3499bb3667a7230685546b7f7b](https://github.com/akka/akka/commit/672e7f947c9d4e3499bb3667a7230685546b7f7b)，
虽然就是新增了一个对ConnectException异常的捕获，但分析这个bug的原因过程，还是有收获的，应该能对使用Akka的remoting、cluster模块的相关朋友有帮助。
