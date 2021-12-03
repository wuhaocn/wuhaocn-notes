
---
title: Akka-Actor-Actor创建

categories:
- network

tag:
- akka

---

## 1.Actor创建


### 1.1 创建过程
     上篇我们介绍了ActorSystem的创建过程，下面我们就研究一下actor的创建过程。
```java
ActorSystem actorSystem = ActorSystem.create(serverName, config, ClassUtils.getClassLoader());
actorSystem.actorOf(props.withDeploy(new Deploy(new RemoteScope(address))), "avatar");
```
     普通情况下，我们一般使用ActorSystem的actorOf来创建actor，当然通过上一篇博客的介绍，我们已经知道actorOf是继承自ActorRefFactory的函数。
```java
def actorOf(props: Props, name: String): ActorRef =
    if (guardianProps.isEmpty) guardian.underlying.attachChild(props, name, systemService = false)
    else throw new UnsupportedOperationException(
      s"cannot create top-level actor [$name] from the outside on ActorSystem with custom user guardian")
```


    也比较简单，就是判断一下guardianProps是不是为空，为空则调用guardian.underlying.attachChild方法创建一个ActorRef。**new ActorSystemImpl(name, appConfig, cl, defaultEC, None, setup).start()** 这段代码显示在创建ActorSystemImpl时，guardianProps一定为空，具体guardianProps的作用我们暂时先忽略。
```java
def guardian: LocalActorRef = provider.guardian
/**
   * Reference to the supervisor used for all top-level user actors.
   */
def guardian: LocalActorRef
```
     通过定位guardian我们发现这是一个LocalActorRef，而且通过官方源码的说明可以看出，这是一个root监督者，用来监督所有用户创建的actor。Akka的actor是按照树状结构创建，都是有一定层级的，actor的路径一般都是/user/actorParent1/actorChild1，其中guardian是user的位置。
```java
/**
 *  Local (serializable) ActorRef that is used when referencing the Actor on its "home" node.
 *
 *  INTERNAL API
 */
private[akka] class LocalActorRef private[akka] (
  _system:           ActorSystemImpl,
  _props:            Props,
  _dispatcher:       MessageDispatcher,
  _mailboxType:      MailboxType,
  _supervisor:       InternalActorRef,
  override val path: ActorPath)
  extends ActorRefWithCell with LocalRef
```
     上面是LocalActorRef的定义。上一篇博客我们也介绍了provider的创建过程，它默认是一个LocalActorRefProvider，那就可以找到guardian具体创建的过程了。
```java
override lazy val guardian: LocalActorRef = {
   val cell = rootGuardian.underlying
   cell.reserveChild("user")
   val ref = new LocalActorRef(system, system.guardianProps.getOrElse(Props(classOf[LocalActorRefProvider.Guardian], guardianStrategy)),
     defaultDispatcher, defaultMailbox, rootGuardian, rootPath / "user")
   cell.initChild(ref)
   ref.start()
   ref
 }
```
### 1.2 构成
分析上面的代码我们看到，LocalActorRef创建时传入了几个非常重要的参数：defaultDispatcher、defaultMailbox、rootGuardian和rootPath / "user"。之所以重要，是因为通过它们我们可以再深入actor的创建过程。Dispatcher和mailbox都是actor运行非常重要的概念，其中mailbox负责存储actor收到的消息，dispatcher负责从mailbox取消息，分配线程给actor执行具体的业务逻辑。我们逐一进行简要分析。
```java
/**
   * The one and only default dispatcher.
   */
  def defaultGlobalDispatcher: MessageDispatcher = lookup(DefaultDispatcherId)
```
```java
/**
   * The id of the default dispatcher, also the full key of the
   * configuration of the default dispatcher.
   */
  final val DefaultDispatcherId = "akka.actor.default-dispatcher"
```
    通过追踪defaultDispatcher的创建，我们最终定位到了上面这段代码，很明显是根据默认配置创建了akka.actor.default-dispatcher对应的MessageDispatcher实例。那么akka.actor.default-dispatcher究竟是什么呢？这个得从reference.conf里面看一下。
```java
default-dispatcher {
      # Must be one of the following
      # Dispatcher, PinnedDispatcher, or a FQCN to a class inheriting
      # MessageDispatcherConfigurator with a public constructor with
      # both com.typesafe.config.Config parameter and
      # akka.dispatch.DispatcherPrerequisites parameters.
      # PinnedDispatcher must be used together with executor=thread-pool-executor.
      type = "Dispatcher"
 
      # Which kind of ExecutorService to use for this dispatcher
      # Valid options:
      #  - "default-executor" requires a "default-executor" section
      #  - "fork-join-executor" requires a "fork-join-executor" section
      #  - "thread-pool-executor" requires a "thread-pool-executor" section
      #  - "affinity-pool-executor" requires an "affinity-pool-executor" section
      #  - A FQCN of a class extending ExecutorServiceConfigurator
      executor = "default-executor"
 
      # This will be used if you have set "executor = "default-executor"".
      # If an ActorSystem is created with a given ExecutionContext, this
      # ExecutionContext will be used as the default executor for all
      # dispatchers in the ActorSystem configured with
      # executor = "default-executor". Note that "default-executor"
      # is the default value for executor, and therefore used if not
      # specified otherwise. If no ExecutionContext is given,
      # the executor configured in "fallback" will be used.
      default-executor {
        fallback = "fork-join-executor"
      }
    }
```
     很明显这是一个fork-join-executor，那么fork-join-executor具体是如何完成实例的创建呢？从lookup这段代码来看，是通过MessageDispatcherConfigurator来构造的，根据类名来猜，它应该是读取配置，然后创建MessageDispatcher类的实例的。那么MessageDispatcherConfigurator具体是什么呢？
```java
abstract class MessageDispatcherConfigurator(_config: Config, val prerequisites: DispatcherPrerequisites) {
 
  val config: Config = new CachingConfig(_config)
 
  /**
   * Returns an instance of MessageDispatcher given the configuration.
   * Depending on the needs the implementation may return a new instance for
   * each invocation or return the same instance every time.
   */
  def dispatcher(): MessageDispatcher
 
  def configureExecutor(): ExecutorServiceConfigurator = {
    def configurator(executor: String): ExecutorServiceConfigurator = executor match {
      case null | "" | "fork-join-executor" ⇒ new ForkJoinExecutorConfigurator(config.getConfig("fork-join-executor"), prerequisites)
      case "thread-pool-executor"           ⇒ new ThreadPoolExecutorConfigurator(config.getConfig("thread-pool-executor"), prerequisites)
      case "affinity-pool-executor"         ⇒ new AffinityPoolConfigurator(config.getConfig("affinity-pool-executor"), prerequisites)
 
      case fqcn ⇒
        val args = List(
          classOf[Config] → config,
          classOf[DispatcherPrerequisites] → prerequisites)
        prerequisites.dynamicAccess.createInstanceFor[ExecutorServiceConfigurator](fqcn, args).recover({
          case exception ⇒ throw new IllegalArgumentException(
            ("""Cannot instantiate ExecutorServiceConfigurator ("executor = [%s]"), defined in [%s],
                make sure it has an accessible constructor with a [%s,%s] signature""")
              .format(fqcn, config.getString("id"), classOf[Config], classOf[DispatcherPrerequisites]), exception)
        }).get
    }
 
    config.getString("executor") match {
      case "default-executor" ⇒ new DefaultExecutorServiceConfigurator(config.getConfig("default-executor"), prerequisites, configurator(config.getString("default-executor.fallback")))
      case other              ⇒ configurator(other)
    }
  }
}
```
     MessageDispatcherConfigurator代码不是太长，简单浏览一下代码就会发现，fork-join-executor对应了ForkJoinExecutorConfigurator。这个类是一个抽象类，里面有一个dispatcher函数返回MessageDispatcher，那么究竟是哪个子类实现了这个方法呢？我们再来看一下lookupConfigurator的具体代码，就会发现其中有一段configuratorFrom(config(id))代码非常可疑，它创建了MessageDispatcherConfigurator类的一个实例。
```java
private def lookupConfigurator(id: String): MessageDispatcherConfigurator = {
  dispatcherConfigurators.get(id) match {
    case null ⇒
      // It doesn't matter if we create a dispatcher configurator that isn't used due to concurrent lookup.
      // That shouldn't happen often and in case it does the actual ExecutorService isn't
      // created until used, i.e. cheap.
      val newConfigurator =
        if (cachingConfig.hasPath(id)) configuratorFrom(config(id))
        else throw new ConfigurationException(s"Dispatcher [$id] not configured")
 
      dispatcherConfigurators.putIfAbsent(id, newConfigurator) match {
        case null     ⇒ newConfigurator
        case existing ⇒ existing
      }
 
    case existing ⇒ existing
  }
}
```


```java
private def configuratorFrom(cfg: Config): MessageDispatcherConfigurator = {
  if (!cfg.hasPath("id")) throw new ConfigurationException("Missing dispatcher 'id' property in config: " + cfg.root.render)
 
  cfg.getString("type") match {
    case "Dispatcher" ⇒ new DispatcherConfigurator(cfg, prerequisites)
    case "BalancingDispatcher" ⇒
      // FIXME remove this case in 2.4
      throw new IllegalArgumentException("BalancingDispatcher is deprecated, use a BalancingPool instead. " +
        "During a migration period you can still use BalancingDispatcher by specifying the full class name: " +
        classOf[BalancingDispatcherConfigurator].getName)
    case "PinnedDispatcher" ⇒ new PinnedDispatcherConfigurator(cfg, prerequisites)
    case fqn ⇒
      val args = List(classOf[Config] → cfg, classOf[DispatcherPrerequisites] → prerequisites)
      prerequisites.dynamicAccess.createInstanceFor[MessageDispatcherConfigurator](fqn, args).recover({
        case exception ⇒
          throw new ConfigurationException(
            ("Cannot instantiate MessageDispatcherConfigurator type [%s], defined in [%s], " +
              "make sure it has constructor with [com.typesafe.config.Config] and " +
              "[akka.dispatch.DispatcherPrerequisites] parameters")
              .format(fqn, cfg.getString("id")), exception)
      }).get
  }
}
```


     而进入到configuratorFrom函数就会发现，它根据配置的type字段分别创建不同的MessageDispatcherConfigurator，而前面的配置文件中type是Dispatcher。那就对应了DispatcherConfigurator，这又是一个什么类呢？它是一个MessageDispatcherConfigurator子类，并且实现了dispatcher函数。这个函数创建了最终的MessageDispatcher。这个类又调用了configureExecutor()方法传入了一个ExecutorServiceConfigurator实例，根据前面的代码我们知道这就是ForkJoinExecutorConfigurator。
```java
/**
 * Configurator for creating [[akka.dispatch.Dispatcher]].
 * Returns the same dispatcher instance for each invocation
 * of the `dispatcher()` method.
 */
class DispatcherConfigurator(config: Config, prerequisites: DispatcherPrerequisites)
  extends MessageDispatcherConfigurator(config, prerequisites) {
 
  private val instance = new Dispatcher(
    this,
    config.getString("id"),
    config.getInt("throughput"),
    config.getNanosDuration("throughput-deadline-time"),
    configureExecutor(),
    config.getMillisDuration("shutdown-timeout"))
 
  /**
   * Returns the same dispatcher instance for each invocation
   */
  override def dispatcher(): MessageDispatcher = instance
}
```


    自此一个MessageDispatcher创建完成。这创建过程真是曲折蜿蜒啊，哈哈哈。不过有些是为了抽象、封装，有些是为了可配置，稍微复杂了点。下面就分析defaultMailbox如何创建的。
```java
private lazy val defaultMailbox = system.mailboxes.lookup(Mailboxes.DefaultMailboxId)
```


     跟dispatcher有点类似，也是同样的lookup创建的，当然这也是为了可配置（DefaultMailboxId = "akka.actor.default-mailbox"）。跟踪lookup来到以下代码。
```java
private def lookupConfigurator(id: String): MailboxType = {
   mailboxTypeConfigurators.get(id) match {
     case null ⇒
       // It doesn't matter if we create a mailbox type configurator that isn't used due to concurrent lookup.
       val newConfigurator = id match {
         // TODO RK remove these two for Akka 2.3
         case "unbounded" ⇒ UnboundedMailbox()
         case "bounded"   ⇒ new BoundedMailbox(settings, config(id))
         case _ ⇒
           if (!settings.config.hasPath(id)) throw new ConfigurationException(s"Mailbox Type [${id}] not configured")
           val conf = config(id)
 
           val mailboxType = conf.getString("mailbox-type") match {
             case "" ⇒ throw new ConfigurationException(s"The setting mailbox-type, defined in [$id] is empty")
             case fqcn ⇒
               val args = List(classOf[ActorSystem.Settings] → settings, classOf[Config] → conf)
               dynamicAccess.createInstanceFor[MailboxType](fqcn, args).recover({
                 case exception ⇒
                   throw new IllegalArgumentException(
                     s"Cannot instantiate MailboxType [$fqcn], defined in [$id], make sure it has a public" +
                       " constructor with [akka.actor.ActorSystem.Settings, com.typesafe.config.Config] parameters",
                     exception)
               }).get
           }
 
           if (!mailboxNonZeroPushTimeoutWarningIssued) {
             mailboxType match {
               case m: ProducesPushTimeoutSemanticsMailbox if m.pushTimeOut.toNanos > 0L ⇒
                 warn(s"Configured potentially-blocking mailbox [$id] configured with non-zero pushTimeOut (${m.pushTimeOut}), " +
                   s"which can lead to blocking behavior when sending messages to this mailbox. " +
                   s"Avoid this by setting `$id.mailbox-push-timeout-time` to `0`.")
                 mailboxNonZeroPushTimeoutWarningIssued = true
               case _ ⇒ // good; nothing to see here, move along, sir.
             }
           }
 
           mailboxType
       }
 
       mailboxTypeConfigurators.putIfAbsent(id, newConfigurator) match {
         case null     ⇒ newConfigurator
         case existing ⇒ existing
       }
 
     case existing ⇒ existing
   }
 }
```


    跟dispatcher创建有点类似，就是先查找有没有，没有就创建一个，只不过不同的是，这段代码只是创建了MailboxType，而没有直接创建真正的消息队列，不过后面再具体分析。那akka.actor.default-mailbox究竟是什么呢？同样需要翻reference.conf配置
```java
default-mailbox {
      # FQCN of the MailboxType. The Class of the FQCN must have a public
      # constructor with
      # (akka.actor.ActorSystem.Settings, com.typesafe.config.Config) parameters.
      mailbox-type = "akka.dispatch.UnboundedMailbox"
 
      # If the mailbox is bounded then it uses this setting to determine its
      # capacity. The provided value must be positive.
      # NOTICE:
      # Up to version 2.1 the mailbox type was determined based on this setting;
      # this is no longer the case, the type must explicitly be a bounded mailbox.
      mailbox-capacity = 1000
 
      # If the mailbox is bounded then this is the timeout for enqueueing
      # in case the mailbox is full. Negative values signify infinite
      # timeout, which should be avoided as it bears the risk of dead-lock.
      mailbox-push-timeout-time = 10s
 
      # For Actor with Stash: The default capacity of the stash.
      # If negative (or zero) then an unbounded stash is used (default)
      # If positive then a bounded stash is used and the capacity is set using
      # the property
      stash-capacity = -1
}
```


     在lookupConfigurator函数中有一段很重要的代码：dynamicAccess.createInstanceFor[MailboxType](fqcn, args)。它同样调用了dynamicAccess创建了一个MailboxType的实例，实例的类型就是mailbox-type的值。那么akka.dispatch.UnboundedMailbox究竟又是怎么样的呢？
```java
/**
 * MailboxType is a factory to create MessageQueues for an optionally
 * provided ActorContext.
 *
 * <b>Possibly Important Notice</b>
 *
 * When implementing a custom mailbox type, be aware that there is special
 * semantics attached to `system.actorOf()` in that sending to the returned
 * ActorRef may—for a short period of time—enqueue the messages first in a
 * dummy queue. Top-level actors are created in two steps, and only after the
 * guardian actor has performed that second step will all previously sent
 * messages be transferred from the dummy queue into the real mailbox.
 */
trait MailboxType {
  def create(owner: Option[ActorRef], system: Option[ActorSystem]): MessageQueue
}
 
trait ProducesMessageQueue[T <: MessageQueue]
 
/**
 * UnboundedMailbox is the default unbounded MailboxType used by Akka Actors.
 */
final case class UnboundedMailbox() extends MailboxType with ProducesMessageQueue[UnboundedMailbox.MessageQueue] {
 
  def this(settings: ActorSystem.Settings, config: Config) = this()
 
  final override def create(owner: Option[ActorRef], system: Option[ActorSystem]): MessageQueue =
    new UnboundedMailbox.MessageQueue
}
```
    源码中对MailboxType的描述也非常清楚。这是一个工厂类，是用来创建MessageQueues的，只不过这个名字非常奇怪，为啥不叫MailboxFactory呢，或者MessageQueueFactory？鬼知道啊。
   MailboxType的创建过程也比较清楚了，具体UnboundedMailbox.MessageQueue的类是怎么样的，继承结构又是怎么样的，我们就不再继续深入分析了。
   下面我们来看guardian调用的第一个方法underlying，这个词的意思是表面下的，下层的，它是一个ActorCell类型。看看它继承的类，貌似还挺复杂的。
![](https://cdn.nlark.com/yuque/0/2021/png/804884/1632368418878-57db4564-8b25-4ae1-8f17-c88d7f03501e.png#clientId=uf121db86-9ab9-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=u2349673f&margin=%5Bobject%20Object%5D&originHeight=518&originWidth=1670&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=none&taskId=u0b863b7b-2deb-4be7-b46e-cc229c7ec4c&title=)
    最终调用了ActorCell的attachChild方法，而这个方法调用了makeChild，最重要的代码如下面红色框表示，调用了ActorCell.provider的actorOf，通过initChild加入了当前的children，调用actor的start方法，actor创建结束。children具体的数据结构我们暂时也不再深入研究。
​![](https://cdn.nlark.com/yuque/0/2021/png/804884/1632368418908-84ef30f9-d20a-498d-a80a-b7ed3effcd07.png#clientId=uf121db86-9ab9-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=uddb7372a&margin=%5Bobject%20Object%5D&originHeight=739&originWidth=1051&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=none&taskId=u8be0db94-7783-4575-b4ed-3e09e3855bf&title=)
   不过，通过ActorCell的构造函数以及继承关系我们知道上面代码中的provider就是ActorSystemImpl中的provider，也就是默认的LocalActorRefProvider，那我们还得回溯代码去看具体的actorOf函数。
![](https://cdn.nlark.com/yuque/0/2021/png/804884/1632368419031-8ab797b9-ef2c-4f45-bb1e-2e8942a85302.png#clientId=uf121db86-9ab9-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=u9c3fb891&margin=%5Bobject%20Object%5D&originHeight=748&originWidth=1119&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=none&taskId=u92b87966-8b63-44dd-a414-fac6296f2a7&title=)
   由于代码很长，可以将无关的代码折叠起来。如上图，会先判断当前有没有router，很显然没有；又用deployer中的配置，判断有没有对当前的dispatcher和mailboxType进行覆盖，很显然也没有，一切保持原样。最后一个if语句，如果async为true则创建RepointableActorRef，根据上面的代码分析，async是true。RepointableActorRef创建完成之后，调用了initialize完成初始化。
```java
/**
 * Initialize: make a dummy cell which holds just a mailbox, then tell our
 * supervisor that we exist so that he can create the real Cell in
 * handleSupervise().
 *
 * Call twice on your own peril!
 *
 * This is protected so that others can have different initialization.
 */
def initialize(async: Boolean): this.type =
  underlying match {
    case null ⇒
      swapCell(new UnstartedCell(system, this, props, supervisor))
      swapLookup(underlying)
      supervisor.sendSystemMessage(Supervise(this, async))
      if (!async) point(false)
      this
    case other ⇒ throw new IllegalStateException("initialize called more than once!")
  }
 
/**
 * This method is supposed to be called by the supervisor in handleSupervise()
 * to replace the UnstartedCell with the real one. It assumes no concurrent
 * modification of the `underlying` field, though it is safe to send messages
 * at any time.
 */
def point(catchFailures: Boolean): this.type
```
在initialize中，给supervisor给监督者发发送了一个Supervise消息，以便监督自己；然后调用了point，具体含义可参考官方源码的注释。其实RepointableActorRef还是比较麻烦的，读者有兴趣可以自己研究，不过我个人感觉它应该主要是为了防止在actor重新创建或新建的过程中消息不会丢失设计的。具体我也没有太明白，后面再深入研究了。
到这里system.actorOf基本就算执行结束，它返回了一个InternalActorRef，这是ActorRef的一个子类。这样，后续的代码就可以使用 ！ 或tell给actor发送消息了。不过我们虽然大致研究了actor的创建过程，但并没有进入深入的研究，比如，我们自身的actor的实现类是在什么时候初始化的并不知道。当然这并不妨碍我们继续研究akka的源码。
​

## 2.参考
[https://www.cnblogs.com/gabry/p/9339785.html](https://www.cnblogs.com/gabry/p/9339785.html)
