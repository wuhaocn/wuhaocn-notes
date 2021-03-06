---
title: Akka-Remote-心跳保活

categories:
- network

tag:
- akka

---


## 1.ProtocolStateActor
ProtocolStateActor通过状态机维持akka链路状态，
### 1.1 状态维持
 ![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1634639191285-79a34003-0b79-4ecf-8e04-5f848f63f61f.png#clientId=u6855f1a2-4e4f-4&from=paste&height=156&id=u0f73ae17&margin=%5Bobject%20Object%5D&name=image.png&originHeight=312&originWidth=1190&originalType=binary&ratio=1&size=289278&status=done&style=none&taskId=u16ef156f-1aba-4a09-a964-428d101f753&width=595)


![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1634640833009-89727cf1-2a1a-4d5c-89f1-63d50b34be0a.png#clientId=uf0f2e3b1-5d66-4&from=paste&id=u8edecfe1&margin=%5Bobject%20Object%5D&name=image.png&originalType=binary&ratio=1&size=421345&status=done&style=none&taskId=u1bfaa84f-944a-42a5-913f-aaf6de4b335)


- systemEnqueue
```java
if (Mailbox.debug) println(receiver + " having enqueued " + message)
    val currentList = systemQueueGet
    if (currentList.head == NoMessage) {
      if (actor ne null) actor.dispatcher.mailboxes.deadLetterMailbox.systemEnqueue(receiver, message)
} else {
      if (!systemQueuePut(currentList, message :: currentList)) {
        message.unlink()
        systemEnqueue(receiver, message)
      }
}
```

- processMailbox

 
```java
if (next ne null) {
  if (Mailbox.debug) println(actor.self + " processing message " + next)
      actor invoke next
  if (Thread.interrupted())
    throw new InterruptedException("Interrupted while processing actor messages")
     processAllSystemMessages()
  if ((left > 1) && ((dispatcher.isThroughputDeadlineTimeDefined == false) || (System.nanoTime - deadlineNs) < 0))
     processMailbox(left - 1, deadlineNs)
}
```
