---
title: 5GC-网络切片

categories:
- 5G

tag:
- 5G
---
## 1.切片概述
## ![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1627466041353-07197c90-661f-4580-8395-c783fbea80d4.png#clientId=u0a72d6f7-f525-4&from=paste&height=423&id=ue0a385c8&margin=%5Bobject%20Object%5D&name=image.png&originHeight=423&originWidth=752&originalType=binary&ratio=1&size=128451&status=done&style=none&taskId=u074cf0b9-aa6c-4e68-aeb0-e641603fa04&width=752)
5G网络基于三大业务场景的网络切片，使切片场景更加多样化。

- eMBB，提供大带宽流量通道，主要是借助无线侧提升带宽上限。
- uRLLC，提供低时延网络，主要借助边缘网络进行边缘计算降低端到端网络距离。
- mMTC，提供大规模机器通信，及4G中NB-IOT规范在制定中预计R16版本制定。现在采用4G核心网eLTE增强实现。

切片实现基于核心网信令侧提供切片标识传输，用户面实现切片能力提供。
### 2. 切片关键点

#### 2.1 核心参数

- NSSAI

当 UE 发起注册流程时，接入网络（gNB）根据 UE 请求携带的 NSSAI（Network Slice Selection Assistance Information，网络切片选择辅助信息）来选择核心网络子切片的入口AMF。NSSAI是S-NSSAI的集合。NSSAI可以是已配置的NSSAI、请求的NSSAI或允许的NSSAI（Configured NSSAI, a Requested NSSAI or an Allowed NSSAI）。在UE和网络之间的信令消息中，允许和请求的NSSAI最多可以有8个。

- S-NSSAI

网络切片主要体现在接纳控制、网络选择和资源分离。标准主要是通过S-NSSAI (Single Network Slice Selection Assistance Information)参数来进行识别

- SST

切片/服务类型（SST），它是指在功能和服务方面预期的网络片行为；
SST指示S-NSSAI的切片和服务类型，而sst-SD是S-NSSAI参数切片、服务类型的组成和切片分量。该参数的结构如下：

- SD

切片分量（SD），它是对切片/服务类型进行补充以在同一切片/服务类型的多个网络切片l之间进行区分的可选信息。
SD字段有一个保留值“no SD value associated with The SST”定义为十六进制FFFFFF。在某些协议中，不包括SD字段以指示没有SD值与SST关联。

-  Subscribed S-NSSAIs：订阅S-NSSAI，属于用户的订阅数据。 
-  Default S-NSSAI：默认S-NSSAI，根据运营商的策略，用户的订阅S-NSSAI中可能会一个或多个被设置为默认S-NSSAI；如果UE在注册请求消息（Registration Request）没有携带Allowed NSSAI，则网络会使用默认S-NSSAI来给UE提供服务，如果默认S-NSSAI存在的话。 
-  Requested NSSAI：请求NSSAI，也就是UE在注册请求消息(Registration Request)携带的Allowed NSSAI。 
-  Allowed NSSAI：允许NSSAI，表示UE请求的NSSAI中，哪些S-NSSAI被网络允许了，网络会在注册接收消息（Registration Accept）的"Allowed NSSAI" IE 带给UE。 
-  Rejected NSSAI：拒绝NSSAI，表示UE请求的NSSAI中，哪些S-NSSAI被网络拒绝了，网络会在注册接收消息（Registration Accept）的"Rejected NSSAI" IE 带给UE。 
-  Configured NSSAI：配置NSSAI，网络配置给UE使用的NSSAI，收到这个配置参数收，UE就知道网络下有哪些S-NSSAI可用；网络会在注册接收消息（Registration Accept）的"Configured NSSAI" IE 带给UE，如果注册后UE的配置有变化，则网络可通过Configuration update command通知UE更新；UE会在非易失存储空间保存每个网络给它配置的Configured NSSAI 【见TS24.501 Annex C】；每个PLMN最多只能配置一个Configured NSSAI。 
-  参数结构 

```
nssai
    s-nssai
        sst
        sd
    s-nssai
        sst
        sd
```

#### 2.2 切片需求来源

网络切片的需求来自于业务对网络提出的差异化要求，网络切片设计的出发点是按照业务对网络的不同需求灵活组织网络，形成为特定业务提供专属服务的网络，达到网络与业务的高度匹配。

#### 2.3 切片类型

- 增强型移动宽带（eMBB）：需要关注峰值速率，容量，频谱效率，移动性，网络能效等这些指标，和 3G、4G 类似。AR/VR、4K/8K 超高清视频等业务属于该类型。
- 海量机器通信（mMTC）：主要关注连接数。对下载速率，移动性等指标不太关心。针对大规模物联网业务。
- 高可靠低时延通信（uRLLC）：主要关注高可靠性，移动性和超低时延。对连接数，峰值速率，容量，频谱效率，网络能效等指标都没有太大需求。例如无人驾驶等业务。

#### 2.4 切片特性

网络切片具有以下四个特性：

- 1.隔离性：不同的网络切片之间互相隔离，一个切片的异常不会影响到其他的切片。
- 2.虚拟化：网络切片是在物理网络上划分出来的虚拟网络。
- 3.按需定制：可以根据不同的业务需求去自定义网络切片的业务、功能、容量、服务质量与连接关系，还可以按需进行切片的生命周期管理。
- 4.端到端：网络切片是针对整个网络而言，不仅需要核心网，还要包括接入网、传输网、管理网络等。

#### 2.5 切片层次

- 无线接入网络子切片：切片资源划分和隔离，切片感知，切片选择，移动性管理，每个切片的 QoS 保障。
- 承载网络子切片：基于 SDN 的统一管理，承载也可以被抽象成资源池来进行灵活分配，从而切割成网络切片。
- 核心网络子切片：5G 核心网基于SBA 架构，核心网的微服务模块就像搭积木一样按需拼装成网络切片。

### 3.切片选择流程

UE对网络切片的选择涉及两个关键过程，一个是UE注册流程，一个是PDUSession建立流程。
在实际应用中，一个 UE 可能同时接入一个或多个网络切片，当 UE 发起注册流程时，接入网络（gNB）根据 UE 请求携带的 NSSAI（Network Slice Selection Assistance Information，网络切片选择辅助信息）来选择核心网络子切片的入口AMF。NSSAI 包括切片/业务的类型和切片区分标识（Slice Differentiator），这些信息可以是标准定义的，也可以是运营商自定义的。如果 UE 发起注册时，请求没有携带任何 NSSAI 信息，接入网将选择默认的 AMF 提供服务。默认的 AMF 将根据运营商的策略和用户签约信息进一步选择 Target AMF 提供服务。AMF 将与 AUSF 一同对 UE 进行鉴权，鉴权通过后，UE 成功注册到网络。UE 注册成功后，AMF 将向 UE 提供被允许的 NSSAI 和临时用户标识（Temporary User ID），后续 UE 将携带这些信息接入网络，网络根据临时用户标识可以得到之前服务的 AMF 信息。
接下来，UE 可以发起业务请求，建立 UE 和 AMF 之间的信令连接，连接过程中或连接建立成功后，UE 和网络之间可以建立 PDU Session。在建立 PDU Session 的过程中，AMF 应综合签约信息、本地策略以及 NSSAI 等信息选择合适的 SMF，SMF 进行 PDU Session 的鉴权，为 UE 分配 IP 地址，指定提供服务的 UPF 提供后续的用户平面服务等。会话建立成功后，AMF 将保存 SMF 和终端的对应关系，SMF 也会保存 AMF 和终端识别的对应关系，以便后续的网络交互。以上是 3GPP 网络切片选择、终端注册、连接建立和会话建立的基本框架。

- 开户

用户开户时，签约数据中会包含用户支持的切片信息（例如切片 A、B、C，其中 A 和 B 被标记为 “default”，“default” 表示在终端不携带切片信息时，网络侧默认用户支持接入的切片。UE 侧存储在 USIM 卡，网络侧存储在 UDM）。

- 终端注册

终端初次入网注册时，不会在用户面建立 QoS Flow，所以终端未携带切片信息，AMF 将本地配置的切片信息与从 UDM 获取的用户签约数据中的切片信息进行匹配。

- 切片校验

如果 AMF 本地配置的切片信息包含签约的默认切片信息，则 AMF 判断可以为终端提供对应切片服务，在注册响应消息中携带用户在当前网络下可以使用的切片 A、B。

- 接入切换

如果 AMF 本地配置的切片信息中不包含签约的默认切片信息，则 AMF 判断自身不能为终端提供对应切片服务，AMF 查询 NSSF 获取可提供切片服务的其他 AMF 信息，NSSF 响应消息中携带为终端分配的切片配置信息。Target AMF 在注册响应消息中携带用户在当前网络下可以使用的切片 A、B。

- 应用接入
用户激活业务时（例如，用户打开一个 APP）才会携带切片信息，终端会根据步骤 2 中的切片选择策略，选择对应的切片 ID（例如网络切片 A）进行业务触发，AMF 选择切片 A 对应的 SMF 为终端建立 PDU Session。

### 4.参考

[https://blog.csdn.net/u010178611/article/details/82109791](https://blog.csdn.net/u010178611/article/details/82109791)
