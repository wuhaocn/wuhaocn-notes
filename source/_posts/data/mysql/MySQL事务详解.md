---
title: MySQL事务详解

categories:
- MySQL

tag:
- MySQL
---


## 1.MySQL事务特性

数据库的事务（Transaction）是一种机制、一个操作序列，包含了一组数据库操作命令。事务把所有的命令作为一个整体一起向系统提交或撤销操作请求，即这一组数据库命令要么都执行，要么都不执行，因此事务是一个不可分割的工作逻辑单元。
在数据库系统上执行并发操作时，事务是作为最小的控制单元来使用的，特别适用于多用户同时操作的数据库系统。例如，航空公司的订票系统、银行、保险公司以及证券交易系统等。
事务具有 4 个特性，即原子性（Atomicity）、一致性（Consistency）、隔离性（Isolation）和持久性（Durability），这 4 个特性通常简称为 ACID。

### 1.1. 原子性

事务是一个完整的操作。事务的各元素是不可分的（原子的）。事务中的所有元素必须作为一个整体提交或回滚。如果事务中的任何元素失败，则整个事务将失败。
以银行转账事务为例，如果该事务提交了，则这两个账户的数据将会更新。如果由于某种原因，事务在成功更新这两个账户之前终止了，则不会更新这两个账户的余额，并且会撤销对任何账户余额的修改，事务不能部分提交。

### 1.2. 一致性

当事务完成时，数据必须处于一致状态。也就是说，在事务开始之前，数据库中存储的数据处于一致状态。在正在进行的事务中. 数据可能处于不一致的状态，如数据可能有部分被修改。然而，当事务成功完成时，数据必须再次回到已知的一致状态。通过事务对数据所做的修改不能损坏数据，或者说事务不能使数据存储处于不稳定的状态。
以银行转账事务事务为例。在事务开始之前，所有账户余额的总额处于一致状态。在事务进行的过程中，一个账户余额减少了，而另一个账户余额尚未修改。因此，所有账户余额的总额处于不一致状态。事务完成以后，账户余额的总额再次恢复到一致状态。

### 1.3. 隔离性

对数据进行修改的所有并发事务是彼此隔离的，这表明事务必须是独立的，它不应以任何方式依赖于或影响其他事务。修改数据的事务可以在另一个使用相同数据的事务开始之前访问这些数据，或者在另一个使用相同数据的事务结束之后访问这些数据。
另外，当事务修改数据时，如果任何其他进程正在同时使用相同的数据，则直到该事务成功提交之后，对数据的修改才能生效。张三和李四之间的转账与王五和赵二之间的转账，永远是相互独立的。

### 1.4. 持久性

事务的持久性指不管系统是否发生了故障，事务处理的结果都是永久的。
一个事务成功完成之后，它对数据库所作的改变是永久性的，即使系统出现故障也是如此。也就是说，一旦事务被提交，事务对数据所做的任何变动都会被永久地保留在数据库中。
事务的 ACID 原则保证了一个事务或者成功提交，或者失败回滚，二者必居其一。因此，它对事务的修改具有可恢复性。即当事务失败时，它对数据的修改都会恢复到该事务执行前的状态。

## 2.重要介绍

### 2.1 事务隔离级别

## 3.事物隔离级别

上文介绍了 MySQL 事务的四大特性，其中事务的隔离性就是指当多个事务同时运行时，各事务之间相互隔离，不可互相干扰。如果事务没有隔离性，就容易出现脏读、不可重复读和幻读等情况。为了保证并发时操作数据的正确性，数据库都会有事务隔离级别的概念。

-  脏读

脏读是指一个事务正在访问数据，并且对数据进行了修改，但是这种修改还没有提交到数据库中，这时，另外一个事务也访问这个数据，然后使用了这个数据。

- 不可重复读

不可重复读是指在一个事务内，多次读取同一个数据。在这个事务还没有结束时，另外一个事务也访问了该同一数据。那么，在第一个事务中的两次读数据之间，由于第二个事务的修改，那么第一个事务两次读到的的数据可能是不一样的。这样在一个事务内两次读到的数据是不一样的，因此称为是不可重复读。

- 幻读

幻读是指当事务不是独立执行时发生的一种现象，例如第一个事务对一个表中的数据进行了修改，这种修改涉及到表中的全部数据行。同时，第二个事务也修改这个表中的数据，这种修改是向表中插入一行新数据。那么，以后就会发生操作第一个事务的用户发现表中还有没有修改的数据行，就好象发生了幻觉一样。为了解决以上这些问题，标准 SQL 定义了 4 类事务隔离级别，用来指定事务中的哪些数据改变是可见的，哪些数据改变是不可见的。
MySQL 包括的事务隔离级别如下：

- 读未提交（READ UNCOMITTED）
- 读提交（READ COMMITTED）
- 可重复读（REPEATABLE READ）
- 串行化（SERIALIZABLE）

MySQL 事务隔离级别可能产生的问题如下表所示：

| 隔离级别 | 脏读 | 不可重复读 | 幻读 |
| --- | --- | --- | --- |
| READ UNCOMITTED | √ | √ | √ |
| READ COMMITTED | × | √ | √ |
| REPEATABLE READ | × | × | √ |
| SERIALIZABLE | × | × | × |

MySQL 的事务的隔离级别由低到高分别为 READ UNCOMITTED、READ COMMITTED、REPEATABLE READ、SERIALIZABLE。低级别的隔离级别可以支持更高的并发处理，同时占用的系统资源更少。

下面根据实例来一一阐述它们的概念和联系。


### 3.1. 读未提交（READ UNCOMITTED，RU）
顾名思义，读未提交就是可以读到未提交的内容。
如果一个事务读取到了另一个未提交事务修改过的数据，那么这种隔离级别就称之为读未提交。
在该隔离级别下，所有事务都可以看到其它未提交事务的执行结果。因为它的性能与其他隔离级别相比没有高多少，所以一般情况下，该隔离级别在实际应用中很少使用。

- 例 1 主要演示了在读未提交隔离级别中产生的脏读现象。
#### 示例 1

- 1) 先在 test 数据库中创建 testnum 数据表，并插入数据。SQL 语句和执行结果如下：
```
mysql> CREATE TABLE testnum( num INT(4)); 
Query OK, 0 rows affected (0.57 sec) 
mysql> INSERT INTO test.testnum (num) VALUES(1),(2),(3),(4),(5); 
Query OK, 5 rows affected (0.09 sec)
```

- 2) 下面的语句需要在两个命令行窗口中执行。为了方便理解，我们分别称之为 A 窗口和 B 窗口。
在 A 窗口中修改事务隔离级别，因为 A 窗口和 B 窗口的事务隔离级别需要保持一致，

所以我们使用 SET GLOBAL TRANSACTION 修改全局变量。SQL 语句如下：
```
mysql> SET GLOBAL TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
Query OK, 0 rows affected (0.04 sec) flush privileges; 
Query OK, 0 rows affected (0.04 sec)
```

 查询事务隔离级别，SQL 语句和运行结果如下：
```
mysql> show variables like '%tx_isolation%'\G *************************** 1. row *************************** Variable_name: tx_isolation         Value: READ-UNCOMMITTED 1 row in set, 1 warning (0.00 sec)
```

结果显示，现在 MySQL 的事务隔离级别为 READ-UNCOMMITTED。
 
3) 在 A 窗口中开启一个事务，并查询 testnum 数据表，SQL 语句和运行结果如下：
```
mysql> BEGIN; Query OK, 0 rows affected (0.00 sec) 
mysql> SELECT * FROM testnum; +------+ | num  | +------+ |    1 | |    2 | |    3 | |    4 | |    5 | +------+ 5 rows in set (0.00 sec)
```

4) 打开 B 窗口，查看当前 MySQL 的事务隔离级别，SQL 语句如下：
```
mysql> show variables like '%tx_isolation%'\G *************************** 1. row *************************** Variable_name: tx_isolation         Value: READ-UNCOMMITTED 1 row in set, 1 warning (0.00 sec)
```

确定事务隔离级别是 READ-UNCOMMITTED 后，开启一个事务，并使用 UPDATE 语句更新 testnum 数据表，SQL 语句和运行结果如下：
```
mysql> BEGIN; Query OK, 0 rows affected (0.00 sec) mysql> UPDATE test.testnum SET num=num*2 WHERE num=2; Query OK, 1 row affected (0.02 sec) Rows matched: 1  Changed: 1  Warnings: 0
```

5) 现在返回 A 窗口，再次查询 testnum 数据表，SQL 语句和运行结果如下：
```
mysql> SELECT * FROM testnum; +------+ | num  | +------+ |    1 | |    4 | |    3 | |    4 | |    5 | +------+ 5 rows in set (0.02 sec)
```
由结果可以看出，A 窗口中的事务读取到了更新后的数据。

 
6) 下面在 B 窗口中回滚事务，SQL 语句和运行结果如下：
```
mysql> ROLLBACK; Query OK, 0 rows affected (0.09 sec)
```
7) 在 A 窗口中查询 testnum 数据表，SQL 语句和运行结果如下：
```
mysql> SELECT * FROM testnum; +------+ | num  | +------+ |    1 | |    2 | |    3 | |    4 | |    5 | +------+ 5 rows in set (0.00 sec)
```
当 MySQL 的事务隔离级别为 READ UNCOMITTED 时，首先分别在 A 窗口和 B 窗口中开启事务，在 B 窗口中的事务更新但未提交之前， A 窗口中的事务就已经读取到了更新后的数据。但由于 B 窗口中的事务回滚了，所以 A 事务出现了脏读现象。

使用读提交隔离级别可以解决实例中产生的脏读问题。

### 3.2. 读提交（READ COMMITTED，RC）
顾名思义，读提交就是只能读到已经提交了的内容。

如果一个事务只能读取到另一个已提交事务修改过的数据，并且其它事务每对该数据进行一次修改并提交后，该事务都能查询得到最新值，那么这种隔离级别就称之为读提交。

该隔离级别满足了隔离的简单定义：一个事务从开始到提交前所做的任何改变都是不可见的，事务只能读取到已经提交的事务所做的改变。

这是大多数数据库系统的默认事务隔离级别（例如 Oracle、SQL Server），但不是 MySQL 默认的。

例 2 演示了在读提交隔离级别中产生的不可重复读问题。
#### 示例 2
1) 使用 SET 语句将 MySQL 事务隔离级别修改为 READ COMMITTED，并查看。SQL 语句和运行结果如下：
```
mysql> SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED; Query OK, 0 rows affected (0.00 sec) mysql> show variables like '%tx_isolation%'\G *************************** 1. row *************************** Variable_name: tx_isolation         Value: READ-COMMITTED 1 row in set, 1 warning (0.00 sec)
```
2) 确定当前事务隔离级别为 READ COMMITTED 后，开启一个事务，SQL 语句和运行结果如下：

```
mysql> BEGIN; Query OK, 0 rows affected (0.00 sec)
``` 

3) 在 B 窗口中开启事务，并使用 UPDATE 语句更新 testnum 数据表，SQL 语句和运行结果如下：

``` 
mysql> BEGIN; Query OK, 0 rows affected (0.00 sec) mysql>  UPDATE test.testnum SET num=num*2 WHERE num=2; Query OK, 1 row affected (0.07 sec) Rows matched: 1  Changed: 1  Warnings: 0
``` 

4) 在 A 窗口中查询 testnum 数据表，SQL 语句和运行结果如下：

``` 
mysql> SELECT * from test.testnum; +------+ | num  | +------+ |    1 | |    2 | |    3 | |    4 | |    5 | +------+ 5 rows in set (0.00 sec)
``` 

5) 提交 B 窗口中的事务，SQL 语句和运行结果如下：

``` 
mysql> COMMIT; Query OK, 0 rows affected (0.07 sec)
``` 

6) 在 A 窗口中查询 testnum 数据表，SQL 语句和运行结果如下：
``` 
mysql> SELECT * from test.testnum; +------+ | num  | +------+ |    1 | |    4 | |    3 | |    4 | |    5 | +------+ 5 rows in set (0.00 sec)
``` 
当 MySQL 的事务隔离级别为 READ COMMITTED 时，首先分别在 A 窗口和 B 窗口中开启事务，在 B 窗口中的事务更新并提交后，A 窗口中的事务读取到了更新后的数据。在该过程中，A 窗口中的事务必须要等待 B 窗口中的事务提交后才能读取到更新后的数据，这样就解决了脏读问题。而处于 A 窗口中的事务出现了不同的查询结果，即不可重复读现象。

使用可重复读隔离级别可以解决实例中产生的不可重复读问题。

### 3.3. 可重复读（REPEATABLE READ，RR）
顾名思义，可重复读是专门针对不可重复读这种情况而制定的隔离级别，可以有效的避免不可重复读。

在一些场景中，一个事务只能读取到另一个已提交事务修改过的数据，但是第一次读过某条记录后，即使其它事务修改了该记录的值并且提交，之后该事务再读该条记录时，读到的仍是第一次读到的值，而不是每次都读到不同的数据。那么这种隔离级别就称之为可重复读。

可重复读是 MySQL 的默认事务隔离级别，它能确保同一事务的多个实例在并发读取数据时，会看到同样的数据行。在该隔离级别下，如果有事务正在读取数据，就不允许有其它事务进行修改操作，这样就解决了可重复读问题。

例 3 演示了在可重复读隔离级别中产生的幻读问题。
#### 示例 3
1) 在 test 数据库中创建 testuser 数据表，SQL 语句和执行结果如下：
``` 
mysql> CREATE TABLE testuser(     -> id INT (4) PRIMARY KEY,     -> name VARCHAR(20)); Query OK, 0 rows affected (0.29 sec)
``` 
2) 使用 SET 语句修改事务隔离级别，SQL 语句如下：
``` 
mysql> SET GLOBAL TRANSACTION ISOLATION LEVEL REPEATABLE READ; Query OK, 0 rows affected (0.00 sec)
``` 
3) 在 A 窗口中开启事务，并查询 testuser 数据表，SQL 语句和运行结果如下：
``` 
mysql> BEGIN; Query OK, 0 rows affected (0.00 sec) mysql> SELECT * FROM test.testuser where id=1; Empty set (0.04 sec)
``` 
4) 在 B 窗口中开启一个事务，并向 testuser 表中插入一条数据，SQL 语句和运行结果如下：
``` 
mysql> BEGIN; Query OK, 0 rows affected (0.00 sec) mysql>  INSERT INTO test.testuser VALUES(1,'zhangsan'); Query OK, 1 row affected (0.04 sec) mysql> COMMIT; Query OK, 0 rows affected (0.06 sec)
``` 
5) 现在返回 A 窗口，向 testnum 数据表中插入数据，SQL 语句和运行结果如下：
``` 
mysql> INSERT INTO test.testuser VALUES(1,'lisi'); ERROR 1062 (23000): Duplicate entry '1' for key 'PRIMARY' mysql>  SELECT * FROM test.testuser where id=1; Empty set (0.00 sec)
``` 

使用串行化隔离级别可以解决实例中产生的幻读问题。
## 3.4. 串行化（SERIALIZABLE）
如果一个事务先根据某些条件查询出一些记录，之后另一个事务又向表中插入了符合这些条件的记录，原先的事务再次按照该条件查询时，能把另一个事务插入的记录也读出来。那么这种隔离级别就称之为串行化。

SERIALIZABLE 是最高的事务隔离级别，主要通过强制事务排序来解决幻读问题。简单来说，就是在每个读取的数据行上加上共享锁实现，这样就避免了脏读、不可重复读和幻读等问题。但是该事务隔离级别执行效率低下，且性能开销也最大，所以一般情况下不推荐使用。

[https://zhuanlan.zhihu.com/p/506585990](https://zhuanlan.zhihu.com/p/506585990)

[https://blog.51cto.com/u_15714244/5461724](https://blog.51cto.com/u_15714244/5461724)
