---
title: 修改服务端IP
categories:
- linux
---
### 1.查看并修改

vim /etc/sysconfig/network-scripts/ifcfg-bond0

```
[root@xxx-001 ~]# cat /etc/sysconfig/network-scripts/ifcfg-bond0
DEVICE=bond0
ONBOOT=yes
BOOTPROTO=none
IPADDR=172.21.77.1
NETMASK=255.255.255.192
GATEWAY=172.21.77.62
BONDING_OPTS="mode=1 miimon=100 primary=eth0"
USERCTL=no
```

### 2.重启

    service network restart

### 3.备注

    ---修改ip地址---

    即时生效:# ifconfig eth0 192.168.1.155 netmask 255.255.255.0

    重启生效:修改vi /etc/sysconfig/network-scripts/ifcfg-eth0

    ---修改default gateway---

    即时生效:# route add default gw 192.168.1.1

    重启生效:修改vi /etc/sysconfig/network-scripts/ifcfg-eth0

    ---修改dns---

    修改vi /etc/resolv.conf  #修改后即时生效，重启同样有效

    ---修改host name---

    即时生效:# hostname test1

    重启生效:修改vi /etc/sysconfig/network
