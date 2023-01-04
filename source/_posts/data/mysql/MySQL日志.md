---
title: MySQL日志分析

categories:
- MySQL

tag:
- MySQL
---


## 慢日志

## binlog
/usr/local/mysql/bin/mysqlbinlog --no-defaults --base64-output=decode-rows --database=testdb -v  mysql-bin.007849 | grep -10 DELETE | grep -3 12345678