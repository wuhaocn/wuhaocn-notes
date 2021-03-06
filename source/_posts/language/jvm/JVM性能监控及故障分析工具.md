---
title: JVM性能监控及故障分析工具
categories:
- java
tag:
- JVM
---


# JVM 性能监控及故障分析工具

## 1.概要
JDK官方提供了不少好用的JAVA故障处理工具,JDK的命令行工具在JDK的bin目录下供用户使用。
## ２.jps
### ２.1.简介　
jps是jdk提供的查看当前java进程的工具，简单看作为JavaVirtual Machine Process Status Tool。
命令格式：
```java
jps [options] [hostid] 
```
options 参数详解:
参数 | 解释
----| ----
 -q | 仅输出VM标识符，不包括classname,jar name,arguments in main method 
 -m | 输出main method的参数 
 -l | 输出完全的包名，应用主类名，jar的完全路径名 
 -v | 输出jvm参数 
 -V | 输出通过flag文件传递到JVM中的参数(.hotspotrc文件或-XX:Flags=所指定的文件 
 -J | 传递参数到vm,例如:-J-Xms512m
hostid 参数解释:
[protocol:][[//]hostname][:port][/servername]

### ２.２.实例

```java
[java@RCS-AS-01 root]$ jps
3201 Jps
20819 AuthBootstrap
```

```java
[java@RCS-AS-01 root]$ jps -lv
20819 com.feinno.urcs.auth.main.AuthBootstrap -Duser.dir=/home/urcs/urcs-as-authentication -Xmx1024m -Xms1024m
```

```java
[java@RCS-AS-01 root]$ jps -lvm 10.10.220.101
RMI Registry not available at 10.10.220.101:1099
Connection refused to host: 10.10.220.101; nested exception is:java.net.ConnectException: Connection refused。
需要在远程机器上开启：jstatd
```

## 3.jstat
### 3.1.简介　

Jstat是JDK自带的一个轻量级小工具。全称“Java Virtual Machine statistics monitoring tool”，它位于Java的bin目录下，主要利用JVM内建的指令对Java应用程序的资源和性能进行实时的命令行的监控，包括了对Heap size和垃圾回收状况的监控。可见，Jstat是轻量级的、专门针对JVM的工具。
命令格式：
```java
jstat [options]
```
###  3.2.options 参数详解:

* 3.2.1. jstat -class <pid> : 显示加载 class 的数量,及所占空间等信息,

显示列名|具体描述
------|-------
Loaded|装载的类的数量
Bytes|装载类所占用的字节数
Unloaded|卸载类的数量
Bytes|卸载类的字节数
Time|装载和卸载类所花费的时间

* 3.2.2.jstat -compiler <pid>:显示 VM 实时编译的数量等信息,

显示列名|具体描述
------|-------
Compiled|编译任务执行数量
Failed|编译任务执行失败数量
Invalid|编译任务执行失效数量
Time|编译任务消耗时间
FailedType|最后一个编译失败任务的类型
FailedMethod|最后一个编译失败任务所在的类及方法

* 3.2.3.jstat -gc <pid>: 可以显示 gc 的信息,查看 gc 的次数,及时间,

显示列名|具体描述
------|-------
S0C|年轻代中第一个 survivor(幸存区)的容量(字节)
S1C|年轻代中第二个 survivor(幸存区)的容量(字节)
S0U|年轻代中第一个 survivor(幸存区)目前已使用空间(字节)
S1U|年轻代中第二个 survivor(幸存区)目前已使用空间(字节)
EC|年轻代中 Eden(伊甸园)的容量(字节)
EU|年轻代中 Eden(伊甸园)目前已使用空间(字节)
OC|Old 代的容量(字节)
OU|Old 代目前已使用空间(字节)
PC|Perm(持久代)的容量(字节)
PU|Perm(持久代)目前已使用空间(字节)
YGC|从应用程序启动到采样时年轻代中 gc 次数
YGCT|从应用程序启动到采样时年轻代中 gc 所用时间(s)
FGC|从应用程序启动到采样时 old 代(全 gc)gc 次数
FGCT|从应用程序启动到采样时 old 代(全 gc)gc 所用时间(s)
GCT|从应用程序启动到采样时 gc 用的总时间(s)

*  3.2.4. jstat -gccapacity <pid>:可以显示,VM 内存中三代(young,old,perm)对象的使用和占用大小

显示列名|具体描述
------|-------
NGCMN|年轻代(young)中初始化(最小)的大小(字节)
NGCMX|年轻代(young)的最大容量(字节)
NGC|年轻代(young)中当前的容量(字节)
S0C|年轻代中第一个 survivor(幸存区)的容量(字节)
S1C|年轻代中第二个 survivor(幸存区)的容量(字节)
EC|年轻代中 Eden(伊甸园)的容量(字节)
OGCMN|old 代中初始化(最小)的大小(字节)
OGCMX|old 代的最大容量(字节)
OGC|old 代当前新生成的容量(字节)
OC|Old 代的容量(字节)
PGCMN|perm 代中初始化(最小)的大小(字节)
PGCMX|perm 代的最大容量(字节)
PGC|perm 代当前新生成的容量(字节)
PC|Perm(持久代)的容量(字节)
YGC|从应用程序启动到采样时年轻代中 gc 次数
FGC|从应用程序启动到采样时 old 代(全 gc)gc 次数

* 3.2.5.jstat -gcutil <pid>:统计 gc 信息

显示列名|具体描述
------|-------
S0| 年轻代中第一个 survivor(幸存区)已使用的占当前容量百分比
S1|年轻代中第二个 survivor(幸存区)已使用的占当前容量百分比
E|年轻代中 Eden(伊甸园)已使用的占当前容量百分比
O|old 代已使用的占当前容量百分比
P|perm 代已使用的占当前容量百分比
YGC|从应用程序启动到采样时年轻代中 gc 次数
YGCT|从应用程序启动到采样时年轻代中 gc 所用时间(s)
FGC|从应用程序启动到采样时 old 代(全 gc)gc 次数
FGCT|从应用程序启动到采样时 old 代(全 gc)gc 所用时间(s)
GCT|从应用程序启动到采样时 gc 用的总时间(s)

* 3.2.6. jstat -gcnew <pid>:年轻代对象的信息,

显示列名|具体描述
------|-------
S0C|年轻代中第一个 survivor(幸存区)的容量(字节)
S1C|年轻代中第二个 survivor(幸存区)的容量(字节)
S0U|年轻代中第一个 survivor(幸存区)目前已使用空间(字节)
S1U|年轻代中第二个 survivor(幸存区)目前已使用空间(字节)
TT|持有次数限制
MTT|最大持有次数限制
EC|年轻代中 Eden(伊甸园)的容量(字节)
EU|年轻代中 Eden(伊甸园)目前已使用空间(字节)
YGC|从应用程序启动到采样时年轻代中 gc 次数
YGCT|从应用程序启动到采样时年轻代中 gc 所用时间(s)

* 3.2.7. jstat -gcnewcapacity <pid>: 年轻代对象的信息及其占用量,

显示列名|具体描述
------|-------
NGCMN|年轻代(young)中初始化(最小)的大小(字节)
NGCMX|年轻代(young)的最大容量(字节)
NGC|年轻代(young)中当前的容量(字节)
S0CMX|年轻代中第一个 survivor(幸存区)的最大容量(字节)
S0C|年轻代中第一个 survivor(幸存区)的容量(字节)
S1CMX|年轻代中第二个 survivor(幸存区)的最大容量(字节)
S1C|年轻代中第二个 survivor(幸存区)的容量(字节)
ECMX|年轻代中 Eden(伊甸园)的最大容量(字节)
EC|年轻代中 Eden(伊甸园)的容量(字节)

* 3.2.8. jstat -gcold <pid>:old 代对象的信息,

显示列名|具体描述
------|-------
PC|Perm(持久代)的容量(字节)
PU|Perm(持久代)目前已使用空间(字节)
OC|Old 代的容量(字节)
OU|Old 代目前已使用空间(字节)
YGC|从应用程序启动到采样时年轻代中 gc 次数
FGC|从应用程序启动到采样时 old 代(全 gc)gc 次数
FGCT|从应用程序启动到采样时 old 代(全 gc)gc 所用时间(s)
GCT|从应用程序启动到采样时 gc 用的总时间(s)

* 3.2.9.stat -gcoldcapacity <pid>: old 代对象的信息及其占用量

显示列名|具体描述
------|-------
OGCMN|old 代中初始化(最小)的大小(字节)
OGCMX|old 代的最大容量(字节)
OGC|old 代当前新生成的容量(字节)
OC|Old 代的容量(字节)
YGC|从应用程序启动到采样时年轻代中 gc 次数
FGC|从应用程序启动到采样时 old 代(全 gc)gc 次数
FGCT|从应用程序启动到采样时 old 代(全 gc)gc 所用时间(s)
GCT|从应用程序启动到采样时 gc 用的总时间(s)

* 3.2.10. jstat -gcpermcapacity<pid>: perm 对象的信息及其占用量,

显示列名|具体描述
------|-------
PGCMN|perm 代中初始化(最小)的大小(字节)
PGCMX|perm 代的最大容量(字节)
PGC|perm 代当前新生成的容量(字节)
PC|Perm(持久代)的容量(字节)
YGC|从应用程序启动到采样时年轻代中 gc 次数
FGC|从应用程序启动到采样时 old 代(全 gc)gc 次数
FGCT|从应用程序启动到采样时 old 代(全 gc)gc 所用时间(s)
GCT|从应用程序启动到采样时 gc 用的总时间(s)

* 3.2.11. jstat -printcompilation <pid>:当前 VM 执行的信息,

显示列名|具体描述
------|-------
Compiled|编译任务的数目
Size|方法生成的字节码的大小
Type|编译类型
Method|类名和方法名用来标识编译的方法,类名使用/做为一个命名空间分隔符,方法名是给定类中的方法,上述格式是由-XX:+PrintComplation 选项进行设置的

### 3.3.实例:

```java
[java@RCS-AS-01 root]$ jstat -gcutil 16885 1000
  S0     S1     E      O      M     CCS    YGC     YGCT    FGC    FGCT     GCT
  0.00  93.51  54.24  10.36  98.25  96.86    205   16.720     3    1.041   17.760
  0.00  93.51  54.24  10.36  98.25  96.86    205   16.720     3    1.041   17.760
```

```java
[java@RCS-AS-01 root]$ jstat -class 16885 1000
Loaded  Bytes  Unloaded  Bytes     Time
 10051 19327.1       32    44.2      27.15
 10051 19327.1       32    44.2      27.15
```

## 4.jinfo
### 4.1.简介　

jinfo(Java Configuration Information)，主要用于查看指定Java进程(或核心文件、远程调试服务器)的Java配置信息。
命令格式：

```java
jinfo [options] pid
jinfo [options] executable core
jinfo [options] [server-id@]remote-hostname-or-IP
```

参数详解:
参数 | 解释
----| ----
 pid  | 进程号
 executable | 产生core dump的java executable
 core  | core file
 remote-hostname-or-IP  | 主机名或ip
 server-id | 远程主机上的debug server的唯一id

options 参数详解:

参数 | 解释
----| ----
no option | 打印命令行参数和系统属性
-flags | 打印命令行参数
-sysprops | 打印系统属性
-h | 帮助

### 4.2.实例

```java
[java@RCS-AS-01 root]$ jinfo 16885
Attaching to process ID 16885, please wait...
Debugger attached successfully.
Server compiler detected.
JVM version is 25.65-b01
Java System Properties:
java.runtime.name = Java(TM) SE Runtime Environment
java.vm.version = 25.65-b01
sun.boot.library.path = /usr/local/jdk8u65/jre/lib/amd64
java.vendor.url = http://java.oracle.com/
java.vm.vendor = Oracle Corporation
path.separator = :
file.encoding.pkg = sun.io
java.vm.name = Java HotSpot(TM) 64-Bit Server VM
.....
VM Flags:
Non-default VM flags: -XX:CICompilerCount=2 -XX:InitialHeapSize=1073741824 -XX:MaxHeapSize=1073741824 -XX:MaxNewSize=357564416 -XX:MinHeapDeltaBytes=524288 -XX:NewSize=357564416 -XX:OldSize=716177408 -XX:+UseCompressedClassPointers -XX:+UseCompressedOops -XX:+UseFastUnorderedTimeStamps -XX:+UseParallelGC
Command line:  -Duser.dir=/home/urcs/urcs-as-im -Xmx1024m -Xms1024m
```

```java
[java@RCS-AS-01 root]$ jinfo -flags 16885
Attaching to process ID 16885, please wait...
Debugger attached successfully.
Server compiler detected.
JVM version is 25.65-b01
Non-default VM flags: -XX:CICompilerCount=2 -XX:InitialHeapSize=1073741824 -XX:MaxHeapSize=1073741824 -XX:MaxNewSize=357564416 -XX:MinHeapDeltaBytes=524288 -XX:NewSize=357564416 -XX:OldSize=716177408 -XX:+UseCompressedClassPointers -XX:+UseCompressedOops -XX:+UseFastUnorderedTimeStamps -XX:+UseParallelGC
Command line:  -Duser.dir=/home/urcs/urcs-as-im -Xmx1024m -Xms1024m
```

## 5.jmap

### 5.1.简介　
jps是jdk提供的查看当前java进程的工具，简单看作为JavaVirtual Machine Process Status Tool。
命令格式：
```java
jmap [options] pid
jmap [options] executable core
jmap [options] [server-id@]remote-hostname-or-IP
```
参数详解:
参数 | 解释
----| ----
 pid  | 进程号
 executable | 产生core dump的java executable
 core  | core file
 remote-hostname-or-IP  | 主机名或ip
 server-id | 远程主机上的debug server的唯一id
 
options 参数详解:
参数 | 解释
----| ----
-dump:[live,]format=b,file=<filename> | 使用hprof二进制形式,输出jvm的heap内容到文件=. live子选项是可选的，假如指定live选项,那么只输出活的对象到文件. 
-finalizerinfo | 打印正等候回收的对象的信息.
-heap  | 打印heap的概要信息，GC使用的算法，heap的配置及wise heap的使用情况.
-histo[:live] | 打印每个class的实例数目,内存占用,类全名信息. VM的内部类名字开头会加上前缀”*”. 如果live子参数加上后,只统计活的对象数量. 
-permstat | 打印classload和jvm heap长久层的信息. 包含每个classloader的名字,活泼性,地址,父classloader和加载的class数量. 另外,内部String的数量和占用内存数也会打印出来. 
-F | 强迫.在pid没有相应的时候使用-dump或者-histo参数. 在这个模式下,live子参数无效. 
-h | -help 打印辅助信息 
-J | 传递参数给jmap启动的jvm.

### 5.2.实例

```java
[java@RCS-AS-01 root]$ jmap -dump:live,format=b,file=/tmp/heap.dump 16885
Dumping heap to /tmp/heap.dump ...
Heap dump file created
```

## 6.jstack

### 6.1.简介　
jstack（ Stack Trace for Java） 命令 用于 生成 虚拟 机 当前 时刻 的 线程 快照（ 一般 称为 threaddump 或 javacore 文件）。 线程 快照 就是 当前 虚拟 机内 每一 条 线程 正在 执行 的 方法 堆栈 的 集合， 生成 线程 快照 的 主要 目的 是 定位 线程 出现 长时间 停顿 的 原因， 如 线程间死锁,死 循环,请求 外部 资源 导致 的 长时间 等待 等 都是 导致 线程 长时间 停顿 的 常见 原因。

命令格式：

```java
jstack [options] pid
jstack [options] executable core
jstack [options] [server-id@]remote-hostname-or-IP
```

参数详解:

参数 | 解释
----| ----
pid | 进程号
executable | 产生 core dump 的 java executable
core | core file
remote-hostname-or-IP | 主机名或 ip
server-id | 远程主机上的 debug server 的唯一 id

options 参数详解:

参数 | 解释
----| ----
-F | 当 jstack [-l] pid 没有相应的时候强制打印栈信息
-l | 长列表. 打印关于锁的附加信息,例如属于 java.util.concurrent 的 ownable synchronizers 列表.
-m | 打印 java 和 native c/c++框架的所有栈信息.
-h | -help 打印帮助信息

### 6.2.实例

```java
[java@RCS-AS-01 root]$ jstack 16885 > /tmp/stack16885.1

查看文件显示：
2017-07-29 16:20:51
Full thread dump Java HotSpot(TM) 64-Bit Server VM (25.65-b01 mixed mode):

"HikariCP connection filler (pool HikariPool-11)" #26011 daemon prio=5 os_prio=0 tid=0x0000000000f46000 nid=0x2bde waiting on condition [0x00007f334e8b4000]
   java.lang.Thread.State: TIMED_WAITING (parking)
        at sun.misc.Unsafe.park(Native Method)
        - parking to wait for  <0x00000000c25016e8> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)
        at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:215)
        at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.awaitNanos(AbstractQueuedSynchronizer.java:2078)
        at java.util.concurrent.LinkedBlockingQueue.poll(LinkedBlockingQueue.java:467)
        at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1066)
        at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1127)
        at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)
        at java.lang.Thread.run(Thread.java:745)
............
```

## 7.jhat

### 7.1.简介　

提供 jhat（ JVM Heap Analysis Tool） 命令 与 jmap 搭配 使用， 来 分析 jmap 生成 的 堆 转储 快照。
命令格式：
```java
　jhat -J-Xmx512m <heap dump file>
```
备注:
jhat 内置 了 一个 微型 的 HTTP/ HTML 服务器， 生成 dump 文件 的 分析 结果 后， 可以 在 浏览器 中 查看。 不过 实事求是 地说， 在 实际 工作中， 除非 笔者 手上 真的 没有 别的 工具 可用， 否则 一般 都 不会 去 直接 使用 jhat 命令 来 分析 dump 文件， 主要原因 有 二： 一是 一般 不会 在 部署 应用 程序 的 服务器 上 直接 分析 dump 文件， 即使 可以 这样做， 也会 尽量 将dump 文件 拷贝 到 其他 机器[ 4] 上进 行 分析， 因为 分析 工作 是一 个 耗时 而且 消耗 硬件 资源 的 过程， 既然 都要 在 其他 机器 上 进行， 就 没 必要 受到 命令行 工具 的 限制 了。 另外 一个 原因 是 jhat 的 分析 功能 相对来说 比较 简陋， 后文 将会 介绍 到 的 VisualVM

### 7.2.实例:

1、产生dump文件 c:\>jmap -dump:file=f:\yown\dump.bin   16912
Dumping heap to F:\apps\dump.txt ...
Heap dump file created

2、生成站点分析报告，便于网络访问 c:\>jhat -J-Xmx512m -port 88f:\yown\dump.bin
```
Reading from f:\apps\dump.bin...
Dump file created Thu Jul 26 16:31:36 CST 2012
Snapshot read, resolving...
Resolving 2194971 objects...
Chasing references, expect 438 dots.............................................
................................................................................
................................................................................
................................................................................
................................................................................
.........................................................................
Eliminating duplicate references................................................
................................................................................
................................................................................
................................................................................
................................................................................
......................................................................
Snapshot resolved.
Started HTTP server on port 88
Server is ready. 3.访问 http://localhost:88/ 这里记录了进程中所有类及实例个数
```

## 8.jvisualvm

### 8.1.简介:

VisualVM（ All- in- One Java Troubleshooting Tool） 是 到 目前 为止， 随 JDK 发布 的 功能 最强 大的 运行 监视 和 故障 处理 程序， 并且 可以 预见 在 未来 一段时间 内 都是 官方 主力 发展 的 虚拟 机 故障 处理 工具。 官方 在 VisualVM 的 软件 说明 中写 上了“ All- in- One” 的 描述 字样， 预示 着 它 除了 运行 监视、 故障 处理 外， 还 提供 了 很多 其他 方面 的 功能。VisualVM 基于 NetBeans 平台 开发， 因此 它 一 开始 就 具备 了 插件 扩展 功能 的 特性， 通过 插件 扩展 支持， VisualVM 可以 做到：
·显示 虚拟 机 进程 及 进程 的 配置 和 环境 信息（ jps、 jinfo）
·监视 应用 程序 的 CPU、 GC、 堆、 方法 区 及 线程 的 信息（ jstat、 jstack）。
·dump 及 分析 堆 转储 快照（ jmap、 jhat）
·方法 级 的 程序 运行 性能 分析， 找出 被 调用 最多、 运行 时间 最长 的 方法
·离 线程 序 快照： 收集 程序 的 运行时 配置、 线程 dump、 内存 dump 等 信息 建立 一个 快照， 可以 将 快照 发送 开发者 处 进行 Bug 反馈。
·其他 plugins 的 无限 的 可能性

### 8.2.界面展示如下图

![这里写图片描述](http://img.blog.csdn.net/20170729163459058?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvY253dWhhbw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

![这里写图片描述](http://img.blog.csdn.net/20170729163624195?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvY253dWhhbw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

## 9.开启Java服务远程监控
### 9.1.启动脚本中添加如下参数
```ruby
JAVA_ARGS[2]="-Dcom.sun.management.jmxremote.port=8999 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname=10.10.220.101"
```
### 9.2.通过jvisualvm可以监控远程java服务，如下：
![这里写图片描述](http://img.blog.csdn.net/20170729163143819?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvY253dWhhbw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
