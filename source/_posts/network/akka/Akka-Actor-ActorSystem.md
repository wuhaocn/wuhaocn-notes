
---
title: Akka-Actor-ActorSystem

categories:
- network

tag:
- akka

---

## 1.ActorSystem-创建
使用Akka首先要创建的一个对象就是ActorSystem，那么我们就先分析这个类及其相关的技术细节。
```java
String clusterName = "test";
Config config = ConfigFactory.defaultReference();
config = ConfigFactory.parseMap(new HashMap<String, Object>() {{
    put("akka.actor.provider", "akka.remote.RemoteActorRefProvider");
    put("akka.remote.netty.tcp.hostname", ip);
    put("akka.remote.netty.tcp.port", port);
    put("akka.remote.netty.tcp.maximum-frame-size", 100 * 1024 * 1024);
    final String serializer = "protostuff";
    put("akka.actor.serializers." + serializer, ProtoStuffer.class.getName());
}}).withFallback(config);
ActorSystem actorSystem = ActorSystem.create(clusterName, config, ClassUtils.getClassLoader());
```
第一步就是创建ActorSystem,以Java调用为例需要如下配置：

- 指定系统集群名称：此处为actor路径的一部分
- 指定akka配置：配置服务地址及端口以及序列化方式等
- 指定类加载器

配置好上述配置后调用 **ActorSystem.create**创建对象。
### 1.1. 构建方式
    ActorSystem创建主要包含集群名称，配置，类加载器，扩展上下文等。
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1634281544005-af8c6561-fb3a-47c9-9a30-573afd919e9e.png#clientId=u0bf93ba4-028a-4&from=paste&height=339&id=u9b348c8e&margin=%5Bobject%20Object%5D&name=image.png&originHeight=416&originWidth=860&originalType=binary&ratio=1&size=196446&status=done&style=none&taskId=u749292b0-2ae8-4541-90ad-b42138b2788&width=700)
### 1.2. 抽象定义
       我们来看ActorSystem类，这是一个抽象类，它继承了ActorRefFactory特质，下面是源码中对该特质的描述。很明显，这个特质是用来创建Actor实例的。我们常用的actorFor和actorSelection是该特质提供的比较重要的方法，当然还有与创建actor有关的其他函数和字段。ActorSystem是一个抽象类，除了继承ActorRefFactory特质的函数和字段之外，定义了一些其他字段和方法，但也都没有具体的实现。
![](https://cdn.nlark.com/yuque/0/2021/png/804884/1632368165109-1889528d-e2ed-4f90-9427-9e495cab29a5.png#clientId=ude74a75a-5503-4&from=paste&id=u13243b5e&margin=%5Bobject%20Object%5D&originHeight=1266&originWidth=1004&originalType=url&ratio=1&status=done&style=none&taskId=u14ce8a30-8dc7-4d0f-8473-dd515d9b788)
通过跟踪AcotSystem的apply我们发现最终调用了以下代码，主要涉及了两个对象：ActorSystemSetup、ActorSystemImpl。

- ActorSystemSetup

      描述是“_A set of setup settings for programmatic configuration of the actor system._”很明显主要是提供一些可编程的配置，我们不再深入这个类。

- ActorSystemImpl

      是我们需要关心的类，因为ActorSystem.apply最终创建了这个类的实例。
### 1.3. 抽象实现
    ActorSystemImpl由继承了ExtendedActorSystem，ExtendedActorSystem抽象类提供了有限的几个函数，暴露了ActorRefFactory中本来是protected的函数，也并没有具体的实现，我们也暂时忽略。
```java
/**
 * Scala API: Creates a new actor system with the specified name and settings
 * The core actor system settings are defined in [[BootstrapSetup]]
 */
def apply(name: String, setup: ActorSystemSetup): ActorSystem = {
    val bootstrapSettings = setup.get[BootstrapSetup]
        val cl = bootstrapSettings.flatMap(_.classLoader).getOrElse(findClassLoader())
        val appConfig = bootstrapSettings.flatMap(_.config).getOrElse(ConfigFactory.load(cl))
        val defaultEC = bootstrapSettings.flatMap(_.defaultExecutionContext)

        new ActorSystemImpl(name, appConfig, cl, defaultEC, None, setup).start()
}
```
## 2. 启动分析
     由于ActorSystemImpl代码比较多，如果从头到尾读一遍代码效率比较低。而且从上面代码可以看出，apply在创建ActorSystemImpl实例之后，调用了start函数，那么我们就从start切入，看看做了哪些操作。
```java
  private lazy val _start: this.type = try {
    registerOnTermination(stopScheduler())
    // the provider is expected to start default loggers, LocalActorRefProvider does this
    provider.init(this)
    if (settings.LogDeadLetters > 0)
      logDeadLetterListener = Some(systemActorOf(Props[DeadLetterListener], "deadLetterListener"))
    eventStream.startUnsubscriber()
    loadExtensions()
    if (LogConfigOnStart) logConfiguration()
    this
  } catch {
    case NonFatal(e) ⇒
      try terminate() catch { case NonFatal(_) ⇒ Try(stopScheduler()) }
      throw e
  }
```
其实start的代码还是比较清晰的:主要包含

- registerOnTermination(stopScheduler())
- provider.init(this)
- logDeadLetterListener
- loadExtensions()eventStream.startUnsubscriber()
- logConfiguration()
### 2.1 注册回调
       首先用registerOnTermination注册了stopScheduler()，也就是给ActorSystem的退出注册了一个回调函数stopScheduler()，这一点也不再具体分析。
### 2.2. Provider初始化
    provider.init(this)这段代码比较重要，从provider的类型来看，它是一个ActorRefProvider，前面我们已经分析过，这是一个用来创建actor的工厂类。provider初始化完成意味着就可以创建actor了，源码注释中也明确的说明了这一点。
```java
val provider: ActorRefProvider = try {
    val arguments = Vector(
        classOf[String] → name,
        classOf[Settings] → settings,
        classOf[EventStream] → eventStream,
        classOf[DynamicAccess] → dynamicAccess)

        dynamicAccess.createInstanceFor[ActorRefProvider](ProviderClass, arguments).get
} catch {
    case NonFatal(e) ⇒
        Try(stopScheduler())
        throw e
}
```
     上面是provider的创建过程，最重要的一段代码是dynamicAccess.createInstanceFor[ActorRefProvider](ProviderClass, arguments).get，它使用DynamicAccess创建了ActorRefProvider对象的实例。跟踪dynamicAccess创建我们发现这是一个ReflectiveDynamicAccess实例，其实这个类也比较简单，就是从ClassLoader中根据ProviderClass字段加载对应的类并创建对应的实例。ProviderClass定义如下，这是配置文件中经常看到的配置。目前的provider一共有三种：LocalActorRefProvider、akka.remote.RemoteActorRefProvider、akka.cluster.ClusterActorRefProvider，当然我们也可以自定义。
```java
final val ProviderClass: String =
      setup.get[BootstrapSetup]
        .flatMap(_.actorRefProvider).map(_.identifier)
        .getOrElse(getString("akka.actor.provider")) match {
          case "local"   ⇒ classOf[LocalActorRefProvider].getName
          // these two cannot be referenced by class as they may not be on the classpath
          case "remote"  ⇒ "akka.remote.RemoteActorRefProvider"
          case "cluster" ⇒ "akka.cluster.ClusterActorRefProvider"
          case fqcn      ⇒ fqcn
        }
```
     自此provider创建结束，简单来说就是根据配置，通过Class._forName_加载了对应的ActorRefProvider实现类，并把当前的参数传给它，调用对应的构造函数，完成实例的创建。provider创建完成后调用init完成初始化，就可以创建actor了。
### 2.3. logDeadLetterListener
      start函数还创建了一个DeadLetterListener类型的actor，这也是我们经常会遇到的。如果给一个不存在的目标actor发消息，或者发送消息超时，都会把消息转发给这个DeadLetter。这就是一个普通的actor，主要用来接收没有发送成功的消息，并把消息打印出来。
### 2.4. eventStream.startUnsubscriber()
      后面还调用了eventStream.startUnsubscriber()，由于eventStream也不是我们关注的重点，先忽略。
### 2.5. loadExtensions()
     loadExtensions()功能也比较单一，就是根据配置加载ActorSystem的扩展类，并进行注册。
```java
private def loadExtensions() {
    /**
     * @param throwOnLoadFail Throw exception when an extension fails to load (needed for backwards compatibility)
     */
    def loadExtensions(key: String, throwOnLoadFail: Boolean): Unit = {
      immutableSeq(settings.config.getStringList(key)) foreach { fqcn ⇒
        dynamicAccess.getObjectFor[AnyRef](fqcn) recoverWith { case _ ⇒ dynamicAccess.createInstanceFor[AnyRef](fqcn, Nil) } match {
          case Success(p: ExtensionIdProvider) ⇒ registerExtension(p.lookup())
          case Success(p: ExtensionId[_])      ⇒ registerExtension(p)
          case Success(other) ⇒
            if (!throwOnLoadFail) log.error("[{}] is not an 'ExtensionIdProvider' or 'ExtensionId', skipping...", fqcn)
            else throw new RuntimeException(s"[$fqcn] is not an 'ExtensionIdProvider' or 'ExtensionId'")
          case Failure(problem) ⇒
            if (!throwOnLoadFail) log.error(problem, "While trying to load extension [{}], skipping...", fqcn)
            else throw new RuntimeException(s"While trying to load extension [$fqcn]", problem)
        }
      }
    }
 
    // eager initialization of CoordinatedShutdown
    CoordinatedShutdown(this)
 
    loadExtensions("akka.library-extensions", throwOnLoadFail = true)
    loadExtensions("akka.extensions", throwOnLoadFail = false)
  }
```
      至此，我们就对ActorSystem的创建和启动分析完毕，但还有一些细节需要说明。
### 2.6. 变量初始化
      在start之前还是有一些其他字段的初始化。由于这些字段同样重要，且初始化的顺序没有太大关联，我就按照代码结构从上至下依次分析几个重要的字段。主要包含如下：

- threadFactory
```java
final val threadFactory: MonitorableThreadFactory =
    MonitorableThreadFactory(name, settings.Daemonicity, Option(classLoader), uncaughtExceptionHandler)
```
     threadFactory这是一个线程工厂类，默认是MonitorableThreadFactory，我们只需要记住这是一个线程工厂类，默认创建ForkJoinWorkerThread的线程就好了。

- scheduler调度器
```java
val scheduler: Scheduler = createScheduler()
```
     scheduler是一个调度器，主要用来定时发送一些消息，这个我们也会经常遇到，但不是此次分析的重点，略过就好。

- mailboxes
```java
val mailboxes: Mailboxes = new Mailboxes(settings, eventStream, dynamicAccess, deadLetters)
```


      mailboxes是一个非常重要的字段，它是Mailboxes一个实例，用来创建对应的Mailbox，Mailbox用来接收消息，并通过dispatcher分发给对应的actor。

- dispatchers
```java
val dispatchers: Dispatchers = new Dispatchers(settings, DefaultDispatcherPrerequisites(
    threadFactory, eventStream, scheduler, dynamicAccess, settings, mailboxes, defaultExecutionContext))
 
  val dispatcher: ExecutionContextExecutor = dispatchers.defaultGlobalDispatcher
```


dispatchers是Dispatchers的一个实例，它用来创建、查询对应的MessageDispatcher。它有一个默认的全局dispatcher，从代码来看，它从配置中读取akka.actor.default-dispatcher，并创建MessageDispatcher实例。MessageDispatcher也是一个非常重要的类，我们后面再具体分析。
```java
/**
 * The one and only default dispatcher.
 */
def defaultGlobalDispatcher: MessageDispatcher = lookup(DefaultDispatcherId)
```


```java
object Dispatchers {
  /**
   * The id of the default dispatcher, also the full key of the
   * configuration of the default dispatcher.
   */
  final val DefaultDispatcherId = "akka.actor.default-dispatcher"
}
```
     到这里我们就算分析完了ActorSystem的创建过程及其技术细节，当然ActorSystem创建只是第一步，后面需要创建actor，actor如何收到dispatcher的消息，还是需要进一步研究的。
​

## 3.参考


[https://www.cnblogs.com/gabry/p/9336477.html](https://www.cnblogs.com/gabry/p/9336477.html)
