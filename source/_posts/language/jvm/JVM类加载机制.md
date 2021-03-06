---
title: JVM类加载机制
categories:
- java
tag:
- JVM
---

# 类加载机制

### 1. 类的加载过程

类从被加载到虚拟机内存中开始，到卸载出内存为止，它的整个生命周期包括：加载（Loading）、验证（Verification）、准备(Preparation)、解析(Resolution)、初始化(Initialization)、使用(Using)和卸载(Unloading)7 个阶段。其中准备、验证、解析 3 个部分统称为连接（Linking）。如图所示:

```
graph LR
加载-->验证
验证-->准备
准备-->解析
解析-->初始化
初始化-->使用
使用-->卸载
```

加载、验证、准备、初始化和卸载这 5 个阶段的顺序是确定的，类的加载过程必须按照这种顺序按部就班地开始，而解析阶段则不一定：它在某些情况下可以在初始化阶段之后再开始，这是为了支持 Java 语言的运行时绑定（也称为动态绑定或晚期绑定）。以下陈述的内容都已 HotSpot 为基准。

#### 1.1 加载

虚拟机在加载阶段需要完成三件事:

1. 通过一个类的全限定名来获取定义此类的二进制字节流，如 Class 文件,网络,动态生成,数据库等
2. 将这个字节流所代表的静态存储结构转化为方法区的运行时数据结构
3. 在内存中生成一个代表这个类的 java.lang.Class 对象，作为方法区这个类的各种数据的访问入口
   加载阶段和连接阶段（Linking）的部分内容（如一部分字节码文件格式验证动作）是交叉进行的，加载阶段尚未完成，连接阶段可能已经开始，但这些夹在加载阶段之中进行的动作，仍然属于连接阶段的内容，这两个阶段的开始时间仍然保持着固定的先后顺序。

#### 1.2 验证

验证是连接阶段的第一步，这一阶段的目的是为了确保 Class 文件的字节流中包含的信息符合当前虚拟机的要求，并且不会危害虚拟机自身的安全，验证阶段大致会完成 4 个阶段的检验动作：

1. 文件格式验证：验证字节流是否符合 Class 文件格式的规范；例如：是否以魔术 0xCAFEBABE 开头、主次版本号是否在当前虚拟机的处理范围之内、常量池中的常量是否有不被支持的类型。
2. 元数据验证：对字节码描述的信息进行语义分析（注意：对比 javac 编译阶段的语义分析），以保证其描述的信息符合 Java 语言规范的要求；例如：这个类是否有父类，除了 java.lang.Object 之外。
3. 字节码验证：通过数据流和控制流分析，确定程序语义是合法的、符合逻辑的。
4. 符号引用验证：确保解析动作能正确执行。
   验证阶段可能抛出一个 java.lang.IncompatibleClassChangeError 异常的子类，如 java.lang.IllegalAccessError、 java. lang. NoSuchFieldError、
   验证阶段是非常重要的，但不是必须的，它对程序运行期没有影响，如果所引用的类经过反复验证，那么可以考虑采用-Xverifynone 参数来关闭大部分的类验证措施，以缩短虚拟机类加载的时间。

#### 1.3 准备

准备阶段是正式为类变量分配内存并设置类变量初始值的阶段，这些变量所使用的内存都将在方法区中进行分配。这时候进行内存分配的仅包括类变量（被 static 修饰的变量），而不包括实例变量，实例变量将会在对象实例化时随着对象一起分配在堆中。其次，这里所说的初始值“通常情况”下是数据类型的零值.

如下定义:public static int value=123; 那变量 value 在准备阶段过后的初始值为 0 而不是 123.因为这时候尚未开始执行任何 java 方法，而把 value 赋值为 123 的 putstatic 指令是程序被编译后，存放于类构造器()方法之中，所以把 value 赋值为 123 的动作将在初始化阶段才会执行。

如下定义：public static final int value=123; 即当类字段的字段属性是 ConstantValue 时，会在准备阶段初始化为指定的值，所以标注为 final 之后，value 的值在准备阶段初始化为 123 而非 0.

#### 1.4 解析

解析阶段是虚拟机将常量池内的符号引用替换为直接引用的过程。解析针对如下 7 类符号引用进行：

> 类或接口
> 字段
> 类方法
> 接口方法
> 方法类型
> 方法句柄
> 调用点限定符

#### 1.5 初始化

类初始化阶段是类加载过程的最后一步，才真正开始执行类中定义的 Java 程序代码（或者说是字节码）。前面的类加载过程中，除了在加载阶段用户应用程序可以通过自定义类加载器参与之外，其余动作完全由虚拟机主导和控制。

在准备阶段，变量已经赋过一次系统要求的初始值，而在初始化阶段，则是根据程序员通过程序制定的主观计划去初始化类变量和其他资源，或者可以从另外一个角度来表达：初始化阶段是执行类构造器<clinit>()方法的过程。我们放到后面再讲<clinit>()方法是怎么生成的，在这里，我们先看一下<clinit>()方法执行过程中可能会影响程序运行行为的一些特点和细节，这部分相对更贴近于普通的程序开发人员[7]：
·<clinit>()方法是由编译器自动收集类中的所有类变量的赋值动作和静态语句块（static{}块）中的语句合并产生的，编译器收集的顺序是由语句在源文件中出现的顺序所决定的，静态语句块中只能访问到定义在静态语句块之前的变量，定义在它之后的变量，在前面的静态语句块中可以赋值，但是不能访问。
·<clinit>()方法与类的构造函数（或者说实例构造器<clinit>()方法）不同，它不需要显式地调用父类构造器，虚拟机会保证在子类的<clinit>()方法执行之前，父类的<clinit>()方法已经执行完毕。因此在虚拟机中第一个被执行的<clinit>()方法的类肯定是 java.lang.Object。
·由于父类的<clinit>()方法先执行，也就意味着父类中定义的静态语句块要优先于子类的变量赋值操作，如下代码执行字段 B 的值将会是 2 而不是 1。
<clinit>()方法执行顺序：

```java
package sf.jvm.load;
 class Parent {
    public static int A = 1;
    static {
        A = 2;
    }
     public int getA(){
         return A;
     }
}
class Sub extends Parent {
     public static int B = A;
     public int getB(){
         return B;
     }
     public static void main(String[] args) {
         new Parent();
        System.out.println(Sub.B);
        System.out.println(new Sub().getB());
    }
}
/**
 Compiled from "Parent.java"
 class sf.jvm.load.Parent {
 public static int A;
 sf.jvm.load.Parent();
 Code:
 0: aload_0
 1: invokespecial #1                  // Method java/lang/Object."<init>":()V
 4: return
 public int getA();
 Code:
 0: getstatic     #2                  // Field A:I
 3: ireturn
 static {};
 Code:
 0: iconst_1
 1: putstatic     #2                  // Field A:I
 4: iconst_2
 5: putstatic     #2                  // Field A:I
 8: return
 }
 */
```

·<clinit>()方法对于类或接口来说并不是必须的，如果一个类中没有静态语句块，也没有对变量的赋值操作，那么编译器可以不为这个类生成<clinit>()方法。
·接口中不能使用静态语句块，但仍然有变量初始化的赋值操作，因此接口与类一样都会生成<clinit>()方法。但接口与类不同的是，执行接口的<clinit>()方法不需要先执行父接口的<clinit>()方法。只有当父接口中定义的变量被使用时，父接口才会被初始化。另外，接口的实现类在初始化时也一样不会执行接口的<clinit>()方法。
·虚拟机会保证一个类的<clinit>()方法在多线程环境中被正确地加锁和同步，如果多个线程同时去初始化一个类，那么只会有一个线程去执行这个类的<clinit>()方法，其他线程都需要阻塞等待，直到活动线程执行<clinit>()方法完毕。如果在一个类的<clinit>()方法中有耗时很长的操作，那就可能造成多个进程阻塞，在实际应用中这种阻塞往往是很隐蔽的。

```java
package sf.jvm.load;
class DeadLoopClass {
    static {
        //如果不加上这个if语句，编译器将提示"Initializerdoesnotcompletenormally"并拒绝编译
        if (true) {
            System.out.println(Thread.currentThread() + "initDeadLoopClass");
            while (true) {
            }
        }
    }
    public static void main(String[] args) {
        Runnable script = new Runnable() {
            public void run() {
                System.out.println(Thread.currentThread() + "start");
                DeadLoopClass dlc = new DeadLoopClass();
                System.out.println(Thread.currentThread() + "runover");
            }
        };
        Thread thread1 = new Thread(script);
        Thread thread2 = new Thread(script);
        thread1.start();
        thread2.start();
    }
}
/**
 *
 "C:\Program Files\Java\jdk1.8.0_91\bin\javap.exe" -c sf.jvm.load.DeadLoopClass
 Compiled from "DeadLoopClass.java"
 class sf.jvm.load.DeadLoopClass {
 sf.jvm.load.DeadLoopClass();
 Code:
 0: aload_0
 1: invokespecial #1                  // Method java/lang/Object."<init>":()V
 4: return
 public static void main(java.lang.String[]);
 Code:
 0: new           #2                  // class sf/jvm/load/DeadLoopClass$1
 3: dup
 4: invokespecial #3                  // Method sf/jvm/load/DeadLoopClass$1."<init>":()V
 7: astore_1
 8: new           #4                  // class java/lang/Thread
 11: dup
 12: aload_1
 13: invokespecial #5                  // Method java/lang/Thread."<init>":(Ljava/lang/Runnable;)V
 16: astore_2
 17: new           #4                  // class java/lang/Thread
 20: dup
 21: aload_1
 22: invokespecial #5                  // Method java/lang/Thread."<init>":(Ljava/lang/Runnable;)V
 25: astore_3
 26: aload_2
 27: invokevirtual #6                  // Method java/lang/Thread.start:()V
 30: aload_3
 31: invokevirtual #6                  // Method java/lang/Thread.start:()V
 34: return
 static {};
 Code:
 0: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
 3: new           #8                  // class java/lang/StringBuilder
 6: dup
 7: invokespecial #9                  // Method java/lang/StringBuilder."<init>":()V
 10: invokestatic  #10                 // Method java/lang/Thread.currentThread:()Ljava/lang/Thread;
 13: invokevirtual #11                 // Method java/lang/StringBuilder.append:(Ljava/lang/Object;)Ljava/lang/StringBuilder;
 16: ldc           #12                 // String initDeadLoopClass
 18: invokevirtual #13                 // Method java/lang/StringBuilder.append:(Ljava/lang/String;)Ljava/lang/StringBuilder;
 21: invokevirtual #14                 // Method java/lang/StringBuilder.toString:()Ljava/lang/String;
 24: invokevirtual #15                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
 27: goto          27
 }
 * */
```

运行结果如下:

```java
Thread[main,5,main]initDeadLoopClass
通过分析：一条线程正在死循环以模拟长时间操作，另外一条线程在阻塞等待.
线程堆栈如下:
2017-07-29 20:05:00
Full thread dump Java HotSpot(TM) 64-Bit Server VM (25.91-b14 mixed mode):

"Monitor Ctrl-Break" #10 daemon prio=5 os_prio=0 tid=0x0000000018554800 nid=0x4920 runnable [0x00000000190de000]
   java.lang.Thread.State: RUNNABLE
        at java.net.DualStackPlainSocketImpl.accept0(Native Method)
        at java.net.DualStackPlainSocketImpl.socketAccept(DualStackPlainSocketImpl.java:131)
        at java.net.AbstractPlainSocketImpl.accept(AbstractPlainSocketImpl.java:409)
        at java.net.PlainSocketImpl.accept(PlainSocketImpl.java:199)
        - locked <0x00000000d79d67c0> (a java.net.SocksSocketImpl)
        at java.net.ServerSocket.implAccept(ServerSocket.java:545)
        at java.net.ServerSocket.accept(ServerSocket.java:513)
        at com.intellij.rt.execution.application.AppMain$1.run(AppMain.java:79)
        at java.lang.Thread.run(Thread.java:745)

"Finalizer" #3 daemon prio=8 os_prio=1 tid=0x00000000027d8800 nid=0x2d14 in Object.wait() [0x000000001837e000]
   java.lang.Thread.State: WAITING (on object monitor)
        at java.lang.Object.wait(Native Method)
        - waiting on <0x00000000d7808ee0> (a java.lang.ref.ReferenceQueue$Lock)
        at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:143)
        - locked <0x00000000d7808ee0> (a java.lang.ref.ReferenceQueue$Lock)
        at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:164)
        at java.lang.ref.Finalizer$FinalizerThread.run(Finalizer.java:209)

"Reference Handler" #2 daemon prio=10 os_prio=2 tid=0x00000000027d3000 nid=0x4914 in Object.wait() [0x000000001827f000]
   java.lang.Thread.State: WAITING (on object monitor)
        at java.lang.Object.wait(Native Method)
        - waiting on <0x00000000d7806b50> (a java.lang.ref.Reference$Lock)
        at java.lang.Object.wait(Object.java:502)
        at java.lang.ref.Reference.tryHandlePending(Reference.java:191)
        - locked <0x00000000d7806b50> (a java.lang.ref.Reference$Lock)
        at java.lang.ref.Reference$ReferenceHandler.run(Reference.java:153)
"main" #1 prio=5 os_prio=0 tid=0x000000000220e000 nid=0x450c runnable [0x00000000026de000]
   java.lang.Thread.State: RUNNABLE
        at sf.jvm.load.DeadLoopClass.<clinit>(DeadLoopClass.java:8)
        at java.lang.Class.forName0(Native Method)
        at java.lang.Class.forName(Class.java:264)
        at com.intellij.rt.execution.application.AppMain.main(AppMain.java:123)
"VM Thread" os_prio=2 tid=0x0000000016ff7000 nid=0x6d4 runnable
"GC task thread#0 (ParallelGC)" os_prio=0 tid=0x00000000026f7800 nid=0x4890 runnable
"GC task thread#1 (ParallelGC)" os_prio=0 tid=0x00000000026f9000 nid=0x4514 runnable
"VM Periodic Task Thread" os_prio=2 tid=0x00000000184e1800 nid=0x4934 waiting on condition
JNI global references: 15
```

### 2 类加载器

#### 2.1 　类加载器概述

虚拟机设计团队把类加载阶段中的“通过一个类的全限定名来获取描述此类的二进制字节流”这个动作放到 Java 虚拟机外部去实现，以便让应用程序自己决定如何去获取所需要的类。实现这个动作的代码模块被称为“类加载器”。
类加载器可以说是 Java 语言的一项创新，也是 Java 语言流行的重要原因之一，它最初是为了满足 JavaApplet 的需求而被开发出来的。如今 JavaApplet 技术基本上已经死掉[1]，但类加载器却在类层次划分、OSGi、热部署、代码加密等领域大放异彩，成为了 Java 技术体系中一块重要的基石。
类加载器（class loader）用来加载 Java 类到 Java 虚拟机中。一般来说，Java 虚拟机使用 Java 类的方式如下：Java 源程序（.java 文件）在经过 Java 编译器编译之后就被转换成 Java 字节代码（.class 文件）。类加载器负责读取 Java 字节代码，并转换成 java.lang.Class 类的一个实例。每个这样的实例用来表示一个 Java 类。通过此实例的 newInstance()方法就可以创建出该类的一个对象。实际的情况可能更加复杂，比如 Java 字节代码可能是通过工具动态生成的，也可能是通过网络下载的。

#### 2.2 类加载器的结构

```
graph BT
启动类加载器-->扩展类加载器
扩展类加载器-->应用类加载器
应用类加载器-->自定义加载器1
应用类加载器-->自定义加载器2
```

Java 虚拟机的角度讲，只存在两种不同的类加载器：一种是启动类加载器（BootstrapClassLoader），这个类加载器使用 C++语言实现[2]，是虚拟机自身的一部分；另外一种就是所有其他的类加载器，这些类加载器都由 Java 语言实现，独立于虚拟机外部，并且全都继承自抽象类 java.lang.ClassLoader。从 Java 开发人员的角度来看，类加载器就还可以划分得更细致一些，绝大部分 Java 程序都会使用到以下三种系统提供的类加载器：：
引导类加载器（bootstrap class loader）：它用来加载 Java 的核心库，是用原生代码来实现的，并不继承自 java.lang.ClassLoader。
扩展类加载器（extensions class loader）：它用来加载 Java 的扩展库。Java 虚拟机的实现会提供一个扩展库目录。该类加载器在此目录里面查找并加载 Java 类。
应用程序类加载器（application class loader）：它根据 Java 应用的类路径（CLASSPATH）来加载 Java 类。一般来说，Java 应用的类都是由它来完成加载的。可以通过 ClassLoader.getSystemClassLoader()来获取它。
除了系统提供的类加载器以外，开发人员可以通过继承 java.lang.ClassLoader 类的方式实现自己的类加载器，以满足一些特殊的需求。

双亲委派模型的工作过程是：如果一个类加载器收到了类加载的请求，它首先不会自己去尝试加载这个类，而是把这个请求委派给父类加载器去完成，每一个层次的类加载器都是如此，因此所有的加载请求最终都应该传送到顶层的启动类加载器中，只有当父加载器反馈自己无法完成这个加载请求（它的搜索范围中没有找到所需的类）时，子加载器才会尝试自己去加载。

破坏双亲委派模型
双亲委派模型的第一次“被破坏”其实发生在双亲委派模型出现之前——即 JDK1.2 发布之前。由于双亲委派模型在 JDK1.2 之后才被引入的，而类加载器和抽象类 java.lang.ClassLoader 则在 JDK1.0 时代就已经存在，面对已经存在的用户自定义类加载器的实现代码，Java 设计者们引入双亲委派模型时不得不做出一些妥协。为了向前兼容，JDK1.2 之后的 java.lang.ClassLoader 添加了一个新的 protected 方法 findClass()，
双亲委派模型的第二次“被破坏”是由这个模型自身的缺陷所导致的，双亲委派很好地解决了各个类加载器的基础类的统一问题（越基础的类由越上层的加载器进行加载），基础类之所以被称为“基础”，是因为它们总是作为被用户代码调用的 API，但世事往往没有绝对的完美，如果基础类又要调用回用户的代码，那该怎么办了？这并非是不可能的事情，一个典型的例子便是 JNDI 服务，JNDI 现在已经是 Java 的标准服务，它的代码由启动类加载器去加载（在 JDK1.3 时代放进去的 rt.jar），但 JNDI 的目的就是对资源进行集中管理和查找，它需要调用由独立厂商实现并部署在应用程序的 ClassPath 下的 JNDI 接口提供者（SPI，ServiceProviderInterface）的代码，但启动类加载器不可能“认识”这些代码啊！那该怎么办？为了解决这个困境，Java 设计团队只好引入了一个不太优雅的设计：线程上下文类加载器（ThreadContextClassLoader）。这个类加载器可以通过 java.lang.Thread 类的 setContextClassLoaser()方法进行设置，如果创建线程时还未设置，它将会从父线程中继承一个；如果在应用程序的全局范围内都没有设置过，那么这个类加载器默认就是应用程序类加载器。有了线程上下文类加载器，就可以做一些“舞弊”的事情了，JNDI 服务使用这个线程上下文类加载器去加载所需要的 SPI 代码，也就是父类加载器请求子类加载器去完成类加载的动作，这种行为实际上就是打通了双亲委派模型的层次结构来逆向使用类加载器，已经违背了双亲委派模型的一般性原则，但这也是无可奈何的事情。Java 中所有涉及 SPI 的加载动作基本上都采用这种方式，例如 JNDI、JDBC、JCE、JAXB 和 JBI 等。
双亲委派模型的第三次“被破坏”是由于用户对程序动态性的追求而导致的，这里所说的“动态性”指的是当前一些非常“热”门的名词：代码热替换（HotSwap）、模块热部署（HotDeployment）等，说白了就是希望应用程序能像我们的电脑外设那样，插上鼠标或 U 盘，不用重启机器就能立即使用，鼠标有问题或要升级就换个鼠标，不用停机也不用重启。对于个人电脑来说，重启一次其实没有什么大不了的，但对于一些生产系统来说，关机重启一次可能就要被列为生产事故，这种情况下热部署就对软件开发者，尤其是企业级软件开发者具有很大的吸引力。在 JSR-297[4]、JSR-277[5]规范从纸上标准变成真正可运行的程序之前，OSGi 是当前业界“事实上”的 Java 模块化标准，而 OSGi 实现模块化热部署的关键则是它自定义的类加载器机制的实现。每一个程序模块（OSGi 中称为 Bundle）都有一个自己的类加载器，当需要更换一个 Bundle 时，就把 Bundle 连同类加载器一起换掉以实现代码的热替换。
在 OSGi 环境下，类加载器不再是双亲委派模型中的树状结构，而是进一步发展为网状结构，当收到类加载请求时，OSGi 将按照下面的顺序进行类搜索：

> （1）将以 java.\*开头的类，委派给父类加载器加载。
> （2）否则，将委派列表名单内的类，委派给父类加载器加载。
> （3）否则，将 Import 列表中的类，委派给 Export 这个类的 Bundle 的类加载器加载。
> （4）否则，查找当前 Bundle 的 ClassPath，使用自己的类加载器加载。
> （5）否则，查找类是否在自己的 FragmentBundle 中，如果在，则委派给 FragmentBundle 的类加载器加载。
> （6）否则，查找 DynamicImport 列表的 Bundle，委派给对应 Bundle 的类加载器加载。
> （7）否则，类查找失败。上面的查找顺序中只有开头两点仍然符合双亲委派规则，其余的类查找都是在平级的类加载器中进行的。

虽然使用了“被破坏”这个词来形容上述不符合双亲委派模型原则的行为，但这里“被破坏”并不带有贬义的感情色彩。只要有足够意义和理由，突破已有的原则就可算作一种创新。正如 OSGi 中的类加载器并不符合传统的双亲委派的类加载器，并且业界对其为了实现热部署而带来的额外的高复杂度还存在不少争议，但在 Java 程序员中基本有一个共识：OSGi 中对类加载器的使用是很值得学习的，弄懂了 OSGi 的实现，自然就明白了类加载器的精粹。
//TODO
OSGI

#### 2.3 自定义类加载器实例:

##### 2.3.1 文件加载:

```java
package sf.jvm.load.classloader;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Method;

public class FileSystemClassLoader extends ClassLoader {

  private String rootDir;

  public FileSystemClassLoader(String rootDir) {
      this.rootDir = rootDir;
  }

  protected Class<?> findClass(String name) throws ClassNotFoundException {
      byte[] classData = getClassData(name);
      if (classData == null) {
          throw new ClassNotFoundException();
      } else {
          return defineClass(name, classData, 0, classData.length);
      }
  }

  private byte[] getClassData(String className) {
      String path = classNameToPath(className);
      try {
          InputStream ins = new FileInputStream(path);
          ByteArrayOutputStream baos = new ByteArrayOutputStream();
          int bufferSize = 4096;
          byte[] buffer = new byte[bufferSize];
          int bytesNumRead = 0;
          while ((bytesNumRead = ins.read(buffer)) != -1) {
              baos.write(buffer, 0, bytesNumRead);
          }
          return baos.toByteArray();
      } catch (IOException e) {
          e.printStackTrace();
      }
      return null;
  }

  private String classNameToPath(String className) {
      return rootDir + File.separatorChar + className.replace('.', File.separatorChar) + ".class";
  }

  public static void main(String[] args) {
      String classDataRootPath = "D:\\Code\\Jcode\\notes\\java-jlp\\java-jvm\\target\\classes";
      FileSystemClassLoader fileSystemClassLoader1 = new FileSystemClassLoader(classDataRootPath);
      FileSystemClassLoader fileSystemClassLoader2 = new FileSystemClassLoader(classDataRootPath);
      String className = "sf.jvm.load.simple.Sample";
      try {
          Class<?> class1 = fileSystemClassLoader1.loadClass(className);
          Object obj1 = class1.newInstance();
          Class<?> class2 = fileSystemClassLoader1.loadClass(className);
          Object obj2 = class2.newInstance();
          Method setSampleMethod = class1.getMethod("setSample", Object.class);
          setSampleMethod.invoke(obj1, obj2);
          Method setSampleMethod2 = class1.getMethod("compare", Object.class);
          setSampleMethod2.invoke(obj1, obj2);
      } catch (Exception e) {
          e.printStackTrace();
      }
  }
}
```

##### 2.3.2 网络加载:

```java
package sf.jvm.load.classloader;

import sf.jvm.load.api.ICalculator;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.URL;

public class NetworkClassLoader extends ClassLoader {

  private String rootUrl;

  public NetworkClassLoader(String rootUrl) {
      this.rootUrl = rootUrl;
  }

  protected Class<?> findClass(String name) throws ClassNotFoundException {
      byte[] classData = getClassData(name);
      if (classData == null) {
          throw new ClassNotFoundException();
      } else {
          return defineClass(name, classData, 0, classData.length);
      }
  }

  private byte[] getClassData(String className) {
      String path = classNameToPath(className);
      try {
          URL url = new URL(path);
          InputStream ins = url.openStream();
          ByteArrayOutputStream baos = new ByteArrayOutputStream();
          int bufferSize = 4096;
          byte[] buffer = new byte[bufferSize];
          int bytesNumRead = 0;
          while ((bytesNumRead = ins.read(buffer)) != -1) {
              baos.write(buffer, 0, bytesNumRead);
          }
          return baos.toByteArray();
      } catch (Exception e) {
          e.printStackTrace();
      }
      return null;
  }

  private String classNameToPath(String className) {
      return rootUrl + "/" + className.replace('.', '/') + ".class";
  }

  public static void main(String[] args) {
      String url = "http://localhost:8080/ClassloaderTest/classes";
      NetworkClassLoader ncl = new NetworkClassLoader(url);
      String basicClassName = "sf.jvm.load.simple.CalculatorBasic";
      String advancedClassName = "sf.jvm.load.simple.CalculatorAdvanced";
      try {
          Class<?> clazz = ncl.loadClass(basicClassName);
          ICalculator calculator = (ICalculator) clazz.newInstance();
          System.out.println(calculator.getVersion());
          clazz = ncl.loadClass(advancedClassName);
          calculator = (ICalculator) clazz.newInstance();
          System.out.println(calculator.getVersion());
      } catch (Exception e) {
          e.printStackTrace();
      }
  }
}
```
