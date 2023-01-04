---
title: Sentinel热点参数限流原理

categories:
- sentinel

tag:
- sentinel

---

## Sentinel热点参数限流原理

### 何为热点

热点即经常访问的数据。很多时候我们希望统计某个热点数据中访问频次最高的 Top K 数据，并对其访问进行限制，比如：

- 商品 ID 为参数，统计一段时间内最常购买的商品 ID 并进行限制
- 用户 ID 为参数，针对一段时间内频繁访问的用户 ID 进行限制


### 如何使用

#### 1.引入依赖

```
<dependency>
    <groupId>com.alibaba.csp</groupId>
    <artifactId>sentinel-core</artifactId>
    <version>${sentinel.version}</version>
</dependency>
<!-- 热点参数限流 -->
<dependency>
    <groupId>com.alibaba.csp</groupId>
    <artifactId>sentinel-parameter-flow-control</artifactId>
    <version>${sentinel.version}</version>
</dependency>
```

#### 2.定义ParamFlowRule

```
private static void loadRules() {
 ParamFlowRule rule = new ParamFlowRule(RESOURCE_KEY)
   .setParamIdx(0) // 指定当前 rule 对应的热点参数索引
   .setGrade(RuleConstant.FLOW_GRADE_QPS) // 限流的维度，该策略针对 QPS 限流
   .setDurationInSec(1) // 限流的单位时间
   .setCount(50) // 未使用指定热点参数时，该资源限流大小为50
   .setParamFlowItemList(new ArrayList<>());

 // item1 设置了对 goods_id = goods_uuid1 的限流，单位时间（DurationInSec）内只能访问10次
 ParamFlowItem item1 = new ParamFlowItem().setObject("goods_uuid1") // 热点参数 value
   .setClassType(String.class.getName()) // 热点参数数据类型
   .setCount(10); // 针对该value的限流值

 ParamFlowRuleManager.loadRules(Collections.singletonList(rule));
}
```

这里的配置属性后文讲源码的时候都会看到，所以要重点关注一下

- Rule 本身可以定义一个限流阈值，每个热点参数也可以定义自己的限流阈值
- 还可以为限流阀值设置一个单位时间

#### 3.调用

```
try {
 // 调用限流
 entry = SphU.entry(RESOURCE_KEY, EntryType.IN, 1, hotParamValue);
 // 业务代码...

} catch (BlockException e) {
 // 当前请求被限流
 e.printStackTrace();
} finally {
 if (entry != null) {
  entry.exit(1, hotParamValue);
 }
}
```

完整实例参考[DEMO](https://github.com/TavenYin/taven-springcloud-learning/blob/master/sentinel-example/src/main/java/com/github/taven/limit/param/SimpleParamFlowDemo.java)

之前有用过 Sentinel 的同学的话其实很好理解。配置方面的话 Rule 属性有些不同，调用方面，需要添加上本次调用相关的参数
举个例子，我们配置了对商品 ID = 1 的限流规则，每次请求商品接口之前调用 Sentinel 的限流 API，指定 Resource 并传入当前要访问的商品
ID。
如果 Sentinel 能找到 Resource 对应的 Rule，则根据 Rule 进行限流。Rule 中如果找到 arg 对应的热点参数配置，则使用热点参数的阈值进行限流。找不到的话，则使用
Rule 中的阈值。

### 实现原理

Sentinel 整体采用了责任链的设计模式（类似 Servlet Filter），每次调用 SphU.entry 时，都会经历一系列功能插槽（slot chain）。
不同的 Slot 职责不同，有的是负责收集信息，有的是负责根据不同的算法策略进行熔断限流操作，
关于整体流程大家可以阅读下 [官网](https://link.zhihu.com/?target=https%3A//sentinelguard.io/zh-cn/docs/basic-implementation.html)
中对 Sentinel 工作流程的介绍。

#### ParamFlowSlot

关于热点参数限流的逻辑在 com.alibaba.csp.sentinel.slots.block.flow.param.ParamFlowSlot 中

```
public class ParamFlowSlot extends AbstractLinkedProcessorSlot<DefaultNode> {

    @Override
    public void entry(Context context, ResourceWrapper resourceWrapper, DefaultNode node, int count,
                      boolean prioritized, Object... args) throws Throwable {
        // ParamFlowManager 中没有对应的 Rule，则执行下一个Slot
        if (!ParamFlowRuleManager.hasRules(resourceWrapper.getName())) {
            fireEntry(context, resourceWrapper, node, count, prioritized, args);
            return;
        }

        // 限流检查
        checkFlow(resourceWrapper, count, args);
        // 执行下一个Slot
        fireEntry(context, resourceWrapper, node, count, prioritized, args);
    }

    @Override
    public void exit(Context context, ResourceWrapper resourceWrapper, int count, Object... args) {
        // 执行下一个Slot
        fireExit(context, resourceWrapper, count, args);
    }

    void applyRealParamIdx(/*@NonNull*/ ParamFlowRule rule, int length) {
        int paramIdx = rule.getParamIdx();
        if (paramIdx < 0) {
            if (-paramIdx <= length) {
                rule.setParamIdx(length + paramIdx);
            } else {
                // Illegal index, give it a illegal positive value, latter rule checking will pass.
                rule.setParamIdx(-paramIdx);
            }
        }
    }

    void checkFlow(ResourceWrapper resourceWrapper, int count, Object... args) throws BlockException {
        if (args == null) {
            return;
        }
        if (!ParamFlowRuleManager.hasRules(resourceWrapper.getName())) {
            return;
        }
        // 获取 resource 对应的全部 ParamFlowRule 
        List<ParamFlowRule> rules = ParamFlowRuleManager.getRulesOfResource(resourceWrapper.getName());

        for (ParamFlowRule rule : rules) {
            applyRealParamIdx(rule, args.length);

            // 初始化该 Rule 需要的限流指标数据
            ParameterMetricStorage.initParamMetricsFor(resourceWrapper, rule);
            // 如果不满足某个 Rule 则抛出异常，代表当前请求被限流
            if (!ParamFlowChecker.passCheck(resourceWrapper, rule, count, args)) {
                String triggeredParam = "";
                if (args.length > rule.getParamIdx()) {
                    Object value = args[rule.getParamIdx()];
                    triggeredParam = String.valueOf(value);
                }
                throw new ParamFlowException(resourceWrapper.getName(), triggeredParam, rule);
            }
        }
    }
}

```

ParamFlowSlot 中代码不多，也没做什么事。参考注释的话应该很好理解。咱们直接挑干的讲，来看下 ParamFlowChecker 中是如何实现限流的

#### ParamFlowChecker数据结构

热点参数限流使用的算法为令牌桶算法，首先来看一下数据结构是如何存储的

```
public class ParameterMetric {

    /**
     * Format: (rule, (value, timeRecorder))
     *
     * @since 1.6.0
     */
    private final Map<ParamFlowRule, CacheMap<Object, AtomicLong>> ruleTimeCounters = new HashMap<>();
    /**
     * Format: (rule, (value, tokenCounter))
     *
     * @since 1.6.0
     */
    private final Map<ParamFlowRule, CacheMap<Object, AtomicLong>> ruleTokenCounter = new HashMap<>();
 
    private final Map<Integer, CacheMap<Object, AtomicInteger>> threadCountMap = new HashMap<>();
 
 // 省略...
 
}

```

Sentinel 中 Resource 代表当前要访问的资源（方法或者api接口），一个 Resource 可以对应多个 Rule，这些 Rule 可以是相同的 class。
现在再来看 ParameterMetric 的结构，每个 Resource 对应一个 ParameterMetric 对象，上述 CacheMap<Object, AtomicLong> 的 Key
代表热点参数的值，Value 则是对应的计数器。
所以这里数据结构的关系是这样的

- 一个 Resource 有一个 ParameterMetric
- 一个 ParameterMetric 统计了多个 Rule 所需要的限流指标数据
- 每个 Rule 又可以配置多个热点参数

CacheMap 的默认实现，包装了 com.googlecode.concurrentlinkedhashmap.ConcurrentLinkedHashMap 
使用该类的主要原因是为了实现热点参数的 LRU

详细解释一下，这三个变量

- ruleTimeCounters ：记录令牌桶的最后添加时间，用于 QPS 限流
- ruleTokenCounter ：记录令牌桶的令牌数量，用于 QPS 限流
- threadCountMap ：用于线程级别限流，这个其实和令牌桶算法没有关系了，线程限流只是在 Rule
  中定义了最大线程数，请求时判断一下当前的线程数是否大于最大线程，具体的应用在 ParamFlowChecker#passSingleValueCheck

实际使用 ParameterMetric 时，使用 ParameterMetricStorage 获取 Resource 对应的 ParameterMetric

```
public final class ParameterMetricStorage {
    // Format (Resource, ParameterMetric)
    private static final Map<String, ParameterMetric> metricsMap = new ConcurrentHashMap<>();
    // 省略相关代码 
}
```

#### ParamFlowChecker执行逻辑

ParamFlowChecker 中 QPS 级限流支持两种策略

- CONTROL_BEHAVIOR_RATE_LIMITER ：请求速率限制，对应的方法ParamFlowChecker#passThrottleLocalCheck
- DEFAULT ：只要桶中还有令牌，就可以通过，对应的方法ParamFlowChecker#passDefaultLocalCheck

接下来我们将以 passDefaultLocalCheck 为例，进行分析。但是在这之前，先来捋一下，从 ParamFlowSlot#checkFlow 到
ParamFlowChecker#passDefaultLocalCheck 这中间都经历了什么，详见

```
// 伪代码，忽略了一些参数传递
checkFlow() {
 // if 没有对应的 rule，跳出 ParamFlowSlot 逻辑

 // if args == null，跳出 ParamFlowSlot 逻辑

 List<ParamFlowRule> rules = ParamFlowRuleManager.getRulesOfResource(resourceWrapper.getName());

 rules.forEach(r -> {
                // 初始化该 Rule 需要的限流指标数据
  ParameterMetricStorage.initParamMetricsFor(resourceWrapper, rule);
  
  if (!ParamFlowChecker.passCheck(resourceWrapper, rule, count, args)) {
   // 抛出限流异常
  }
 })

}

passCheck() {
 // 从 args 中获取本次限流需要使用的 value
 int paramIdx = rule.getParamIdx();
 Object value = args[paramIdx];
 
 // 根据 rule 判断是该请求使用集群限流还是本地限流
 if (rule.isClusterMode() && rule.getGrade() == RuleConstant.FLOW_GRADE_QPS) {
  return passClusterCheck(resourceWrapper, rule, count, value);
 }

 return passLocalCheck(resourceWrapper, rule, count, value);
}

passLocalCheck() {
 // 如果 value 是 Collection 或者 Array
 // Sentinel 认为这一组数据都需要经过热点参数限流校验
        // 遍历所有值调用热点参数限流校验
 if (isCollectionOrArray(value)) {
  value.forEach(v -> {
   // 当数组中某个 value 无法通过限流校验时，return false 外部会抛出限流异常
   if (!passSingleValueCheck(resourceWrapper, rule, count, param)) {
    return false;
   }
  })
 }
}

passSingleValueCheck() {
 if (rule.getGrade() == RuleConstant.FLOW_GRADE_QPS) {
  if (rule.getControlBehavior() == RuleConstant.CONTROL_BEHAVIOR_RATE_LIMITER) {
   // 速率限制
   return passThrottleLocalCheck(resourceWrapper, rule, acquireCount, value);
  } else {
   // 默认限流
   return passDefaultLocalCheck(resourceWrapper, rule, acquireCount, value);
  }
 } else if (rule.getGrade() == RuleConstant.FLOW_GRADE_THREAD) {
  // 线程级限流逻辑
 }
}
```

上面提到了一个集群限流，和上一篇中说到的集群限流实现原理是一样的，选出一台 Server 来做限流决策，所有客户端的限流请求都咨询
Server，由 Server 来决定。由于不是本文重点，就不多说了。

#### ParamFlowChecker限流核心代码

```
static boolean passDefaultLocalCheck(ResourceWrapper resourceWrapper, ParamFlowRule rule, int acquireCount,
          Object value) {
 // 根据 resource 获取 ParameterMetric
 ParameterMetric metric = getParameterMetric(resourceWrapper);
 // 根据 rule 从 metric 中获取当前 rule 的计数器
 CacheMap<Object, AtomicLong> tokenCounters = metric == null ? null : metric.getRuleTokenCounter(rule);
 CacheMap<Object, AtomicLong> timeCounters = metric == null ? null : metric.getRuleTimeCounter(rule);

 if (tokenCounters == null || timeCounters == null) {
  return true;
 }

 // Calculate max token count (threshold)
 Set<Object> exclusionItems = rule.getParsedHotItems().keySet();
 long tokenCount = (long)rule.getCount();
 // 如果热点参数中包含当前 value，则使用热点参数配置的count，否则使用 rule 中定义的 count
 if (exclusionItems.contains(value)) {
  tokenCount = rule.getParsedHotItems().get(value);
 }

 if (tokenCount == 0) {
  return false;
 }

 long maxCount = tokenCount + rule.getBurstCount();
 // 当前申请的流量 和 最大流量比较
 if (acquireCount > maxCount) {
  return false;
 }

 while (true) {
  long currentTime = TimeUtil.currentTimeMillis();
  
  // 这里相当于对当前 value 对应的令牌桶进行初始化
  AtomicLong lastAddTokenTime = timeCounters.putIfAbsent(value, new AtomicLong(currentTime));
  if (lastAddTokenTime == null) {
   // Token never added, just replenish the tokens and consume {@code acquireCount} immediately.
   tokenCounters.putIfAbsent(value, new AtomicLong(maxCount - acquireCount));
   return true;
  }

  // Calculate the time duration since last token was added.
  long passTime = currentTime - lastAddTokenTime.get();
  // A simplified token bucket algorithm that will replenish the tokens only when statistic window has passed.
  if (passTime > rule.getDurationInSec() * 1000) {
   // 补充 token
   AtomicLong oldQps = tokenCounters.putIfAbsent(value, new AtomicLong(maxCount - acquireCount));
   if (oldQps == null) {
    // Might not be accurate here.
    lastAddTokenTime.set(currentTime);
    return true;
   } else {
    long restQps = oldQps.get();
    // 每毫秒应该生成的 token = tokenCount / (rule.getDurationInSec() * 1000)
    // 再 * passTime 即等于应该补充的 token
    long toAddCount = (passTime * tokenCount) / (rule.getDurationInSec() * 1000);
    // 补充的 token 不会超过最大值
    long newQps = toAddCount + restQps > maxCount ? (maxCount - acquireCount)
     : (restQps + toAddCount - acquireCount);

    if (newQps < 0) {
     return false;
    }
    if (oldQps.compareAndSet(restQps, newQps)) {
     lastAddTokenTime.set(currentTime);
     return true;
    }
    Thread.yield();
   }
  } else {
   // 直接操作计数器扣减即可
   AtomicLong oldQps = tokenCounters.get(value);
   if (oldQps != null) {
    long oldQpsValue = oldQps.get();
    if (oldQpsValue - acquireCount >= 0) {
     if (oldQps.compareAndSet(oldQpsValue, oldQpsValue - acquireCount)) {
      return true;
     }
    } else {
     return false;
    }
   }
   Thread.yield();
  }
 }
}
```

令牌桶算法核心思想如下图所示，结合这个图咱们再来理解理解代码
![](https://cdn.nlark.com/yuque/0/2023/webp/804884/1672846031117-714aa636-6f58-4ca4-855e-f93fcb06b4e6.webp#averageHue=%23f6f6f6&clientId=u5e430d1a-bdd7-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=uf4f4f9f2&margin=%5Bobject%20Object%5D&originHeight=456&originWidth=357&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=none&taskId=ua6371456-ed84-487c-8aa6-4b43f7b97fe&title=)
核心逻辑在 while 循环中，咱们直接挑干的讲
先回顾一下上面说过 tokenCounters 和 timeCounters，在默认限流实现中，这两个参数分别代表最后添加令牌时间，令牌剩余数量
while 逻辑：

1. 首先如果当前 value 对应的令牌桶为空，则执行初始化
2. 计算当前时间到上次添加 token 时间经历了多久，即 passTime = currentTime - lastAddTokenTime.get() 用于判断是否需要添加
   token
   2.1) if (pass > rule 中设定的限流单位时间) ，则使用原子操作为令牌桶补充 token（具体补充 token 的逻辑详见上面代码注释）
   2.2) else 不需要补充 token，使用原子操作扣减令牌

可以看到关于 token 的操作全是使用原子操作（CAS），保证了线程安全。如果原子操作更新失败，则会继续执行。

#### 速率限制的实现

再顺便叨咕下上面说过CONTROL_BEHAVIOR_RATE_LIMITER 速率限制策略是如何实现的，只简单说说思路，具体细节大家可以自己看下源码
该策略中，仅使用 timeCounters，该参数存储的数据变成了 lastPassTime（最后通过时间），所以这个实现和令牌桶也没啥关系了
新的请求到来时，首先根据 Rule 中定义时间范围，count 计算 costTime，代表每隔多久才能通过一个请求
long costTime = Math.round(1.0 * 1000 * acquireCount * rule.getDurationInSec() / tokenCount);
只有 lastPassTime + costTime <= currentTime ，请求才有可能成功通过，lastPassTime + costTime 过大会导致限流。

### 参考：

[https://zhuanlan.zhihu.com/p/394124184](https://zhuanlan.zhihu.com/p/394124184)
