---
title: Akka-Remote-配置

categories:
- network

tag:
- akka

---

```
#//#shared
#####################################
# Akka Remote Reference Config File #
#####################################

# This is the reference config file that contains all the default settings.
# Make your edits/overrides in your application.conf.

# comments about akka.actor settings left out where they are already in akka-
# actor.jar, because otherwise they would be repeated in config rendering.
#
# For the configuration of the new remoting implementation (Artery) please look
# at the bottom section of this file as it is listed separately.

akka {

  actor {

    serializers {
      akka-containers = "akka.remote.serialization.MessageContainerSerializer"
      akka-misc = "akka.remote.serialization.MiscMessageSerializer"
      artery = "akka.remote.serialization.ArteryMessageSerializer"
      proto = "akka.remote.serialization.ProtobufSerializer"
      daemon-create = "akka.remote.serialization.DaemonMsgCreateSerializer"
      primitive-long = "akka.remote.serialization.LongSerializer"
      primitive-int = "akka.remote.serialization.IntSerializer"
      primitive-string = "akka.remote.serialization.StringSerializer"
      primitive-bytestring = "akka.remote.serialization.ByteStringSerializer"
      akka-system-msg = "akka.remote.serialization.SystemMessageSerializer"
    }

    serialization-bindings {
      "akka.actor.ActorSelectionMessage" = akka-containers

      "akka.remote.DaemonMsgCreate" = daemon-create

      "akka.remote.artery.ArteryMessage" = artery

      # 因为akka.protobuf.Message没有扩展Serializable但
      # GeneratedMessage做，需要使用更具体的在这里的顺序
      # 避免歧义。
      # Since akka.protobuf.Message does not extend Serializable but
      # GeneratedMessage does, need to use the more specific one here in order
      # to avoid ambiguity.
      "akka.protobuf.GeneratedMessage" = proto

      #自从com.google.protobuf.Message没有扩展Serializable但是

      # GeneratedMessage做，需要使用更具体的在这里的顺序
      # 避免歧义。
      # This com.google.protobuf serialization binding is only used if the class can be loaded，
      # 即com.google.protobuf依赖已经添加到应用程序项目中。
      # Since com.google.protobuf.Message does not extend Serializable but
      # GeneratedMessage does, need to use the more specific one here in order
      # to avoid ambiguity.
      # This com.google.protobuf serialization binding is only used if the class can be loaded,
      # i.e. com.google.protobuf dependency has been added in the application project.
      "com.google.protobuf.GeneratedMessage" = proto
      
      "java.util.Optional" = akka-misc
    }
      
    # 了保持协议的向后兼容性，这些绑定没有
    # 认包含。可以使用enable-additional-serialization-bindings=on来启用它们。
    # 果akka.remote.artery是默认启用的。如果启用了=
    # akka.actor.allow-java-serialization =。
    # For the purpose of preserving protocol backward compatibility these bindings are not
    # included by default. They can be enabled with enable-additional-serialization-bindings=on.
    # They are enabled by default if akka.remote.artery.enabled=on or if 
    # akka.actor.allow-java-serialization=off.
    additional-serialization-bindings {
      "akka.actor.Identify" = akka-misc
      "akka.actor.ActorIdentity" = akka-misc
      "scala.Some" = akka-misc
      "scala.None$" = akka-misc
      "akka.actor.Status$Success" = akka-misc
      "akka.actor.Status$Failure" = akka-misc
      "akka.actor.ActorRef" = akka-misc
      "akka.actor.PoisonPill$" = akka-misc
      "akka.actor.Kill$" = akka-misc
      "akka.remote.RemoteWatcher$Heartbeat$" = akka-misc
      "akka.remote.RemoteWatcher$HeartbeatRsp" = akka-misc
      "akka.actor.ActorInitializationException" = akka-misc

      "akka.dispatch.sysmsg.SystemMessage" = akka-system-msg

      "java.lang.String" = primitive-string
      "akka.util.ByteString$ByteString1C" = primitive-bytestring
      "akka.util.ByteString$ByteString1" = primitive-bytestring
      "akka.util.ByteString$ByteStrings" = primitive-bytestring
      "java.lang.Long" = primitive-long
      "scala.Long" = primitive-long
      "java.lang.Integer" = primitive-int
      "scala.Int" = primitive-int

      # Java Serializer默认用于异常。

      # 建议自定义序列化器
      # 远程tor.Status.Failure中请求回复。您可以添加
      # 绑定到akka-misc (MiscMessageSerializerSpec)的异常
      # 一个构造函数的单个message String或构造函数的message String为
      # 为第一个参数，cause Throwable作为第二个参数。请注意，事实并非如此
      # 一般异常，如IllegalArgumentException，添加此绑定是安全的
      # 因为它可能有一个没有必需构造函数的子类。
          
      # Java Serializer is by default used for exceptions.
      # It's recommended that you implement custom serializer for exceptions that are
      # sent remotely, e.g. in akka.actor.Status.Failure for ask replies. You can add
      # binding to akka-misc (MiscMessageSerializerSpec) for the exceptions that have
      # a constructor with single message String or constructor with message String as
      # first parameter and cause Throwable as second parameter. Note that it's not
      # safe to add this binding for general exceptions such as IllegalArgumentException
      # because it may have a subclass without required constructor.
      "java.lang.Throwable" = java
      "akka.actor.IllegalActorStateException" = akka-misc
      "akka.actor.ActorKilledException" = akka-misc
      "akka.actor.InvalidActorNameException" = akka-misc
      "akka.actor.InvalidMessageException" = akka-misc
    }

    serialization-identifiers {
      "akka.remote.serialization.ProtobufSerializer" = 2
      "akka.remote.serialization.DaemonMsgCreateSerializer" = 3
      "akka.remote.serialization.MessageContainerSerializer" = 6
      "akka.remote.serialization.MiscMessageSerializer" = 16
      "akka.remote.serialization.ArteryMessageSerializer" = 17
      "akka.remote.serialization.LongSerializer" = 18
      "akka.remote.serialization.IntSerializer" = 19
      "akka.remote.serialization.StringSerializer" = 20
      "akka.remote.serialization.ByteStringSerializer" = 21
      "akka.remote.serialization.SystemMessageSerializer" = 22
    }

    deployment {

      default {

        # if this is set to a valid remote address, the named actor will be
        # deployed at that node e.g. "akka.tcp://sys@host:port"
        remote = ""

        target {

          # A list of hostnames and ports for instantiating the children of a
          # router
          #   The format should be on "akka.tcp://sys@host:port", where:
          #    - sys is the remote actor system name
          #    - hostname can be either hostname or IP address the remote actor
          #      should connect to
          #    - port should be the port for the remote server on the other node
          # The number of actor instances to be spawned is still taken from the
          # nr-of-instances setting as for local routers; the instances will be
          # distributed round-robin among the given nodes.
          nodes = []

        }
      }
    }
  }

  remote {
    ### Settings shared by classic remoting and Artery (the new implementation of remoting)

    # If set to a nonempty string remoting will use the given dispatcher for
    # its internal actors otherwise the default dispatcher is used. Please note
    # that since remoting can load arbitrary 3rd party drivers (see
    # "enabled-transport" and "adapters" entries) it is not guaranteed that
    # every module will respect this setting.
    use-dispatcher = "akka.remote.default-remote-dispatcher"

    # 设置失败检测器监视连接。
    # 对于TCP来说，快速的故障检测并不重要，因为
    # 大多数连接失败是由TCP本身捕获的。
    # 默认的DeadlineFailureDetector将触发，如果没有心跳
    # 持续时间心跳间隔+可接受的心跳暂停，即124秒
    # 使用默认设置。
    # Settings for the failure detector to monitor connections.
    # For TCP it is not important to have fast failure detection, since
    # most connection failures are captured by TCP itself.
    # The default DeadlineFailureDetector will trigger if there are no heartbeats within
    # the duration heartbeat-interval + acceptable-heartbeat-pause, i.e. 124 seconds
    # with the default settings.
    transport-failure-detector {

      # 故障检测器实现的FQCN。
      # 它必须实现akka.remote.FailureDetector
      # 使用com.typesafe.config.Config和
      # akka.actor.EventStream参数。
      # FQCN of the failure detector implementation.
      # It must implement akka.remote.FailureDetector and have
      # a public constructor with a com.typesafe.config.Config and
      # akka.actor.EventStream parameter.
      implementation-class = "akka.remote.DeadlineFailureDetector"
      
	  # 向每个连接发送keep-alive心跳消息的频率。
      # How often keep-alive heartbeat messages should be sent to each connection.
      heartbeat-interval = 4 s
      
      # 在认为是异常之前，可能丢失/延迟的心跳数将被接受。
      # “心跳间隔”的范围对于能够在心跳到达时的突然、偶尔的停顿(例如垃圾收集或网络掉落)中生存很重要。
      # Number of potentially lost/delayed heartbeats that will be
      # accepted before considering it to be an anomaly.
      # A margin to the `heartbeat-interval` is important to be able to survive sudden,
      # occasional, pauses in heartbeat arrivals, due to for example garbage collect or
      # network drop.
      acceptable-heartbeat-pause = 120 s
    }

    # Phi累积故障检测器的设置(http://www.jaist.ac.jp/~defago/files/pdf/IS_RR_2004_010.pdf
    # [Hayashibara等人])用于远程死亡监视。
    # 如果没有心跳，默认的PhiAccrualFailureDetector将触发
    # duration heartbeat-interval + acceptable-heartbeat-pause + threshold_adjustment，
    # 即默认设置大约12.5秒。
    # Settings for the Phi accrual failure detector (http://www.jaist.ac.jp/~defago/files/pdf/IS_RR_2004_010.pdf
    # [Hayashibara et al]) used for remote death watch.
    # The default PhiAccrualFailureDetector will trigger if there are no heartbeats within
    # the duration heartbeat-interval + acceptable-heartbeat-pause + threshold_adjustment,
    # i.e. around 12.5 seconds with default settings.
    watch-failure-detector {

      # 故障检测器实现的FQCN。
      # 它必须实现akka.remote.FailureDetector
      # 使用com.typesafe.config.Config和
      # akka.actor.EventStream参数。
      # FQCN of the failure detector implementation.
      # It must implement akka.remote.FailureDetector and have
      # a public constructor with a com.typesafe.config.Config and
      # akka.actor.EventStream parameter.
      implementation-class = "akka.remote.PhiAccrualFailureDetector"

      # 向每个连接发送keep-alive心跳消息的频率。    
      # How often keep-alive heartbeat messages should be sent to each connection.
      heartbeat-interval = 1 s

      # 定义故障检测器阈值。
      # 低门槛容易产生许多错误的怀疑，但可以确保
      # 在真正崩溃的情况下快速检测。相反,高
      # threshold产生的错误更少，但需要更多的时间来检测
      # 真正的崩溃。
      # Defines the failure detector threshold.
      # A low threshold is prone to generate many wrong suspicions but ensures
      # a quick detection in the event of a real crash. Conversely, a high
      # threshold generates fewer mistakes but needs more time to detect
      # actual crashes.
      threshold = 10.0

      # 心跳间到达时间的样本数量
      # 计算连接的失败超时时间。
      # Number of the samples of inter-heartbeat arrival times to adaptively
      # calculate the failure timeout for connections.
      max-sample-size = 200

      # 用于正态分布的最小标准偏差
      # AccrualFailureDetector。标准偏差过低可能导致
      # 对突然但正常的心跳偏差过于敏感
      # 到达时间。
      # Minimum standard deviation to use for the normal distribution in
      # AccrualFailureDetector. Too low standard deviation might result in
      # too much sensitivity for sudden, but normal, deviations in heartbeat
      # inter arrival times.
      min-std-deviation = 100 ms

      # 可能丢失/延迟的心跳数
      # 在认为它是异常之前接受。
      # 这一界限很重要，因为它能让你在突然的、偶然的、
      # 心跳到达时暂停，例如由于垃圾收集或
      # 网络下降。
      # Number of potentially lost/delayed heartbeats that will be
      # accepted before considering it to be an anomaly.
      # This margin is important to be able to survive sudden, occasional,
      # pauses in heartbeat arrivals, due to for example garbage collect or
      # network drop.
      acceptable-heartbeat-pause = 10 s

      # 检查失败检测器标记为不可达的节点的频率
      # How often to check for nodes marked as unreachable by the failure
      # detector
      unreachable-nodes-reaper-interval = 1s

      # 发送心跳请求后，第一次检测失败
      # 将在这段时间后开始，即使没有心跳消息
      # 收到。
      # After the heartbeat request has been sent the first failure detection
      # will start after this period, even though no heartbeat mesage has
      # been received.
      expected-response-after = 1 s

    }
    
    # remote deployment configuration section
    deployment {
      # If true, will only allow specific classes to be instanciated on this system via remote deployment
      enable-whitelist = off
      
      whitelist = []
    }
#//#shared
  }

}

akka {

  remote {
#//#classic

    ### Configuration for classic remoting
    # 超时，在此之后，远程子系统的启动被认为是失败的。
    # 如果您的传输驱动程序(请参阅enabled-transports一节)需要更长的加载时间，则增加此值。
    # Timeout after which the startup of the remoting subsystem is considered
    # to be failed. Increase this value if your transport drivers (see the
    # enabled-transports section) need longer time to be loaded.
    startup-timeout = 10 s

    # 超时，在此之后远程子系统将优雅地关闭
    # 被认为失败了。超时后，远程连接系统
    # 强制关机。如果您的运输司机增加这个值
    # (参见enabled-transports一节)需要更长的时间才能正常停止。
    # Timout after which the graceful shutdown of the remoting subsystem is
    # considered to be failed. After the timeout the remoting system is
    # forcefully shut down. Increase this value if your transport drivers
    # (see the enabled-transports section) need longer time to stop properly.
    shutdown-timeout = 10 s

    # 在关闭驱动程序之前，远程控制子系统尝试刷新
    # 所有挂起的写。此设置控制远程处理的最大时间
    # 愿意在关闭司机之前等待。
    # Before shutting down the drivers, the remoting subsystem attempts to flush
    # all pending writes. This setting controls the maximum time the remoting is
    # willing to wait before moving on to shut down the drivers.
    flush-wait-on-shutdown = 2 s
    
    # 为出站消息重用入站连接
    # Reuse inbound connections for outbound messages
    use-passive-connections = on
    # 控制被拒绝的写被重新尝试后的回退间隔。(如果传输程序的内部缓冲区已满，它们可能会拒绝写入)
    # Controls the backoff interval after a refused write is reattempted.
    # (Transports may refuse writes if their internal buffer is full)
    backoff-interval = 5 ms
    # 发送到传输堆栈的管理命令的确认超时。
    # Acknowledgment timeout of management commands sent to the transport stack.
    command-ack-timeout = 30 s

    # 出站关联执行握手的超时时间。
    # 如果传输是akka.remote.net .tcp或akka.remote.net .ssl
    # 将使用为传输配置的连接超时。
    # The timeout for outbound associations to perform the handshake.
    # If the transport is akka.remote.netty.tcp or akka.remote.netty.ssl
    # the configured connection-timeout for the transport will be used instead.
    handshake-timeout = 15 s
    
    ### Security settings

    # 启用不受信任模式，以确保服务器托管参与者的完全安全，防止客户端发送系统消息，例如:
    # 比如“创建”、“暂停”、“恢复”、“终止”、“监督”、“链接”等。
    # Enable untrusted mode for full security of server managed actors, prevents
    # system messages to be send by clients, e.g. messages like 'Create',
    # 'Suspend', 'Resume', 'Terminate', 'Supervise', 'Link' etc.
    untrusted-mode = off

    # 当'untrusted-mode=on'入站参与者选择默认被丢弃。
    # 具有此白名单中定义的路径的actor被授予接收actor选择消息的权限。
    # 例如:trusted-selection-paths = ["/user/接待员"，"/user/namingService"]
    # When 'untrusted-mode=on' inbound actor selections are by default discarded.
    # Actors with paths defined in this white list are granted permission to receive actor
    # selections messages.
    # E.g. trusted-selection-paths = ["/user/receptionist", "/user/namingService"]
    trusted-selection-paths = []

    # 如果远程服务器要求它的对等端共享相同的
    # secure-cookie(在'remote'部分定义)?通过安全cookie
    # 在第一次握手时。如果初始连接被拒绝
    # message包含一个不匹配的cookie或cookie丢失。
    # Should the remote server require that its peers share the same
    # secure-cookie (defined in the 'remote' section)? Secure cookies are passed
    # between during the initial handshake. Connections are refused if the initial
    # message contains a mismatching cookie or the cookie is missing.
    require-cookie = off

    # Deprecated since 2.4-M1
    secure-cookie = ""

    ### Logging
    # 如果这是“on”，Akka将在DEBUG级别记录所有入站消息，
    # 如果关闭，则不记录
    # If this is "on", Akka will log all inbound messages at DEBUG level,
    # if off then they are not logged
    log-received-messages = off
	# 如果这是“on”，Akka将在DEBUG级别记录所有出站消息，
    # 如果关闭，则不记录
    # If this is "on", Akka will log all outbound messages at DEBUG level,
    # if off then they are not logged
    log-sent-messages = off

    # 连接状态生命周期
    # Sets the log granularity level at which Akka logs remoting events. This setting
    # can take the values OFF, ERROR, WARNING, INFO, DEBUG, or ON. For compatibility
    # reasons the setting "on" will default to "debug" level. Please note that the effective
    # logging level is still determined by the global logging level of the actor system:
    # for example debug level remoting events will be only logged if the system
    # is running with debug level logging.
    # Failures to deserialize received messages also fall under this flag.
    log-remote-lifecycle-events = on

    # 以字节为单位记录有效负载大小大于的消息类型
    # 这个值。记录一次每个消息类型检测到的最大大小，
    # 增加10%的门槛。
    # 默认情况下，该功能是关闭的。通过将属性设置为激活它
    # a以字节为单位的值，例如1000b。注意，对于所有大于此值的消息
    # 这将增加额外的性能和可伸缩性成本。
    # Logging of message types with payload size in bytes larger than
    # this value. Maximum detected size per message type is logged once,
    # with an increase threshold of 10%.
    # By default this feature is turned off. Activate it by setting the property to
    # a value in bytes, such as 1000b. Note that for all messages larger than this
    # limit there will be extra performance and scalability cost.
    log-frame-size-exceeding = off
    # 如果在端点的回退缓冲区中的消息的数量
    # writer超出此限制。可以通过将该值设置为off来禁用它。
    # Log warning if the number of messages in the backoff buffer in the endpoint
    # writer exceeds this limit. It can be disabled by setting the value to off.
    log-buffer-size-exceeding = 50000


    # 建立出站连接失败后，远程处理将标记
    # 地址失败。这个配置选项控制应该使用多少时间
    # 在重新尝试一个新连接之前经过#。地址是
    # 门控，所有发送到该地址的消息将被发送到死信。
    # 因为这个设置限制了重新连接的速率，所以设置为a
    # 非常短的间隔(即少于一秒)可能导致暴风雨
    # 连接尝试。
    # After failed to establish an outbound connection, the remoting will mark the
    # address as failed. This configuration option controls how much time should
    # be elapsed before reattempting a new connection. While the address is
    # gated, all messages sent to the address are delivered to dead-letters.
    # Since this setting limits the rate of reconnects setting it to a
    # very short interval (i.e. less than a second) may result in a storm of
    # reconnect attempts.
    retry-gate-closed-for = 5 s

    # 在灾难性的通信故障导致系统丢失之后
    # 消息或在远程DeathWatch触发后，远程系统得到
    # 隔离以防止不一致的行为。
    # 此设置控制隔离标记将保留多长时间
    # ，以避免长期内存泄漏。
    # 警告:不要将此更改为小值以重新启用通信
    # 隔离节点。这样的特性是不支持的，任何行为之间
    # 解除隔离后受影响的系统未定义    
    # After catastrophic communication failures that result in the loss of system
    # messages or after the remote DeathWatch triggers the remote system gets
    # quarantined to prevent inconsistent behavior.
    # This setting controls how long the Quarantine marker will be kept around
    # before being removed to avoid long-term memory leaks.
    # WARNING: DO NOT change this to a small value to re-enable communication with
    # quarantined nodes. Such feature is not supported and any behavior between
    # the affected systems after lifting the quarantine is undefined.
    prune-quarantine-marker-after = 5 d
        
    # 如果系统消息已经在两个系统之间交换(例如远程死亡)
    # watch or remote deployment has been used)远程系统将被标记为
    # 隔离后的两个系统没有活动的关联，没有
    # 在这里配置的时间内进行通信。
    # 这个设置的唯一目的是避免存储系统消息重传
    # data (sequence number state, etc) for an undefined amount of time导致long
    # 术语内存泄漏。相反，如果一个系统在这个时期消失了，
    # 或者更确切地说
    # -两个系统之间没有关联(TCP连接，如果使用TCP传输)
    # 双方都没有试图与对方沟通
    # 没有挂起的系统消息要传递
    # 对于此处配置的时间量，远程系统将被隔离并处于所有状态
    # 与它关联的#将被删除。
    # If system messages have been exchanged between two systems (i.e. remote death
    # watch or remote deployment has been used) a remote system will be marked as
    # quarantined after the two system has no active association, and no
    # communication happens during the time configured here.
    # The only purpose of this setting is to avoid storing system message redelivery
    # data (sequence number state, etc.) for an undefined amount of time leading to long
    # term memory leak. Instead, if a system has been gone for this period,
    # or more exactly
    # - there is no association between the two systems (TCP connection, if TCP transport is used)
    # - neither side has been attempting to communicate with the other
    # - there are no pending system messages to deliver
    # for the amount of time configured here, the remote system will be quarantined and all state
    # associated with it will be dropped.
    quarantine-after-silence = 2 d

    # 该设置定义了未确认系统消息的最大数量
    # 允许远程系统。如果达到此限制，则远程系统将
    # 声明为死亡，其UID被标记为受污染。
    # This setting defines the maximum number of unacknowledged system messages
    # allowed for a remote system. If this limit is reached the remote system is
    # declared to be dead and its UID marked as tainted.
    system-message-buffer-size = 20000

    # 这个设置定义了个人之后的最大空闲时间
    # 发送系统消息的确认。系统消息传递
    # 由显式确认消息保证。这些ack
    # 利用普通交通信息。如果没有检测到流量
    # 在此处配置的时间段内，远程将发送出去
    # 个人ack。
    # This setting defines the maximum idle time after an individual
    # acknowledgement for system messages is sent. System message delivery
    # is guaranteed by explicit acknowledgement messages. These acks are
    # piggybacked on ordinary traffic messages. If no traffic is detected
    # during the time period configured here, the remoting will send out
    # an individual ack.
    system-message-ack-piggyback-timeout = 0.3 s
   
    # 此设置定义了未明确确认或否定确认的参与者(用于临终看护和监督)之间的内部管理信号被怨恨的时间。
    # 被否定确认的消息总是立即被厌恶。
    # This setting defines the time after internal management signals
    # between actors (used for DeathWatch and supervision) that have not been
    # explicitly acknowledged or negatively acknowledged are resent.
    # Messages that were negatively acknowledged are always immediately
    # resent.
    resend-interval = 2 s

    # 重发未确认的系统消息的最大数量
    # 每个“resend-interval”。如果你看到许多(> 1000)远程角色，你可以
    # 增加这个值，例如600，但是限制太大(例如10000)
    # 可能会淹没连接，并可能导致错误的故障检测触发。
    # 测试这样的配置，同时观察所有的参与者并停止
    # 所有人在同一时间观看演员。
    # Maximum number of unacknowledged system messages that will be resent
    # each 'resend-interval'. If you watch many (> 1000) remote actors you can
    # increase this value to for example 600, but a too large limit (e.g. 10000)
    # may flood the connection and might cause false failure detection to trigger.
    # Test such a configuration by watching all actors at the same time and stop
    # all watched actors at the same time.
    resend-limit = 200

    # WARNING:这个设置不应该不被更改，除非它的所有结果
    # 是正确理解的假设经验与远程内部或专家建议。
    # 此设置定义内部管理重试后的时间
    # 停止信号到一个远程系统，该系统之前没有被确认是活的。     
    # WARNING: this setting should not be not changed unless all of its consequences
    # are properly understood which assumes experience with remoting internals
    # or expert advice.
    # This setting defines the time after redelivery attempts of internal management
    # signals are stopped to a remote system that has been not confirmed to be alive by
    # this system before.
    initial-system-message-delivery-timeout = 3 m

    ### Transports and adapters

    # List of the transport drivers that will be loaded by the remoting.
    # A list of fully qualified config paths must be provided where
    # the given configuration path contains a transport-class key
    # pointing to an implementation class of the Transport interface.
    # If multiple transports are provided, the address of the first
    # one will be used as a default address.
    enabled-transports = ["akka.remote.netty.tcp"]

    # Transport drivers can be augmented with adapters by adding their
    # name to the applied-adapters setting in the configuration of a
    # transport. The available adapters should be configured in this
    # section by providing a name, and the fully qualified name of
    # their corresponding implementation. The class given here
    # must implement akka.akka.remote.transport.TransportAdapterProvider
    # and have public constructor without parameters.
    adapters {
      gremlin = "akka.remote.transport.FailureInjectorProvider"
      trttl = "akka.remote.transport.ThrottlerProvider"
    }

    ### Default configuration for the Netty based transport drivers

    netty.tcp {
      # The class given here must implement the akka.remote.transport.Transport
      # interface and offer a public constructor which takes two arguments:
      #  1) akka.actor.ExtendedActorSystem
      #  2) com.typesafe.config.Config
      transport-class = "akka.remote.transport.netty.NettyTransport"

      # Transport drivers can be augmented with adapters by adding their
      # name to the applied-adapters list. The last adapter in the
      # list is the adapter immediately above the driver, while
      # the first one is the top of the stack below the standard
      # Akka protocol
      applied-adapters = []

      transport-protocol = tcp

      # The default remote server port clients should connect to.
      # Default is 2552 (AKKA), use 0 if you want a random available port
      # This port needs to be unique for each actor system on the same machine.
      port = 2552

      # The hostname or ip clients should connect to.
      # InetAddress.getLocalHost.getHostAddress is used if empty
      hostname = ""

      # Use this setting to bind a network interface to a different port
      # than remoting protocol expects messages at. This may be used
      # when running akka nodes in a separated networks (under NATs or docker containers).
      # Use 0 if you want a random available port. Examples:
      #
      # akka.remote.netty.tcp.port = 2552
      # akka.remote.netty.tcp.bind-port = 2553
      # Network interface will be bound to the 2553 port, but remoting protocol will
      # expect messages sent to port 2552.
      #
      # akka.remote.netty.tcp.port = 0
      # akka.remote.netty.tcp.bind-port = 0
      # Network interface will be bound to a random port, and remoting protocol will
      # expect messages sent to the bound port.
      #
      # akka.remote.netty.tcp.port = 2552
      # akka.remote.netty.tcp.bind-port = 0
      # Network interface will be bound to a random port, but remoting protocol will
      # expect messages sent to port 2552.
      #
      # akka.remote.netty.tcp.port = 0
      # akka.remote.netty.tcp.bind-port = 2553
      # Network interface will be bound to the 2553 port, and remoting protocol will
      # expect messages sent to the bound port.
      #
      # akka.remote.netty.tcp.port = 2552
      # akka.remote.netty.tcp.bind-port = ""
      # Network interface will be bound to the 2552 port, and remoting protocol will
      # expect messages sent to the bound port.
      #
      # akka.remote.netty.tcp.port if empty
      bind-port = ""

      # Use this setting to bind a network interface to a different hostname or ip
      # than remoting protocol expects messages at.
      # Use "0.0.0.0" to bind to all interfaces.
      # akka.remote.netty.tcp.hostname if empty
      bind-hostname = ""

      # Enables SSL support on this transport
      enable-ssl = false

      # Sets the connectTimeoutMillis of all outbound connections,
      # i.e. how long a connect may take until it is timed out
      connection-timeout = 15 s

      # If set to "<id.of.dispatcher>" then the specified dispatcher
      # will be used to accept inbound connections, and perform IO. If "" then
      # dedicated threads will be used.
      # Please note that the Netty driver only uses this configuration and does
      # not read the "akka.remote.use-dispatcher" entry. Instead it has to be
      # configured manually to point to the same dispatcher if needed.
      use-dispatcher-for-io = ""

      # Sets the high water mark for the in and outbound sockets,
      # set to 0b for platform default
      write-buffer-high-water-mark = 0b

      # Sets the low water mark for the in and outbound sockets,
      # set to 0b for platform default
      write-buffer-low-water-mark = 0b

      # Sets the send buffer size of the Sockets,
      # set to 0b for platform default
      send-buffer-size = 256000b

      # Sets the receive buffer size of the Sockets,
      # set to 0b for platform default
      receive-buffer-size = 256000b

      # Maximum message size the transport will accept, but at least
      # 32000 bytes.
      # Please note that UDP does not support arbitrary large datagrams,
      # so this setting has to be chosen carefully when using UDP.
      # Both send-buffer-size and receive-buffer-size settings has to
      # be adjusted to be able to buffer messages of maximum size.
      maximum-frame-size = 128000b

      # Sets the size of the connection backlog
      backlog = 4096

      # Enables the TCP_NODELAY flag, i.e. disables Nagle’s algorithm
      tcp-nodelay = on

      # Enables TCP Keepalive, subject to the O/S kernel’s configuration
      tcp-keepalive = on

      # Enables SO_REUSEADDR, which determines when an ActorSystem can open
      # the specified listen port (the meaning differs between *nix and Windows)
      # Valid values are "on", "off" and "off-for-windows"
      # due to the following Windows bug: http://bugs.sun.com/bugdatabase/view_bug.do?bug_id=4476378
      # "off-for-windows" of course means that it's "on" for all other platforms
      tcp-reuse-addr = off-for-windows

      # Used to configure the number of I/O worker threads on server sockets
      server-socket-worker-pool {
        # Min number of threads to cap factor-based number to
        pool-size-min = 2

        # The pool size factor is used to determine thread pool size
        # using the following formula: ceil(available processors * factor).
        # Resulting size is then bounded by the pool-size-min and
        # pool-size-max values.
        pool-size-factor = 1.0

        # Max number of threads to cap factor-based number to
        pool-size-max = 2
      }

      # Used to configure the number of I/O worker threads on client sockets
      client-socket-worker-pool {
        # Min number of threads to cap factor-based number to
        pool-size-min = 2

        # The pool size factor is used to determine thread pool size
        # using the following formula: ceil(available processors * factor).
        # Resulting size is then bounded by the pool-size-min and
        # pool-size-max values.
        pool-size-factor = 1.0

        # Max number of threads to cap factor-based number to
        pool-size-max = 2
      }


    }

    netty.udp = ${akka.remote.netty.tcp}
    netty.udp {
      transport-protocol = udp
    }

    netty.ssl = ${akka.remote.netty.tcp}
    netty.ssl = {
      # Enable SSL/TLS encryption.
      # This must be enabled on both the client and server to work.
      enable-ssl = true

      security {
        # This is the Java Key Store used by the server connection
        key-store = "keystore"

        # This password is used for decrypting the key store
        key-store-password = "changeme"

        # This password is used for decrypting the key
        key-password = "changeme"

        # This is the Java Key Store used by the client connection
        trust-store = "truststore"

        # This password is used for decrypting the trust store
        trust-store-password = "changeme"

        # Protocol to use for SSL encryption, choose from:
        # TLS 1.2 is available since JDK7, and default since JDK8:
        # https://blogs.oracle.com/java-platform-group/entry/java_8_will_use_tls
        protocol = "TLSv1.2"

        # Example: ["TLS_RSA_WITH_AES_128_CBC_SHA", "TLS_RSA_WITH_AES_256_CBC_SHA"]
        # You need to install the JCE Unlimited Strength Jurisdiction Policy
        # Files to use AES 256.
        # More info here:
        # http://docs.oracle.com/javase/7/docs/technotes/guides/security/SunProviders.html#SunJCEProvider
        enabled-algorithms = ["TLS_RSA_WITH_AES_128_CBC_SHA"]

        # There are three options, in increasing order of security:
        # "" or SecureRandom => (default)
        # "SHA1PRNG" => Can be slow because of blocking issues on Linux
        # "AES128CounterSecureRNG" => fastest startup and based on AES encryption
        # algorithm
        # "AES256CounterSecureRNG"
        #
        # The following are deprecated in Akka 2.4. They use one of 3 possible
        # seed sources, depending on availability: /dev/random, random.org and
        # SecureRandom (provided by Java)
        # "AES128CounterInetRNG"
        # "AES256CounterInetRNG" (Install JCE Unlimited Strength Jurisdiction
        # Policy Files first)
        # Setting a value here may require you to supply the appropriate cipher
        # suite (see enabled-algorithms section above)
        random-number-generator = ""

        # Require mutual authentication between TLS peers
        #
        # Without mutual authentication only the peer that actively establishes a connection (TLS client side)
        # checks if the passive side (TLS server side) sends over a trusted certificate. With the flag turned on,
        # the passive side will also request and verify a certificate from the connecting peer.
        #
        # To prevent man-in-the-middle attacks you should enable this setting. For compatibility reasons it is
        # still set to 'off' per default.
        #
        # Note: Nodes that are configured with this setting to 'on' might not be able to receive messages from nodes that
        # run on older versions of akka-remote. This is because in older versions of Akka the active side of the remoting
        # connection will not send over certificates.
        #
        # However, starting from the version this setting was added, even with this setting "off", the active side
        # (TLS client side) will use the given key-store to send over a certificate if asked. A rolling upgrades from
        # older versions of Akka can therefore work like this:
        #   - upgrade all nodes to an Akka version supporting this flag, keeping it off
        #   - then switch the flag on and do again a rolling upgrade of all nodes
        # The first step ensures that all nodes will send over a certificate when asked to. The second
        # step will ensure that all nodes finally enforce the secure checking of client certificates.
        require-mutual-authentication = off
      }
    }

    ### Default configuration for the failure injector transport adapter

    gremlin {
      # Enable debug logging of the failure injector transport adapter
      debug = off
    }

    ### Default dispatcher for the remoting subsystem

    default-remote-dispatcher {
      type = Dispatcher
      executor = "fork-join-executor"
      fork-join-executor {
        parallelism-min = 2
        parallelism-factor = 0.5
        parallelism-max = 16
      }
      throughput = 10
    }

    backoff-remote-dispatcher {
      type = Dispatcher
      executor = "fork-join-executor"
      fork-join-executor {
        # Min number of threads to cap factor-based parallelism number to
        parallelism-min = 2
        parallelism-max = 2
      }
    }
  }
}
#//#classic

akka {

  remote {
  #//#artery

    ### Configuration for Artery, the reimplementation of remoting
    artery {

      # Enable the new remoting with this flag
      enabled = off

      # Canonical address is the address other clients should connect to.
      # Artery transport will expect messages to this address.
      canonical {

        # The default remote server port clients should connect to.
        # Default is 25520, use 0 if you want a random available port
        # This port needs to be unique for each actor system on the same machine.
        port = 25520

        # Hostname clients should connect to. Can be set to an ip, hostname
        # or one of the following special values:
        #   "<getHostAddress>"   InetAddress.getLocalHost.getHostAddress
        #   "<getHostName>"      InetAddress.getLocalHost.getHostName
        #
        hostname = "<getHostAddress>"
      }

      # Use these settings to bind a network interface to a different address
      # than artery expects messages at. This may be used when running Akka
      # nodes in a separated networks (under NATs or in containers). If canonical
      # and bind addresses are different, then network configuration that relays
      # communications from canonical to bind addresses is expected.
      bind {

        # Port to bind a network interface to. Can be set to a port number
        # of one of the following special values:
        #   0    random available port
        #   ""   akka.remote.artery.canonical.port
        #
        port = ""

        # Hostname to bind a network interface to. Can be set to an ip, hostname
        # or one of the following special values:
        #   "0.0.0.0"            all interfaces
        #   ""                   akka.remote.artery.canonical.hostname
        #   "<getHostAddress>"   InetAddress.getLocalHost.getHostAddress
        #   "<getHostName>"      InetAddress.getLocalHost.getHostName
        #
        hostname = ""
      }

      # Actor paths to use the large message stream for when a message
      # is sent to them over remoting. The large message stream dedicated
      # is separate from "normal" and system messages so that sending a
      # large message does not interfere with them.
      # Entries should be the full path to the actor. Wildcards in the form of "*"
      # can be supplied at any place and matches any name at that segment -
      # "/user/supervisor/actor/*" will match any direct child to actor,
      # while "/supervisor/*/child" will match any grandchild to "supervisor" that
      # has the name "child"
      # Messages sent to ActorSelections will not be passed through the large message
      # stream, to pass such messages through the large message stream the selections
      # but must be resolved to ActorRefs first.
      large-message-destinations = []

      # Enable untrusted mode, which discards inbound system messages, PossiblyHarmful and
      # ActorSelection messages. E.g. remote watch and remote deployment will not work.
      # ActorSelection messages can be enabled for specific paths with the trusted-selection-paths
      untrusted-mode = off

      # When 'untrusted-mode=on' inbound actor selections are by default discarded.
      # Actors with paths defined in this white list are granted permission to receive actor
      # selections messages.
      # E.g. trusted-selection-paths = ["/user/receptionist", "/user/namingService"]
      trusted-selection-paths = []

      # If this is "on", all inbound remote messages will be logged at DEBUG level,
      # if off then they are not logged
      log-received-messages = off

      # If this is "on", all outbound remote messages will be logged at DEBUG level,
      # if off then they are not logged
      log-sent-messages = off

      advanced {

        # Maximum serialized message size, including header data.
        maximum-frame-size = 256 KiB

        # Direct byte buffers are reused in a pool with this maximum size.
        # Each buffer has the size of 'maximum-frame-size'.
        # This is not a hard upper limit on number of created buffers. Additional
        # buffers will be created if needed, e.g. when using many outbound
        # associations at the same time. Such additional buffers will be garbage
        # collected, which is not as efficient as reusing buffers in the pool.
        buffer-pool-size = 128

        # Maximum serialized message size for the large messages, including header data.
        # See 'large-message-destinations'.
        maximum-large-frame-size = 2 MiB

        # Direct byte buffers for the large messages are reused in a pool with this maximum size.
        # Each buffer has the size of 'maximum-large-frame-size'.
        # See 'large-message-destinations'.
        # This is not a hard upper limit on number of created buffers. Additional
        # buffers will be created if needed, e.g. when using many outbound
        # associations at the same time. Such additional buffers will be garbage
        # collected, which is not as efficient as reusing buffers in the pool.
        large-buffer-pool-size = 32

        # For enabling testing features, such as blackhole in akka-remote-testkit.
        test-mode = off

        # Settings for the materializer that is used for the remote streams.
        materializer = ${akka.stream.materializer}

        # If set to a nonempty string artery will use the given dispatcher for
        # the ordinary and large message streams, otherwise the default dispatcher is used.
        use-dispatcher = "akka.remote.default-remote-dispatcher"

        # If set to a nonempty string remoting will use the given dispatcher for
        # the control stream, otherwise the default dispatcher is used.
        # It can be good to not use the same dispatcher for the control stream as
        # the dispatcher for the ordinary message stream so that heartbeat messages
        # are not disturbed.
        use-control-stream-dispatcher = ""

        # Controls whether to start the Aeron media driver in the same JVM or use external
        # process. Set to 'off' when using external media driver, and then also set the
        # 'aeron-dir'.
        embedded-media-driver = on

        # Directory used by the Aeron media driver. It's mandatory to define the 'aeron-dir'
        # if using external media driver, i.e. when 'embedded-media-driver = off'.
        # Embedded media driver will use a this directory, or a temporary directory if this
        # property is not defined (empty).
        aeron-dir = ""

        # Whether to delete aeron embeded driver directory upon driver stop.
        delete-aeron-dir = yes

        # Level of CPU time used, on a scale between 1 and 10, during backoff/idle.
        # The tradeoff is that to have low latency more CPU time must be used to be
        # able to react quickly on incoming messages or send as fast as possible after
        # backoff backpressure.
        # Level 1 strongly prefer low CPU consumption over low latency.
        # Level 10 strongly prefer low latency over low CPU consumption.
        idle-cpu-level = 5

        # WARNING: This feature is not supported yet. Don't use other value than 1.
        # It requires more hardening and performance optimizations.
        # Number of outbound lanes for each outbound association. A value greater than 1
        # means that serialization can be performed in parallel for different destination
        # actors. The selection of lane is based on consistent hashing of the recipient
        # ActorRef to preserve message ordering per receiver.
        outbound-lanes = 1

        # WARNING: This feature is not supported yet. Don't use other value than 1.
        # It requires more hardening and performance optimizations.
        # Total number of inbound lanes, shared among all inbound associations. A value
        # greater than 1 means that deserialization can be performed in parallel for
        # different destination actors. The selection of lane is based on consistent
        # hashing of the recipient ActorRef to preserve message ordering per receiver.
        inbound-lanes = 1

        # Size of the send queue for outgoing messages. Messages will be dropped if
        # the queue becomes full. This may happen if you send a burst of many messages
        # without end-to-end flow control. Note that there is one such queue per
        # outbound association. The trade-off of using a larger queue size is that
        # it consumes more memory, since the queue is based on preallocated array with
        # fixed size.
        outbound-message-queue-size = 3072

        # Size of the send queue for outgoing control messages, such as system messages.
        # If this limit is reached the remote system is declared to be dead and its UID
        # marked as quarantined.
        # The trade-off of using a larger queue size is that it consumes more memory,
        # since the queue is based on preallocated array with fixed size.
        outbound-control-queue-size = 3072

        # Size of the send queue for outgoing large messages. Messages will be dropped if
        # the queue becomes full. This may happen if you send a burst of many messages
        # without end-to-end flow control. Note that there is one such queue per
        # outbound association. The trade-off of using a larger queue size is that
        # it consumes more memory, since the queue is based on preallocated array with
        # fixed size.
        outbound-large-message-queue-size = 256

        # This setting defines the maximum number of unacknowledged system messages
        # allowed for a remote system. If this limit is reached the remote system is
        # declared to be dead and its UID marked as quarantined.
        system-message-buffer-size = 20000

        # unacknowledged system messages are re-delivered with this interval
        system-message-resend-interval = 1 second

        # The timeout for outbound associations to perform the handshake.
        # This timeout must be greater than the 'image-liveness-timeout'.
        handshake-timeout = 20 s

        # incomplete handshake attempt is retried with this interval
        handshake-retry-interval = 1 second

        # handshake requests are performed periodically with this interval,
        # also after the handshake has been completed to be able to establish
        # a new session with a restarted destination system
        inject-handshake-interval = 1 second

        # messages that are not accepted by Aeron are dropped after retrying for this period
        give-up-message-after = 60 seconds

        # System messages that are not acknowledged after re-sending for this period are
        # dropped and will trigger quarantine. The value should be longer than the length
        # of a network partition that you need to survive.
        give-up-system-message-after = 6 hours

        # during ActorSystem termination the remoting will wait this long for
        # an acknowledgment by the destination system that flushing of outstanding
        # remote messages has been completed
        shutdown-flush-timeout = 1 second

        # See 'inbound-max-restarts'
        inbound-restart-timeout = 5 seconds

        # Max number of restarts within 'inbound-restart-timeout' for the inbound streams.
        # If more restarts occurs the ActorSystem will be terminated.
        inbound-max-restarts = 5

        # See 'outbound-max-restarts'
        outbound-restart-timeout = 5 seconds

        # Max number of restarts within 'outbound-restart-timeout' for the outbound streams.
        # If more restarts occurs the ActorSystem will be terminated.
        outbound-max-restarts = 5

        # Stop outbound stream of a quarantined association after this idle timeout, i.e.
        # when not used any more.
        stop-quarantined-after-idle = 3 seconds

        # Timeout after which aeron driver has not had keepalive messages
        # from a client before it considers the client dead.
        client-liveness-timeout = 20 seconds

        # Timeout for each the INACTIVE and LINGER stages an aeron image
        # will be retained for when it is no longer referenced.
        # This timeout must be less than the 'handshake-timeout'.
        image-liveness-timeout = 10 seconds

        # Timeout after which the aeron driver is considered dead
        # if it does not update its C'n'C timestamp.
        driver-timeout = 20 seconds

        flight-recorder {
          // FIXME it should be enabled by default when we have a good solution for naming the files
          enabled = off
          # Controls where the flight recorder file will be written. There are three options:
          # 1. Empty: a file will be generated in the temporary directory of the OS
          # 2. A relative or absolute path ending with ".afr": this file will be used
          # 3. A relative or absolute path: this directory will be used, the file will get a random file name
          destination = ""
        }

        # compression of common strings in remoting messages, like actor destinations, serializers etc
        compression {

          actor-refs {
            # Max number of compressed actor-refs
            # Note that compression tables are "rolling" (i.e. a new table replaces the old
            # compression table once in a while), and this setting is only about the total number
            # of compressions within a single such table.
            # Must be a positive natural number.
            max = 256

            # interval between new table compression advertisements.
            # this means the time during which we collect heavy-hitter data and then turn it into a compression table.
            advertisement-interval = 1 minute 
          }
          manifests {
            # Max number of compressed manifests
            # Note that compression tables are "rolling" (i.e. a new table replaces the old
            # compression table once in a while), and this setting is only about the total number
            # of compressions within a single such table.
            # Must be a positive natural number.
            max = 256

            # interval between new table compression advertisements.
            # this means the time during which we collect heavy-hitter data and then turn it into a compression table.
            advertisement-interval = 1 minute
          }
        }

        # List of fully qualified class names of remote instruments which should
        # be initialized and used for monitoring of remote messages.
        # The class must extend akka.remote.artery.RemoteInstrument and
        # have a public constructor with empty parameters or one ExtendedActorSystem
        # parameter.
        # A new instance of RemoteInstrument will be created for each encoder and decoder.
        # It's only called from the stage, so if it dosn't delegate to any shared instance
        # it doesn't have to be thread-safe.
        # Refer to `akka.remote.artery.RemoteInstrument` for more information.
        instruments = ${?akka.remote.artery.advanced.instruments} []
      }
    }
  }

}
#//#artery

```
