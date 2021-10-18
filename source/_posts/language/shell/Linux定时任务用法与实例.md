---
title: Linux定时任务用法与实例
categories:
- linux
---

## 1.简介
**    在**[Linux系统](https://www.linuxprobe.com/)**的实际使用中，可能会经常碰到让系统在某个特定时间执行某些任务的情况，比如定时采集服务器的状态信息、负载状况；定时执行某些任务/**[脚本](https://www.linuxcool.com/)**来对远端进行数据采集等。这里将介绍下crontab的配置参数以及一些使用实例。**
**​**

![](https://cdn.nlark.com/yuque/0/2021/jpeg/804884/1630977884673-4e4b1724-9235-4016-ae29-267640a57ad5.jpeg#clientId=ubca59353-6701-4&from=paste&id=u78135138&margin=%5Bobject%20Object%5D&originHeight=251&originWidth=620&originalType=url&ratio=1&status=done&style=none&taskId=u78389e0f-56f1-4453-8018-3ad3f3a80e4)
**crontab配置文件**
[Linux](https://www.linuxprobe.com/)下的任务调度分为两类：系统任务调度和用户任务调度。Linux系统任务是由 cron (crond) 这个系统服务来控制的，这个系统服务是默认启动的。用户自己设置的计划任务则使用crontab [命令](https://www.linuxcool.com/)。
## 2.常见配置
### 2.1 配置详情
```
cat /etc/crontab
```
```
# /etc/crontab: system-wide crontab
# Unlike any other crontab you don't have to run the `crontab'
# command to install the new version when you edit this file
# and files in /etc/cron.d. These files also have username fields,
# that none of the other crontabs do.

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# m h dom mon dow user	command
17 *	* * *	root    cd / && run-parts --report /etc/cron.hourly
25 6	* * *	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
47 6	* * 7	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6	1 * *	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
```
### 2.2 crontab格式
![](https://cdn.nlark.com/yuque/0/2021/png/804884/1630977884651-539dcfb6-109b-400d-8296-b7dfccf87cd6.png#clientId=ubca59353-6701-4&from=paste&id=ufd7c16a7&margin=%5Bobject%20Object%5D&originHeight=446&originWidth=538&originalType=url&ratio=1&status=done&style=none&taskId=u86808066-51b9-4864-8e2b-697bfac61c0)
  在以上各个字段中，还可以使用以下特殊字符：
```
"*"代表所有的取值范围内的数字，如月份字段为*，则表示1到12个月；
"/"代表每一定时间间隔的意思，如分钟字段为*/10，表示每10分钟执行1次。
"-"代表从某个区间范围，是闭区间。如“2-5”表示“2,3,4,5”，小时字段中0-23/2表示在0~23点范围内每2个小时执行一次。
","分散的数字（不一定连续），如1,2,3,4,7,9。
注：由于各个地方每周第一天不一样，因此Sunday=0（第一天）或Sunday=7（最后1天）。
```
**crontab命令详解**
### 2.3 配置文件
​


- 其一：/var/spool/cron/
该目录下存放的是每个用户（包括root）的crontab任务，文件名以用户名命名
- 其二：/etc/cron.d/
这个目录用来存放任何要执行的crontab文件或脚本。
## 3.服务状态
​


- 启动服务

sudo service cron start      

- 关闭服务

sudo service cron stop      

- 重启服务

 sudo service cron restart  

- 重新载入配置

 sudo service cron reload 

- 查看服务状态

sudo service cron status  


## 4.常见命令

- 重新指定crontab定时任务列表文件

crontab $filepath 

- 查看crontab定时任务

crontab -l 

- 编辑定时任务【删除-添加-修改】

crontab -e 

- **_添加定时任务【推荐】_**
Step-One : 编辑任务脚本【分目录存放】【ex: backup.sh】
Step-Two : 编辑定时文件【命名规则:backup.cron】
Step-Three : crontab命令添加到系统crontab backup.cron
Step-Four : 查看crontab列表 crontab -l

---

## 5.crontab时间举例
### 规则
```
每一分钟执行一次command（因cron默认每1分钟扫描一次，因此全为*即可）
*    *    *    *    *  command
每小时的第3和第15分钟执行command
3,15   *    *    *    *  command
每天上午8-11点的第3和15分钟执行command：
3,15  8-11  *  *  *  command
每隔2天的上午8-11点的第3和15分钟执行command：
3,15  8-11  */2  *   *  command
每个星期一的上午8点到11点的第3和第15分钟执行command
3,15  8-11   *   *  1 command
每晚的21:30重启smb
30  21   *   *  *  /etc/init.d/smb restart
每月1、10、22日的4 : 45重启smb
45  4  1,10,22  *  *  /etc/init.d/smb restart
每周六、周日的1 : 10重启smb
10  1  *  *  6,0  /etc/init.d/smb restart
每天18 : 00至23 : 00之间每隔30分钟重启smb
0,30  18-23  *  *  *  /etc/init.d/smb restart
每一小时重启smb
*  */1  *  *  *  /etc/init.d/smb restart
晚上11点到早上7点之间，每隔一小时重启smb
*  23-7/1  *   *   *  /etc/init.d/smb restart
每月的4号与每周一到周三的11点重启smb
0  11  4  *  mon-wed  /etc/init.d/smb restart
每小时执行/etc/cron.hourly目录内的脚本
0  1   *   *   *     root run-parts /etc/cron.hourly
```
**crontab配置实例**
### 举例
```
# 每天早上6点 
0 6 * * * echo "Good morning." >> /tmp/test.txt //注意单纯echo，从屏幕上看不到任何输出，因为cron把任何输出都email到root的信箱了。

# 每两个小时 
0 */2 * * * echo "Have a break now." >> /tmp/test.txt  

# 晚上11点到早上8点之间每两个小时和早上八点 
0 23-7/2，8 * * * echo "Have a good dream" >> /tmp/test.txt

# 每个月的4号和每个礼拜的礼拜一到礼拜三的早上11点 
0 11 4 * 1-3 command line

# 1月1日早上4点 
0 4 1 1 * command line SHELL=/bin/bash PATH=/sbin:/bin:/usr/sbin:/usr/bin MAILTO=root //如果出现错误，或者有数据输出，数据作为邮件发给这个帐号 HOME=/ 

# 每小时（第一分钟）执行/etc/cron.hourly内的脚本
01 * * * * root run-parts /etc/cron.hourly

# 每天（凌晨4：02）执行/etc/cron.daily内的脚本
02 4 * * * root run-parts /etc/cron.daily 

# 每星期（周日凌晨4：22）执行/etc/cron.weekly内的脚本
22 4 * * 0 root run-parts /etc/cron.weekly 

# 每月（1号凌晨4：42）去执行/etc/cron.monthly内的脚本 
42 4 1 * * root run-parts /etc/cron.monthly 

# 注意:  "run-parts"这个参数了，如果去掉这个参数的话，后面就可以写要运行的某个脚本名，而不是文件夹名。 　 

# 每天的下午4点、5点、6点的5 min、15 min、25 min、35 min、45 min、55 min时执行命令。 
5，15，25，35，45，55 16，17，18 * * * command

# 每周一，三，五的下午3：00系统进入维护状态，重新启动系统。
00 15 * *1，3，5 shutdown -r +5

# 每小时的10分，40分执行用户目录下的innd/bbslin这个指令： 
10，40 * * * * innd/bbslink 

# 每小时的1分执行用户目录下的bin/account这个指令： 
1 * * * * bin/account

# 每天早晨三点二十分执行用户目录下如下所示的两个指令（每个指令以;分隔）： 
203 * * * （/bin/rm -f expire.ls logins.bad;bin/expire$#@62;expire.1st）　
```










