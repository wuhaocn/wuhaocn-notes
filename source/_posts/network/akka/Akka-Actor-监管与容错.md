---
title: Akka-Actor-监管与容错

categories:
- network

tag:
- akka

---

## 1.概述
     Akka作为一种成熟的生产环境并发解决方案，必须拥有一套完善的错误异常处理机制，本文主要讲讲Akka中的监管和容错。
## 2.监管
      Akka中的Actor系统它的很重要的概念就是分而治之，既然我们把任务分配给Actor去执行，那么我们必须去监管相应的Actor，当Actor出现了失败，比如系统环境错误，各种异常，能根据我们制定的相应监管策略进行错误恢复，就是后面我们会说到的容错。
### 2.1 监管者
    既然有监管这一事件，那必然存在着**监管者**这么一个角色，那么在ActorSystem中是如何确定这种角色的呢？
    我们先来看下ActorSystem中的顶级监管者：
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1632279269265-ec086cfc-9273-4eb5-a3a7-f14efdce9d6d.png#clientId=u78e747ea-013b-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=753&id=u6be28fc7&margin=%5Bobject%20Object%5D&name=image.png&originHeight=753&originWidth=833&originalType=binary&ratio=1&rotation=0&showTitle=false&size=58348&status=done&style=none&taskId=ueb676476-a220-4713-a637-1077136adac&title=&width=833)
    一个actor系统在其创建过程中至少要**启动三个actor**，如上图所示，下面来说说这三个Actor的功能：
#### 2.1.1. 根监管者 /:
    顾名思义，它是一个老大，它监管着ActorSystem中所有的顶级Actor，顶级Actor有以下几种：

- /user： 是所有由用户创建的顶级actor的监管者；用ActorSystem.actorOf创建的actor在其下。
- /system： 是所有由系统创建的顶级actor的监管者，如日志监听器，或由配置指定在actor系统启动时自动部署的actor。
- /deadLetters： 是死信actor，所有发往已经终止或不存在的actor的消息会被重定向到这里。
- /temp：是所有系统创建的短时actor的监管者，例如那些在ActorRef.ask的实现中用到的actor。
- /remote： 是一个人造虚拟路径，用来存放所有其监管者是远程actor引用的actor。

     跟我们平常打交道最多的就是/user，它是我们在程序中用ActorSystem.actorOf创建的actor的监管者，下面的容错我们重点关心的就是它下面的失败处理，其他几种顶级Actor具体功能定义已经给出，有兴趣的也可以去了解一下。
     根监管者监管着所有顶级Actor，对它们的各种失败情况进行处理，一般来说如果错误要上升到根监管者，整个系统就会停止。
#### 2.1.2. 顶级actor监管者 /user：
    上面已经讲过/user是所有由用户创建的顶级actor的监管者，即用ActorSystem.actorOf创建的actor，我们可以自己制定相应的监管策略，但由于它是actor系统启动时就产生的，所以我们需要在相应的配置文件里配置，具体的配置可以参考这里[Akka配置](http://doc.akka.io/docs/akka/current/general/configuration.html)
​

#### 2.1.3. 系统监管者 /system： 
    /system所有由系统创建的顶级actor的监管者,比如Akka中的日志监听器，因为在Akka中日志本身也是用Actor实现的，/system的监管策略如下：对收到的除ActorInitializationException和ActorKilledException之外的所有Exception无限地执行重启，当然这也会终止其所有子actor。所有其他Throwable被上升到根监管者，然后整个actor系统将会关闭。
    用户创建的普通actor的监管：上一篇文章介绍了Actor系统的组织结构，它是一种树形结构，其实这种结构对actor的监管是非常有利的，Akka实现的是一种叫“父监管”的形式，每一个被创建的actor都由其父亲所监管，这种限制使得actor的监管结构隐式符合其树形结构，所以我们可以得出一个结论：
  **  一个被创建的Actor肯定是一个被监管者，也可能是一个监管者，它监管着它的子级Actor**
**​**

### 2.2 监管策略
      在Akka框架内，父Actor对子Actor进行监督，监控子Actor的行为是否有异常。大体上，监控策略分为两种:

- OneForOneStrategy策略：父Actor只会对出问题的子Actor进行处理。比如重启或停止。Akka的默认策略，推荐使用。
- AllForOneStrategy策略：父Actor会对出问题的子Actor以及它所有的兄弟节点都进行处理。只适用于各个Actor联系非常紧密的场景，如果多个Actor只要有一个失败，则宣布整个任务失败的情况。
- Actor中具体的处理方式主要包括以下：
   - 继续（resume） ：Actor 继续处理下一条消息；
   - 停止（stop） ：停 止 Actor，不再做任何操作；
   - 重启（restart） ：新建一个 Actor，代替原来的 Actor；
   - 向上反映（escalate） ：将异常信息传递给下一个监督者。
```
public class JavaSupervisorStrategyDemo extends AbstractActor {
    private static SupervisorStrategy strategy =
            new OneForOneStrategy(
                    10,
                    Duration.create("1 minute"),
                    /*
                     * resume(): Actor 继续处理下一条消息;
                     * restart():  停 止Actor，不再做任何操作;
                     * escalate(): 新建一个 Actor，代替原来的 Actor;
                     * stop(): 将异常信息传递给下一个监督者;
                     */
                    DeciderBuilder.match(ArithmeticException.class, e -> SupervisorStrategy.resume())
                            .match(NullPointerException.class, e -> SupervisorStrategy.restart())
                            .match(IllegalArgumentException.class, e -> SupervisorStrategy.stop())
                            .matchAny(o -> SupervisorStrategy.escalate())
                            .build());

    @Override
    public SupervisorStrategy supervisorStrategy() {
        return strategy;
    }
}

```
      一对一策略（one-for-one strategy）意味着每个子级都被单独对待。在上面的示例中，10和Duration.create(1, TimeUnit.MINUTES)分别传递给maxNrOfRetries和withinTimeRange参数，这意味着策略每分钟重新启动一个子级最多10次。如果在withinTimeRange持续时间内重新启动计数超过maxNrOfRetries，则子 Actor 将停止。
​

     如果策略在监督者 Actor（而不是单独的类）中声明，则其决策者可以线程安全方式访问 Actor 的所有内部状态，包括获取对当前失败的子级的引用，可用作失败消息的getSender()。

- 默认监督策略

     一般情况下使用默认的行为就可以了：如果 Actor 在运行中抛出异常，就重启 Actor；如果发生错误，就向上反映或是关闭应用程序。不过如果 Actor 在构造函数中抛出异常，那么会导致 ActorInitializationException，并最终导致 Actor 停止运行。如果没有为 Actor 定义监督策略，则默认情况下会处理以下异常：

   - ActorInitializationException将停止失败的子 Actor
   - ActorKilledException将停止失败的子 Actor
   - DeathPactException将停止失败的子 Actor
   - Exception将重新启动失败的子 Actor
   - 其他类型的Throwable将向上反映到父级 Actor
   - 如果异常一直升级到根守护者，它将以与上面定义的默认策略相同的方式处理它。
- 停止监督策略

在子级失败时采取措施阻止他们，然后在DeathWatch显示子级死亡时由监督者采取纠正措施。此策略还预打包为SupervisorStrategy.stoppingStrategy，并附带一个StoppingSupervisorStrategy配置程序，以便在您希望/user下监护人应用它时使用。

- 记录 Actor 的失败

     默认情况下，除非向上反映escalate，否则SupervisorStrategy会记录故障。escalate的故障应该在层次结构中更高的级别处理并记录下来。
     通过在实例化时将loggingEnabled设置为false，可以将SupervisorStrategy的默认日志设置为静音。定制的日志记录可以在Decider内完成。
     请注意，当在监督者 Actor 内部声明SupervisorStrategy时，对当前失败的子级的引用可用作sender。
你还可以通过重写logFailure方法自定义自己的SupervisorStrategy中的日志记录。


## 3.监管容错示例
本示例主要演示Actor在发生错误时，它的监管者会根据相应的监管策略进行不同的处理。[源码链接](https://github.com/godpan/akka-demo/tree/master/Example_03)
因为这个例子比较简单，这里我直接贴上相应代码，后面根据具体的测试用例来解释各种监管策略所进行的响应：
```
class Supervisor extends Actor {
  //监管下属，根据下属抛出的异常进行相应的处理
  override val supervisorStrategy =
    OneForOneStrategy(maxNrOfRetries = 10, withinTimeRange = 1 minute) {
      case _: ArithmeticException => Resume
      case _: NullPointerException => Restart
      case _: IllegalArgumentException => Stop
      case _: Exception => Escalate
    }
  var childIndex = 0 //用于标示下属Actor的序号

  def receive = {
    case p: Props =>
      childIndex += 1
      //返回一个Child Actor的引用，所以Supervisor Actor是Child Actor的监管者
      sender() ! context.actorOf(p,s"child${childIndex}")
  }
}

class Child extends Actor {
  val log = Logging(context.system, this)
  var state = 0
  def receive = {
    case ex: Exception => throw ex //抛出相应的异常
    case x: Int => state = x //改变自身状态
    case s: Command if s.content == "get" =>
      log.info(s"the ${s.self} state is ${state}")
      sender() ! state //返回自身状态
  }
}

case class Command(  //相应命令
    content: String,
    self: String
)
```
现在我们来看看具体的测试用例： 首先我们先构建一个测试环境：
```
class GuardianSpec(_system: ActorSystem)
    extends TestKit(_system)
    with WordSpecLike
    with Matchers
    with ImplicitSender {

  def this() = this(ActorSystem("GuardianSpec"))

  "A supervisor" must {

    "apply the chosen strategy for its child" in {
        code here...
        val supervisor = system.actorOf(Props[Supervisor], "supervisor") //创建一个监管者
        supervisor ! Props[Child]
        val child = expectMsgType[ActorRef] // 从 TestKit 的 testActor 中获取回应
    } 
  }
}
```
### 3.1.TestOne：正常运行
```
child ! 50 // 将状态设为 50
child ! Command("get",child.path.name)
expectMsg(50)
```
正常运行，测试通过。
​

### 3.2.TestTwo：抛出ArithmeticException
```
child ! new ArithmeticException // crash it
child ! Command("get",child.path.name)
expectMsg(50)     
```


大家猜这时候测试会通过吗？答案是通过，原因是根据我们制定的监管策略，监管者在面对子级Actor抛出ArithmeticException异常时，它会去恢复相应出异常的Actor，并保持该Actor的状态，所以此时Actor的状态值还是50，测试通过。
​

### 3.3 TestThree：抛出NullPointerException
```
child ! new NullPointerException // crash it harder
child ! "get"
expectMsg(50)   
```
 
这种情况下测试还会通过吗？答案是不通过，原因是根据我们制定的监管策略，监管者在面对子级Actor抛出NullPointerException异常时，它会去重启相应出异常的Actor，其状态会被清除，所以此时Actor的状态值应该是0，测试不通过。
​

### 3.4.TestFour：抛出IllegalArgumentException
```
supervisor ! Props[Child] // create new child
val child2 = expectMsgType[ActorRef]
child2 ! 100 // 将状态设为 100
watch(child) // have testActor watch “child”
child ! new IllegalArgumentException // break it
expectMsgPF() {
  case Terminated(`child`) => (println("the child stop"))
}
child2 ! Command("get",child2.path.name)
expectMsg(100)   
```
这里首先我们又创建了一个Child Actor为child2，并将它的状态置为100，这里我们监控前面创建的child1，然后给其发送一个IllegalArgumentException的消息，让其抛出该异常，测试结果:
**​**

```
the child stop 
测试通过
```


​

从结果中我们可以看出，child在抛出IllegalArgumentException后，会被其监管着停止，但监管者下的其他Actor还是正常工作。
### 3.5.TestFive：抛出一个自定义异常
```
 watch(child2)
 child2 ! Command("get",child2.path.name) // verify it is alive
 expectMsg(100)
 supervisor ! Props[Child] // create new child
 val child3 = expectMsgType[ActorRef]
 child2 ! new Exception("CRASH") // escalate failure
 expectMsgPF() {
    case t @ Terminated(`child2`) if t.existenceConfirmed => (
       println("the child2 stop")
    )
}
child3 ! Command("get",child3.path.name)
expectMsg(0) 
```
这里首先我们又创建了一个Child Actor为child3,这里我们监控前面创建的child2,然后给其发送一个Exception("CRASH")的消息，让其抛出该异常,测试结果:
```
the child2 stop 
测试不通过
```


很多人可能会疑惑为什么TestFour可以通过，这里就通不过不了呢？因为这里错误Actor抛出的异常其监管者无法处理，只能将失败上溯传递，而顶级actor的缺省策略是对所有的Exception情况（ActorInitializationException和ActorKilledException例外）进行重启. 由于缺省的重启指令会停止所有的子actor，所以我们这里的child3也会被停止。导致测试不通过。当然这里你也可以复写默认的重启方法，比如：
​

```
override def preRestart(cause: Throwable, msg: Option[Any]) {}
```
这样重启相应Actor时就不会停止其子级下的所有Actor了。
本文主要介绍了Actor系统中的监管和容错，这一部分内容在Akka中也是很重要的，它与Actor的树形组织结构巧妙结合，本文大量参考了Akka官方文档的相应章节，有兴趣的同学可以点击这里[Akka docs](https://doc.akka.io/docs/akka/2.5/scala/fault-tolerance.html)。也可以下载我的示例程序，里面包含了一个官方的提供的容错示例。
​

## 参考
​

[https://blog.csdn.net/lp284558195/article/details/112466024](https://blog.csdn.net/lp284558195/article/details/112466024)
[https://godpan.me/2017/04/15/learning-akka-3.html](https://blog.csdn.net/lp284558195/article/details/112466024)
