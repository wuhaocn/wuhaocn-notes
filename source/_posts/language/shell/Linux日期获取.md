---
title: Linux日期获取
categories:
- linux
---

## 1.linux获取日期
 linux中通过date命令获取昨天或明天时间的方法.
 date命令可以获取当前的时间，通过man，可以看到date有很多参数可以用，很容易做到格式化
```java
date +"%F"
输出格式：2011-12-31 

date +"%F %H:%M:%S"
输出格式：2011-12-31 16:29:50
```
这都是打印出系统的当前时间，如果要获取相对当前时间的某个时间，需要怎么做，通过 -d 参数就能实现。例如：
​

```java
date -d"tomorrow" +"%F %H:%M:%S"
输出明天这个时候的时间

date -d"yesterday" +"%F %H:%M:%S"
输出昨天这个时候的时间
```
如果说我想获取13天前的时间怎么办，-d参数还有更加灵活的用法，例如：
```java
date -d"-1 day ago" +"%F %H:%M:%S"
输出明天这个时候的时间

date -d"1 day ago" +"%F %H:%M:%S"
输出昨天这个时候的时间

date -d"1 week ago" +"%F %H:%M:%S"
输出7天前这个时候的时间，等价于
date -d"7 day ago" +"%F %H:%M:%S"
```
可以看到ago的强大了吧，第一个数字可以是负数，负数表示将来时间，正数表示前面已经过去的时间，第二个参数minute、hour、day、month、week。
## 2.使用实例

- 定时删除三天前类似"2021_10_18_09"文件

  编写shell脚本"clean_tcpdump.sh"
```java
#!/bin/bash
dumpfile3=`date -d"3 day ago" '+%Y_%m_%d'`*
echo $dumpfile3
dumpfile3del="$dumpfile3*" 
rm -rf $dumpfile3del
dumpfile4=`date -d"4 day ago" '+%Y_%m_%d'`*
echo $dumpfile4
dumpfile4del="$dumpfile4*" 
rm -rf $dumpfile4del
dumpfile5=`date -d"5 day ago" '+%Y_%m_%d'`*
echo $dumpfile5
dumpfile5del="$dumpfile5*" 
rm -rf $dumpfile5del
```
暴力一点部署特别优雅，其实可以用循环


## 3.参考：
[https://blog.csdn.net/qq_16885135/article/details/52063477](https://blog.csdn.net/qq_16885135/article/details/52063477)
