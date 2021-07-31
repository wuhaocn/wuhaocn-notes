---
title: SCTP概要

categories:
- 5G

tag:
- 5G
- NGAP
---

## 1.简介
SCTP(Stream Control Transmission Protocol),流控制传输协议,和UDP，TCP类似
TCP是一种面向连接的协议，提供可靠传输，确保数据有序发送；
UDP是一种面向消息的协议，不能确保数据有序发送
SCTP是后来引入的一种新的协议，提供了和TCP一样的可靠、有序的数据传输功能，同时却能和UDP一样面对消息的方式来进行操作，保护消息边界，有下面一些特性
## 2.SCTP特性

- 多宿主（Multi-Homing）
- 多流（Multi-streaming）
- 初始化保护（Initiation protection）
- 消息分帧（Message framing）
- 可配置的无序发送（Configurable unordered delivery）
- 平滑关闭（Graceful shutdown）

​

### 2.1 多宿主


SCTP里面引入了联合（Association）的概念TCP连接是在两个主机的单个接口之间建立的SCTP可以把多条路径合并到一个联合中，数据可以在任意一个连接路径上进行传输
![](https://cdn.nlark.com/yuque/0/2021/png/804884/1627480915523-b1986537-7174-48d4-a148-fba170b4d657.png#clientId=u48df284e-bf72-4&from=paste&id=u8942af97&margin=%5Bobject%20Object%5D&originHeight=325&originWidth=485&originalType=url&ratio=1&status=done&style=none&taskId=uafde6a16-0d86-4649-9d84-0dcd105a004)
### 2.2 多流
       SCTP可以在一个联合中支持多流机制，每个流（stream）都是独立的。每个流都有各自的编号，编码在SCTP报文中阻塞的流不会影响同一联合中的其他流，可以并行进行传输
![](https://cdn.nlark.com/yuque/0/2021/png/804884/1627480914764-6dbae28f-4e8d-4bf3-9bf9-a53f4d86d378.png#clientId=u48df284e-bf72-4&from=paste&id=u08bbe321&margin=%5Bobject%20Object%5D&originHeight=164&originWidth=463&originalType=url&ratio=1&status=done&style=none&taskId=u612f73a4-99ec-4c4d-85c8-ff80dcdc695)
### 2.3 初始化保护
      TCP中的三次握手机制会被利用来进行DoS（Denial of Service）攻击，通过发送大量的SYN报文最终耗尽服务器的资源SCTP通过引入4次握手机制来避免这种场景：服务器的INIT-ACK中会包含cookie（标识这个连接的唯一上下文）；
客户端使用这个cookie来进行响应。服务器收到这个响应后，才为这个连接分配资源；为了解决4次握手机制带来的时延，SCTP协议还允许在COOKIE-ECHO和COOKIE-ACK报文中传输数据包
![](https://cdn.nlark.com/yuque/0/2021/png/804884/1627480917379-b7cb7c2b-b1cb-4a80-8573-ebe1d246c7c7.png#clientId=u48df284e-bf72-4&from=paste&id=u3a4682d7&margin=%5Bobject%20Object%5D&originHeight=258&originWidth=546&originalType=url&ratio=1&status=done&style=none&taskId=u554b496a-477c-49ba-bcc3-a16bad0a456)
消息分帧
TCP协议是按照字节流的方式进行数据传输的，并不存在消息边界，比如说音频视频都可以通过流的方式进行传递；UDP使用的是消息分帧，发端多大的数据包，收端收到的数据包也是这么大；
![](https://cdn.nlark.com/yuque/0/2021/png/804884/1627480915216-fecb3fa7-5a65-419b-9101-aff14c310912.png#clientId=u48df284e-bf72-4&from=paste&id=u3c6a317d&margin=%5Bobject%20Object%5D&originHeight=202&originWidth=426&originalType=url&ratio=1&status=done&style=none&taskId=u68997ce0-2001-421a-9e05-de4aaad582a)
可配置的无序发送
TCP能确保数据按照次序发送；UDP无法保证消息有序；SCTP中也可以配置成接受无序的消息；
这样的通信方式对于面向消息的传输非常有用，因为每个消息都是各自独立的，次序并不重要。
平滑关闭
TCP和SCTP都是基于连接的协议，完成传输后都需要有一个拆除连接的过程。TCP中连接的删除是半关闭的，服务的某一端可以关闭自己这端的socket，但是可以继续接受数据。SCTP协议设计的时候考虑这种半关闭的状态实际上很少使用，所以简化了关闭的过程，一旦某一端发起了连接拆除，对等的两端都关闭。
![](https://cdn.nlark.com/yuque/0/2021/png/804884/1627480914813-f11dbcb5-74ba-46f1-a04d-c7e5538f7a5d.png#clientId=u48df284e-bf72-4&from=paste&id=u04833e5f&margin=%5Bobject%20Object%5D&originHeight=258&originWidth=546&originalType=url&ratio=1&status=done&style=none&taskId=u43fedf9d-ba51-4d9a-992d-96bed9ef960)


版权声明：本文为博主原创文章，遵循[CC 4.0 BY-SA](https://creativecommons.org/licenses/by-sa/4.0/)版权协议，转载请附上原文出处链接和本声明。
本文链接：[https://blog.csdn.net/qq_34709713/article/details/106511096](https://blog.csdn.net/qq_34709713/article/details/106511096)
