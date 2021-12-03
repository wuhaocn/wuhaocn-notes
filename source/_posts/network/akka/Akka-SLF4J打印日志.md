---
title: Akka-SLF4J打印日志

categories:
- network

tag:
- akka

---

## 1. 用SLF4J 打印Akka日志
    你可能注意到，我们直接将quoteResponse 打印到标准的输出是一个很不好的想法，让我们通过启用SLF4J Facade打印日志来修改这个。
### 1.1 通过日志来修复Actor类
Akka提供了一个非常小的trait 来打印日志，称为 ActorLogging。让我们来修改一下代码：
```java
classTeacherLogActor extendsActor withActorLogging {
 
   valquotes =List(
    "Moderation is for cowards",
    "Anything worth doing is worth overdoing",
    "The trouble is you think you have time",
    "You never gonna know if you never even try")
 
  defreceive ={
 
    caseQuoteRequest => {
 
      importutil.Random
 
      //get a random element (for now)
      valquoteResponse=QuoteResponse(quotes(Random.nextInt(quotes.size)))
      log.info(quoteResponse.toString())
    }
  }
 
  //We'll cover the purpose of this method in the Testing section
  defquoteList=quotes
 
}
```
   这里有点绕道。实际上，当我们以日志记下来一个message，ActorLogging 中的logging 方法已经将该消息publishes到了EventStream。那什么是EventStream？
​

### 1.2 EventStream and Logging

     EventStream的行为其实有点像消息中介，我们可以通过它发布和接收消息。和一般的MOM的微秒区别就是，EventStream的订阅者（subscribers）只能是Actor。在logging消息的场景，所有的log message都会发布到EventStream中。默认情况下，订阅这些消息的Actor是DefaultLogger ，它只是简单的将消息打印到标准输出。代码片段如下：
```java
classDefaultLogger extendsActor withStdOutLogger {  
    overridedefreceive:Receive ={
        ...
        caseevent:LogEvent ⇒ print(event)
    }
}
```
    这就是为什么当我面再次启动StudentSimulatorApp程序的时候，我们看到日志消息被打印到终端。
也就是说，EventStream不仅仅适合打日志。它是Actor世界中常用的public-subscribe机制。让我们再回到SLF4J
### 1.3 配置Akka来启用SLF4J
代码片段如下：
```java
akka{  
    loggers =["akka.event.slf4j.Slf4jLogger"]
    loglevel ="DEBUG"
    logging-filter ="akka.event.slf4j.Slf4jLoggingFilter"
}
```
我们将这些配置信息存储在名为application.conf文件中，这个文件需要配置在你的classpath里面。在我们的工程目录下，可以放在main/resources目录下面。
从这个配置中，我们可以
1、loggers属性表明，Actor将消息订阅到log Event中。 Slf4jLogger所做的仅仅是消费 log messages并将它放到SLF4J Logger facade里。
2、loglevel 属性表明，日志的输出级别。
3、logging-filter和loglevel 结合，传入日志消息的输出级别并将符合的消息publishing到EventStream中。
你可能会说，在之前的例子里怎么就没有application.conf文件呢？那是因为Akka提供了一些默认的配置属性。
### 1.4 THROW IN A logback.xml
我们将通过logback.xml文件来配置SLF4J logger backed，如下：
```java
<?xmlversion="1.0"encoding="UTF-8"?>  
<configuration>  
    <appendername="FILE"
        class="ch.qos.logback.core.rolling.RollingFileAppender">
        <encoder>
            <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
 
        <rollingPolicyclass="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>logs\akka.%d{yyyy-MM-dd}.%i.log</fileNamePattern>
            <timeBasedFileNamingAndTriggeringPolicy
                      class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>50MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
        </rollingPolicy>
    </appender>
 
    <rootlevel="DEBUG">
        <appender-refref="FILE"/>
    </root>
</configuration>  
```
 同样将它放到 main/resources目录下面，你得确保 main/resources目录在你的eclipse或者其他IDE的 Classpath里面。同时，你得将logback 和slf4j-api加入到你的pom文件中或者build.sbt中，如下：
```java
name :="AkkaNotes_Messaging"
 
version :="1.0"
 
organization :="com.arunma"
 
scalaVersion :="2.11.2"
 
resolvers ++=
        Seq("repo"at "http://repo.typesafe.com/typesafe/releases/")
             
libraryDependencies ++={
        valakkaVersion ="2.3.4"
        valsprayVersion ="1.3.1"
        Seq(
            "com.typesafe.akka"%%"akka-actor"%akkaVersion,
            "io.spray"%%"spray-can"%sprayVersion,
            "io.spray"%%"spray-routing"%sprayVersion,
            "io.spray"%%"spray-json"%"1.2.6",
            "com.typesafe.akka"%%"akka-slf4j"%akkaVersion,
            "ch.qos.logback"%"logback-classic"%"1.1.2",
            "com.typesafe.akka"%%"akka-testkit"%akkaVersion, 
            "org.scalatest"%%"scalatest"%"2.2.0"
            )
}
```
当我们再次启动StudentSimulatorApp的时候，并且发送消息到新的TeacherLogActor中，将会生成一个名为akkaxxxxx.log的文件，内容大概如下：
[![](https://cdn.nlark.com/yuque/0/2021/png/804884/1634640266729-e10bead7-510f-430c-a276-d0fbb14e8140.png#clientId=u17e16d1a-90c9-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=u1d3275c2&margin=%5Bobject%20Object%5D&originHeight=122&originWidth=1255&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=none&taskId=u8900f147-e819-4ca0-bdee-3d975019064&title=)](https://www.iteblog.com/pic/akka/SLF4JLogging.png)
如果想及时了解[Spark](https://www.iteblog.com/archives/tag/spark/)、Hadoop或者Hbase相关的文章，欢迎关注微信公共帐号：**iteblog_hadoop**
