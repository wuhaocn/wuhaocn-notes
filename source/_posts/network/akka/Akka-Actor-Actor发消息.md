---
title: Akka-Actor-Actor发消息

categories:
- network

tag:
- akka

---

## 1.概述


### 1.1 示例
   前面两简单介绍了ActorSystem、actor以及dispatcher和mailbox的创建，下面我们就来看一下actor发消息的内部机制。
```
val system = ActorSystem("firstActorSystem",ConfigFactory.load())
val helloActor = system.actorOf(Props(new HelloActor),"HelloActor")
helloActor ! "Hello"
```
   同样还是回到一个简单的akka应用，通过之前的分析我们知道，helloActor应该是一个RepointableActorRef类型的对象，那么调用 ！ 应该也是调用RepointableActorRef对应的 ！ 方法。
```
def !(message: Any)(implicit sender: ActorRef = Actor.noSender) = underlying.sendMessage(message, sender)
```
### 1.2 解析   
   上面是RepointableActorRef对！方法的实现，其实就是调用underlying.sendMessage。怎么样，underliying是不是似曾相似呢？再来看看underliying的定义，它是一个Cell类，不过获取过程稍显复杂啊。
```
/*
  * H E R E   B E   D R A G O N S !
  *
  * There are two main functions of a Cell: message queueing and child lookup.
  * When switching out the UnstartedCell for its real replacement, the former
  * must be switched after all messages have been drained from the temporary
  * queue into the real mailbox, while the latter must be switched before
  * processing the very first message (i.e. before Cell.start()). Hence there
  * are two refs here, one for each function, and they are switched just so.
  */
 @volatile private var _cellDoNotCallMeDirectly: Cell = _
 @volatile private var _lookupDoNotCallMeDirectly: Cell = _
 
 def underlying: Cell = Unsafe.instance.getObjectVolatile(this, cellOffset).asInstanceOf[Cell]
 def lookup = Unsafe.instance.getObjectVolatile(this, lookupOffset).asInstanceOf[Cell]
 
 @tailrec final def swapCell(next: Cell): Cell = {
   val old = underlying
   if (Unsafe.instance.compareAndSwapObject(this, cellOffset, old, next)) old else swapCell(next)
 }
 
 @tailrec final def swapLookup(next: Cell): Cell = {
   val old = lookup
   if (Unsafe.instance.compareAndSwapObject(this, lookupOffset, old, next)) old else swapLookup(next)
 }
```
     从官网源码的注释来看，这两个cell的功能进行了严格区分。一个用来消息的出队、入队，一个用来查找child。不过从initialize的逻辑来看，刚开始underlying是一个UnstartedCell实例。
```
def sendMessage(msg: Envelope): Unit = {
   if (lock.tryLock(timeout.length, timeout.unit)) {
     try {
       val cell = self.underlying
       if (cellIsReady(cell)) {
         cell.sendMessage(msg)
       } else if (!queue.offer(msg)) {
         system.eventStream.publish(Warning(self.path.toString, getClass, "dropping message of type " + msg.message.getClass + " due to enqueue failure"))
         system.deadLetters.tell(DeadLetter(msg.message, msg.sender, self), msg.sender)
       } else if (Mailbox.debug) println(s"$self temp queueing ${msg.message} from ${msg.sender}")
     } finally lock.unlock()
   } else {
     system.eventStream.publish(Warning(self.path.toString, getClass, "dropping message of type" + msg.message.getClass + " due to lock timeout"))
     system.deadLetters.tell(DeadLetter(msg.message, msg.sender, self), msg.sender)
   }
 }
```
     上面是UnstartedCell的sendMessage的具体实现。从代码来看如果underlying已经ready的话，就调用相应的sendMessage方法否则就把消息暂存到JLinkedList里面，其实就是java的LinkedList；如果暂存失败，则把消息发送到eventStream，并转发给deadLetters。那么underlying怎么判断是ready呢？
```
private[this] final def cellIsReady(cell: Cell): Boolean = (cell ne this) && (cell ne null)
```
     这判断方法也挺简单，就是判断RepointableActorRef的underlying和当前的cell指针是不是相同。还记得underlying是怎么初始化的吗？没错，就是一个UnstartedCell。那么underlying什么时候被修改了呢，或者说什么时候ready了呢？这个就要研究RepointableActorRef中用到underlying字段的地方了。
```
def point(catchFailures: Boolean): this.type =
    underlying match {
      case u: UnstartedCell ⇒
        val cell =
          try newCell(u)
          catch {
            case NonFatal(ex) if catchFailures ⇒
              val safeDispatcher = system.dispatchers.defaultGlobalDispatcher
              new ActorCell(system, this, props, safeDispatcher, supervisor).initWithFailure(ex)
          }
        /*
         * The problem here was that if the real actor (which will start running
         * at cell.start()) creates children in its constructor, then this may
         * happen before the swapCell in u.replaceWith, meaning that those
         * children cannot be looked up immediately, e.g. if they shall become
         * routees.
         */
        swapLookup(cell)
        cell.start()
        u.replaceWith(cell)
        this
      case null ⇒ throw new IllegalStateException("underlying cell is null")
      case _    ⇒ this // this happens routinely for things which were created async=false
    }
```
       还记得initialize最后调用了point么，我们来看看这个函数是干啥的？看到没，它在判断underlying的类型，如果是UnstartedCell做了什么呢？简单来说就是它创建了一个新的ActorCell，然后调用新ActorCell的start函数，最后调用UnstartedCell的replaceWith函数。那么replaceWith做了什么呢？
```
def replaceWith(cell: Cell): Unit = locked {
  try {
    def drainSysmsgQueue(): Unit = {
      // using while in case a sys msg enqueues another sys msg
      while (sysmsgQueue.nonEmpty) {
        var sysQ = sysmsgQueue.reverse
        sysmsgQueue = SystemMessageList.LNil
        while (sysQ.nonEmpty) {
          val msg = sysQ.head
          sysQ = sysQ.tail
          msg.unlink()
          cell.sendSystemMessage(msg)
        }
      }
    }
 
    drainSysmsgQueue()
 
    while (!queue.isEmpty) {
      cell.sendMessage(queue.poll())
      // drain sysmsgQueue in case a msg enqueues a sys msg
      drainSysmsgQueue()
    }
  } finally {
    self.swapCell(cell)
  }
}
```
       代码也比较简单，就是先把系统消息取出发送给新的Cell，然后把原来暂存的消息通过sendMessage转发给新Cell。最后调用了原来的swapCell函数，用刚才新创建的ActorCell替换underlying。
```
/**
   * This is called by activate() to obtain the cell which is to replace the
   * unstarted cell. The cell must be fully functional.
   */
  def newCell(old: UnstartedCell): Cell =
    new ActorCell(system, this, props, dispatcher, supervisor).init(sendSupervise = false, mailboxType)
```
         我们来看看新ActorCell的创建代码，也比较简单，就是new了一个ActorCell，然后调用init进行初始化。其实分析到这里，基本也就清楚了，helloActor ! "Hello"最终调用了ActorCell的sendMessage方法。不过在ActorCell里面并没有直接找到sendMessage的方法，这是为啥呢？是不是我们分析错了呢。在分析一下newCell方法我们会发现，它并没有直接返回ActorCell，而是返回了ActorCell调用你init之后的对象，我们似乎没有分析init，那就继续看吧。
通过追踪代码我们发现，init这是ActorCell从Dispatch继承的方法。
```
/**
   * Initialize this cell, i.e. set up mailboxes and supervision. The UID must be
   * reasonably different from the previous UID of a possible actor with the same path,
   * which can be achieved by using ThreadLocalRandom.current.nextInt().
   */
  final def init(sendSupervise: Boolean, mailboxType: MailboxType): this.type = {
    /*
     * Create the mailbox and enqueue the Create() message to ensure that
     * this is processed before anything else.
     */
    val mbox = dispatcher.createMailbox(this, mailboxType)
 
    /*
     * The mailboxType was calculated taking into account what the MailboxType
     * has promised to produce. If that was more than the default, then we need
     * to reverify here because the dispatcher may well have screwed it up.
     */
    // we need to delay the failure to the point of actor creation so we can handle
    // it properly in the normal way
    val actorClass = props.actorClass
    val createMessage = mailboxType match {
      case _: ProducesMessageQueue[_] if system.mailboxes.hasRequiredType(actorClass) ⇒
        val req = system.mailboxes.getRequiredType(actorClass)
        if (req isInstance mbox.messageQueue) Create(None)
        else {
          val gotType = if (mbox.messageQueue == null) "null" else mbox.messageQueue.getClass.getName
          Create(Some(ActorInitializationException(
            self,
            s"Actor [$self] requires mailbox type [$req] got [$gotType]")))
        }
      case _ ⇒ Create(None)
    }
 
    swapMailbox(mbox)
    mailbox.setActor(this)
 
    // ➡➡➡ NEVER SEND THE SAME SYSTEM MESSAGE OBJECT TO TWO ACTORS ⬅⬅⬅
    mailbox.systemEnqueue(self, createMessage)
 
    if (sendSupervise) {
      // ➡➡➡ NEVER SEND THE SAME SYSTEM MESSAGE OBJECT TO TWO ACTORS ⬅⬅⬅
      parent.sendSystemMessage(akka.dispatch.sysmsg.Supervise(self, async = false))
    }
    this
  }
```


      首先用dispatcher创建了mailbox，那么dispatcher从哪里来的呢？从Dispatch的定义我们看出，继承Dispatch的一定子类必定是一个ActorCell，那么很明显，这个Dispatch就是子类ActorCell的的dispatcher字段。
```
private[akka] trait Dispatch { this: ActorCell ⇒
```
从前面的分析我们知道dispatcher是akka.dispatch.Dispatcher的一个实例，下面是createMailbox函数的具体实现。
```
/**
 * INTERNAL API
 */
protected[akka] def createMailbox(actor: akka.actor.Cell, mailboxType: MailboxType): Mailbox = {
  new Mailbox(mailboxType.create(Some(actor.self), Some(actor.system))) with DefaultSystemMessageQueue
}
```
下面是Mailbox的定义，它继承了ForkJoinTask[Unit] 、SystemMessageQueue、Runnable，这好像可以放到线程池去执行的，不过我们先略过不作分析。
```
/**
 * Mailbox and InternalMailbox is separated in two classes because ActorCell is needed for implementation,
 * but can't be exposed to user defined mailbox subclasses.
 *
 * INTERNAL API
 */
private[akka] abstract class Mailbox(val messageQueue: MessageQueue)
  extends ForkJoinTask[Unit] with SystemMessageQueue with Runnable
```


继续分析init我们发现，它通过swapMailbox方法把新创建的mbox赋值给了mailbox，然后又通过setActor把ActorCell与mailbox进行关联，最后给mailBox发送了一个createMessage。这也不再深入分析，继续回到Dispatch特质。
我们发现ActorCell虽然没有实现sendMessage，但它继承的Dispatch实现了这个方法。
```
def sendMessage(msg: Envelope): Unit =
    try {
      val msgToDispatch =
        if (system.settings.SerializeAllMessages) serializeAndDeserialize(msg)
        else msg
 
      dispatcher.dispatch(this, msgToDispatch)
    } catch handleException
```
很明显，最终调用了dispatcher的dispatch方法，把消息发送出去了。
```
/**
  * INTERNAL API
  */
 protected[akka] def dispatch(receiver: ActorCell, invocation: Envelope): Unit = {
   val mbox = receiver.mailbox
   mbox.enqueue(receiver.self, invocation)
   registerForExecution(mbox, true, false)
 }
```
上面是dispatch的方法，它调用receiver.mailbox的enqueue方法，把消息入队列，然后调用registerForExecution。
```
/**
 * Returns if it was registered
 *
 * INTERNAL API
 */
protected[akka] override def registerForExecution(mbox: Mailbox, hasMessageHint: Boolean, hasSystemMessageHint: Boolean): Boolean = {
  if (mbox.canBeScheduledForExecution(hasMessageHint, hasSystemMessageHint)) { //This needs to be here to ensure thread safety and no races
    if (mbox.setAsScheduled()) {
      try {
        executorService execute mbox
        true
      } catch {
        case e: RejectedExecutionException ⇒
          try {
            executorService execute mbox
            true
          } catch { //Retry once
            case e: RejectedExecutionException ⇒
              mbox.setAsIdle()
              eventStream.publish(Error(e, getClass.getName, getClass, "registerForExecution was rejected twice!"))
              throw e
          }
      }
    } else false
  } else false
}
```
registerForExecution做了什么呢？很明显它修改了Mailbox的状态使其变成_Scheduled_ 。如果设置成功，则把该Mailbox放到executorService去调度。还记不记得Mailbox都实现了哪些接口呢：ForkJoinTask[Unit] 、SystemMessageQueue、Runnable。它当然是可以被线程池调度的啊。
至此消息的发送就已经分析完毕了，通过上面的分析我们知道，发送消息的过程大概就是先把消息通过Mailbox的enque进入队列，当然这默认实现就是akka.dispatch.UnboundedMailbox。Mailbox会在ForkJoinPool（默认是这样的）线程池中申请一个线程进行调度，执行最终的run方法。
​

```
override final def run(): Unit = {
   try {
     if (!isClosed) { //Volatile read, needed here
       processAllSystemMessages() //First, deal with any system messages
       processMailbox() //Then deal with messages
     }
   } finally {
     setAsIdle() //Volatile write, needed here
     dispatcher.registerForExecution(this, false, false)
   }
 }
```
下面是run方法的具体实现，也比较简单，就是调用processAllSystemMessages/processMailbox分别处理系统消息和用户发送的消息，当然不会全部把消息处理完毕，会有一定的限制（dispatch的吞吐量参数）。最后设置mailbox状态为idle，然后又调用了dispatcher.registerForExecution，进入下一次线程调度。mailbox这样以循环的方式对队列中的消息进行处理。
由于时间关系，今天就先分析到这里。我们已经知道了 ！ 的内部细节，它只是把消息放到了mailbox的队列中，然后mailbox被线程池异步调度，循环处理队列中的数据。当然考虑到多线程，这个队列是一个一致性队列，线程安全。下一篇博文，我们会详细介绍processMailbox的功能，下面只是简单的贴出这个函数的源码，读者也可以先简单分析一下。
```
/**
  * Process the messages in the mailbox
  */
 @tailrec private final def processMailbox(
   left:       Int  = java.lang.Math.max(dispatcher.throughput, 1),
   deadlineNs: Long = if (dispatcher.isThroughputDeadlineTimeDefined == true) System.nanoTime + dispatcher.throughputDeadlineTime.toNanos else 0L): Unit =
   if (shouldProcessMessage) {
     val next = dequeue()
     if (next ne null) {
       if (Mailbox.debug) println(actor.self + " processing message " + next)
       actor invoke next
       if (Thread.interrupted())
         throw new InterruptedException("Interrupted while processing actor messages")
       processAllSystemMessages()
       if ((left > 1) && ((dispatcher.isThroughputDeadlineTimeDefined == false) || (System.nanoTime - deadlineNs) < 0))
         processMailbox(left - 1, deadlineNs)
     }
   }
```
