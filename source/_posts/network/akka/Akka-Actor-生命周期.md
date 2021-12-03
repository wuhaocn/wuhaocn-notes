---
title: Akka-Actor-生命周期

categories:
- network

tag:
- akka

---


## 1.概述
我们首先来看一下官方给出的Actor的声明周期的图:
![](https://cdn.nlark.com/yuque/0/2021/png/804884/1632622242945-c53683ee-8723-4f34-817c-7b57416221b2.png#clientId=ucf8de5bf-9346-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=u9de87b2c&margin=%5Bobject%20Object%5D&originHeight=755&originWidth=866&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=none&taskId=ud1d73754-3d94-4793-bf8c-0feb48264f1&title=)
    在上图中，Actor系统中的路径代表一个地方，其可能会被活着的Actor占据。最初路径都是空的。

- 创建    

在调用actorOf()时，将会为指定的路径分配根据传入Props创建的一个Actor引用。该Actor引用是由路径和一个Uid标识的。

- 重启    

重启时只会替换有Props定义的Actor示例，但不会替换引用，因此Uid保持不变。

- 停止

    当Actor停止时，其引用的生命周期结束。在这一时间点上相关的生命周期事件被调用，监视该Actor的Actor都会获得终止通知。当引用停止后，路径可以重复使用，通过actorOf()创建一个Actor。在这种情况下，除了UID不同外，新引用与老引用是相同的。ActorRef始终表示引用（路径和UID）而不只是一个给定的路径。因此如果Actor停止，并且创建一个新的具有相同名称的Actor，则指向老化身的ActorRef将不会指向新的化身。

- 选择

相对地，ActorSelection指向路径（或多个路径，如果使用了通配符），且完全不关注有没有引用占据它。因此ActorSelection 不能被监视。获取某路径下的当前化身ActorRef是可能的，只要向该ActorSelection发送Identify，如果收到ActorIdentity回应，则正确的引用就包含其中。也可以使用ActorSelection的resolveOne方法，它会返回一个包含匹配ActorRef的Future。

- 状态切换

从上图我们可以发现Actor的生命周期主要包含三个状态：开始、终止和重启。下面分别就 这三个状态进行说明。
## 2.开始
     其实Actor的生命周期是使用Hooks体现和控制的，我们可以重新相关的hooks，从而实现对Actor生命周期各环节的细粒度控制。而当Akka通过Props构建一个Actor后，这个Actor可以立即开始处理消息，进入开始（started）状态。Akka提供了针对开始状态的事件接口（event hooks）preStart方法，因此，我们可以重写该方法进行一些操作，例如：
```java
override def preStart={     
    log.info ("Starting storage actor...")     
    initDB   
}
```
## 3.终止
一个Actor可能因为完成运算、发生异常又或者人为通过发送Kill，PoisonPill强行终止等而进入停止（stopping）状态。
而这个终止过程分为两步：

- 第一步：Actor将挂起对邮箱的处理，并向所有子Actor发送终止命令，然后处理来自子Actor的终止消息直到所有的子Actor都完成终止。
- 第二步：终止自己，调用postStop方法，清空邮箱，向DeathWatch发布Terminated，通知其监管者。

整个人过程保证Actor系统中的子树以一种有序的方式终止，将终止命令传播到叶子结点并收集它们回送的确认消息给被终止的监管者。如果其中某个Actor没有响应（即由于处理消息用了太长时间以至于没有收到终止命令），整个过程将会被阻塞。
因此，我们可以再最后调用postStop方法，来进行一些资源清理等工作，例如：
```java
override def postStop={     log.info ("Stopping storage actor...")     db.release   }
```
## 4.重启
     重启是Actor生命周期里一个最重要的环节。在一个Actor的生命周期里可能因为多种原因发生重启（Restart）。造成一个Actor需要重启的原因可能有下面几个：

- （1）在处理某特定消息时造成了系统性的异常，必须通过重启来清理系统错误
- （2）内部状态毁坏，必须通过重启来重新构建状态
- （3）在处理消息时无法使用到一些依赖资源，需要重启来重新配置资源

其实，Actor的重启过程也是一个递归的过程，由于其比较复杂，先上个图：
![](https://cdn.nlark.com/yuque/0/2021/png/804884/1632622243218-d050dcdc-3839-4e2d-a743-ea2a3e2d9c02.png#clientId=ucf8de5bf-9346-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=uf36aa449&margin=%5Bobject%20Object%5D&originHeight=306&originWidth=955&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=none&taskId=u26a59e29-2cb2-4249-9ca3-b4a0f9e9348&title=)
在默认情况下 ，重启过程主要分为以下几步：
（1）该Actor将被挂起
（2）调用旧实例的 supervisionStrategy.handleSupervisorFailing 方法 (缺省实现为挂起所有的子Actor)
（3）调用preRestart方法，preRestart方法将所有的children Stop掉了！（Stop动作，大家注意！），并调用postStop回收资源
（4）调用旧实例的 supervisionStrategy.handleSupervisorRestarted 方法 (缺省实现为向所有剩下的子Actor发送重启请求)
（5）等待所有子Actor终止直到 preRestart 最终结束
（6）再次调用之前提供的actor工厂创建新的actor实例
（7）对新实例调用 postRestart（默认postRestart是调用preStart方法）
（8）恢复运行新的actor
​

参考
[https://www.cnblogs.com/junjiang3/p/9747594.html](https://www.cnblogs.com/junjiang3/p/9747594.html)
