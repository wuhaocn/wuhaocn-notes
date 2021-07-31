---
title: JVM软引用和弱引用
categories:
- java
tag:
- JVM
---

#### 一个场景
```java
如果有一个值，对应的键已经不再使用了, 将会出现什么情况呢？假定对某个键的最后一次引用已经消亡, 
不再有任何途径引用这个值的对象了, 但是, 由于在程序中的任何部分没有再出现这个键, 
所以, 这个 键/值 对无法从映射中删除.

垃圾收集器怎么处理这样的场景呢? 引用出现了!
```


#### JAVA 中的引用
**强引用 StrongReference**: 普通对象引用，只要还有强引用指向一个对象，就能表明对象还“活着”，垃圾收集器不会碰这种对象。对于一个普通的对象，如果没有其他的引用关系，只要超过了引用的作用域或者显式地将相应（强）引用赋值为 null，就是可以被垃圾收集的了，当然具体回收时机还是要看垃圾收集策略


**软引用 SoftReference**: 一种相对强引用弱化一些的引用，可以让对象豁免一些垃圾收集，只有当 JVM 认为内存不足时，才会去试图回收软引用指向的对象。JVM 会确保在抛出 OutOfMemoryError 之前，清理软引用指向的对象。软引用通常用来实现内存敏感的缓存，如果还有空闲内存，就可以暂时保留缓存，当内存不足时清理掉，这样就保证了使用缓存的同时，不会耗尽内存, 维护一种非强制性的映射关系


**弱引用 WeakReference**: 并不能使对象豁免垃圾收集，仅仅是提供一种访问在弱引用状态下对象的途径。这就可以用来构建一种没有特定约束的关系,如果试图获取时对象还在，就使用它，否则重现实例化。它同样是很多缓存实现的选择。这个类对象的引用，一般主要是在 major collection 的时候回收，所以它可能在 minor collection 后仍然存在。


**虚引用 PhantomReference: **The object is the referent of a PhantomReference, and it has already been selected for collection and its finalizer (if any) has run. The term “reachable” is really a misnomer in this case, as there's no way for you to access the actual object. 不可达, 不影响对象的生命周期, 通过虚引用的 get() 方法永远返回 null.


正如您可能猜到的，向对象生命周期图添加三个新的可选状态会造成混乱。尽管文档指出了从强可达到软、弱和虚到回收的逻辑过程，但实际过程取决于程序创建的引用对象。如果创建 WeakReference 但不创建SoftReference，则对象将直接从强可达到弱可达，再从最终确定到收集。
![image.png](https://cdn.nlark.com/yuque/0/2021/png/12487950/1619438588692-902fee26-a911-48f8-8556-09bbe528b41a.png#clientId=u1abc7148-9485-4&from=paste&height=206&id=u6a33dc73&margin=%5Bobject%20Object%5D&name=image.png&originHeight=206&originWidth=656&originalType=binary&size=8628&status=done&style=none&taskId=u0e0ed8d5-e6b2-418d-a350-ed9052bcb93&width=656)
#### References and Referents
A reference object is a layer of indirection between your program code and some other object, called a referent. Each reference object is constructed around its referent, and the referent cannot be changed.
![image.png](https://cdn.nlark.com/yuque/0/2021/png/12487950/1619605033615-5ec8b4a0-689c-4d6f-bdee-effa11da7b26.png#clientId=u406342b3-8a6c-4&from=paste&height=82&id=Qh0bD&margin=%5Bobject%20Object%5D&name=image.png&originHeight=82&originWidth=490&originalType=binary&size=3281&status=done&style=none&taskId=u2755513c-92e7-4ec9-9371-4629adea141&width=490)
#### 引用意义
垃圾回收时的垃圾判定方式: [垃圾回收](https://rongcloud.yuque.com/ofnwgp/xdbvrt/scix1x) 
JVM 在进行垃圾回收的时候，会判定对象是否还存在引用，它会针对不同的引用类型分别对待。
弱引用可以用来访问对象，但进行垃圾回收时，如果对象仅有弱引用指向，则仍然会被 GC 回收。




#### 小例子
```java
// 软引用和弱引用的一个例子

// 强引用
String str = new String("str-value");
SoftReference<String> softRef = new SoftReference<String>(str); // 软引用
str = null; 	// 去掉强引用
System.gc(); 	// 垃圾回收器进行回收
System.out.println(softRef.get());

// 强引用
String abc = new String("abc-value");
WeakReference<String> weakRef = new WeakReference<String>(abc); // 弱引用
abc = null;		// 去掉强引用
System.gc(); 	// 垃圾回收器进行回收
System.out.println(weakRef.get());


输出:
str-value
null
```


```java
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.WeakHashMap;

public class ReferenceDemo {
    public static void main(String[] args) {
        String a = new String("key-a");
        String b = new String("key-b");

        Map map = new HashMap();
        map.put(a, "aaa");
        map.put(b, "bbb");

        Map weakmap = new WeakHashMap();
        weakmap.put(a, "aaaa");
        weakmap.put(b, "bbbb");

        map.remove(a);
        
        a = null; // 移除 a 的强引用, key-a 也没人引用了; map.size();
        b = null; // 移除 b 的强引用, key-b 还被 map 引用着 map.get(b); map.get("key-b");

        System.gc();

        Iterator i = map.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry en = (Map.Entry) i.next();
            System.out.println("map:" + en.getKey() + ":" + en.getValue());
        }

        Iterator j = weakmap.entrySet().iterator();
        while (j.hasNext()) {
            Map.Entry en = (Map.Entry) j.next();
            System.out.println("weakmap:" + en.getKey() + ":" + en.getValue());
        }
    }
}

输出
map:key-b:bbb
weakmap:key-b:bbbb
```


#### 想说的话
```java
// 平时使用的缓存存在的问题
1. 对象都是强引用的
2. 不确定单个对象占用的 byte size 大小
3. 无法准确的估算创建缓存的时候为其指定一个准确的大小
4. JVM 即使报 OOM 也不会清理这些缓存, 失去缓存的意义 => LRU 

// 弱引用缓存 WeakHashMap
1. key 是经过弱引用化处理的, value 不是
2. 即使不被主动调用 remove, clear 方法，元素也是会有机会清除的
3. key-value 的清理时机, key 伴随 gc 清理, value 根据 ReferenceQueue 进行清理
4. ReferenceQueue
5. 为什么会存在 ReferenceQueue ? 
    我们可以通过 reference.get() 的返回值确定 referent 是否被回收了, 
	但是现实是我们有大量的引用对象，这么操作是不实际的，一个好的解决方案就出来了 - 引用队列，
    在构造时将引用与队列相关联，并且在清除引用后将其放在队列上。要发现哪些引用已被清除,
    可以轮询队列。这可以通过后台线程完成，但是在创建新引用时轮询队列通常更简单(WeakHashMap就是这么做的)
	引用队列更像是监听器.
    
// 弱引用的特点更适合高速缓存

// 引用的状态
1. Active: 
	新创建的实例处于活动状态, 由垃圾收集者进行特殊处理,
	收集器检测到引用对象的可访问性已更改为适当的状态后的一段时间，它会将实例的状态更改为挂起或不活动，
    这取决于创建实例时是否向队列注册了实例, 在前一种情况下，它还将实例添加到挂起引用列表中.
2. Pending: 
	挂起引用列表的元素，等待引用处理程序线程排队,未注册的实例从不处于此状态.
3. Enqueued
	在创建实例时向其注册的队列元素. 当实例从其引用队列中移除时,它将变为非活动状态.
    未注册的实例从不处于此状态
4. Inactive
	一旦实例变为非活动状态,其状态将永远不会再改变.
```


#### 弱引用的应用
WeakHashMap (源码分析)
```java
1. 根据 API 文档，当 Map 中的键不再使用，键对应的键值也将自动在 WeakHashMap 中删除。WeakHashMap 中的键为弱键，和其他 Map 接口的实现有些不同；
2. 和 HashMap 类似; 但是支持 key 和 value 为 null, 不存在红黑树结构，因为没必要
3. 同样不是线程安全的，可以使用 Collections.synchronizedMap(Map map) 来使之线程安全
4. 没有实现 Cloneable, Serializable接口, 没有必要

public class WeakHashMap<K,V> extends AbstractMap<K,V> implements Map<K,V> {
	// 基本组成属性
	private static final int DEFAULT_INITIAL_CAPACITY = 16;
    private static final int MAXIMUM_CAPACITY = 1 << 30;
    private static final float DEFAULT_LOAD_FACTOR = 0.75f;
    private static final Object NULL_KEY = new Object();
    Entry<K,V>[] table; // 这个 Entry 继承了 WeakReference
    private int size;
    private int threshold;
    private final float loadFactor;
    
    /**
  	* Reference queue for cleared WeakEntries
    *
    * 队列放的是什么 ?
 	*/
    private final ReferenceQueue<Object> queue = new ReferenceQueue<>();
    
    int modCount;
}

// 1. put 方法分析
public V put(K key, V value) {
    Object k = maskNull(key);
    int h = hash(k);
    Entry<K,V>[] tab = getTable();
    int i = indexFor(h, tab.length);
    
    // 遍历 table[i] 链表, 如果找到相同的 key 则将老的 value 用新的 value 替换
    for (Entry<K,V> e = tab[i]; e != null; e = e.next) {
        if (h == e.hash && eq(k, e.get())) {
            V oldValue = e.value;
            if (value != oldValue)
                e.value = value;
            return oldValue;
        }
    }
    
    modCount++;// 修改次数++
    Entry<K,V> e = tab[i];// 取得链表的第一个元素
    
    // 构建新的链表（将新元素放在链表最前面）,同时将 key 注册到引用队列
    tab[i] = new Entry<>(k, value, queue, h, e); 
    
    if (++size >= threshold)
        resize(tab.length * 2);
    return null;
}

private static Object maskNull(Object key) {
	return (key == null) ? NULL_KEY : key;
}

final int hash(Object k) {
    int h = k.hashCode();
    
    h ^= (h >>> 20) ^ (h >>> 12);
    return h ^ (h >>> 7) ^ (h >>> 4);
}

private Entry<K,V>[] getTable() {
    expungeStaleEntries();
    return table;
}

// 将引用队列里的元素拿出来，修正 table 中的无效数据
private void expungeStaleEntries() {
    for (Object x; (x = queue.poll()) != null; ) {
        synchronized (queue) {
            @SuppressWarnings("unchecked")
            Entry<K,V> e = (Entry<K,V>) x;// queue 放的是元素, 将要被清理的元素
            
            int i = indexFor(e.hash, table.length);// 定位在 table 数组的位置

            Entry<K,V> prev = table[i];// 取得 table [i] 处链表的第一个元素
            Entry<K,V> p = prev;
            while (p != null) {// 链表是否为空或者是否是链表的最后一个元素
                Entry<K,V> next = p.next;
                if (p == e) { // 找到了要被清理的元素
                    if (prev == e)// prev 不一定和 p 相同
                        table[i] = next; // 用下一个元素对 e 元素替换
                    else
                        prev.next = next; // 修复链接
                    // Must not null out e.next;
                    // stale entries may be in use by a HashIterator
                    e.value = null; // Help GC
                    size--;
                    break;
                }
                prev = p; // 没找到要被清理的元素,交换指针,移动位置,继续比对
                p = next;
            }
        }
    }
}

Entry(Object key, V value, ReferenceQueue<Object> queue, int hash, Entry<K,V> next) {
	super(key, queue);
    this.value = value;
    this.hash  = hash;
    this.next  = next;
}

/**
 * Creates a new weak reference that refers to the given object and is
 * registered with the given queue.
 *
 * @param referent object the new weak reference will refer to
 * @param q the queue with which the reference is to be registered,
 *          or <tt>null</tt> if registration is not required
 *
 * 监听器效果, 如果引用的对象被回收(reference.get() == null)，则将其加入该队列
 */
public WeakReference(T referent, ReferenceQueue<? super T> q) {
	super(referent, q);
}

Reference(T referent, ReferenceQueue<? super T> queue) {
	this.referent = referent;
    this.queue = (queue == null) ? ReferenceQueue.NULL : queue;
}
```


```java
// 2. get 方法分析
public V get(Object key) {
    Object k = maskNull(key);
    int h = hash(k);
    Entry<K,V>[] tab = getTable();
    int index = indexFor(h, tab.length);
    Entry<K,V> e = tab[index];
    while (e != null) {
        if (e.hash == h && eq(k, e.get()))
            return e.value;
        e = e.next;
    }
    return null;
}

// 3. remove 方法, 分析过 expungeStaleEntries 方法，该方法就没必要看了
public V remove(Object key) {
    Object k = maskNull(key);
    int h = hash(k);
    Entry<K,V>[] tab = getTable();
    int i = indexFor(h, tab.length);
    Entry<K,V> prev = tab[i];
    Entry<K,V> e = prev;

    while (e != null) {
        Entry<K,V> next = e.next;
        if (h == e.hash && eq(k, e.get())) {
            modCount++;
            size--;
            if (prev == e)
                tab[i] = next;
            else
                prev.next = next;
            return e.value;
        }
        prev = e;
        e = next;
    }

    return null;
}

// 通过分析可以看到 getTable() 经常被调用到，它和 ReferenceQueue 一起完成的对 k-v 的清理工作
```
