---
title: Akka-持久化-消息发送与接收

categories:
- network

tag:
- akka

---


## 1.概述
      在《使用Akka持久化——持久化与快照》一文中介绍了如何使用Akka持久化消息及生成快照。对于集群应用来说，发送者发出消息，只有当收到了接受者的成功回复才应当认为是一次完整的请求和应答（一些RPC框架只提供了远程调用、序列化/反序列化的机制，但是具体调用的成功与否实际是抛给了开发者本人），利用Akka的应答机制很容易实现这些功能。特殊情况下发送者发送了消息，但是最终接受者却没有接收到消息，导致这一情况发生的因素很多（例如：发送者调用完发送接口后，发送者所在进程奔溃了；网络故障；接收者不存在等）。如果这些消息的成功接收与处理对于整个应用而言具有强一致性的要求，那么这些都会导致很多困扰，好在我们可以使用Akka的持久化机制。
​

 发送者在发送消息之前先对消息进行持久化，那么无论任何原因导致没有收到接收者的成功回复时，我们总能有办法从持久化信息中找出那些未被成功回复的消息进行重发（这说明接收者接到的消息有可能会重复，此时需要保证接收者的实现是冥等的）。当接收者收到消息进行处理后需要向发送者发送成功回复，发送者收到回复后的第一个动作应当是对回复内容的持久化，否则有可能在还未真正对成功回复处理时宕机或进程奔溃导致回复消息丢失（在持久化与收到消息之间仍然会存在宕机和进程奔溃的情况，只不过这个时间非常短，因此丢失回复的可能会很低），当持久化回复消息完成后，可以自己慢慢来处理这些确认信息，而不用担心它们丢失了。
​

 本文将根据Akka官网的例子，对其做一些适应性改造后，向大家展示Akka持久化的另一个强大武器——At least once delivery！
[
](https://blog.csdn.net/beliefer/article/details/53929751)
## 2.消息投递规则
 一般而言，消息投递有下面三种情况：

- at-most-once 意味着每条应用了这种机制的消息会被投递0次或1次。可以说这条消息可能会丢失。
- at-least-once 意味着每条应用了这种机制的消息潜在的存在多次投递尝试并保证至少会成功一次。就是说这条消息可能会重复但是不会丢失。
- exactly-once 意味着每条应用了这种机制的消息只会向接收者准确的发送一次。换言之，这种消息既不会丢失也不会重复。

      at-most-once的成本最低且性能最高，因为它在发送完消息后不会尝试去记录任何状态，然后这条消息将被他抛之脑后。at-least-once需要发送者必须认识它所发送过的消息，并对没有收到回复的消息进行发送重试。exactly-once的成本是三者中最高的而且性能却又是三者中最差的，它除了要求发送者有记忆和重试能力，还要求接收者能够认识接收过的消息并能过滤出那些重复的消息投递。Akka的Actor模型一般提供的消息都属于at-most-once，那是因为大多数场景都不需要有状态的消息投递，例如web服务器请求。当你有强一致性需求时，才应该启用Akka的at-least-once机制，那就是你的Actor不再继承自UntypedActor，而是继承自UntypedPersistentActorWithAtLeastOnceDelivery。
## 3.配置
  如果要使用，那么需要在中增加以下的一些配置：
```
at-least-once-delivery {
  redeliver-interval = 20000
  redelivery-burst-limit = 100
}
```
   redeliver-interval用于配置重新进行投递尝试的时间间隔，单位是毫秒。redelivery-burst-limit用于配置每次重新执行投递尝试时发送的最大消息条数。
​

## 4.一致性消息例子


 我们首先来看看本例中用到的消息体MsgSent、Msg、Confirm及MsgConfirmed。MsgSent代表将要发送的消息，但是只用于持久化，持久化完成后会将MsgSent转换为Msg进行发送。也就是说Msg才会被真正用于消息发送。接收者收到Msg消息后将向发送者回复Confirm消息，需要注意的是Msg和Confirm都有属性deliveryId，此deliveryId由发送者的持久化功能生成，一条Msg消息和其对应的Confirm回复的deliveryId必须一致，否则在利用UntypedPersistentActorWithAtLeastOnceDelivery对回复消息进行确认时会产生严重的bug。发送者收到接收者的Confirm回复后首先将其转换为MsgConfirmed，然后对MsgConfirmed进行持久化，最后调用UntypedPersistentActorWithAtLeastOnceDelivery提供的confirmDelivery方法对回复进行确认。MsgSent、Msg、Confirm及MsgConfirmed的代码实现如下：
```
public interface Persistence {
 
	public static class Msg implements Serializable {
		private static final long serialVersionUID = 1L;
		public final long deliveryId;
		public final String s;
 
		public Msg(long deliveryId, String s) {
			this.deliveryId = deliveryId;
			this.s = s;
		}
	}
 
	public static class Confirm implements Serializable {
		private static final long serialVersionUID = 1L;
		public final long deliveryId;
 
		public Confirm(long deliveryId) {
			this.deliveryId = deliveryId;
		}
	}
 
	public static class MsgSent implements Serializable {
		private static final long serialVersionUID = 1L;
		public final String s;
 
		public MsgSent(String s) {
			this.s = s;
		}
	}
 
	public static class MsgConfirmed implements Serializable {
		private static final long serialVersionUID = 1L;
		public final long deliveryId;
 
		public MsgConfirmed(long deliveryId) {
			this.deliveryId = deliveryId;
		}
	}
 
}
```
### 4.1.服务端
本例中的服务端非常简单，是一个接收处理Msg消息，并向发送者回复Confirm消息的Actor，代码如下:
```
@Named("MyDestination")
@Scope("prototype")
public class MyDestination extends UntypedActor {
	
	LoggingAdapter log = Logging.getLogger(getContext().system(), this);
	
	public void onReceive(Object message) throws Exception {
		if (message instanceof Msg) {
			Msg msg = (Msg) message;
			log.info("receive msg : " + msg.s + ", deliveryId : " + msg.deliveryId);
			getSender().tell(new Confirm(msg.deliveryId), getSelf());
		} else {
			unhandled(message);
		}
	}
}
```
服务端的启动代码如下：
```
logger.info("Start myDestination");
final ActorRef myDestination = actorSystem.actorOf(springExt.props("MyDestination"), "myDestination");
logger.info("Started myDestination");
```
### 4.2.客户端
具体介绍客户端之前，先来列出其实现，代码如下
```
@Named("MyPersistentActor")
@Scope("prototype")
public class MyPersistentActor extends UntypedPersistentActorWithAtLeastOnceDelivery {
	
	LoggingAdapter log = Logging.getLogger(getContext().system(), this);
	
	private final ActorSelection destination;
 
	@Override
	public String persistenceId() {
		return "persistence-id";
	}
 
	public MyPersistentActor(ActorSelection destination) {
		this.destination = destination;
	}
 
	@Override
	public void onReceiveCommand(Object message) {
		if (message instanceof String) {
			String s = (String) message;
			log.info("receive msg : " + s);
			persist(new MsgSent(s), new Procedure<MsgSent>() {
				public void apply(MsgSent evt) {
					updateState(evt);
				}
			});
		} else if (message instanceof Confirm) {
			Confirm confirm = (Confirm) message;
			log.info("receive confirm with deliveryId : " + confirm.deliveryId);
			persist(new MsgConfirmed(confirm.deliveryId), new Procedure<MsgConfirmed>() {
				public void apply(MsgConfirmed evt) {
					updateState(evt);
				}
			});
		} else if (message instanceof UnconfirmedWarning) {
			log.info("receive unconfirmed warning : " + message);
			// After a number of delivery attempts a AtLeastOnceDelivery.UnconfirmedWarning message will be sent to self. The re-sending will still continue, but you can choose to call confirmDelivery to cancel the re-sending. 
			List<UnconfirmedDelivery> list = ((UnconfirmedWarning) message).getUnconfirmedDeliveries();
			for (UnconfirmedDelivery unconfirmedDelivery : list) {
				Msg msg = (Msg) unconfirmedDelivery.getMessage();
				confirmDelivery(msg.deliveryId);
			}
		} else {
			unhandled(message);
		}
	}
 
	@Override
	public void onReceiveRecover(Object event) {
		updateState(event);
	}
 
	void updateState(Object event) {
		if (event instanceof MsgSent) {
			final MsgSent evt = (MsgSent) event;
			deliver(destination, new Function<Long, Object>() {
				public Object apply(Long deliveryId) {
					return new Msg(deliveryId, evt.s);
				}
			});
		} else if (event instanceof MsgConfirmed) {
			final MsgConfirmed evt = (MsgConfirmed) event;
			confirmDelivery(evt.deliveryId);
		}
	}
}
```
正如我们之前所述——要使用at-least-once的能力，就必须继承UntypedPersistentActorWithAtLeastOnceDelivery。有关MsgSent、Msg、Confirm及MsgConfirmed等消息的处理过程已经介绍过，这里不再赘述。我们注意到onReceiveCommand方法还处理了一种名为UnconfirmedWarning的消息，这类消息将在at-least-once机制下进行无限或者一定数量的投递尝试后发送给当前Actor，这里的数量可以通过在at-least-once-delivery配置中增加配置项warn-after-number-of-unconfirmed-attempts来调整，例如：
```
at-least-once-delivery {
  redeliver-interval = 20000
  redelivery-burst-limit = 100
  warn-after-number-of-unconfirmed-attempts = 6
}

```
当你收到UnconfirmedWarning的消息时，说明已经超出了你期望的最大重试次数，此时可以做一些控制了，例如：对于这些消息发送报警、丢弃等。本例中选择了丢弃。
​

UntypedPersistentActorWithAtLeastOnceDelivery的状态由那些尚未被确认的消息和一个序列号组成。UntypedPersistentActorWithAtLeastOnceDelivery本身不会存储这些状态，依然需要你在调用deliver方法投递消息之前，调用persist方法持久化这些事件或消息，以便于当持久化Actor能够在恢复阶段恢复。在恢复阶段，deliver方法并不会将发出消息，此时持久化Actor一面恢复，一面只能等待接收回复。当恢复完成，deliver将发送那些被缓存的消息（除了收到回复，并调用confirmDelivery方法的消息）。
### 4.3.运行例子
本文将率先启动客户端并向服务端发送hello-1，hello-2，hello-3这三消息，但是由于服务端此时并未启动，所以客户端会不断重试，直到重试达到上限或者受到回复并确认。服务端发送消息的代码如下：
```
		logger.info("Start myPersistentActor");
		final String path = "akka.tcp://metadataAkkaSystem@127.0.0.1:2551/user/myDestination";
		final ActorSelection destination = actorSystem.actorSelection(path);
		final ActorRef myPersistentActor = actorSystem.actorOf(springExt.props("MyPersistentActor", destination), "myPersistentActor");
		actorMap.put("myPersistentActor", myPersistentActor);
		logger.info("Started myPersistentActor");
		myPersistentActor.tell("hello-1", null);
		myPersistentActor.tell("hello-2", null);
		myPersistentActor.tell("hello-3", null);
```

客户端发送三条消息后，日志中立马打印出了以下内容：
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1638194881274-1090ae0e-f718-4fe7-a8cb-ad75517df01d.png#clientId=ue70c9369-308a-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=39&id=u3b7e7e90&margin=%5Bobject%20Object%5D&name=image.png&originHeight=78&originWidth=550&originalType=binary&ratio=1&rotation=0&showTitle=false&size=19614&status=done&style=none&taskId=ua51cf7ee-a6c2-4f6b-bccc-9a3501e200c&title=&width=275)
但是一直未受到回复信息，然后我们启动服务端，不一会就看到了以下日志输出：
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1638194890814-0fbb271f-c805-4aeb-ad6e-ea273e911cf1.png#clientId=ue70c9369-308a-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=24&id=u6a72b8d4&margin=%5Bobject%20Object%5D&name=image.png&originHeight=47&originWidth=632&originalType=binary&ratio=1&rotation=0&showTitle=false&size=14867&status=done&style=none&taskId=u00ac55c8-ef21-4ed2-9762-df9011bbf7e&title=&width=316)
我们再来看看客户端，发现已经收到了回复，内容如下：
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1638194898363-0b3dbc2e-6a80-416f-935c-9eb838483a5d.png#clientId=ue70c9369-308a-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=32&id=ufbd72f03&margin=%5Bobject%20Object%5D&name=image.png&originHeight=63&originWidth=631&originalType=binary&ratio=1&rotation=0&showTitle=false&size=19173&status=done&style=none&taskId=u48fb0c4c-13df-4868-b07e-969da1367c6&title=&width=315.5)
### 4.4.总结
通过使用UntypedPersistentActorWithAtLeastOnceDelivery提供的persist、deliver及confirmDelivery等方法可以对整个应用的at-least-once需求，轻松实现在框架层面上一致的实现。
## 参考
​[https://blog.csdn.net/beliefer/article/details/53929751](https://blog.csdn.net/beliefer/article/details/53929751)
