---
title: MySQL连接挂死原因分析

categories:
- MySQL

tag:
- MySQL
---


## 1.背景
近期由测试反馈的问题有点多，其中关于系统可靠性测试提出的问题令人感到头疼，一来这类问题有时候属于“偶发”现象，难以在环境上快速复现；二来则是可靠性问题的定位链条有时候变得很长，极端情况下可能要从 a 服务追踪到 z 服务，或者是从应用代码追溯到硬件层面。
本次分享的是一次关于 mysql 高可用问题的定位过程，其中曲折颇多但问题本身却比较有些代表性，遂将其记录以供参考。
### 1.1 业务架构
首先，本系统以 mysql 作为主要的数据存储部件。整一个是典型的微服务架构（springboot + springcloud），持久层则采用了如下几个组件：

- mybatis，实现 sql <-> method 的映射
- hikaricp，实现数据库连接池
- mariadb-java-client，实现 jdbc 驱动

在 mysql 服务端部分，后端采用了双主架构，前端以 keepalived 结合浮动ip（vip）做一层高可用。如下
![image.png](https://cdn.nlark.com/yuque/0/2022/png/804884/1651111231100-ea7fc92f-bb61-45d7-8fdb-f9ce157b3ac9.png#clientId=u7254b6cc-7da7-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=304&id=ud9a0200d&margin=%5Bobject%20Object%5D&name=image.png&originHeight=410&originWidth=558&originalType=binary&ratio=1&rotation=0&showTitle=false&size=26491&status=done&style=none&taskId=ua54129ca-e6f8-4b36-8161-b52b1067d3b&title=&width=414)
说明

-  mysql 部署两台实例，设定为互为主备的关系。
-  为每台 mysql 实例部署一个 keepalived 进程，由 keepalived 提供 vip 高可用的故障切换。实际上，keepalived 和 mysql 都实现了容器化，而 vip 端口则映射到 vm 上的 nodeport 服务端口上。
-  业务服务一律使用 vip 进行数据库访问。

      keepalived 是基于 vrrp 协议实现了路由层转换的，在同一时刻，vip 只会指向其中的一个虚拟机（master）。当主节点发生故障时，其他的 keepalived 会检测到问题并重新选举出新的 master，此后 vip 将切换到另一个可用的 mysql 实例节点上。这样一来，mysql 数据库就拥有了基础的高可用能力。
     另外一点，keepalived 还会对 mysql 实例进行定时的健康检查，一旦发现 mysql 实例不可用会将自身进程杀死，进而再触发 vip 的切换动作。
### 1.2 问题现象
本次的测试用例也是基于虚拟机故障的场景来设计的：
持续以较小的压力向业务服务发起访问，随后将其中一台 mysql 的容器实例(master)重启。按照原有的评估，业务可能会产生很小的抖动，但其中断时间应该保持在秒级。
然而经过多次的测试后发现，在重启 mysql 主节点容器之后，有一定的概率会出现业务却再也无法访问的情况！
## 2.分析过程
      在发生问题之后，开发同学的第一反应是 mysql 的高可用机制出了问题。由于此前曾经出现过由于 keepalived 配置不当导致 vip 未能及时切换的问题，因此对其已经有所戒备。先是经过一通的排查，然后并没有找到 keepalived 任何配置上的毛病。然后在没有办法的情况下，重新测试了几次，问题又复现了。
紧接着，我们提出了几个疑点：

- 1.keepalived 会根据 mysql 实例的可达性进行判断，会不会是健康检查出了问题？

但在本次测试场景中，mysql 容器销毁会导致 keepalived 的端口探测产生失败，这同样会导致 keepalived 失效。如果 keepalived 也发生了中止，那么 vip 应该能自动发生抢占。而通过对比两台虚拟机节点的信息后，发现 vip 的确发生了切换。

- 2. 业务进程所在的容器是否发生了网络不可达的问题？

尝试进入容器，对当前发生切换后的浮动ip、端口执行 telnet 测试，发现仍然能访问成功。
### 2.1 连接池
       在排查前面两个疑点之后，我们只能将目光转向了业务服务的db客户端上。从日志上看，在产生故障的时刻，业务侧的确出现了一些异常，如下：
```java
unable to acquire jdbc connection [n/a]

java.sql.sqltransientconnectionexception: hikaripool-1 - connection is not available, request timed out after 30000ms.

    at com.zaxxer.hikari.pool.hikaripool.createtimeoutexception(hikaripool.java:669) ~[hikaricp-2.7.9.jar!/:?]

    at com.zaxxer.hikari.pool.hikaripool.getconnection(hikaripool.java:183) ~[hikaricp-2.7.9.jar!/:?] 

    ...
```
      这里提示的是业务操作获取连接超时了（超过了30秒）。那么，会不会是连接数不够用呢？业务接入采用的是 hikaricp 连接池，这也是市面上流行度很高的一款组件了。我们随即检查了当前的连接池配置，如下：
```java
//最小空闲连接数
spring.datasource.hikari.minimum-idle=10
//连接池最大大小
spring.datasource.hikari.maximum-pool-size=50
//连接最大空闲时长
spring.datasource.hikari.idle-timeout=60000
//连接生命时长
spring.datasource.hikari.max-lifetime=1800000
//获取连接的超时时长
spring.datasource.hikari.connection-timeout=30000

```
其中 注意到 hikari 连接池配置了 minimum-idle = 10，也就是说，就算在没有任何业务的情况下，连接池应该保证有 10 个连接。更何况当前的业务访问量极低，不应该存在连接数不够使用的情况。除此之外，另外一种可能性则可能是出现了“僵尸连接”，也就是说在重启的过程中，连接池一直没有释放这些不可用的连接，最终造成没有可用连接的结果。开发同学对"僵尸链接"的说法深信不疑，倾向性的认为这很可能是来自于 hikaricp 组件的某个 bug…于是开始走读 hikaricp 的源码，发现应用层向连接池请求连接的一处代码如下：
```java
public class hikaripool{
 
   //获取连接对象入口
   public connection getconnection(final long hardtimeout) throws sqlexception
   {
      suspendresumelock.acquire();
      final long starttime = currenttime();
 
      try {
         //使用预设的30s 超时时间
         long timeout = hardtimeout;
         do {
            //进入循环，在指定时间内获取可用连接
            //从 connectionbag 中获取连接
            poolentry poolentry = connectionbag.borrow(timeout, milliseconds);
            if (poolentry == null) {
               break; // we timed out... break and throw exception
            }
 
            final long now = currenttime();
            //连接对象被标记清除或不满足存活条件时，关闭该连接
            if (poolentry.ismarkedevicted() || (elapsedmillis(poolentry.lastaccessed, now) > alivebypasswindowms && !isconnectionalive(poolentry.connection))) {
               closeconnection(poolentry, poolentry.ismarkedevicted() ? evicted_connection_message : dead_connection_message);
               timeout = hardtimeout - elapsedmillis(starttime);
            }
            //成功获得连接对象
            else {
               metricstracker.recordborrowstats(poolentry, starttime);
               return poolentry.createproxyconnection(leaktaskfactory.schedule(poolentry), now);
            }
         } while (timeout > 0l);
 
         //超时了，抛出异常
         metricstracker.recordborrowtimeoutstats(starttime);
         throw createtimeoutexception(starttime);
      }
      catch (interruptedexception e) {
         thread.currentthread().interrupt();
         throw new sqlexception(poolname + " - interrupted during connection acquisition", e);
      }
      finally {
         suspendresumelock.release();
      }
   }
}
```
      getconnection() 方法展示了获取连接的整个流程，其中 connectionbag 是用于存放连接对象的容器对象。如果从 connectionbag 获得的连接不再满足存活条件，那么会将其手动关闭，代码如下：
```java
void closeconnection(final poolentry poolentry, final string closurereason)
   {
      //移除连接对象
      if (connectionbag.remove(poolentry)) {
         final connection connection = poolentry.close();
         //异步关闭连接
         closeconnectionexecutor.execute(() -> {
            quietlycloseconnection(connection, closurereason);
            //由于可用连接变少，将触发填充连接池的任务
            if (poolstate == pool_normal) {
               fillpool();
            }
         });
      }
   }
```
    注意到，只有当连接满足下面条件中的其中一个时，会被执行 close。

-  ismarkedevicted() 的返回结果是 true，即标记为清除，如果连接存活时间超出最大生存时间(maxlifetime)，或者距离上一次使用超过了idletimeout，会被定时任务标记为清除状态，清除状态的连接在获取的时候才真正 close。
-  500ms 内没有被使用，且连接已经不再存活，即 isconnectionalive() 返回 false

由于我们把 idletimeout 和 maxlifetime 都设置得非常大，因此需重点检查 isconnectionalive 方法中的判断，如下：
```java
public class poolbase{
 
   //判断连接是否存活
   boolean isconnectionalive(final connection connection)
   {
      try {
         try {
            //设置 jdbc 连接的执行超时
            setnetworktimeout(connection, validationtimeout);
 
            final int validationseconds = (int) math.max(1000l, validationtimeout) / 1000;
 
            //如果没有设置 testquery，使用 jdbc4 的校验接口
            if (isusejdbc4validation) {
               return connection.isvalid(validationseconds);
            }
 
            //使用 testquery（如 select 1）语句对连接进行探测
            try (statement statement = connection.createstatement()) {
               if (isnetworktimeoutsupported != true) {
                  setquerytimeout(statement, validationseconds);
               }
 
               statement.execute(config.getconnectiontestquery());
            }
         }
         finally {
            setnetworktimeout(connection, networktimeout);
 
            if (isisolateinternalqueries && !isautocommit) {
               connection.rollback();
            }
         }
 
         return true;
      }
      catch (exception e) {
         //发生异常时，将失败信息记录到上下文
         lastconnectionfailure.set(e);
         logger.warn("{} - failed to validate connection {} ({}). possibly consider using a shorter maxlifetime value.",
                     poolname, connection, e.getmessage());
         return false;
      }
   }
 
}
```
       我们看到，在poolbase.isconnectionalive 方法中对连接执行了一系列的探测，如果发生异常还会将异常信息记录到当前的线程上下文中。随后，在 hikaripool 抛出异常时会将最后一次检测失败的异常也一同收集，如下：
```java
private sqlexception createtimeoutexception(long starttime)
{
   logpoolstate("timeout failure ");
   metricstracker.recordconnectiontimeout();
 
   string sqlstate = null;
   //获取最后一次连接失败的异常
   final throwable originalexception = getlastconnectionfailure();
   if (originalexception instanceof sqlexception) {
      sqlstate = ((sqlexception) originalexception).getsqlstate();
   }
   //抛出异常
   final sqlexception connectionexception = new sqltransientconnectionexception(poolname + " - connection is not available, request timed out after " + elapsedmillis(starttime) + "ms.", sqlstate, originalexception);
   if (originalexception instanceof sqlexception) {
      connectionexception.setnextexception((sqlexception) originalexception);
   }
 
   return connectionexception;
}
```

这里的异常消息和我们在业务服务中看到的异常日志基本上是吻合的，即除了超时产生的 “connection is not available, request timed out after xxxms” 消息之外，日志中还伴随输出了校验失败的信息：
```java
caused by: java.sql.sqlexception: connection.setnetworktimeout cannot be called on a closed connection

    at org.mariadb.jdbc.internal.util.exceptions.exceptionmapper.getsqlexception(exceptionmapper.java:211) ~[mariadb-java-client-2.2.6.jar!/:?]

    at org.mariadb.jdbc.mariadbconnection.setnetworktimeout(mariadbconnection.java:1632) ~[mariadb-java-client-2.2.6.jar!/:?]

    at com.zaxxer.hikari.pool.poolbase.setnetworktimeout(poolbase.java:541) ~[hikaricp-2.7.9.jar!/:?]

    at com.zaxxer.hikari.pool.poolbase.isconnectionalive(poolbase.java:162) ~[hikaricp-2.7.9.jar!/:?]

    at com.zaxxer.hikari.pool.hikaripool.getconnection(hikaripool.java:172) ~[hikaricp-2.7.9.jar!/:?]

    at com.zaxxer.hikari.pool.hikaripool.getconnection(hikaripool.java:148) ~[hikaricp-2.7.9.jar!/:?]

    at com.zaxxer.hikari.hikaridatasource.getconnection(hikaridatasource.java:128) ~[hikaricp-2.7.9.jar!/:?]
```

到这里，我们已经将应用获得连接的代码大致梳理了一遍，整个过程如下图所示：
![image.png](https://cdn.nlark.com/yuque/0/2022/png/804884/1651115833161-81a5bf4d-46fb-48b7-9985-175d18fd3941.png#clientId=u7254b6cc-7da7-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=275&id=ue62f8238&margin=%5Bobject%20Object%5D&name=image.png&originHeight=313&originWidth=673&originalType=binary&ratio=1&rotation=0&showTitle=false&size=22527&status=done&style=none&taskId=ua5895b10-27bc-4ed9-8920-f9f4639e23d&title=&width=591.5)
       从执行逻辑上看，连接池的处理并没有问题，相反其在许多细节上都考虑到位了。在对非存活连接执行 close 时，同样调用了 removefrombag 动作将其从连接池中移除，因此也不应该存在僵尸连接对象的问题。那么，我们之前的推测应该就是错误的！
### 2.2 陷入焦灼
在代码分析之余，开发同学也注意到当前使用的 hikaricp 版本为 3.4.5，而环境上出问题的业务服务却是 2.7.9 版本，这仿佛预示着什么… 让我们再次假设 hikaricp 2.7.9 版本存在某种未知的 bug，导致了问题的产生。
为了进一步分析连接池对于服务端故障的行为处理，我们尝试在本地机器上进行模拟，这一次使用了 hikaricp 2.7.9 版本进行测试，并同时将 hikaricp 的日志级别设置为 debug。
模拟场景中，会由 由本地应用程序连接本机的 mysql 数据库进行操作，步骤如下：
```java
1. 初始化数据源，此时连接池 min-idle 设置为 10；

2. 每隔50ms 执行一次sql操作，查询当前的元数据表；

3. 将 mysql 服务停止一段时间，观察业务表现；

4. 将 mysql 服务重新启动，观察业务表现。
```
最终产生的日志如下：
```java
//初始化过程，建立10个连接

debug -hikaripool.logpoolstate - pool stats (total=1, active=1, idle=0, waiting=0)

debug -hikaripool$poolentrycreator.call- added connection mariadbconnection@71ab7c09

debug -hikaripool$poolentrycreator.call- added connection mariadbconnection@7f6c9c4c

debug -hikaripool$poolentrycreator.call- added connection mariadbconnection@7b531779

...

debug -hikaripool.logpoolstate- after adding stats (total=10, active=1, idle=9, waiting=0)

 

//执行业务操作，成功

execute statement: true

test time -------1

execute statement: true

test time -------2

 

...

//停止mysql

...

//检测到无效连接

warn  -poolbase.isconnectionalive - failed to validate connection mariadbconnection@9225652 ((conn=38652) 

connection.setnetworktimeout cannot be called on a closed connection). possibly consider using a shorter maxlifetime value.

warn  -poolbase.isconnectionalive - failed to validate connection mariadbconnection@71ab7c09 ((conn=38653) 

connection.setnetworktimeout cannot be called on a closed connection). possibly consider using a shorter maxlifetime value.

//释放连接

debug -poolbase.quietlycloseconnection(poolbase.java:134) - closing connection mariadbconnection@9225652: (connection is dead) 

debug -poolbase.quietlycloseconnection(poolbase.java:134) - closing connection mariadbconnection@71ab7c09: (connection is dead)

 

//尝试创建连接失败

debug -hikaripool.createpoolentry - cannot acquire connection from data source

java.sql.sqlnontransientconnectionexception: could not connect to address=(host=localhost)(port=3306)(type=master) : 

socket fail to connect to host:localhost, port:3306. connection refused: connect

caused by: java.sql.sqlnontransientconnectionexception: socket fail to connect to host:localhost, port:3306. connection refused: connect

    at internal.util.exceptions.exceptionfactory.createexception(exceptionfactory.java:73) ~[mariadb-java-client-2.6.0.jar:?]

    ...

 

//持续失败.. 直到mysql重启

 

//重启后，自动创建连接成功

debug -hikaripool$poolentrycreator.call -added connection mariadbconnection@42c5503e

debug -hikaripool$poolentrycreator.call -added connection mariadbconnection@695a7435

//连接池状态，重新建立10个连接

debug -hikaripool.logpoolstate(hikaripool.java:421) -after adding stats (total=10, active=1, idle=9, waiting=0)

//执行业务操作，成功（已经自愈）

execute statement: true
```
      从日志上看，hikaricp 还是能成功检测到坏死的连接并将其踢出连接池，一旦 mysql 重新启动，业务操作又能自动恢复成功了。根据这个结果，基于 hikaricp 版本问题的设想也再次落空，研发同学再次陷入焦灼。
### 2.3 拨开云雾见光明
多方面求证无果之后，我们最终尝试在业务服务所在的容器内进行抓包，看是否能发现一些蛛丝马迹。
进入故障容器，执行_tcpdump -i eth0 tcp port 30052_进行抓包，然后对业务接口发起访问。
此时令人诡异的事情发生了，没有任何网络包产生！而业务日志在 30s 之后也出现了获取连接失败的异常。
我们通过 netstat 命令检查网络连接，发现只有一个 established 状态的 tcp 连接。
![image.png](https://cdn.nlark.com/yuque/0/2022/png/804884/1651115938675-b4c2c525-7fc4-4b79-91c6-191a7e866eba.png#clientId=u7254b6cc-7da7-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=26&id=ueb7db788&margin=%5Bobject%20Object%5D&name=image.png&originHeight=35&originWidth=647&originalType=binary&ratio=1&rotation=0&showTitle=false&size=7198&status=done&style=none&taskId=u82a18b53-9916-4a05-9034-743712d19e8&title=&width=474.5)
也就是说，当前业务实例和 mysql 服务端是存在一个建好的连接的，但为什么业务还是报出可用连接呢？
推测可能原因有二：

-  该连接被某个业务（如定时器）一直占用。
-  该连接实际上还没有办法使用，可能处于某种僵死的状态。

对于原因一，很快就可以被推翻，一来当前服务并没有什么定时器任务，二来就算该连接被占用，按照连接池的原理，只要没有达到上限，新的业务请求应该会促使连接池进行新连接的建立，那么无论是从 netstat 命令检查还是 tcpdump 的结果来看，不应该一直是只有一个连接的状况。
那么，情况二的可能性就很大了。带着这个思路，继续分析 java 进程的线程栈。
执行 kill -3 pid 将线程栈输出后分析，果不其然，在当前 thread stack 中发现了如下的条目：
```java
"hikaripool-1 connection adder" #121 daemon prio=5 os_prio=0 tid=0x00007f1300021800 nid=0xad runnable [0x00007f12d82e5000]

   java.lang.thread.state: runnable

    at java.net.socketinputstream.socketread0(native method)

    at java.net.socketinputstream.socketread(socketinputstream.java:116)

    at java.net.socketinputstream.read(socketinputstream.java:171)

    at java.net.socketinputstream.read(socketinputstream.java:141)

    at java.io.filterinputstream.read(filterinputstream.java:133)

    at org.mariadb.jdbc.internal.io.input.readaheadbufferedstream.fillbuffer(readaheadbufferedstream.java:129)

    at org.mariadb.jdbc.internal.io.input.readaheadbufferedstream.read(readaheadbufferedstream.java:102)

    - locked <0x00000000d7f5b480> (a org.mariadb.jdbc.internal.io.input.readaheadbufferedstream)

    at org.mariadb.jdbc.internal.io.input.standardpacketinputstream.getpacketarray(standardpacketinputstream.java:241)

    at org.mariadb.jdbc.internal.io.input.standardpacketinputstream.getpacket(standardpacketinputstream.java:212)

    at org.mariadb.jdbc.internal.com.read.readinitialhandshakepacket.<init>(readinitialhandshakepacket.java:90)

    at org.mariadb.jdbc.internal.protocol.abstractconnectprotocol.createconnection(abstractconnectprotocol.java:480)

    at org.mariadb.jdbc.internal.protocol.abstractconnectprotocol.connectwithoutproxy(abstractconnectprotocol.java:1236)

    at org.mariadb.jdbc.internal.util.utils.retrieveproxy(utils.java:610)

    at org.mariadb.jdbc.mariadbconnection.newconnection(mariadbconnection.java:142)

    at org.mariadb.jdbc.driver.connect(driver.java:86)

    at com.zaxxer.hikari.util.driverdatasource.getconnection(driverdatasource.java:138)

    at com.zaxxer.hikari.pool.poolbase.newconnection(poolbase.java:358)

    at com.zaxxer.hikari.pool.poolbase.newpoolentry(poolbase.java:206)

    at com.zaxxer.hikari.pool.hikaripool.createpoolentry(hikaripool.java:477)
```
这里显示hikaripool-1 connection adder这个线程一直处于 socketread 的可执行状态。从命名上看该线程应该是 hikaricp 连接池用于建立连接的任务线程，socket 读操作则来自于 mariadbconnection.newconnection() 这个方法，即 mariadb-java-client 驱动层建立 mysql 连接的一个操作，其中 readinitialhandshakepacket 初始化则属于 mysql 建链协议中的一个环节。
简而言之，上面的线程刚好处于建链的一个过程态，关于 mariadb 驱动和 mysql 建链的过程大致如下：
![image.png](https://cdn.nlark.com/yuque/0/2022/png/804884/1651115971011-d3e4acf2-0f89-4c0c-ab43-a1690fab334a.png#clientId=u7254b6cc-7da7-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=172&id=ua1d502b9&margin=%5Bobject%20Object%5D&name=image.png&originHeight=344&originWidth=350&originalType=binary&ratio=1&rotation=0&showTitle=false&size=15361&status=done&style=none&taskId=uf80b57a0-92e0-47f9-8e97-8082322adac&title=&width=175)
mysql 建链首先是建立 tcp 连接（三次握手），客户端会读取 mysql 协议的一个初始化握手消息包，内部包含 mysql 版本号，鉴权算法等等信息，之后再进入身份鉴权的环节。
这里的问题就在于 readinitialhandshakepacket 初始化（读取握手消息包）一直处于 socket read 的一个状态。
如果此时 mysql 远端主机故障了，那么该操作就会一直卡住。而此时的连接虽然已经建立（处于 established 状态），但却一直没能完成协议握手和后面的身份鉴权流程，即该连接只能算一个半成品（无法进入 hikaricp 连接池的列表中）。从故障服务的 debug 日志也可以看到，连接池持续是没有可用连接的，如下：
debug hikaripool.logpoolstate --> before cleanup stats (total=0, active=0, idle=0, waiting=3)
另一个需要解释的问题则是，这样一个 socket read 操作的阻塞是否就造成了整个连接池的阻塞呢？
经过代码走读，我们再次梳理了 hikaricp 建立连接的一个流程，其中涉及到几个模块：

-  hikaripool，连接池实例，由该对象连接的获取、释放以及连接的维护。
-  connectionbag，连接对象容器，存放当前的连接对象列表，用于提供可用连接。
-  addconnectionexecutor，添加连接的执行器，命名如 “hikaripool-1 connection adder”，是一个单线程的线程池。
-  poolentrycreator，添加连接的任务，实现创建连接的具体逻辑。
-  housekeeper，内部定时器，用于实现连接的超时淘汰、连接池的补充等工作。

housekeeper 在连接池初始化后的 100ms 触发执行，其调用 fillpool() 方法完成连接池的填充，例如 min-idle 是10，那么初始化就会创建10个连接。connectionbag 维护了当前连接对象的列表，该模块还维护了请求连接者(waiters)的一个计数器，用于评估当前连接数的需求。
其中，borrow 方法的逻辑如下：
```java
public t borrow(long timeout, final timeunit timeunit) throws interruptedexception
   {
      // 尝试从 thread-local 中获取
      final list<object> list = threadlist.get();
      for (int i = list.size() - 1; i >= 0; i--) {
         ...
      }
 
      // 计算当前等待请求的任务
      final int waiting = waiters.incrementandget();
      try {
         for (t bagentry : sharedlist) {
            if (bagentry.compareandset(state_not_in_use, state_in_use)) {
               //如果获得了可用连接，会触发填充任务
               if (waiting > 1) {
                  listener.addbagitem(waiting - 1);
               }
               return bagentry;
            }
         }
 
         //没有可用连接，先触发填充任务
         listener.addbagitem(waiting);
 
         //在指定时间内等待可用连接进入
         timeout = timeunit.tonanos(timeout);
         do {
            final long start = currenttime();
            final t bagentry = handoffqueue.poll(timeout, nanoseconds);
            if (bagentry == null || bagentry.compareandset(state_not_in_use, state_in_use)) {
               return bagentry;
            }
 
            timeout -= elapsednanos(start);
         } while (timeout > 10_000);
 
         return null;
      }
      finally {
         waiters.decrementandget();
      }
   }
```
注意到，无论是有没有可用连接，该方法都会触发一个 listener.addbagitem() 方法，hikaripool 对该接口的实现如下：
```java
public void addbagitem(final int waiting)
   {
      final boolean shouldadd = waiting - addconnectionqueuereadonlyview.size() >= 0; // yes, >= is intentional.
      if (shouldadd) {
         //调用 addconnectionexecutor 提交创建连接的任务
         addconnectionexecutor.submit(poolentrycreator);
      }
      else {
         logger.debug("{} - add connection elided, waiting {}, queue {}", poolname, waiting, addconnectionqueuereadonlyview.size());
      }
   }
poolentrycreator 则实现了创建连接的具体逻辑，如下：
public class poolentrycreator{
     @override
      public boolean call()
      {
         long sleepbackoff = 250l;
         //判断是否需要建立连接
         while (poolstate == pool_normal && shouldcreateanotherconnection()) {
            //创建 mysql 连接
            final poolentry poolentry = createpoolentry();
 
            if (poolentry != null) {
               //建立连接成功，直接返回。
               connectionbag.add(poolentry);
               logger.debug("{} - added connection {}", poolname, poolentry.connection);
               if (loggingprefix != null) {
                  logpoolstate(loggingprefix);
               }
               return boolean.true;
            }
            ...
         }
 
         // pool is suspended or shutdown or at max size
         return boolean.false;
      }
}
```
        由此可见，addconnectionexecutor 采用了单线程的设计，当产生新连接需求时，会异步触发 poolentrycreator 任务进行补充。其中 poolentrycreator. createpoolentry() 会完成 mysql 驱动连接建立的所有事情，而我们的情况则恰恰是mysql 建链过程产生了永久性阻塞。因此无论后面怎么获取连接，新来的建链任务都会一直排队等待，这便导致了业务上一直没有连接可用。
下面这个图说明了 hikaricp 的建链过程：
![image.png](https://cdn.nlark.com/yuque/0/2022/png/804884/1651116036818-7a6e1c0e-f002-44e7-a189-66c840840795.png#clientId=u7254b6cc-7da7-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=182&id=ubcb6ae8c&margin=%5Bobject%20Object%5D&name=image.png&originHeight=291&originWidth=850&originalType=binary&ratio=1&rotation=0&showTitle=false&size=33936&status=done&style=none&taskId=uf133067f-59a2-40aa-99c3-53be781dc4e&title=&width=531)
         好了，让我们在回顾一下前面关于可靠性测试的场景：
首先，mysql 主实例发生故障，而紧接着 hikaricp 则检测到了坏的连接(connection is dead)并将其释放，在释放关闭连接的同时又发现连接数需要补充，进而立即触发了新的建链请求。
而问题就刚好出在这一次建链请求上，tcp 握手的部分是成功了（客户端和 mysql vm 上 nodeport 完成连接），但在接下来由于当前的 mysql 容器已经停止（此时 vip 也切换到了另一台 mysql 实例上），因此客户端再也无法获得原 mysql 实例的握手包响应（该握手属于mysql应用层的协议），此时便陷入了长时间的阻塞式 socketread 操作。而建链请求任务恰恰好采用了单线程运作，进一步则导致了所有业务的阻塞。
## 3.解决方案
在了解了事情的来龙去脉之后，我们主要考虑从两方面进行优化：

-  优化一，增加 hirakipool 中 addconnectionexecutor 线程的数量，这样即使第一个线程出现挂死，还有其他的线程能参与建链任务的分配。
-  优化二，出问题的 socketread 是一种同步阻塞式的调用，可通过 so_timeout 来避免长时间挂死。

对于优化点一，我们一致认为用处并不大，如果连接出现了挂死那么相当于线程资源已经泄露，对服务后续的稳定运行十分不利，而且 hikaricp 在这里也已经将其写死了。因此关键的方案还是避免阻塞式的调用。
查阅了 mariadb-java-client 官方文档后，发现可以在 jdbc url 中指定网络io 的超时参数，如下：
![image.png](https://cdn.nlark.com/yuque/0/2022/png/804884/1651116071903-125a3222-ffd6-4ef1-a209-b61138f7dba1.png#clientId=u7254b6cc-7da7-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=150&id=u4d014a28&margin=%5Bobject%20Object%5D&name=image.png&originHeight=300&originWidth=1178&originalType=binary&ratio=1&rotation=0&showTitle=false&size=46146&status=done&style=none&taskId=uebc1b35e-4760-4e97-a55f-5a7ba427cd6&title=&width=589)
具体参考：https://mariadb.com/kb/en/about-mariadb-connector-j/
如描述所说的，sockettimeout 可以设置 socket 的 so_timeout 属性，从而达到控制超时时间的目的。默认是 0，即不超时。
我们在 mysql jdbc url 中加入了相关的参数，如下：
```java
	
spring.datasource.url=jdbc:mysql://10.0.71.13:33052/appdb?sockettimeout=60000&connecttimeout=30000&servertimezone=utc
```
此后对 mysql 可靠性场景进行多次验证，发现连接挂死的现象已经不再出现，此时问题得到解决。
### 3.1 解决示例

- 未开启timeout
```java
jdbc:mysql://testdb.com:3306/app000000?useUnicode=yes&charset=utf8mb4&collation=utf8mb4_general_ci
```
![257ba1ce0ad9cf0f77e78eecb45a022e.png](https://cdn.nlark.com/yuque/0/2022/png/804884/1651117210644-d6a3f8cc-43ae-4a93-ad25-8c71e3363d3b.png#clientId=u8f11f2f5-2078-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=241&id=u720af2b7&margin=%5Bobject%20Object%5D&name=257ba1ce0ad9cf0f77e78eecb45a022e.png&originHeight=482&originWidth=1705&originalType=binary&ratio=1&rotation=0&showTitle=false&size=199589&status=done&style=none&taskId=u8d80f25a-8a79-439f-b7ea-f905ea097e7&title=&width=852.5)
```java
wuhaocn-rongcloud-macbook:web-app wuhao$ jstack 72303 
2022-04-29 11:21:53
Full thread dump Java HotSpot(TM) 64-Bit Server VM (25.231-b11 mixed mode):

"Attach Listener" #88 daemon prio=9 os_prio=31 tid=0x00007f819d97b000 nid=0x9777 waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"HikariPool-2 housekeeper" #47 daemon prio=5 os_prio=31 tid=0x00007f819802c000 nid=0x8503 waiting on condition [0x000070000e329000]
   java.lang.Thread.State: TIMED_WAITING (parking)
	at sun.misc.Unsafe.park(Native Method)
	- parking to wait for  <0x000000074067e0a8> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)
	at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:215)
	at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.awaitNanos(AbstractQueuedSynchronizer.java:2078)
	at java.util.concurrent.ScheduledThreadPoolExecutor$DelayedWorkQueue.take(ScheduledThreadPoolExecutor.java:1093)
	at java.util.concurrent.ScheduledThreadPoolExecutor$DelayedWorkQueue.take(ScheduledThreadPoolExecutor.java:809)
	at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1074)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1134)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
	at java.lang.Thread.run(Thread.java:748)

"db_pool_factory_0" #46 prio=5 os_prio=31 tid=0x00007f8199156800 nid=0x8803 waiting on condition [0x000070000e226000]
   java.lang.Thread.State: WAITING (parking)
	at sun.misc.Unsafe.park(Native Method)
	- parking to wait for  <0x00000007401f6558> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)
	at java.util.concurrent.locks.LockSupport.park(LockSupport.java:175)
	at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:2039)
	at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:442)
	at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1074)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1134)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
	at java.lang.Thread.run(Thread.java:748)

"HikariPool-1 housekeeper" #43 daemon prio=5 os_prio=31 tid=0x00007f8196c4d000 nid=0x8b03 waiting on condition [0x000070000df1d000]
   java.lang.Thread.State: TIMED_WAITING (parking)
	at sun.misc.Unsafe.park(Native Method)
	- parking to wait for  <0x000000074067e288> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)
	at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:215)
	at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.awaitNanos(AbstractQueuedSynchronizer.java:2078)
	at java.util.concurrent.ScheduledThreadPoolExecutor$DelayedWorkQueue.take(ScheduledThreadPoolExecutor.java:1093)
	at java.util.concurrent.ScheduledThreadPoolExecutor$DelayedWorkQueue.take(ScheduledThreadPoolExecutor.java:809)
	at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1074)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1134)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
	at java.lang.Thread.run(Thread.java:748)

"Abandoned connection cleanup thread" #42 daemon prio=5 os_prio=31 tid=0x00007f81962dd000 nid=0x7203 in Object.wait() [0x000070000de1a000]
   java.lang.Thread.State: TIMED_WAITING (on object monitor)
	at java.lang.Object.wait(Native Method)
	at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:144)
	- locked <0x00000007401f5ae8> (a java.lang.ref.ReferenceQueue$Lock)
	at com.mysql.jdbc.AbandonedConnectionCleanupThread.run(AbandonedConnectionCleanupThread.java:41)

```

- 开启timeout
```java
jdbc:mysql://testdb.com:3306/app000000?sockettimeout=60000&connecttimeout=30000&useUnicode=yes&charset=utf8mb4&collation=utf8mb4_general_ci
```
![6a7ed567d5c5f1b841491abfd82daf3e.png](https://cdn.nlark.com/yuque/0/2022/png/804884/1651117219754-bd7b763c-c3a2-4369-98e4-2917c39f5b67.png#clientId=u8f11f2f5-2078-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=157&id=ubcdbfc85&margin=%5Bobject%20Object%5D&name=6a7ed567d5c5f1b841491abfd82daf3e.png&originHeight=313&originWidth=1672&originalType=binary&ratio=1&rotation=0&showTitle=false&size=139687&status=done&style=none&taskId=u94163a31-bfc7-46a3-9a0b-b84eceab2c8&title=&width=836)
## 4.小结
本次分享了一次关于 mysql 连接挂死问题排查的心路历程，由于环境搭建的工作量巨大，而且该问题复现存在偶然性，整个分析过程还是有些坎坷的（其中也踩了坑）。的确，我们很容易被一些表面的现象所迷惑，而觉得问题很难解决时，更容易带着偏向性思维去处理问题。例如本例中曾一致认为连接池出现了问题，但实际上却是由于 mysql jdbc 驱动（mariadb driver）的一个不严谨的配置所导致。
从原则上讲，应该避免一切可能导致资源挂死的行为。如果我们能在前期对代码及相关配置做好充分的排查工作，相信 996 就会离我们越来越远。
以上就是详解mysql连接挂死的原因的详细内容，更多关于mysql连接挂死的原因的资料请关注服务器之家其它相关文章！
## 5.参考
[详解MySQL连接挂死的原因](http://www.zzvips.com/article/176926.html)
