---
title: Shell关闭防火墙
categories:
- linux
---
### Redhat6.x 关闭防火墙的方法

    关闭防火墙的方法为：

    1. 永久性生效

    开启：chkconfig iptables on

    关闭：chkconfig iptables off

    2. 即时生效，重启后失效

    开启：service iptables start

    关闭：service iptables stop

    需要说明的是对于 Linux 下的其它服务都可以用以上命令执行开启和关闭操作

    补充：

    a. 防火墙还需要关闭ipv6的防火墙：

    chkconfig ip6tables off

    并且可以通过如下命令查看状态：

    chkconfig --list iptables

    b. selinux状态可以通过以下命令查看：

    sestatus
