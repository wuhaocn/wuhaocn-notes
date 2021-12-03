---
title: Akka-Remote-收消息

categories:
- network

tag:
- akka

---


## 1.概述
在上文中，我们分析了网络链接建立的过程，一旦建立就可以正常的收发消息了。

- 发送消息的细节不再分析，因为对于本地的actor来说这个过程相对简单，它只是创立链接然后给指定的netty网路服务发送消息就好了。
- 接收消息就比较麻烦了，因为这对于actor来说是透明的，netty收到消息后如何把消息分发给指定的actor呢？这个分发的过程值得研究研究。
## 2.Actor触发
Akka的收消息是从mailbox里面消费消息,消费成功后触发业务Actor的onReceive，详细调用链如下：
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1632968210922-098d3766-4937-45ca-aa4e-695901e8be11.png#clientId=u36dc08b3-c1fa-4&from=paste&height=390&id=u3bfadf91&margin=%5Bobject%20Object%5D&name=image.png&originHeight=442&originWidth=809&originalType=binary&ratio=1&size=67385&status=done&style=none&taskId=uf5ce47b1-cb0f-44bd-ac69-efa776b5a0f&width=713.5)
调用堆栈如下：
```java
onReceive:19, ClientActor (com.rcloud.akka.server.cmp)
applyOrElse:167, UntypedActor$$anonfun$receive$1 (akka.actor)
aroundReceive:465, Actor$class (akka.actor)
aroundReceive:97, UntypedActor (akka.actor)
receiveMessage:516, ActorCell (akka.actor)
invoke:487, ActorCell (akka.actor)
processMailbox:238, Mailbox (akka.dispatch)
run:220, Mailbox (akka.dispatch)
exec:393, ForkJoinExecutorConfigurator$AkkaForkJoinTask (akka.dispatch)
doExec:260, ForkJoinTask (scala.concurrent.forkjoin)
runTask:1339, ForkJoinPool$WorkQueue (scala.concurrent.forkjoin)
runWorker:1979, ForkJoinPool (scala.concurrent.forkjoin)
run:107, ForkJoinWorkerThread (scala.concurrent.forkjoin)
```
相关值如下：
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1632967070768-848bae89-41a5-4f22-8d49-d10dd5192725.png#clientId=u36dc08b3-c1fa-4&from=paste&height=380&id=uff013532&margin=%5Bobject%20Object%5D&name=image.png&originHeight=760&originWidth=1630&originalType=binary&ratio=1&size=691247&status=done&style=none&taskId=u2651f574-c875-45f2-9368-cc0964303a4&width=815)
那消息是如何推送到mailbox呢，详细见下文分析
## 3.网络层触发
### 3.1 网络管理
之前分析过，在监听创立的过程中，有一个对象非常关键：TcpServerHandler。它负责链接建立、消息收发等功能。TcpServerHandler继承了ServerHandler
```java
private[netty] abstract class ServerHandler(
  protected final val transport:               NettyTransport,
  private final val associationListenerFuture: Future[AssociationEventListener])
  extends NettyServerHelpers with CommonHandlers
```
ServerHandler继承了NettyServerHelpers
```java
private[netty] trait NettyServerHelpers extends SimpleChannelUpstreamHandler with NettyHelpers {
 
  final override def messageReceived(ctx: ChannelHandlerContext, e: MessageEvent): Unit = {
    super.messageReceived(ctx, e)
    onMessage(ctx, e)
  }
 
  final override def exceptionCaught(ctx: ChannelHandlerContext, e: ExceptionEvent): Unit = transformException(ctx, e)
 
  final override def channelConnected(ctx: ChannelHandlerContext, e: ChannelStateEvent): Unit = {
    super.channelConnected(ctx, e)
    onConnect(ctx, e)
  }
 
  final override def channelOpen(ctx: ChannelHandlerContext, e: ChannelStateEvent): Unit = {
    super.channelOpen(ctx, e)
    onOpen(ctx, e)
  }
 
  final override def channelDisconnected(ctx: ChannelHandlerContext, e: ChannelStateEvent): Unit = {
    super.channelDisconnected(ctx, e)
    onDisconnect(ctx, e)
  }
}
```
很明显NettyServerHelpers有一个messageReceived应该就是收到消息时回调的方法，那onMessage在哪里实现呢？TcpServerHandler还继承了TcpHandlers，我们来看看TcpHandlers的onMessage方法。
```java
override def onMessage(ctx: ChannelHandlerContext, e: MessageEvent): Unit = {
   val bytes: Array[Byte] = e.getMessage.asInstanceOf[ChannelBuffer].array()
   if (bytes.length > 0) notifyListener(e.getChannel, InboundPayload(ByteString(bytes)))
 }
```
它最终用InboundPayload封装了收到的数据，并调用了ChannelLocalActor.notifyListener方法。
```java
private[remote] object ChannelLocalActor extends ChannelLocal[Option[HandleEventListener]] {
  override def initialValue(channel: Channel): Option[HandleEventListener] = None
  def notifyListener(channel: Channel, msg: HandleEvent): Unit = get(channel) foreach { _ notify msg }
}
```
ChannelLocalActor可以先把它理解成一个ThreadLocal对象，其他的技术细节读者可以自行谷歌。notifyListener只调用了get，那具体是在哪里set的呢？通过channel变量get到的Option[HandleEventListener]又是在哪里赋值的呢？
```java
override def registerListener(
  channel:             Channel,
  listener:            HandleEventListener,
  msg:                 ChannelBuffer,
  remoteSocketAddress: InetSocketAddress): Unit = ChannelLocalActor.set(channel, Some(listener))
```
很显然是在registerListener时set的值，那registerListener在哪里调用呢？如果读过上一篇的文章，一定会知道ServerHandler.initInbound函数，这个函数调用了CommonHandlers.init
```java
final protected def init(channel: Channel, remoteSocketAddress: SocketAddress, remoteAddress: Address, msg: ChannelBuffer)(
    op: (AssociationHandle ⇒ Any)): Unit = {
    import transport._
    NettyTransport.addressFromSocketAddress(channel.getLocalAddress, schemeIdentifier, system.name, Some(settings.Hostname), None) match {
      case Some(localAddress) ⇒
        val handle = createHandle(channel, localAddress, remoteAddress)
        handle.readHandlerPromise.future.foreach {
          listener ⇒
            registerListener(channel, listener, msg, remoteSocketAddress.asInstanceOf[InetSocketAddress])
            channel.setReadable(true)
        }
        op(handle)
 
      case _ ⇒ NettyTransport.gracefulClose(channel)
    }
  }
```


上面的函数中调用了registerListener，那listener具体在哪里创建的呢，或者是哪个变量对应的值呢？这就需要研究createHandle对象及其返回值是什么了。经过分析还是找到了TcpHandlers这个trait，里面有createHandle的具体实现。
```java
override def createHandle(channel: Channel, localAddress: Address, remoteAddress: Address): AssociationHandle =
  new TcpAssociationHandle(localAddress, remoteAddress, transport, channel)

```
TcpAssociationHandle源码如下
```java
private[remote] class TcpAssociationHandle(
  val localAddress:    Address,
  val remoteAddress:   Address,
  val transport:       NettyTransport,
  private val channel: Channel)
  extends AssociationHandle {
  import transport.executionContext
 
  override val readHandlerPromise: Promise[HandleEventListener] = Promise()
 
  override def write(payload: ByteString): Boolean =
    if (channel.isWritable && channel.isOpen) {
      channel.write(ChannelBuffers.wrappedBuffer(payload.asByteBuffer))
      true
    } else false
 
  override def disassociate(): Unit = NettyTransport.gracefulClose(channel)
}

```
### 3.2 节点管理
      由此可见，readHandlerPromise是一个Promise[HandleEventListener]，并没有具体赋值的逻辑，这就要去使用TcpAssociationHandle的相关代码找相关的赋值逻辑了。TcpAssociationHandle在哪里使用呢？还记得handleInboundAssociation建立连接的过程吗？它最终调用了createAndRegisterEndpoint
```java
private def createAndRegisterEndpoint(handle: AkkaProtocolHandle): Unit = {
  val writing = settings.UsePassiveConnections && !endpoints.hasWritableEndpointFor(handle.remoteAddress)
  eventPublisher.notifyListeners(AssociatedEvent(handle.localAddress, handle.remoteAddress, inbound = true))
 
  val endpoint = createEndpoint(
    handle.remoteAddress,
    handle.localAddress,
    transportMapping(handle.localAddress),
    settings,
    Some(handle),
    writing)
 
  if (writing)
    endpoints.registerWritableEndpoint(handle.remoteAddress, Some(handle.handshakeInfo.uid), endpoint)
  else {
    endpoints.registerReadOnlyEndpoint(handle.remoteAddress, endpoint, handle.handshakeInfo.uid)
    if (!endpoints.hasWritableEndpointFor(handle.remoteAddress))
      endpoints.removePolicy(handle.remoteAddress)
  }
}
```
createAndRegisterEndpoint拿着一个连接实例AkkaProtocolHandle创建了一个endpoint，其中有个很关键的字段writing，它是true还是false呢？UsePassiveConnections默认为true，且经分析!endpoints.hasWritableEndpointFor(handle.remoteAddress)应该也是true，所以writing是true
```java
# Reuse inbound connections for outbound messages
use-passive-connections = on
```
ReliableDeliverySupervisor其实是对EndpointWriter的代理。在创建ReliableDeliverySupervisor的过程中AkkaProtocolHandle是作为参数传入的，也就监听到连接消息后创建的handle。而在创建EndpointWriter的过程中，这个handle又是作为第一个参数传入了EndpointWriter。我们来看看EndpointWriter是如何使用这个handle的。
```java
override def preStart(): Unit = {
   handle match {
     case Some(h) ⇒
       reader = startReadEndpoint(h)
     case None ⇒
       transport.associate(remoteAddress, refuseUid).map(Handle(_)) pipeTo self
   }
 }
```
在preStart时，handle应该是有值的，如果有值，就调用了startReadEndpoint(h)方法。
```java
private def startReadEndpoint(handle: AkkaProtocolHandle): Some[ActorRef] = {
    val newReader =
      context.watch(context.actorOf(
        RARP(context.system).configureDispatcher(EndpointReader.props(localAddress, remoteAddress, transport, settings, codec,
          msgDispatch, inbound, handle.handshakeInfo.uid, reliableDeliverySupervisor, receiveBuffers)).withDeploy(Deploy.local),
        "endpointReader-" + AddressUrlEncoder(remoteAddress) + "-" + readerId.next()))
    handle.readHandlerPromise.success(ActorHandleEventListener(newReader))
    Some(newReader)
  }
```
startReadEndpoint做了什么呢？它又创建了一个Actor：EndpointReader！！！好多中间的actor创建。创建之后，调用了handle.readHandlerPromise.success(ActorHandleEventListener(newReader))给handle.readHandlerPromise。还记得ActorHandleEventListener吗，它就是把收到的消息转发了对应的actor，此处就是newReader。
![](https://cdn.nlark.com/yuque/0/2021/png/804884/1632652170834-4126b27a-81fd-41d9-858f-5315162d46e9.png#clientId=u15d7a13d-fab5-4&from=paste&id=u69c57aba&margin=%5Bobject%20Object%5D&originHeight=494&originWidth=931&originalType=url&ratio=1&status=done&style=none&taskId=u48b42796-f94c-4a82-b9a1-c5dbd8013e6)
### 3.3 消息解码
EndpointReader如何处理InboundPayload消息呢？首先解码收到的消息，然后给创建它的reliableDelivery发送ack消息。
```java
override def decodeMessage(
  raw:          ByteString,
  provider:     RemoteActorRefProvider,
  localAddress: Address): (Option[Ack], Option[Message]) = {
  val ackAndEnvelope = AckAndEnvelopeContainer.parseFrom(raw.toArray)
 
  val ackOption = if (ackAndEnvelope.hasAck) {
    import scala.collection.JavaConverters._
    Some(Ack(SeqNo(ackAndEnvelope.getAck.getCumulativeAck), ackAndEnvelope.getAck.getNacksList.asScala.map(SeqNo(_)).toSet))
  } else None
 
  val messageOption = if (ackAndEnvelope.hasEnvelope) {
    val msgPdu = ackAndEnvelope.getEnvelope
    Some(Message(
      recipient = provider.resolveActorRefWithLocalAddress(msgPdu.getRecipient.getPath, localAddress),
      recipientAddress = AddressFromURIString(msgPdu.getRecipient.getPath),
      serializedMessage = msgPdu.getMessage,
      senderOption =
        if (msgPdu.hasSender) OptionVal(provider.resolveActorRefWithLocalAddress(msgPdu.getSender.getPath, localAddress))
        else OptionVal.None,
      seqOption =
        if (msgPdu.hasSeq) Some(SeqNo(msgPdu.getSeq)) else None))
  } else None
 
  (ackOption, messageOption)
}

```


上面是decodeMessage的源码，消息最终被decode成了Message对象。
```java
final case class Message(
  recipient:         InternalActorRef,
  recipientAddress:  Address,
  serializedMessage: SerializedMessage,
  senderOption:      OptionVal[ActorRef],
  seqOption:         Option[SeqNo]) extends HasSequenceNumber {
 
  def reliableDeliveryEnabled = seqOption.isDefined
 
  override def seq: SeqNo = seqOption.get
}
```


默认情况下reliableDeliveryEnabled是false的，因为发送出去的msgPdu是没有getSeq的，因为默认的tcp是保证消息发送的。所以EndpointReader收到消息后调用了msgDispatch.dispatch把消息分发出去了。根据上下文msgDispatch是在EndpointWriter创建的，代码如下。
```java
	
val msgDispatch = new DefaultMessageDispatcher(extendedSystem, provider, markLog)
```
DefaultMessageDispatcher.dispatch不再具体分析，它就是把消息tell给了Message.recipient，而recipient是一个InternalActorRef，对的，你没有看错，这就是一个InternalActorRef，是不是很神奇，payload解码之后直接就有目标actor的InternalActorRef了？？！！那我们就得好好看看是如何对payload进行解码的了。
在decodeMessage函数中，有两处代码非常关键：“recipient = provider.resolveActorRefWithLocalAddress(msgPdu.getRecipient.getPath, localAddress)”、“if (msgPdu.hasSender) OptionVal(provider.resolveActorRefWithLocalAddress(msgPdu.getSender.getPath, localAddress))”。都是调用provider.resolveActorRefWithLocalAddress函数通过actor的path转化成了对应actor的ActorRef，很显然provider就是RemoteActorRefProvider。
```java
/**
   * INTERNAL API
   * Called in deserialization of incoming remote messages where the correct local address is known.
   */
  private[akka] def resolveActorRefWithLocalAddress(path: String, localAddress: Address): InternalActorRef = {
    path match {
      case ActorPathExtractor(address, elems) ⇒
        if (hasAddress(address))
          local.resolveActorRef(rootGuardian, elems)
        else try {
          new RemoteActorRef(transport, localAddress, RootActorPath(address) / elems, Nobody, props = None, deploy = None)
        } catch {
          case NonFatal(e) ⇒
            log.warning("Error while resolving ActorRef [{}] due to [{}]", path, e.getMessage)
            new EmptyLocalActorRef(this, RootActorPath(address) / elems, eventStream)
        }
      case _ ⇒
        log.debug("Resolve (deserialization) of unknown (invalid) path [{}], using deadLetters.", path)
        deadLetters
    }
  }
```
resolveActorRefWithLocalAddress也很简单，如果目标address包含在本机范围，就调用local.resolveActorRef，否则就创建RemoteActorRef，关于RemoteActorRef的作用这里不再讲解。
```java
/**
 * INTERNAL API
 */
private[akka] def resolveActorRef(ref: InternalActorRef, pathElements: Iterable[String]): InternalActorRef =
  if (pathElements.isEmpty) {
    log.debug("Resolve (deserialization) of empty path doesn't match an active actor, using deadLetters.")
    deadLetters
  } else ref.getChild(pathElements.iterator) match {
    case Nobody ⇒
      if (log.isDebugEnabled)
        log.debug(
          "Resolve (deserialization) of path [{}] doesn't match an active actor. " +
            "It has probably been stopped, using deadLetters.",
          pathElements.mkString("/"))
      new EmptyLocalActorRef(system.provider, ref.path / pathElements, eventStream)
    case x ⇒ x
  }
```
LocalActorRefProvider.resolveActorRef也比较简单，就是调用ref.getChild，而ref是LocalActorRefProvider.rootGuardian，其实就是在本地范围内从root向下查找对应的ActorRef。
既然在收到消息时，是通过ActorPath找到对应的ActorRef的，那么发送消息的时候一定有把ActorRef转化成ActorPath的地方，关于这点我也带领大家验证一下。在之前的文章，我们分析过，发送消息是通过EndpointWriter.writeSend发送的，那就再来回顾一下这个函数。
​

```java
def writeSend(s: Send): Boolean = try {
    handle match {
      case Some(h) ⇒
        if (provider.remoteSettings.LogSend && log.isDebugEnabled) {
          def msgLog = s"RemoteMessage: [${s.message}] to [${s.recipient}]<+[${s.recipient.path}] from [${s.senderOption.getOrElse(extendedSystem.deadLetters)}]"
          log.debug("sending message {}", msgLog)
        }
 
        val pdu = codec.constructMessage(
          s.recipient.localAddressToUse,
          s.recipient,
          serializeMessage(s.message),
          s.senderOption,
          seqOption = s.seqOpt,
          ackOption = lastAck)
 
        val pduSize = pdu.size
        remoteMetrics.logPayloadBytes(s.message, pduSize)
 
        if (pduSize > transport.maximumPayloadBytes) {
          val reason = new OversizedPayloadException(s"Discarding oversized payload sent to ${s.recipient}: max allowed size ${transport.maximumPayloadBytes} bytes, actual size of encoded ${s.message.getClass} was ${pdu.size} bytes.")
          log.error(reason, "Transient association error (association remains live)")
          true
        } else {
          val ok = h.write(pdu)
          if (ok) {
            ackDeadline = newAckDeadline
            lastAck = None
          }
          ok
        }
 
      case None ⇒
        throw new EndpointException("Internal error: Endpoint is in state Writing, but no association handle is present.")
    }
  } catch {
    case e: NotSerializableException ⇒
      log.error(e, "Serializer not defined for message type [{}]. Transient association error (association remains live)", s.message.getClass)
      true
    case e: IllegalArgumentException ⇒
      log.error(e, "Serializer not defined for message type [{}]. Transient association error (association remains live)", s.message.getClass)
      true
    case e: MessageSerializer.SerializationException ⇒
      log.error(e, "{} Transient association error (association remains live)", e.getMessage)
      true
    case e: EndpointException ⇒
      publishAndThrow(e, Logging.ErrorLevel)
    case NonFatal(e) ⇒
      publishAndThrow(new EndpointException("Failed to write message to the transport", e), Logging.ErrorLevel)
  }
```


在发送之前，调用了codec.constructMessage把消息相关的数据都编码进了pdu，具体如何进行编码的呢？
​

```java
override def constructMessage(
    localAddress:      Address,
    recipient:         ActorRef,
    serializedMessage: SerializedMessage,
    senderOption:      OptionVal[ActorRef],
    seqOption:         Option[SeqNo]       = None,
    ackOption:         Option[Ack]         = None): ByteString = {
 
    val ackAndEnvelopeBuilder = AckAndEnvelopeContainer.newBuilder
 
    val envelopeBuilder = RemoteEnvelope.newBuilder
 
    envelopeBuilder.setRecipient(serializeActorRef(recipient.path.address, recipient))
    senderOption match {
      case OptionVal.Some(sender) ⇒ envelopeBuilder.setSender(serializeActorRef(localAddress, sender))
      case OptionVal.None         ⇒
    }
 
    seqOption foreach { seq ⇒ envelopeBuilder.setSeq(seq.rawValue) }
    ackOption foreach { ack ⇒ ackAndEnvelopeBuilder.setAck(ackBuilder(ack)) }
    envelopeBuilder.setMessage(serializedMessage)
    ackAndEnvelopeBuilder.setEnvelope(envelopeBuilder)
 
    ByteString.ByteString1C(ackAndEnvelopeBuilder.build.toByteArray) //Reuse Byte Array (naughty!)
  }
```


看到serializeActorRef了吗，它把ActorRef（这里分别是recipient和sender）进行了序列化。
```java
private def serializeActorRef(defaultAddress: Address, ref: ActorRef): ActorRefData = {
    ActorRefData.newBuilder.setPath(
      if (ref.path.address.host.isDefined) ref.path.toSerializationFormat else ref.path.toSerializationFormatWithAddress(defaultAddress)).build()
  }
```
其实serializeActorRef也比较简单，如果当前ActorRef是本地（有host字段）则直接调用path.toSerializationFormat，否则调用toSerializationFormatWithAddress(defaultAddress)
```java
/**
 * Generate full String representation including the
 * uid for the actor cell instance as URI fragment.
 * This representation should be used as serialized
 * representation instead of `toString`.
 */
def toSerializationFormat: String
 
/**
 * Generate full String representation including the uid for the actor cell
 * instance as URI fragment, replacing the Address in the RootActor Path
 * with the given one unless this path’s address includes host and port
 * information. This representation should be used as serialized
 * representation instead of `toStringWithAddress`.
 */
def toSerializationFormatWithAddress(address: Address): String
```
toSerializationFormat和toSerializationFormatWithAddress的功能官网注释已经解释的很清楚，我就不啰嗦了，不过这直接验证了在发送消息时把ActorRef序列化成对应ActorPath的String的猜测。那么在收到消息时就可以通过ActorPath找到具体的ActorRef了。
至此remote模式下收发消息的过程我们就分析清楚了，如果还有不清楚的小伙伴就再把之前的文章复习一下，当然还可以在下面留言讨论。
​

## 参考
[https://www.cnblogs.com/gabry/p/9390621.html](https://www.cnblogs.com/gabry/p/9390621.html)
