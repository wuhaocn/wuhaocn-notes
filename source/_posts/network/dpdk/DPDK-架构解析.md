
---
title: DPDK-架构解析

categories:
- 5G

tag:
- DPDK
- 5G
---

# 目录

### DPDK-架构解析

- [目录](http://t.zoukankan.com/hzcya1995-p-13309271.html#_0)
- [前文列表](http://t.zoukankan.com/hzcya1995-p-13309271.html#_3)
- [DPDK 架构](http://t.zoukankan.com/hzcya1995-p-13309271.html#DPDK__7)
- [内核态模块](http://t.zoukankan.com/hzcya1995-p-13309271.html#_32)
   - [IGB_UIO](http://t.zoukankan.com/hzcya1995-p-13309271.html#IGB_UIO_33)
   - [KNI](http://t.zoukankan.com/hzcya1995-p-13309271.html#KNI_35)
- [PMD](http://t.zoukankan.com/hzcya1995-p-13309271.html#PMD_44)
- [DPDK Lib（核心部件库）](http://t.zoukankan.com/hzcya1995-p-13309271.html#DPDK_Lib_47)
   - [组件代码](http://t.zoukankan.com/hzcya1995-p-13309271.html#_75)
- [平台相关模块](http://t.zoukankan.com/hzcya1995-p-13309271.html#_98)
- [Classify 库](http://t.zoukankan.com/hzcya1995-p-13309271.html#Classify__109)
- [QoS 库](http://t.zoukankan.com/hzcya1995-p-13309271.html#QoS__112)
# 前文列表
《[DPDK — 安装部署](https://is-cloud.blog.csdn.net/article/details/105980054)》
《[DPDK — 数据平面开发技术](https://is-cloud.blog.csdn.net/article/details/98944634)》
# DPDK 架构
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1627481768904-b3db99fb-9713-449c-8322-139b150da09f.png#clientId=u0928072c-4fbe-4&from=paste&id=ud4958617&margin=%5Bobject%20Object%5D&name=image.png&originHeight=750&originWidth=942&originalType=url&ratio=1&size=130624&status=done&style=none&taskId=ue7338f12-4782-4375-b298-d165d19cfce)
**内核态模块**：

- IGB_UIO：
- KNI

**用户态函数库以及网卡驱动程序**：

- 用户态轮询模式的网卡驱动程序（PMD Driver）
- 核心部件库（Core Libraries）
- 操作系统平台相关模块（Platform）
- QoS 库
- 报文转发分类算法库（Classify）

用户应用程序可以应用以上函数库以及驱动支持，来实现完全内核旁路的数据面转发应用程序，例如：OVS-DPDK。
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1627481769146-6c669857-20c2-4539-8a45-342d8064df02.png#clientId=u0928072c-4fbe-4&from=paste&id=u61914ee9&margin=%5Bobject%20Object%5D&name=image.png&originHeight=496&originWidth=389&originalType=url&ratio=1&size=244431&status=done&style=none&taskId=u498a303d-b2c5-4b95-9d2b-b86ccccf82b)

- **EAL（Environment Abstraction Layer，环境抽象层）**：为应用提供了一个通用接口，隐藏了与底层库与设备打交道的相关细节。EAL 实现了 DPDK 运行的初始化工作，基于大页表的内存分配，多核亲缘性设置，原子和锁操作，并将 PCI 设备地址映射到用户空间，方便应用程序访问。
- **Buffer Manager API**：通过预先从 EAL 上分配固定大小的多个内存对象，避免了在运行过程中动态进行内存分配和回收，以此来提高效率，用于数据包 Buffer 的管理。
- **Queue/Ring Manager API**：以高效的方式实现了无锁的 FIFO 环形队列，适用于一个生产者多个消费者、一个消费者多个生产者模型。支持批量无锁操作，可避免锁冲突导致的等待。
- **Packet Flow Classification API**：通过 Intel SSE 基于多元组的方式实现了高效的 HASH 算法，以便快速对数据包进行分类处理。该 API 一般用于路由查找过程中的最长前缀匹配。此外，安全产品场景中，可以根据 DataFlow 五元组来标记不同的用户。
- **PMD（Poll Mode Library）**：则实现了 Intel 1GbE、10GbE 和 40GbE 网卡下基于轮询收发包的工作模式，大大加速网卡收发包性能。
# 内核态模块
## IGB_UIO
《[DPDK — IGB_UIO，与 UIO Framework 进行交互的内核模块](https://is-cloud.blog.csdn.net/article/details/106007926)》
## KNI
KNI（Kernel NIC Interface，内核网卡接口），是 DPDK 允许用户态和内核态交换报文的解决方案，模拟了一个虚拟的网口，提供 DPDK 应用程序和 Linux 内核之间通讯没接。**即 KNI 接口允许报文从用户态接收后转发到 Linux 内核协议栈中去**。
虽然 DPDK 的高速转发性能很出色，但是也有自己的一些缺点，比如没有标准协议栈就是其中之一，当然也可能当时设计时就将没有将协议栈考虑进去，毕竟协议栈需要将报文转发处理，可能会使处理报文的能力大大降低。
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1627481769261-be65ada1-ff35-4880-a322-d18f4e381979.png#clientId=u0928072c-4fbe-4&from=paste&id=uba9293cc&margin=%5Bobject%20Object%5D&name=image.png&originHeight=345&originWidth=558&originalType=url&ratio=1&size=82294&status=done&style=none&taskId=ucad680f6-11df-4deb-8c57-78c6b3ef9ff)
上图是 KNI 的 mbuf 的使用流程，也可以看出报文的流向，因为报文在代码中其实就是一个个内存指针。其中 rx_q 右边是用户态，左边是内核态。最后通过调用 netif_rx 将报文送入 Linux 内核协议栈，这其中需要将 DPDK 的 mbuf 转换成标准的 skb_buf 结构体。当 Linux 内核向 KNI 端口发送报文时，调用回调函数 kni_net_tx，然后报文经过转换之后发送到端口上。
# PMD
《[DPDK — PMD，DPDK 的核心优化](https://blog.csdn.net/Jmilk/article/details/103025477)》
# DPDK Lib（核心部件库）
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1627481773020-678f8177-7108-49a0-864e-ddf4523e41ba.png#clientId=u0928072c-4fbe-4&from=paste&id=uf52df5e3&margin=%5Bobject%20Object%5D&name=image.png&originHeight=378&originWidth=797&originalType=url&ratio=1&size=72204&status=done&style=none&taskId=ud2675454-3c19-45ba-93aa-e142cbd7379)
核心部件库（Core Libraries）是 DPDK 面向用户态协议栈应用程序员开发的模块。

- **EAL（Environment Abstraction Layer，环境抽象层）**：对 DPDK 的运行环境（e.g. Linux 操作系统）进行初始化，包括：HugePage 内存分配、内存/缓冲区/队列分配、原子性无锁操作、NUMA 亲和性、CPU 绑定等，并通过 UIO 或 VFIO 技术将 PCI/PCIe 设备地址映射到用户态，方便了用户态的 DPDK 应用程序调用。同时为应用程序提供了一个通用接口，隐藏了其与底层库以及设备打交道的相关细节。
- **MALLOC（堆内存管理组件）**：为 DPDK 应用程序提供从 HugePage 内分配堆内存的接口。当需要为 SKB（Socket Buffer，本质是若干个数据包的缓存区）分配大量的小块内存时（如：分配用于存储 Buffer descriptor table 中每个表项指针的内存）可以调用该接口。由于堆内存是从 HugePage 内存分配的，所以可以减少 TLB 缺页。

注：堆，是由开发人员主动分配和释放的存储空间， 若开发人员不释放，则程序结束时由 OS 回收，分配方式类似于链表；与堆不同，栈，是由操作系统自动分配和释放的存储空间 ，用于存放函数的参数值、局部变量等，其操作方式类似于数据结构中的栈。

- **MBUF（网络报文缓存块管理组件）**：为 DPDK 应用程序提供创建和释放用于存储数据报文信息的缓存块的接口。提供了两种类型的 MBUF，一种用于存储一般信息，一种用于存储实际的报文数据。这些 MBUF 存储在一个内存池中。
- **MEMPOOL（内存池管理组件）**：为 DPDK 应用程序和其它组件提供分配内存池的接口，内存池是一个由固定大小的多个内存块组成的内存容器，可用于存储不同的对像实体，如：数据报文缓存块等。内存池由内存池的名称（一个字符串）进行唯一标识，它由一个 Ring 缓冲区和一组本地缓存队列组成，每个 CPU Core 优先从自身的缓存队列中分配内存块，当本地缓存队列减少到一定程度时，开始从内存环缓冲区中申请内存块来进行补充。
- **RING（环缓冲区管理组件）**：为 DPDK 应用程序和其它组件提供一个无锁的多生产者多消费者 FIFO 队列。

**NOTE**：DPDK 基于 Linux 内核的无锁环形缓冲 kfifo 实现了一套自己的无锁机制。支持单生产者入列/单消费者出列和多生产者入列/多消费者出列操作，在数据传输的时候，降低性能的同时还能保证数据的同步。

- **TIMER（定时器组件）**：提供一些异步周期执行的接口（也可以只执行一次），可以指定某个函数在规定时间内的异步执行，就像 LIBC 中的 timer 定时器。但是这里的定时器需要 DPDK 应用程序在主循环中周期内调用 rte_timer_manage 来使能定时器，使用起来不那么方便。TIMER 的时间参考来自 EAL 层提供的时间接口。

注：除了以上六个核心组件外，DPDK 还提供以下功能：

1. 以太网轮询模式驱动（PMD）架构：把以太网驱动从内核移到应用层，采用同步轮询机制而不是内核态的异步中断机制来提高报文的接收和发送效率。
1. 报文转发算法支持：Hash 库和 LPM 库为报文转发算法提供支持。
1. 网络协议定义和相关宏定义：基于 FreeBSD IP 协议栈的相关定义，如：TCP、UDP、SCTP 等协议头定义。
1. 报文 QoS 调度库：支持随机早检测、流量整形、严格优先级和加权随机循环优先级调度等相关 QoS 功能。
1. 内核网络接口库（KNI）：提供一种 DPDK 应用程序与内核协议栈的通信的方法，类似 Linux 的 TUN/TAP 接口，但比 TUN/TAP 接口效率高。每个物理网口可以虚拟出多个 KNI 接口。
## 组件代码
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1627481769193-9dfea3cf-22c5-4457-a519-93ed7c367c80.png#clientId=u0928072c-4fbe-4&from=paste&id=u0bdac4d1&margin=%5Bobject%20Object%5D&name=image.png&originHeight=567&originWidth=754&originalType=url&ratio=1&size=235286&status=done&style=none&taskId=u50cc4576-6bc3-4c17-9ca9-16f78f2a3f9)
**注**：

- RTE：Run-Time Environment
- EAL：Environment Abstraction Layer
- PMD：Poll-Mode Driver

核心部件库对应的 DPDK 核心组件实现：

- **Memory Manager（librte_malloc，堆内存管理器）**：提供一组 API，用于从 HugePages 内存创建的 memzones 中分配内存，而不是在堆中分配。这有助于改善 Linux 用户空间环境下典型的从堆中大量分配 4KB 页面而容易引起 TLB 不命中。
- **Memory Pool Manager（librte_mempool，内存池管理器）**：内存池管理器负责分配的内存中的 Pool 对象。Pool 由名称唯一标识，并使用一个 Ring 来存储空闲对象。它提供了其他一些可选的服务，例如：每个 CPU Core 的对象缓存和对齐方式帮助，以确保将填充的对象在所有内存通道上得到均匀分布。
- **Ring Manager（librte_ring，环形队列管理器）**：在一个大小有限的页表中，Ring 数据结构提供了一个无锁的多生产者-多消费者 FIFO API。相较于无锁队列，它有一些的优势，如：更容易实现，适应于大容量操作，而且速度更快。 一个 Ring 可以在 Memory Pool Manager 中被使用，也可以用于不同 CPU Core 或 Processor 之间作为通用的通信机制。
- **Network Packet Buffer Management（librte_mbuf，网络报文缓冲区管理）**：提供一组 API，用于分配、释放和操作 MBUFs（数据报文缓冲区），DPDK 应用程序中可以使用这些缓存区来存储消息以及报文数据。
- **Timer Manager（librte_timer，定时器管理）**：为 DPDK 应用程序的执行单元提供了定时服务，支持以异步的方式执行函数。定时器可以设置周期调用，也可以设置为只调用一次。DPDK 应用程序可以使用 EAL 提供的 HPET 接口来获取高精度时钟的引用，并且能在每个 Core 上根据需要进行初始化。

代码目录：
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1627481772817-48082ec2-383b-4210-ba40-a1222f0bc792.png#clientId=u0928072c-4fbe-4&from=paste&id=u3da3a1cd&margin=%5Bobject%20Object%5D&name=image.png&originHeight=1242&originWidth=850&originalType=url&ratio=1&size=875251&status=done&style=none&taskId=uf4da37b8-7885-437e-85b9-45254cdde0a)
# 平台相关模块
平台相关模块（Platform）包括 KNI、POWER（能耗管理）以及 IVSHMEM 接口。

- **KNI**：主要通过 Linux 内核中的 kni.ko 模块将数据报文从用户态传递给内核态协议栈处理，以便常规的用户进程（e.g. Container）可以使用 Linux 内核协议栈传统的 Socket 接口对相关报文进行处理。
- **POWER**：提供了一些 API，让 DPDK 应用程序可以根据收包速率动态调整 CPU 频率或让 CPU 进入不同的休眠状态。
- **IVSHMEM**：模块提供了虚拟机与虚拟机之间，或者虚拟机与主机之间的零拷贝共享内存机制。当 DPDK 应用程序运行时，IVSHMEM 模块会调用 Core Libraries 的 API，把几个 HugePage 内存映射为一个 IVSHMEM 设备池，并通过参数传递给 QEMU，这样，就实现了虚拟机之间的零拷贝内存共享。
# Classify 库
支持精确匹配（Exact Match）、最长匹配（LPM）和通配符匹配（ACL）数据报文，并提供常用的包处理的查表操作。
# QoS 库
提供网络服务质量相关的组件，如：限速（Meter）和调度（Scheduler）。
