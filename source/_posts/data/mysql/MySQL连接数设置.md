---
title: MySQL连接数配置

categories:
- MySQL

tag:
- MySQL
---
## 配置
show variables like '%connection%';
配置库
max_connections	15000
max_user_connections	15000
独立库
max_connections	5000
max_user_connections	5000
合并库
max_connections	5000
max_user_connections	5000

show global status like 'connection';
配置库
Max_used_connections	5834
Max_used_connections_time	2022-09-27 15:09:15
独立库
Max_used_connections	2465
Max_used_connections_time	2022-10-20 20:15:29
合并库
Max_used_connections	3129
Max_used_connections_time	2022-10-21 11:29:58


## 修改配置

```
解决方式一：通过命令

可以通过 set GLOBAL max_connections=100; 命令将最大连接数设置为100，此方法是即时生效的，不需要重启mysql服务。

需注意的是，要通过root权限的mysql帐号才能操作，否则会报“1227 - Access denied; you need (at least one of) the SUPER privilege(s) for this operation”的错误。

同时，设置max_connections最小值为1。

解决方式二：修改my.cnf

打开mysql的配置文件vim /etc/my.cnf，加入max_connections=100一行（如果有，直接修改值即可），然后重启服务：/etc/init.d/mysqld restart，此时生效。

区别：

1.通过修改配置文件，需要重启服务；而用命令修改，即时生效。

2.采用修改配置文件的方式，更稳定可靠。因为如果配置文件中有max_connections=100，再去用命令修改的话，一旦重启mysql服务后，会重新以配置文件中指定的连接数为准。

`10.41.1.187
