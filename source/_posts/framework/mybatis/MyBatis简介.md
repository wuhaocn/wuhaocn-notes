---
title: MyBatis简介

categories:

- MyBatis

tag:

- MyBatis

---
## 一、什么是MyBatis

Mybatis是一个优秀的ORM框架.应用在持久层. 它对jdbc的 操作数据库过程 进行封装，使开发者只需要关注 SQL 本身，
而不需要花费精力去处理例如注册驱动、创建connection、等jdbc繁杂的过程代码。

## 二、Mybatis执行流程

1、创建 SqlSessionFactory
2、通过 SqlSessionFactory 创建 SqlSession
3、通过 sqlsession 执行数据库操作
4、调用 session.commit()提交事务
5、调用 session.close()关闭会话

## 三、Mybatis中#和$的区别

#{}是预编译处理，相当于对数据加上 双引号
${}是字符串替换，相当于直接显示数据
#方式能够很大程度防止 sql 注入
$方式无法防止 Sql 注入
$方式一般用于传入数据库对象，例如传入表名
一般能用#的就别用$

## 四、使用 MyBatis 的 mapper 接口调用时有哪些要求？
Mapper 接口方法名和 mapper.xml 中定义的每个 sql 的 id 相同
Mapper 接口方法的输入参数类型和 mapper.xml 中定义的每个 sql 的 parameterType 的类型相同
Mapper 接口方法的输出参数类型和 mapper.xml 中定义的每个 sql 的 resultType 的类型相同
Mapper.xml 文件中的 namespace 即是 mapper 接口的类路径

## 五、JDBC 编程有哪些不足之处，MyBatis 是如何解决这些问题的？

* 数据库链接创建、释放频繁造成系统资源浪费从而影响系统性能，如果使用数据库链接池可解决此问题。
  解决：在 SqlMapConfig.xml 中配置数据链接池，使用连接池管理数据库链接。

* Sql 语句写在代码中造成代码不易维护，实际应用 sql 变化的可能较大，sql 变动需要改变 java 代码。

解决：将 Sql 语句配置在 XXXXmapper.xml 文件中与 java 代码分离。

* 向 sql 语句传参数麻烦，因为 sql 语句的 where 条件不一定，可能多也可能少，占位符需要和参数一一对应。

解决： Mybatis 自动将 java 对象映射至 sql 语句。

* 对结果集解析麻烦，sql 变化导致解析代码变化，且解析前需要遍历，如果能将数据库记录封装成 pojo 对象解析比较方便。

解决：Mybatis 自动将 sql 执行结果映射至 java 对象。

## 六、MyBatis 在 insert 插入操作时返回主键 ID

* 1、数据库为 MySql 时：

```
<insert id="insert" parameterType="com.test.User" keyProperty="userId" useGeneratedKeys="true" >
注：

“keyProperty”表示返回的 id 要保存到对象的那个属性中；
“useGeneratedKeys”表示主键 id 为自增长模式。
MySQL 中做以上配置就 OK 了
```

2、数据库为 Oracle时：

```
 <insert id="insert" parameterType="com.test.User">
 
	 <selectKey resultType="INTEGER" order="BEFORE" keyProperty="userId">
 		SELECT SEQ_USER.NEXTVAL as userId from DUAL
 	</selectKey>
 	
 	insert into user (user_id, user_name, modified, state)
	 values (#{userId,jdbcType=INTEGER}, #{userName,jdbcType=VARCHAR},
	#{modified,jdbcType=TIMESTAMP}, #{state,jdbcType=INTEGER})
 </insert>
```

* 注：

由于 Oracle 没有自增长一说法，只有序列这种模仿自增的形式，所以不能再使用“useGeneratedKeys”属性。而是使用将 ID 获取并赋值到对象的属性中，insert 插入操作时正常插入 id。

## 七、Mybatis 中的一级缓存与二级缓存？
* 一级缓存:
  基于 PerpetualCache 的 HashMap 本地缓存，其存储作用域为 Session，当 Session flush 或close 之后，该 Session 中的所有 Cache 就将清空。
* 二级缓存
  二级缓存与一级缓存其机制相同，默认也是采用 PerpetualCache，HashMap 存储，不同在于其存储作用域为Mapper(Namespace)，并且可自定义存储源，如 Ehcache。作用域为 namespance 是指对该 namespance 对应的配置文件中所有的 select 操作结果都缓存，这样不同线程之间就可以共用二级缓存。启动二级缓存：在 mapper 配置文件中：< cache />
  二级缓存可以设置返回的缓存对象策略：。当 readOnly="true"时，表示二级缓存返回给所有调用者同一个缓存对象实例，调用者可以 update 获取的缓存实例，但是这样可能会造成其他调用者出现数据不一致的情况（因为所有调用者调用的是同一个实例）。
  当 readOnly="false"时，返回给调用者的是二级缓存总缓存对象的拷贝，即不同调用者获取的是缓存对象不同的实例，这样调用者对各自的缓存对象的修改不会影响到其他的调用者，即是安全的，所以默认是 readOnly=“false”;
  对于缓存数据更新机制，当某一个作用域(一级缓存 Session/二级缓存 Namespaces)的进行了 C/U/D 操作后，
  默认该作用域下所有 select 中的缓存将被 clear

## 八、Hibernate 和 Mybatis 有哪些不同？

* 1）Mybatis 和 hibernate 不同，它不完全是一个 ORM 框架，因为 MyBatis 需要程序员自己编写 Sql 语句，不过 mybatis 可以通过 XML 或注解方式灵活配置要运行的 sql 语句，并将java 对象和 sql 语句映射生成最终执行的 sql，最后将 sql 执行的结果再映射生成 java 对象。

* 2）Mybatis 学习门槛低，简单易学，程序员直接编写原生态 sql，可严格控制 sql 执行性能，灵活度高，非常适合对关系数据模型要求不高的软件开发，例如互联网软件、企业运营类软件等，因为这类软件需求变化频繁，一但需求变化要求成果输出迅速。但是灵活的前提是 mybatis 无法做到数据库无关性，如果需要实现支持多种数据库的软件则需要自定义多套 sql 映射文件，工作量大。

* 3）Hibernate 对象/关系映射能力强，数据库无关性好，对于关系模型要求高的软件（例如需求固定的定制化软件）如果用 hibernate 开发可以节省很多代码，提高效率。但是Hibernate 的缺点是学习门槛高，要精通门槛更高，而且怎么设计 O/R 映射，在性能和对象模型之间如何权衡，以及怎样用好 Hibernate 需要具有很强的经验和能力才行。