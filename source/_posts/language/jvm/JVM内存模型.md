---
title: JVM内存模型
categories:
- java
tag:
- JVM
---



##<center>JVM 内存模型</center> 1.内存模型结构图

![**这里写图片描述**](http://img.blog.csdn.net/20170724161538339?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvY253dWhhbw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

| 名称         | 特征                                                     | 作用                                                                      | 配置参数                           | 异常                                 |
| ------------ | -------------------------------------------------------- | ------------------------------------------------------------------------- | ---------------------------------- | ------------------------------------ |
| 程序计数器   | 占用内存小，线程私有， 生命周期与线程相同                | 大致为字节码行号指示器                                                    | 无                                 | 无                                   |
| 虚拟机栈     | 线程私有，生命周期与线程相同，使用连续的内存空间         | Java 方法执行的内存模型，存储局部变量表、操作栈、动态链接、方法出口等信息 | -Xss                               | OutOfMemoryError，StackOverflowError |
| java 堆      | 线程共享，生命周期与虚拟机相同，可以不使用连续的内存地址 | 保存对象实例，所有对象实例（包括数组）都要在堆上分配                      | -Xms-Xsx -Xmn                      | OutOfMemoryError                     |
| 方法区       | 线程共享，生命周期与虚拟机相同，可以不使用连续的内存地址 | 存储已被虚拟机加载的类信息、常量、静态变量、即时编译器编译后的代码等数据  | -XX:PermSize:16M-XX:MaxPermSize64M | OutOfMemoryError                     |
| 运行时常量池 | 方法区的一部分，具有动态性                               | 存放字面量及符号引用                                                      | 无                                 | 无                                   |

<h5>1.1 程序计数器</h5>
程序 计数器（ Program Counter Register） 是一 块 较小 的 内存 空间， 它的 作用 可以 看做 是 当前 线程 所 执行 的 字节 码 的 行号 指示器。 在 虚拟 机 的 概念 模型 里（ 仅是 概念 模型， 各种 虚拟 机 可能 会 通过 一些 更 高效 的 方式 去 实现）， 字节 码 解释器 工作 时 就是 通过 改变 这个 计数器 的 值 来 选取 下一 条 需要 执行 的 字节 码 指令， 分支、 循环、 跳 转、 异常 处理、 线程 恢复 等 基础 功能 都 需要 依赖 这个 计数器 来 完成。
由于 Java 虚拟 机 的 多 线程 是 通过 线程 轮流 切换 并 分配 处理器 执行 时间 的 方式 来 实现 的， 在任 何 一个 确定 的 时刻， 一个 处理器（ 对于 多 核 处理器 来说 是一 个 内核） 只会 执行 一条 线程 中的 指令。 因此， 为了 线程 切换 后能 恢复 到 正确 的 执行 位置， 每条 线程 都 需要 有一个 独立 的 程序 计数器， 各条 线程 之间 的 计数器 互不 影响， 独立 存储， 我们 称 这类 内存 区域 为“ 线程 私有” 的 内存。 如果 线程 正在 执行 的 是 一个 Java 方法， 这个 计数器 记录 的 是 正在 执行 的 虚拟 机 字节 码 指令 的 地址； 如果 正在 执 行的 是 Natvie 方法， 这个 计数器 值 则为 空（ Undefined）。 此 内存 区域 是 唯一 一个 在 Java 虚拟 机 规范 中 没有 规定 任何 OutOfMemoryError 情况 的 区域。

<h5>1.2 Java 虚拟 机 栈</h5>
与 程序 计数器 一样， Java 虚拟 机 栈（ Java Virtual Machine Stacks） 也是 线程 私有 的， 它的 生命 周期 与 线程 相同。 虚拟 机 栈 描述 的 是 Java 方法 执行 的 内存 模型： 每个 方法 被 执行 的 时候 都会 同时 创建 一个 栈 帧（ Stack Frame[ 1]） 用于 存储 局部 变 量表、 操作 栈、 动态 链接、 方法 出口 等 信息。 每一个 方法 被 调用 直至 执行 完成 的 过程， 就 对应 着 一个 栈 帧 在 虚拟 机 栈 中 从 入栈 到 出 栈 的 过程,对于执行引擎来说，活动线程中，只有栈顶的栈帧是有效的，称为当前栈帧，这个栈帧所关联的方法称为当前方法。执行引擎所运行的所有字节码指令都只针对当前栈帧进行操作。 经常 有人 把 Java 内存 区 分为 堆 内存（ Heap） 和 栈 内存（ Stack）， 这种 分法 比较 粗糙， Java 内存 区域 的 划分 实际上 远比 这 复杂。 这种 划分 方式 的 流行 只能 说明 大多数 程序员 最 关注 的、 与 对象 内存 分配 关系 最 密切 的 内存 区域 是 这 两块。 其中 所指 的“ 堆” 在后面 会 专门 讲述， 而 所指 的“ 栈” 就是 现在 讲的 虚拟 机 栈， 或者 说是 虚拟 机 栈 中的 局部 变量 表 部分。 局部 变量 表 存放 了 编译 期 可知 的 各种 基本 数据 类型（ boolean、 byte、 char、 short、 int、 float、 long、 double）、 对象 引用（ reference 类型， 它不 等同 于 对象 本身， 根据 不同 的 虚拟 机 实现， 它可 能 是一 个 指向 对象 起始 地址 的 引用 指针， 也可能 指向 一个 代表 对象 的 句柄 或者 其他 与此 对象 相关 的 位置） 和 returnAddress 类型（ 指向 了 一条 字节 码 指令 的 地址）。 其中 64 位 长度 的 long 和 double 类型 的 数据 会 占用 2 个 局部 变量 空间（Slot）， 其余 的 数据 类型 只占 用 1 个。 局部 变量 表 所需 的 内存 空间 在编 译 期间 完成 分配， 当 进入 一个 方法 时， 这个 方法 需 要在 帧 中 分配 多大 的 局部 变量 空间 是 完全 确定 的， 在 方法 运行 期间 不会 改变 局部 变 量表 的 大小。 在 Java 虚拟 机 规范 中， 对这 个 区域 规定了 两种 异常 状况： 如果 线程 请求 的 栈 深度 大于 虚拟 机 所 允许 的 深度， 将 抛出 StackOverflowError 异常； 如果 虚拟 机 栈 可以 动态 扩展（ 当前 大部分 的 Java 虚拟 机 都可 动态 扩展， 只不过 Java 虚拟 机 规范 中 也 允许 固定 长度 的 虚拟 机 栈）， 当 扩展 时 无法 申请 到 足够 的 内存 时会 抛出 OutOfMemoryError 异常。
<h6>1.2.1 局部变量表</h6>
局部变量表是一组变量值存储空间，用于存放方法参数和方法内部定义的局部变量。在Java程序被编译成Class文件时，就在方法的Code属性的max_locals数据项中确定了该方法所需要分配的最大局部变量表的容量。
局部变量表的容量以变量槽（Slot）为最小单位，32位虚拟机中一个Slot可以存放一个32位以内的数据类型（boolean、byte、char、short、int、float、reference和returnAddress八种）。
reference类型虚拟机规范没有明确说明它的长度，但一般来说，虚拟机实现至少都应当能从此引用中直接或者间接地查找到对象在Java堆中的起始地址索引和方法区中的对象类型数据。
returnAddress类型是为字节码指令jsr、jsr_w和ret服务的，它指向了一条字节码指令的地址。
虚拟机是使用局部变量表完成参数值到参数变量列表的传递过程的，如果是实例方法（非static），那么局部变量表的第0位索引的Slot默认是用于传递方法所属对象实例的引用，在方法中通过this访问。
 Slot是可以重用的，当Slot中的变量超出了作用域，那么下一次分配Slot的时候，将会覆盖原来的数据。Slot对对象的引用会影响GC（要是被引用，将不会被回收）。
 系统不会为局部变量赋予初始值（实例变量和类变量都会被赋予初始值）。也就是说不存在类变量那样的准备阶段。
<h6>1.2.2 操作数栈</h6>
和局部变量区一样，操作数栈也是被组织成一个以字长为单位的数组。但是和前者不同的是，它不是通过索引来访问，而是通过标准的栈操作——压栈和出栈—来访问的。比如，如果某个指令把一个值压入到操作数栈中，稍后另一个指令就可以弹出这个值来使用。
虚拟机在操作数栈中存储数据的方式和在局部变量区中是一样的：如int、long、float、double、reference和returnType的存储。对于byte、short以及char类型的值在压入到操作数栈之前，也会被转换为int。
虚拟机把操作数栈作为它的工作区——大多数指令都要从这里弹出数据，执行运算，然后把结果压回操作数栈。比如，iadd指令就要从操作数栈中弹出两个整数，执行加法运算，其结果又压回到操作数栈中。如下演示了虚拟机是如何把两个int类型的局部变量相加，再把结果保存到第三个局部变量的：
```java
   begin  
   iload_0    // push the int in local variable 0 ontothe stack  
   iload_1    //push the int in local variable 1 onto the stack  
   iadd       // pop two ints, add them, push result  
   istore_2   // pop int, store into local variable 2  
   end
```
1. 指令iload_0和iload_1将存储在局部变量中索引为0和1的整数压入操作数栈中
2. iadd指令从操作数栈中弹出那两个整数相加，再将结果压入操作数栈
3. istore_2则从操作数栈中弹出结果，并把它存储到局部变量区索引为2的位置。
4. 局部变量和操作数栈的状态变化，图中没有使用的局部变量区和操作数栈区域以空白表示。

![**这里写图片描述**](http://img.blog.csdn.net/20170727201918687?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvY253dWhhbw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)<center>

<h6>1.2.3 动态连接<h6>
虚拟机运行的时候,运行时常量池会保存大量的符号引用，这些符号引用可以看成是每个方法的间接引用。如果代表栈帧A的方法想调用代表栈帧B的方法，那么这个虚拟机的方法调用指令就会以B方法的符号引用作为参数，但是因为符号引用并不是直接指向代表B方法的内存位置，所以在调用之前还必须要将符号引用转换为直接引用，然后通过直接引用才可以访问到真正的方法。
如果符号引用是在类加载阶段或者第一次使用的时候转化为直接应用，那么这种转换成为静态解析，如果是在运行期间转换为直接引用，那么这种转换就成为动态连接。
<h6> 1.2.4 返回地址 <h6>
方法的返回分为两种情况，一种是正常退出，退出后会根据方法的定义来决定是否要传返回值给上层的调用者，一种是异常导致的方法结束，这种情况是不会传返回值给上层的调用方法。
不过无论是那种方式的方法结束，在退出当前方法时都会跳转到当前方法被调用的位置，如果方法是正常退出的，则调用者的PC计数器的值就可以作为返回地址,，果是因为异常退出的，则是需要通过异常处理表来确定。
方法的的一次调用就对应着栈帧在虚拟机栈中的一次入栈出栈操作，因此方法退出时可能做的事情包括：恢复上层方法的局部变量表以及操作数栈，如果有返回值的话，就把返回值压入到调用者栈帧的操作数栈中，还会把PC计数器的值调整为方法调用入口的下一条指令。

![这里写图片描述](http://img.blog.csdn.net/20170727204302809?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvY253dWhhbw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)</center>

<h6> 1.2.5 异常 <h6>
在Java 虚拟机规范中，对虚拟机栈规定了两种异常状况：如果线程请求的栈深度大于虚拟机所允许的深度，将抛出StackOverflowError 异常；如果虚拟机栈可以动态扩展（当前大部分的Java 虚拟机都可动态扩展，只不过Java 虚拟机规范中也允许固定长度的虚拟机栈），当扩展时无法申请到足够的内存时会抛出OutOfMemoryError 异常。如下代码为请求大于虚拟机堆栈深度所出现的异常

```
    java
package com.sf.jvm;
/**
* VM Args：- Xss128k
*/
public class JavaVMStackSOF {
  private intstackLength=1;
  public void stackLeak() {
    stackLength++;
    stackLeak();
  }
  public static void main(String[] args)throwsThrowable {
    JavaVMStackSOF oom =newJavaVMStackSOF();
    try{
      oom.stackLeak();
    }catch(Throwable e) {
      System.out.println(" stack length:" + oom.stackLength);
      throw e;
    }
  }
}
```

运行出现如下情况：

```
stack length:22337
Exception in thread "main" java.lang.StackOverflowError
at com.sf.jvm.JavaVMStackSOF.stackLeak(JavaVMStackSOF.java:11)
at com.sf.jvm.JavaVMStackSOF.stackLeak(JavaVMStackSOF.java:11)
at com.sf.jvm.JavaVMStackSOF.stackLeak(JavaVMStackSOF.java:11)
at com.sf.jvm.JavaVMStackSOF.stackLeak(JavaVMStackSOF.java:11)
at com.sf.jvm.JavaVMStackSOF.stackLeak(JavaVMStackSOF.java:11)
at com.sf.jvm.JavaVMStackSOF.stackLeak(JavaVMStackSOF.java:11)
```

<h4>1.3 本地 方法 栈</h4>

本地 方法 栈（ Native Method Stacks） 与 虚拟 机 栈 所 发挥 的 作用 是非 常 相似 的， 其 区别 不过 是 虚拟 机 栈 为 虚拟 机 执行 Java 方法（ 也就是 字节 码） 服务， 而 本地 方法 栈 则是 为 虚拟 机 使 用到 的 Native 方法 服务。 虚拟 机 规范 中 对本 地 方法 栈 中的 方法 使用 的 语言、 使用 方式 与 数据 结构 并没有 强制 规定， 因此 具体 的 虚拟 机 可以 自由 实现 它。 甚至 有的 虚拟 机（ 譬如 Sun HotSpot 虚拟 机） 直接 就把 本地 方法 栈 和 虚拟 机 栈 合二为一。 与 虚拟 机 栈 一样， 本地 方法 栈 区域 也会 抛出 StackOverflowError 和 OutOfMemoryError 异常。

对于一个运行中的 Java 程序而言，它还可能会用到一些跟本地方法相关的数据区。当某个线程调用一个本地方法时，它就进入了一个全新的并且不再受虚拟机限制的世界。本地方法可以通过本地方法接口来访问虚拟机的运行时数据区，但不止如此，它还可以做任何它想做的事情。
　　本地方法本质上时依赖于实现的，虚拟机实现的设计者们可以自由地决定使用怎样的机制来让 Java 程序调用本地方法。
　　任何本地方法接口都会使用某种本地方法栈。当线程调用 Java 方法时，虚拟机会创建一个新的栈帧并压入 Java 栈。然而当它调用的是本地方法时，虚拟机会保持 Java 栈不变，不再在线程的 Java 栈中压入新的帧，虚拟机只是简单地动态连接并直接调用指定的本地方法。
　　如果某个虚拟机实现的本地方法接口是使用 C 连接模型的话，那么它的本地方法栈就是 C 栈。当 C 程序调用一个 C 函数时，其栈操作都是确定的。传递给该函数的参数以某个确定的顺序压入栈，它的返回值也以确定的方式传回调用者。同样，这就是虚拟机实现中本地方法栈的行为。
　　很可能本地方法接口需要回调 Java 虚拟机中的 Java 方法，在这种情况下，该线程会保存本地方法栈的状态并进入到另一个 Java 栈。
　　![这里写图片描述](http://img.blog.csdn.net/20170727205440144?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvY253dWhhbw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
　　这幅图展示了 JAVA 虚拟机内部线程运行的全景图。当一个线程调用一个本地方法时，本地方法又回调虚拟机中的另一个 Java 方法，一个线程可能在整个生命周期中都执行 Java 方法，操作它的 Java 栈；或者它可能毫无障碍地在 Java 栈和本地方法栈之间跳转。

该线程首先调用了两个 Java 方法，而第二个 Java 方法又调用了一个本地方法，这样导致虚拟机使用了一个本地方法栈。假设这是一个 C 语言栈，其间有两个 C 函数，第一个 C 函数被第二个 Java 方法当做本地方法调用，而这个 C 函数又调用了第二个 C 函数。之后第二个 C 函数又通过本地方法接口回调了一个 Java 方法（第三个 Java 方法），最终这个 Java 方法又调用了一个 Java 方法（它成为图中的当前方法）。
内存溢出实例：

```java
packagecom.sf.jvm;
/**
* VM Args：
* -Xss2M
*/
public classJavaVMStackOOM {
   private void dontStop() {
      while(true) {
         try{
           Thread.sleep(100000);
        }catch(InterruptedException e) {
		   e.printStackTrace();
	    }
	  }
  }
	  public void stackLeakByThread() {
		int threadNum =0;
	    while(true) {
		    Thread thread =newThread(newRunnable() {
				public void run() {
				dontStop();
				}
		});
		thread.start();
		threadNum++;
		}
	}
	public static void main(String[] args)throwsThrowable {
		JavaVMStackOOM oom =newJavaVMStackOOM();
		oom.stackLeakByThread();
	}
}

运行程序抛出如下异常：
Exception in thread "main" java. lang. OutOfMemoryError: unable to create new native thread
```

<h4>1.4 Java 堆<h4>

Java 堆（ Java Heap） 是 Java 虚拟 机 所 管理 的 内存 中最 大的 一块。 Java 堆 是 被 所有 线程 共享 的 一块 内存 区域， 在 虚拟 机 启动 时 创建。 此 内存 区域 的 唯一 目的 就是 存放 对象 实例， 几乎 所有 的 对象 实例 都在 这里 分配 内存。 这一 点在 Java 虚拟 机 规范 中的 描述 是： 所有 的 对象 实例 以及 数组 都 要在 堆 上 分配[ 2]， 但是 随着 JIT 编译器 的 发展 与 逃逸 分析 技术 的 逐渐 成熟， 栈 上 分配、 标量 替换[ 3] 优化 技术 将会 导致 一些 微妙 的 变化 发生， 所有 的 对象 都 分配 在 堆 上 也 渐渐 变得 不是 那么“ 绝对” 了。 Java 堆 是 垃圾 收集 器 管理 的 主要 区域， 因此 很多 时候 也 被 称做“ GC 堆”（ Garbage Collected Heap）。 如果 从内 存 回收 的 角度 看， 由于 现在 收集 器 基本 都是 采 用的 分 代收 集 算法， 所以 Java 堆 中 还可以 细分 为： 新生代 和 老 年代； 再 细致 一点 的 有 Eden 空间、 From Survivor 空间、 To Survivor 空间 等。 如果 从内 存 分配 的 角度 看， 线程 共享 的 Java 堆 中 可能 划分 出 多个 线程 私有 的 分配 缓冲区（ Thread Local Allocation Buffer， TLAB）。 不过， 无论如何 划分， 都与 存放 内容 无关， 无论 哪个 区域， 存储 的 都 仍然是 对象 实例， 进一步 划分 的 目的 是 为了 更好 地 回收 内存， 或者 更快 地 分配 内存。 在 本章 中， 我们 仅仅 针对 内存 区域 的 作用 进行 讨论， Java 堆 中的 上述 各个 区域 的 分配 和 回收 等 细节 将会 是 下 一章 的 主题。 根据 Java 虚拟 机 规范 的 规定， Java 堆 可以 处于 物理上 不连续 的 内存 空间 中， 只要 逻辑上 是 连续 的 即可， 就 像 我们 的 磁盘 空间 一样。 在 实现 时， 既可以 实现 成 固定 大小 的， 也可以 是 可扩展 的， 不过 当前 主流 的 虚拟 机 都是 按照 可扩展 来 实现 的（ 通过- Xmx 和- Xms 控制）。
Java 中的堆是 JVM 所管理的最大的一块内存空间，主要用于存放各种类的实例对象。
在 Java 中，堆被划分成两个不同的区域：新生代 ( Young )、老年代 ( Old )。新生代 ( Young ) 又被划分为三个区域：Eden、From Survivor、To Survivor。这样划分的目的是为了使 JVM 能够更好的管理堆内存中的对象，包括内存的分配以及回收。如下图所示：

![这里写图片描述](http://img.blog.csdn.net/20170727210308831?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvY253dWhhbw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)</center>

从图中可以看出： 堆大小 = 新生代 + 老年代。其中，堆的大小可以通过参数 –Xms、-Xmx 来指定。
默认的，新生代 ( Young ) 与老年代 ( Old ) 的比例的值为 1:2 ( 该值可以通过参数 –XX:NewRatio 来指定 )，即：新生代 ( Young ) = 1/3 的堆空间大小。
老年代 ( Old ) = 2/3 的堆空间大小。其中，新生代 ( Young ) 被细分为 Eden 和 两个 Survivor 区域，这两个 Survivor 区域分别被命名为 from 和 to，以示区分。
默认的，Edem : from : to = 8 : 1 : 1 ( 可以通过参数 –XX:SurvivorRatio 来设定 )，即： Eden = 8/10 的新生代空间大小，from = to = 1/10 的新生代空间大小。
JVM 每次只会使用 Eden 和其中的一块 Survivor 区域来为对象服务，所以无论什么时候，总是有一块 Survivor 区域是空闲着的。
因此，新生代实际可用的内存空间为 9/10 ( 即 90% )的新生代空间。

GC 堆
Java 中的堆也是 GC 收集垃圾的主要区域。GC 分为两种：Minor GC、Full GC ( 或称为 Major GC )。
Minor GC 是发生在新生代中的垃圾收集动作，所采用的是复制算法。
新生代几乎是所有 Java 对象出生的地方，即 Java 对象申请的内存以及存放都是在这个地方。Java 中的大部分对象通常不需长久存活，具有朝生夕灭的性质。
当一个对象被判定为 “死亡” 的时候，GC 就有责任来回收掉这部分对象的内存空间。新生代是 GC 收集垃圾的频繁区域。
当对象在 Eden ( 包括一个 Survivor 区域，这里假设是 from 区域 ) 出生后，在经过一次 Minor GC 后，如果对象还存活，并且能够被另外一块 Survivor 区域所容纳
( 上面已经假设为 from 区域，这里应为 to 区域，即 to 区域有足够的内存空间来存储 Eden 和 from 区域中存活的对象 )，则使用复制算法将这些仍然还存活的对象复制到另外一块 Survivor 区域 ( 即 to 区域 ) 中，然后清理所使用过的 Eden 以及 Survivor 区域 ( 即 from 区域 )，并且将这些对象的年龄设置为 1，以后对象在 Survivor 区每熬过一次 Minor GC，就将对象的年龄 + 1，当对象的年龄达到某个值时 ( 默认是 15 岁，可以通过参数 -XX:MaxTenuringThreshold 来设定 )，这些对象就会成为老年代。
但这也不是一定的，对于一些较大的对象 ( 即需要分配一块较大的连续内存空间 ) 则是直接进入到老年代。
Full GC 是发生在老年代的垃圾收集动作，所采用的是标记-清除算法。
现实的生活中，老年代的人通常会比新生代的人 “早死”。堆内存中的老年代(Old)不同于这个，老年代里面的对象几乎个个都是在 Survivor 区域中熬过来的，它们是不会那么容易就 “死掉” 了的。因此，Full GC 发生的次数不会有 Minor GC 那么频繁，并且做一次 Full GC 要比进行一次 Minor GC 的时间更长。
另外，标记-清除算法收集垃圾的时候会产生许多的内存碎片 ( 即不连续的内存空间 )，此后需要为较大的对象分配内存空间时，若无法找到足够的连续的内存空间，就会提前触发一次 GC 的收集动作。

设置 JVM 参数为 -XX:+PrintGCDetails，使得控制台能够显示 GC 相关的日志信息，执行上面代码，下面是其中一次执行的结果。

| jvm 参数                        | 解释                                                                                                                    |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| -Xms                            | 初始堆大小。如：-Xms256m                                                                                                |
| -Xmx                            | 最大堆大小。如：-Xmx512m                                                                                                |
| -Xmn                            | 新生代大小。通常为 Xmx 的 1/3 或 1/4。新生代 = Eden + 2 个 Survivor 空间。实际可用空间为 = Eden + 1 个 Survivor，即 90% |
| -Xss                            | JDK1.5+ 每个线程堆栈大小为 1M，一般来说如果栈不是很深的话， 1M 是绝对够用了的。                                         |
| -XX:NewRatio                    | 新生代与老年代的比例，如 –XX:NewRatio=2，则新生代占整个堆空间的 1/3，老年代占 2/3                                       |
| -XX:SurvivorRatio               | 新生代中 Eden 与 Survivor 的比值。默认值为 8。即 Eden 占新生代空间的 8/10，另外两个 Survivor 各占 1/10                  |
| -XX:PermSize                    | 永久代(方法区)的初始大小                                                                                                |
| -XX:MaxPermSize                 | 永久代(方法区)的最大值                                                                                                  |
| -XX:+PrintGCDetails             | 打印 GC 信息                                                                                                            |
| -XX:+HeapDumpOnOutOfMemoryError | 让虚拟机在发生内存溢出时 Dump 出当前的内存堆转储快照，以便分析用                                                        |

Java 堆 用于 储存 对象 实例， 我们 只要 不断 地 创建 对象， 并且 保证 GC Roots 到 对象 之间 有可 达 路径 来 避免 垃圾 回收 机制 清除 这些 对象， 就会 在 对象 数量 到达 最 大堆 的 容量 限制 后 产生 内存 溢出 异常。实例如下：

```java
packagecom.sf.jvm;
importjava.util.ArrayList;
importjava.util.List;
/**
* VM Args：
* -Xms20m -Xmx20m
* -XX:+HeapDumpOnOutOfMemoryError
* -XX:+PrintGCDetails
*/
public classHeapOutOfMemory {

	public static void main(String[] args) {
		outOfMemory();
	}
	static void noOutOfMemory(){
		while(true) {
			newOOMObject();
		}
	}
	static void outOfMemory(){
		List<OOMObject> list =newArrayList<OOMObject>();
		while(true) {
			list.add(newOOMObject());
		}
	}
}
classOOMObject {
	bytemem[] =new byte[2014];
}
异常信息如下：
[GC (Allocation Failure) [PSYoungGen: 5632K->512K(6144K)] 5632K->5024K(19968K), 0.0027725 secs] [Times: user=0.00 sys=0.00, real=0.00 secs]
[GC (Allocation Failure) [PSYoungGen: 6144K->504K(6144K)] 10656K->11432K(19968K), 0.0022202 secs] [Times: user=0.00 sys=0.00, real=0.00 secs]
[Full GC (Ergonomics) [PSYoungGen: 504K->0K(6144K)] [ParOldGen: 10928K->10092K(13824K)] 11432K->10092K(19968K), [Metaspace: 2973K->2973K(1056768K)], 0.0149535 secs] [Times: user=0.02 sys=0.00, real=0.01 secs]
........
[Full GC (Allocation Failure) [PSYoungGen: 5632K->5632K(6144K)] [ParOldGen: 13823K->13823K(13824K)] 19455K->19455K(19968K), [Metaspace: 2973K->2973K(1056768K)], 0.0086009 secs] [Times: user=0.00 sys=0.00, real=0.01 secs]
java.lang.OutOfMemoryError: Java heap space
Dumping heap to java_pid2780.hprof ...
Heap dump file created [20898436 bytes in 0.027 secs]
[Full GC (Ergonomics) Exception in thread "main" java.lang.OutOfMemoryError: Java heap space
at com.sf.jvm.OOMObject.<init>(HeapOutOfMemory.java:29)
at com.sf.jvm.HeapOutOfMemory.outOfMemory(HeapOutOfMemory.java:23)
at com.sf.jvm.HeapOutOfMemory.main(HeapOutOfMemory.java:12)
[PSYoungGen: 5632K->0K(6144K)] [ParOldGen: 13823K->579K(13824K)] 19455K->579K(19968K), [Metaspace: 2973K->2973K(1056768K)], 0.0096016 secs] [Times: user=0.00 sys=0.00, real=0.01 secs]
Heap
PSYoungGen total 6144K, used 177K [0x00000000ff980000, 0x0000000100000000, 0x0000000100000000)
eden space 5632K, 3% used [0x00000000ff980000,0x00000000ff9ac4a0,0x00000000fff00000)
from space 512K, 0% used [0x00000000fff80000,0x00000000fff80000,0x0000000100000000)
to space 512K, 0% used [0x00000000fff00000,0x00000000fff00000,0x00000000fff80000)
ParOldGen total 13824K, used 579K [0x00000000fec00000, 0x00000000ff980000, 0x00000000ff980000)
object space 13824K, 4% used [0x00000000fec00000,0x00000000fec90c20,0x00000000ff980000)
Metaspace used 3005K, capacity 4496K, committed 4864K, reserved 1056768K
class space used 326K, capacity 388K, committed 512K, reserved 1048576K
```

用 jvisualvm.exe 打开查看 dump，发现主要是 OOMobject 不被释放。

<h4>1.5 方法 区<h4>
      <h5>1.5.1 方法区</h5> 
方法 区（ Method Area） 与 Java 堆 一样， 是 各个 线程 共享 的 内存 区域， 它 用于 存储 已被 虚拟 机 加载 的 类 信息、 常量、 静态 变量、 即时 编译器 编译 后的 代码 等 数据。 虽然 Java 虚拟 机 规范 把 方法 区 描述为 堆 的 一个 逻辑 部分， 但是 它 却有 一个 别名 叫做 Non- Heap（ 非 堆）， 目的 应该 是与 Java 堆 区分 开来。 对于 习惯 在 HotSpot 虚拟 机上 开发 和 部署 程序 的 开发者 来说， 很多人 愿意 把 方法 区 称为“ 永久 代”（ Permanent Generation）， 本质上 两者 并不 等价， 仅仅 是因为 HotSpot 虚拟 机 的 设计 团队 选择 把 GC 分 代收 集 扩展 至 方法 区， 或者说 使用 永久 代 来 实现 方法 区 而已。 对于 其他 虚拟 机（ 如 BEA JRockit、 IBM J9 等） 来说 是 不存在 永久 代 的 概念 的。 即使是 HotSpot 虚拟 机 本身， 根据 官方 发布 的 路线 图 信息， 现在 也有 放弃 永久 代 并“ 搬家” 至 Native Memory 来 实现 方法 区 的 规划 了。 Java 虚拟 机 规范 对这 个 区域 的 限制 非常 宽松， 除了 和 Java 堆 一样 不需要 连续 的 内存 和 可以 选择 固定 大小 或者 可扩展 外， 还可以 选择 不实 现 垃圾 收集。 相对而言， 垃圾 收集 行为 在这 个 区域 是 比较 少 出现 的， 但 并非 数据 进入 了 方法 区 就 如 永久 代 的 名字 一样“ 永久” 存在 了。 这个 区域 的 内存 回收 目标 主要 是 针对 常量 池 的 回收 和 对 类型 的 卸载， 一般来说 这个 区域 的 回收“ 成绩” 比较 难以 令人满意， 尤其是 类型 的 卸载， 条件 相当 苛刻， 但是 这部 分 区域 的 回收 确实 是有 必要 的。 在 Sun 公司 的 BUG 列表 中， 曾 出现 过 的 若干个 严重 的 BUG 就是 由于 低 版本 的 HotSpot 虚拟 机 对此 区域 未完 全 回收 而 导致 内存 泄漏。 根据 Java 虚拟 机 规范 的 规定， 当 方法 区 无法 满足 内存 分配 需求 时， 将 抛出 OutOfMemoryError 异常。方法 区 用于 存放 Class 的 相关 信息， 如 类 名、 访问 修饰 符、 常量 池、 字段 描述、 方法 描述 等。 对于 这个 区域 的 测试， 基本 的 思路 是 运行时 产生 大量 的 类 去 填满 方法 区， 直到 溢出。 虽然 直接 使用 Java SE API 也可以 动态 产生 类（ 如 反射 时 的 GeneratedConstructorAccessor 和 动态 代理 等）， 但在 本次 实验 中 操作 起来 比较 麻烦。 在 代码 清单 2- 5 中， 笔者 借助 CGLib[ 3] 直接 操作 字节 码 运行时， 生成 了 大量 的 动态 类。 值得 特别 注意 的 是， 我们 在这 个 例子 中 模拟 的 场景 并非 纯粹 是一 个 实验， 这样 的 应用 经常 会 出现 在 实际 应用 中： 当前 的 很多 主流 框架， 如 Spring 和 Hibernate 对 类 进行 增强 时， 都会 使用 到 CGLib 这类 字节 码 技术， 增 强的 类 越多， 就 需要 越大 的 方法 区 来 保证 动态 生成 的 Class 可以 加载 入 内存。
方法 区 溢出 也是 一种 常见 的 内存 溢出 异常， 一个 类 如果 要被 垃圾 收集 器 回收 掉， 判定 条件 是非 常 苛刻 的。 在 经常 动态 生成 大量 Class 的 应用 中， 需要 特别 注意 类 的 回收 状况。 这类 场景 除了 上面 提到 的 程序 使用 了 GCLib 字节 码 增强 外， 常见 的 还有： 大量 JSP 或 动态 产生 JSP 文件 的 应用（ JSP 第一次 运行时 需要 编译 为 Java 类）、 基于 OSGi 的 应用（ 即使是 同一个 类 文件， 被 不同 的 加载 器 加载 也会 视为 不同 的 类） 等。
代码 清单 2- 5 　 借助 CGLib 使得 方法 区 出现 内存 溢出 异常
```java
packagecom.sf.jvm;
/**
* VM Args： -XX: PermSize= 10M -XX: MaxPermSize= 10M
*/
public class JavaMethodAreaOOM {
	public static void main(String[] args) {
		while(true) {
			Enhancer enhancer =newEnhancer();
			enhancer.setSuperclass(OOMObject.class);
			enhancer.setUseCache(false);
			enhancer.setCallback(newMethodInterceptor() {
				public Object intercept(Object obj, Method method, 
					Object[] args, MethodProxy proxy)throwsThrowable {
					returnproxy.invokeSuper(obj, args);
				}
			});
			enhancer.create();
		}
	}
	static classOOMObject {
	}
}
运行 结果：
Caused by: 
java. lang. OutOfMemoryError: 
PermGen space at java. lang. ClassLoader. defineClass1( Native Method)
at java. lang. ClassLoader. defineClassCond( ClassLoader. java: 632) 
at java. lang. ClassLoader. defineClass( ClassLoader. java: 616）
```

<h5>1.5.2 运行时常量池</h5>
 运行时 常量 池（ Runtime Constant Pool） 是 方法 区 的 一部分。 Class 文件 中 除了 有 类 的 版本、 字段、 方法、接口 等 描述 等 信息 外， 还有 一项 信息 是 常量 池（ Constant Pool Table）， 用于 存放 编译 期 生成 的 各种 字面 量 和 符号 引用， 这部 分 内容 将 在 类 加载 后 存放 到 方法 区 的 运行时 常量 池 中。 Java 虚拟 机 对 Class 文件 的 每一 部分（ 自然 也 包括 常量 池） 的 格式 都有 严格 的 规定， 每一个 字节 用于 存储 哪种 数据 都 必须 符合 规范 上 的 要求， 这样 才会 被 虚拟 机 认可、 装载 和 执行。 但 对于 运行时 常量 池， Java 虚拟 机 规范 没有 做 任何 细节 的 要求， 不同 的 提供 商 实现 的 虚拟 机 可以 按照 自己的 需要 来 实现 这个 内存 区域。 不过， 一般来说， 除了 保存 Class 文件 中 描述 的 符号 引用 外， 还会 把 翻译 出来 的 直接 引用 也 存储 在 运行时 常量 池 中[ 4]。 运行时 常量 池 相对于 Class 文件 常量 池 的 另外 一个 重要 特征 是 具备 动态 性， Java 语言 并不 要求 常量 一定 只能 在 编译 期 产生， 也就是 并非 预置 入 Class 文件 中 常量 池 的 内容 才能 进入 方法 区 运行时 常量 池， 运行 期间 也可 能将 新的 常量 放入 池 中， 这种 特性 被 开发 人员 利用 得比 较多 的 便是 String 类 的 intern() 方法。 既然 运行时 常量 池 是 方法 区 的 一部分， 自然 会受 到 方法 区 内存 的 限制， 当 常量 池 无法 再 申请 到 内存 时会 抛出 OutOfMemoryError 异常。
 
```java
package com.sf.jvm;
importjava.util.ArrayList;
importjava.util.List;
/**
* VM Args：- XX:PermSize=10M -XX:MaxPermSize=10M
*/
public class RuntimeConstantPoolOOM {
	public static void main(String[] args) {
		// 使用 List 保持 着 常量 池 引用， 避免 Full GC 回收 常量 池 行为
		List<String> list =new ArrayList<String>();
		// 10MB 的 PermSize 在 integer 范围内 足够 产生 OOM 了
		int i = 0;
		while(true) {
			list.add(String.valueOf(i++ +"xxxxxxxxxxxxxxxxxxxxx").intern());
		}
	}
}
运行异常：
Exception in thread "main" java. lang. OutOfMemoryError: 
PermGen space at java. lang. String. intern( Native Method) 
at org. fenixsoft. oom. RuntimeConstantPoolOOM. main( RuntimeConstantPoolOOM. java:...
```

<h4>1.7 直接 内存</h4>
 直接内存（DirectMemory）并不是虚拟机运行时数据区的一部分，也不是Java虚拟机规范中定义的内存区域，但是这部分内存也被频繁地使用，而且也可能导致OutOfMemoryError异常出现，所以我们放到这里一起讲解。在JDK1.4中新加入了NIO（NewInput/Output）类，引入了一种基于通道（Channel）与缓冲区（Buffer）的I/O方式，它可以使用Native函数库直接分配堆外内存，然后通过一个存储在Java堆里面的DirectByteBuffer对象作为这块内存的引用进行操作。这样能在一些场景中显著提高性能，因为避免了在Java堆和Native堆中来回复制数据。显然，本机直接内存的分配不会受到Java堆大小的限制，但是，既然是内存，则肯定还是会受到本机总内存（包括RAM及SWAP区或者分页文件）的大小及处理器寻址空间的限制。服务器管理员配置虚拟机参数时，一般会根据实际内存设置-Xmx等参数信息，但经常会忽略掉直接内存，使得各个内存区域的总和大于物理内存限制（包括物理上的和操作系统级的限制），从而导致动态扩展时出现OutOfMemoryError异常。DirectMemory容量可通过-XX：MaxDirectMemorySize指定，如果不指定，则默认与Java堆的最大值（-Xmx指定）一样。越过了DirectByteBuffer类，直接通过反射获取Unsafe实例并进行内存分配（Unsafe类的getUnsafe()方法限制了只有引导类加载器才会返回实例，也就是设计者希望只有rt.jar中的类才能使用Unsafe的功能）。因为，虽然使用DirectByteBuffer分配内存也会抛出内存溢出异常，但它抛出异常时并没有真正向操作系统申请分配内存，而是通过计算得知内存无法分配，于是手动抛出异常，真正申请分配内存的方法是unsafe.allocateMemory()。如下实例为直接内存溢出。    
```java
package com.sf.jvm;
import sun.misc.Unsafe;
import java.lang.reflect.Field;
import staticcom.sun.deploy.util.BufferUtil.MB;
/**
* VM Args：- Xmx20M -XX: MaxDirectMemorySize= 10M
*/
public classDirectMemoryOOM {
	private static final int_1MB=1024*1024;
	public static void main(String[] args)throwsException {
		Field unsafeField = Unsafe.class.getDeclaredFields()[0];
		unsafeField.setAccessible(true);
		Unsafe unsafe = (Unsafe) unsafeField.get(null);
		while(true) {
			unsafe.allocateMemory(_1MB);
		}
	}
}
运行异常：
Exception in thread "main" java.lang.OutOfMemoryError
at sun.misc.Unsafe.allocateMemory(Native Method)
at com.sf.jvm.DirectMemoryOOM.main(DirectMemoryOOM.java:20)
```
<h4>1.8 对象的访问</h4>
介绍完Java虚拟机的运行时数据区之后，我们就可以来探讨一个问题：在Java语言中，对象访问是如何进行的？对象访问在Java语言中无处不在，是最普通的程序行为，但即使是最简单的访问，也会却涉及Java栈、Java堆、方法区这三个最重要内存区域之间的关联关系，如下面的这句代码：Objectobj=newObject();假设这句代码出现在方法体中，那“Objectobj”这部分的语义将会反映到Java栈的本地变量表中，作为一个reference类型数据出现。而“newObject()”这部分的语义将会反映到Java堆中，形成一块存储了Object类型所有实例数据值（InstanceData，对象中各个实例字段的数据）的结构化内存，根据具体类型以及虚拟机实现的对象内存布局（ObjectMemoryLayout）的不同，这块内存的长度是不固定的。另外，在Java堆中还必须包含能查找到此对象类型数据（如对象类型、父类、实现的接口、方法等）的地址信息，这些类型数据则存储在方法区中。由于reference类型在Java虚拟机规范里面只规定了一个指向对象的引用，并没有定义这个引用应该通过哪种方式去定位，以及访问到Java堆中的对象的具体位置，因此不同虚拟机实现的对象访问方式会有所不同，主流的访问方式有两种：使用句柄和直接指针。
       如果使用句柄访问方式，Java堆中将会划分出一块内存来作为句柄池，reference中存储的就是对象的句柄地址，而句柄中包含了对象实例数据和类型数据各自的具体地址信息，如图:
![这里写图片描述](http://img.blog.csdn.net/20170728094239784?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvY253dWhhbw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)</center>
        如果使用直接指针访问方式，Java堆对象的布局中就必须考虑如何放置访问类型数据的相关信息，reference中直接存储的就是对象地址，如图:`<center>`![这里写图片描述](http://img.blog.csdn.net/20170728094300056?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvY253dWhhbw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)</center>
         这两种对象的访问方式各有优势，使用句柄访问方式的最大好处就是reference中存储的是稳定的句柄地址，在对象被移动（垃圾收集时移动对象是非常普遍的行为）时只会改变句柄中的实例数据指针，而reference本身不需要被修改。使用直接指针访问方式的最大好处就是速度更快，它节省了一次指针定位的时间开销，由于对象的访问在Java中非常频繁，因此这类开销积少成多后也是一项非常可观的执行成本。就本书讨论的主要虚拟机SunHotSpot而言，它是使用第二种方式进行对象访问的，但从整个软件开发的范围来看，各种语言和框架使用句柄来访问的情况也十分常见。
参照：
深入理解Java虚拟机
http://blog.csdn.net/u012152619/article/details/46968883
http://www.importnew.com/14630.html
