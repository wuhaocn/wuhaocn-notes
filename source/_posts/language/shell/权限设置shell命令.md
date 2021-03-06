---
title: 权限设置shell命令
categories:
- linux
---

### 权限篇 chmod chgrp chown

    chmod 777 文件名
    chgrp 用户名 文件名  -R
    chown 用户名 文件名  -R

    -R表示递归目录下所有文件

    一、修改文件所属组群——chgrp
       修改文件所属组群很简单-chgrp命令，就是change group的缩写（我们可以利用这些来记忆命令）
       语法：chgrp  组群  文件名/目录
       举例：
    [root@redhat ~]# groupadd groupa
    [root@redhat ~]# groupadd groupb
    [root@redhat ~]# useradd   -g groupa zgz
    [root@redhat ~]# su - zgz
    [zgz@redhat ~]$ touch filea
    [zgz@redhat ~]$ touch fileb
    [zgz@redhat ~]$ ls -l
    total 8
    -rw-r--r--  1 zgz groupa 0 Sep 26 05:48 filea
    -rw-r--r--  1 zgz groupa 0 Sep 26 05:50 fileb
              --
    [root@redhat zgz]# chgrp  groupb filea      --改变filea所属群组
    [root@redhat zgz]# ls -l
    total 8
    -rw-r--r--  1 zgz groupb 0 Sep 26 05:48 filea
    -rw-r--r--  1 zgz groupa 0 Sep 26 05:50 fileb

    二、修改文件拥有者——chown
       修改组群的命令使chgrp，即change group，那么修改文件拥有者的命令自然就是chown，即change owner。chown功能很多，不仅仅能更改文件拥有者，还可以修改文件所属组群。如果需要将某一目录下的所有文件都改变其拥有者，可以使用-R参数。
       语法如下：
       chown [-R] 账号名称      文件/目录
       chown [-R] 账号名称:组群  文件/目录
       举例：
    [root@redhat zgz]# ls -l
    total 20
    -rw-r--r--  1 zgz groupb    0 Sep 26 05:48 filea
    -rw-r--r--  1 zgz groupa    3 Sep 26 05:59 fileb
    drwxr-xr-x  2 zgz groupa 4096 Sep 26 06:07 zgzdir
    [root@redhat zgz]# chown myy fileb --修改fileb的拥有者为myy
    [root@redhat zgz]# ls -l
    total 20
    -rw-r--r--  1 zgz groupb    0 Sep 26 05:48 filea
    -rw-r--r--  1 myy groupa    3 Sep 26 05:59 fileb
    drwxr-xr-x  2 zgz groupa 4096 Sep 26 06:07 zgzdir
    [root@redhat zgz]# chown myy:groupa filea --修改filea的拥有者为myy，并且同
    [root@redhat zgz]# ls -l时修改组群为groupa
    total 20
    -rw-r--r--  1 myy groupa    0 Sep 26 05:48 filea
    -rw-r--r--  1 myy groupa    3 Sep 26 05:59 fileb
    drwxr-xr-x  2 zgz groupa 4096 Sep 26 06:07 zgzdir
    [root@redhat zgz]# chown -R myy  zgzdir                同时改变其下所有文件拥有者
    total 20
    -rw-r--r--  1 myy groupa    0 Sep 26 05:48 filea
    -rw-r--r--  1 myy groupa    3 Sep 26 05:59 fileb
    drwxr-xr-x  2 myy groupa 4096 Sep 26 06:07 zgzdir
    [root@redhat zgz]# cd zgzdir/
    [root@redhat zgzdir]# ls -l
    total 8
    -rw-r--r--  1 myy groupa 0 Sep 26 06:07 filec
    -rw-r--r--  1 myy groupa 0 Sep 26 06:07 filed

    三、改变文件权限——chmod
       1.用数字来改变文件权限
         我们已经了解了-rw-r--r-- 所表示含义，linux为每一个权限分配一个固定的数字：
         r： 4（读权限）
         w： 2（写权限）
         x： 1（执行权限）
    我们再将这些数字相加，就得到每一组的权限值，例如
    -rw-r--r--  1 myy groupa 0 Sep 26 06:07 filed
    第一组（user）：rw- = 4+2+0 = 6
    第二组（group）：r-- = 4+0+0 = 4
    第三组（others）：r-- = 4+0+0 = 4
    那么644就是fileb权限的数字表示值。
         如果我们想改变某一个文件的权限，首先需要将权限转化为数字组合，例如我们想得到-rwxrw-r--，那么就应该得到数字组合：[4+2+1][4+2+0][4+0+0]=764,然后再用chmod命令去修改
         chmod语法：
         chmod xyz 文件/目录
         举例：
    [root@redhat zgzdir]# ls -l
    total 8
    -rw-r--r--  1 myy groupa 0 Sep 26 06:07 filec
    -rw-r--r--  1 myy groupa 0 Sep 26 06:07 filed
    [root@redhat zgzdir]# chmod 777 filec--将filec的权限改变为777
    [root@redhat zgzdir]# ls -l
    total 8
    -rwxrwxrwx  1 myy groupa 0 Sep 26 06:07 filec
    -rw-r--r--  1 myy groupa 0 Sep 26 06:07 filed
    [root@redhat zgzdir]# chmod 750 filed--将filed的权限改变为750
    [root@redhat zgzdir]# ls -l
    total 8
    -rwxrwxrwx  1 myy groupa 0 Sep 26 06:07 filec
    -rwxr-x---  1 myy groupa 0 Sep 26 06:07 filed

       2、用字符来改变文件权限
          还有一种改变权限的方法，我们已经了解到，文件权限分为三组，分别是user，group，others，那么我们可以用u，g,o分别代表三组，另外，a（all）代表全部，而权限属性即可用r，w，x三个字符来表示，那么请看下面的语法：
    chmod   u/g/o/a   +(加入)/-(除去)/=(设定)  r/w/x  文件或者目录

     举例：
     我们想使filed文件得到：u：可读，可写，可执行
                             g，o：可读，可执行
    [root@redhat zgzdir]# ls -l
    total 8
    -rwxrwxrwx  1 myy groupa 0 Sep 26 06:07 filec
    -rwxr-x---  1 myy groupa 0 Sep 26 06:07 filed
    [root@redhat zgzdir]# chmod u=rwx,go=rx filed--修改filed的文件属性
    [root@redhat zgzdir]# ls -l
    total 8
    -rwxrwxrwx  1 myy groupa 0 Sep 26 06:07 filec
    -rwxr-xr-x  1 myy groupa 0 Sep 26 06:07 filed
    其中g和o也可以用“，”分开来分别设定。
    假设目前我不知道各组权限如何，只是想让所有组都增加“x”权限，那么我们可以用chmod a+x filename来实现，
    举例：
    [root@redhat zgz]# ls -l
    total 24
    -rw-r--r--  1 myy groupa    0 Sep 26 05:48 filea
    -rw-r--r--  1 myy groupa    3 Sep 26 05:59 fileb
    -rw-r--r--  1 zgz groupa    0 Sep 26 06:39 fileg
    drwxr-xr-x  2 myy groupa 4096 Sep 26 06:07 zgzdir
    [root@redhat zgz]# chmod a+x filea--修改filea的文件属性，所有组都增加“x”权限
    [root@redhat zgz]# ls -l
    total 24
    -rwxr-xr-x  1 myy groupa    0 Sep 26 05:48 filea
    -rw-r--r--  1 myy groupa    3 Sep 26 05:59 fileb
    -rw-r--r--  1 zgz groupa    0 Sep 26 06:39 fileg
    drwxr-xr-x  2 myy groupa 4096 Sep 26 06:07 zgzdir
    如果想除去某一权限，可以用“-”来操作，
    举例：
    [root@redhat zgz]# ls -l
    total 24
    -rwxr-xr-x  1 myy groupa    0 Sep 26 05:48 filea
    -rw-r--r--  1 myy groupa    3 Sep 26 05:59 fileb
    -rw-r--r--  1 zgz groupa    0 Sep 26 06:39 fileg
    drwxr-xr-x  2 myy groupa 4096 Sep 26 06:07 zgzdir
    [root@redhat zgz]# chmod a-x filea-修改filea文件属性所有组都除去“x”权限
    [root@redhat zgz]# ls -l
    total 24
    -rw-r--r--  1 myy groupa    0 Sep 26 05:48 filea
    -rw-r--r--  1 myy groupa    3 Sep 26 05:59 fileb
    -rw-r--r--  1 zgz groupa    0 Sep 26 06:39 fileg
    drwxr-xr-x  2 myy groupa 4096 Sep 26 06:07 zgzdir
    [root@redhat zgz]#

    友情提醒：
    chgrp，chown，chmod这些命令默认的情况下只有root有权限执行，大家有时可能会用普通账户去修改文件权限，linux会提示你没有这个权限。因此大家一定要注意当前用户，例如：
    [zgz@redhat ~]$ chgrp groupb filea
    chgrp: changing group of `filea': Operation not permitted
    --zgz没有权限来改变‘filea’的组群
