---
title: MySQL协议介绍

categories:
- MySQL

tag:
- MySQL
---

## 问题分析
### 背景
MySQL升级8.0,对接kingshard报错
```
Caused by: com.mysql.cj.exceptions.UnableToConnectException: CLIENT_PLUGIN_AUTH is required
	at java.base/jdk.internal.reflect.NativeConstructorAccessorImpl.newInstance0(Native Method)
	at java.base/jdk.internal.reflect.NativeConstructorAccessorImpl.newInstance(NativeConstructorAccessorImpl.java:62)
	at java.base/jdk.internal.reflect.DelegatingConstructorAccessorImpl.newInstance(DelegatingConstructorAccessorImpl.java:45)
	at java.base/java.lang.reflect.Constructor.newInstance(Constructor.java:490)
```
### 代码分析

* kingshard 下发Server Greeting Plugin Auth 标识位不对  NativeServerSession.CLIENT_PLUGIN_AUTH
* NativeAuthenticationProvider部分代码
```
if (((capabilityFlags & NativeServerSession.CLIENT_SSL) == 0) && sslMode != SslMode.DISABLED && sslMode != SslMode.PREFERRED) {
    throw ExceptionFactory.createException(UnableToConnectException.class, Messages.getString("MysqlIO.15"), getExceptionInterceptor());
} else if ((capabilityFlags & NativeServerSession.CLIENT_SECURE_CONNECTION) == 0) {
    throw ExceptionFactory.createException(UnableToConnectException.class, "CLIENT_SECURE_CONNECTION is required", getExceptionInterceptor());
} else if ((capabilityFlags & NativeServerSession.CLIENT_PLUGIN_AUTH) == 0) {
    //这里报出问题
    throw ExceptionFactory.createException(UnableToConnectException.class, "CLIENT_PLUGIN_AUTH is required", getExceptionInterceptor());
}
```
### 修复
* DEFAULT_CAPABILITY增加mysql.CLIENT_PLUGIN_AUTH标识
```
var DEFAULT_CAPABILITY uint32 = mysql.CLIENT_LONG_PASSWORD | mysql.CLIENT_LONG_FLAG |
	mysql.CLIENT_CONNECT_WITH_DB | mysql.CLIENT_PROTOCOL_41 |
	mysql.CLIENT_TRANSACTIONS | mysql.CLIENT_SECURE_CONNECTION | mysql.CLIENT_PLUGIN_AUTH


```

## 协议概述
* 产生问题主要原因
  * 原有
```
Extended Server Capabilities: 0x0000
    .... .... .... ...0 = Multiple statements: Not set
    .... .... .... ..0. = Multiple results: Not set
    .... .... .... .0.. = PS Multiple results: Not set
    .... .... .... 0... = Plugin Auth: Not set
    .... .... ...0 .... = Connect attrs: Not set
    .... .... ..0. .... = Plugin Auth LENENC Client Data: Not set
    .... .... .0.. .... = Client can handle expired passwords: Not set
    .... .... 0... .... = Session variable tracking: Not set
    .... ...0 .... .... = Deprecate EOF: Not set
    .... ..0. .... .... = Client can handle optional resultset metadata: Not set
    .... .0.. .... .... = ZSTD Compression Algorithm: Not set
    .... 0... .... .... = Query Attributes: Not set
    ...0 .... .... .... = Multifactor Authentication: Not set
    ..0. .... .... .... = Capability Extension: Not set
    .0.. .... .... .... = Client verifies server's TLS/SSL certificate: Not set
    0... .... .... .... = Unused: 0x0
```
  * 修正后 
```
Extended Server Capabilities: 0x0008
    .... .... .... ...0 = Multiple statements: Not set
    .... .... .... ..0. = Multiple results: Not set
    .... .... .... .0.. = PS Multiple results: Not set
    .... .... .... 1... = Plugin Auth: Set
    .... .... ...0 .... = Connect attrs: Not set
    .... .... ..0. .... = Plugin Auth LENENC Client Data: Not set
    .... .... .0.. .... = Client can handle expired passwords: Not set
    .... .... 0... .... = Session variable tracking: Not set
    .... ...0 .... .... = Deprecate EOF: Not set
    .... ..0. .... .... = Client can handle optional resultset metadata: Not set
    .... .0.. .... .... = ZSTD Compression Algorithm: Not set
    .... 0... .... .... = Query Attributes: Not set
    ...0 .... .... .... = Multifactor Authentication: Not set
    ..0. .... .... .... = Capability Extension: Not set
    .0.. .... .... .... = Client verifies server's TLS/SSL certificate: Not set
    0... .... .... .... = Unused: 0x0
```
* 主要流程
  * s->c Server Greeting
  * c->s Login Request
  * s->c Response
  * c->s Request Command Query
  * s->c Response
  * c->s Request Command Ping
  * s->c Response

### Server Greeting
```
MySQL Protocol
    Packet Length: 62
    Packet Number: 0
    Server Greeting
        Protocol: 10
        Version: 5.6.20-kingshard
        Thread ID: 10001
        Salt: x}B2Wg7 
        Server Capabilities: 0xa20d
            .... .... .... ...1 = Long Password: Set
            .... .... .... ..0. = Found Rows: Not set
            .... .... .... .1.. = Long Column Flags: Set
            .... .... .... 1... = Connect With Database: Set
            .... .... ...0 .... = Don't Allow database.table.column: Not set
            .... .... ..0. .... = Can use compression protocol: Not set
            .... .... .0.. .... = ODBC Client: Not set
            .... .... 0... .... = Can Use LOAD DATA LOCAL: Not set
            .... ...0 .... .... = Ignore Spaces before '(': Not set
            .... ..1. .... .... = Speaks 4.1 protocol (new flag): Set
            .... .0.. .... .... = Interactive Client: Not set
            .... 0... .... .... = Switch to SSL after handshake: Not set
            ...0 .... .... .... = Ignore sigpipes: Not set
            ..1. .... .... .... = Knows about transactions: Set
            .0.. .... .... .... = Speaks 4.1 protocol (old flag): Not set
            1... .... .... .... = Can do 4.1 authentication: Set
        Server Language: utf8 COLLATE utf8_general_ci (33)
        Server Status: 0x0002
            .... .... .... ...0 = In transaction: Not set
            .... .... .... ..1. = AUTO_COMMIT: Set
            .... .... .... .0.. = Multi query / Unused: Not set
            .... .... .... 0... = More results: Not set
            .... .... ...0 .... = Bad index used: Not set
            .... .... ..0. .... = No index used: Not set
            .... .... .0.. .... = Cursor exists: Not set
            .... .... 0... .... = Last row sent: Not set
            .... ...0 .... .... = Database dropped: Not set
            .... ..0. .... .... = No backslash escapes: Not set
            .... .0.. .... .... = Metadata changed: Not set
            .... 0... .... .... = Query was slow: Not set
            ...0 .... .... .... = PS Out Params: Not set
            ..0. .... .... .... = In Trans Readonly: Not set
            .0.. .... .... .... = Session state changed: Not set
        Extended Server Capabilities: 0x0008
            .... .... .... ...0 = Multiple statements: Not set
            .... .... .... ..0. = Multiple results: Not set
            .... .... .... .0.. = PS Multiple results: Not set
            .... .... .... 1... = Plugin Auth: Set
            .... .... ...0 .... = Connect attrs: Not set
            .... .... ..0. .... = Plugin Auth LENENC Client Data: Not set
            .... .... .0.. .... = Client can handle expired passwords: Not set
            .... .... 0... .... = Session variable tracking: Not set
            .... ...0 .... .... = Deprecate EOF: Not set
            .... ..0. .... .... = Client can handle optional resultset metadata: Not set
            .... .0.. .... .... = ZSTD Compression Algorithm: Not set
            .... 0... .... .... = Query Attributes: Not set
            ...0 .... .... .... = Multifactor Authentication: Not set
            ..0. .... .... .... = Capability Extension: Not set
            .0.. .... .... .... = Client verifies server's TLS/SSL certificate: Not set
            0... .... .... .... = Unused: 0x0
        Authentication Plugin Length: 21
        Unused: 00000000000000000000
        Salt: Lg:Z:j[n"]Ws

```

### Login Request
```
MySQL Protocol
    Packet Length: 86
    Packet Number: 1
    Login Request
        Client Capabilities: 0xa20d
            .... .... .... ...1 = Long Password: Set
            .... .... .... ..0. = Found Rows: Not set
            .... .... .... .1.. = Long Column Flags: Set
            .... .... .... 1... = Connect With Database: Set
            .... .... ...0 .... = Don't Allow database.table.column: Not set
            .... .... ..0. .... = Can use compression protocol: Not set
            .... .... .0.. .... = ODBC Client: Not set
            .... .... 0... .... = Can Use LOAD DATA LOCAL: Not set
            .... ...0 .... .... = Ignore Spaces before '(': Not set
            .... ..1. .... .... = Speaks 4.1 protocol (new flag): Set
            .... .0.. .... .... = Interactive Client: Not set
            .... 0... .... .... = Switch to SSL after handshake: Not set
            ...0 .... .... .... = Ignore sigpipes: Not set
            ..1. .... .... .... = Knows about transactions: Set
            .0.. .... .... .... = Speaks 4.1 protocol (old flag): Not set
            1... .... .... .... = Can do 4.1 authentication: Set
        Extended Client Capabilities: 0x0008
            .... .... .... ...0 = Multiple statements: Not set
            .... .... .... ..0. = Multiple results: Not set
            .... .... .... .0.. = PS Multiple results: Not set
            .... .... .... 1... = Plugin Auth: Set
            .... .... ...0 .... = Connect attrs: Not set
            .... .... ..0. .... = Plugin Auth LENENC Client Data: Not set
            .... .... .0.. .... = Client can handle expired passwords: Not set
            .... .... 0... .... = Session variable tracking: Not set
            .... ...0 .... .... = Deprecate EOF: Not set
            .... ..0. .... .... = Client can handle optional resultset metadata: Not set
            .... .0.. .... .... = ZSTD Compression Algorithm: Not set
            .... 0... .... .... = Query Attributes: Not set
            ...0 .... .... .... = Multifactor Authentication: Not set
            ..0. .... .... .... = Capability Extension: Not set
            .0.. .... .... .... = Client verifies server's TLS/SSL certificate: Not set
            0... .... .... .... = Unused: 0x0
        MAX Packet: 16777215
        Charset: utf8mb4 COLLATE utf8mb4_general_ci (45)
        Unused: 0000000000000000000000000000000000000000000000
        Username: root
        Password: 2c48c54a318c555031fbfff54df4b98e326cd182
        Schema: appdb
        Client Auth Plugin: mysql_native_password

```

### Response
```
MySQL Protocol - response OK
    Packet Length: 7
    Packet Number: 2
    Response Code: OK Packet (0x00)
    Affected Rows: 0
    Server Status: 0x0002
        .... .... .... ...0 = In transaction: Not set
        .... .... .... ..1. = AUTO_COMMIT: Set
        .... .... .... .0.. = Multi query / Unused: Not set
        .... .... .... 0... = More results: Not set
        .... .... ...0 .... = Bad index used: Not set
        .... .... ..0. .... = No index used: Not set
        .... .... .0.. .... = Cursor exists: Not set
        .... .... 0... .... = Last row sent: Not set
        .... ...0 .... .... = Database dropped: Not set
        .... ..0. .... .... = No backslash escapes: Not set
        .... .0.. .... .... = Metadata changed: Not set
        .... 0... .... .... = Query was slow: Not set
        ...0 .... .... .... = PS Out Params: Not set
        ..0. .... .... .... = In Trans Readonly: Not set
        .0.. .... .... .... = Session state changed: Not set
    Warnings: 0

```

## Request Command Query
```
MySQL Protocol
    Packet Length: 969
    Packet Number: 0
    Request Command Query
        Command: Query (3)
        Statement [truncated]: /* mysql-connector-j-8.0.33 (Revision: 7d6b0800528b6b25c68b52dc10d6c1c8429c100c) */SELECT  @@session.auto_increment_increment AS auto_increment_increment, @@character_set_client AS character_set_client, @@character_s

```

## Response
```
MySQL Protocol - column count
    Packet Length: 1
    Packet Number: 1
    Number of fields: 21

MySQL Protocol - field packet
    Packet Length: 46
    Packet Number: 2
    Catalog
        Catalog: def
    Database
        Database: 
    Table
        Table: 
    Original table
        Original table: 
    Name
        Name: auto_increment_increment
    Original name
        Original name: 
    Charset number: binary COLLATE binary (63)
    Length: 21
    Type: FIELD_TYPE_LONGLONG (8)
    Flags: 0x00a0
        .... .... .... ...0 = Not null: Not set
        .... .... .... ..0. = Primary key: Not set
        .... .... .... .0.. = Unique key: Not set
        .... .... .... 0... = Multiple key: Not set
        .... .... ...0 .... = Blob: Not set
        .... .... ..1. .... = Unsigned: Set
        .... .... .0.. .... = Zero fill: Not set
        .... ...0 .... .... = Enum: Not set
        .... ..0. .... .... = Auto increment: Not set
        .... .0.. .... .... = Timestamp: Not set
        .... 0... .... .... = Set: Not set
    Decimals: 0

```

### Request Command Ping
```
MySQL Protocol
    Packet Length: 1
    Packet Number: 0
    Request Command Ping
        Command: Ping (14)

```

### Response
```
MySQL Protocol - response OK
    Packet Length: 7
    Packet Number: 1
    Response Code: OK Packet (0x00)
    Affected Rows: 0
    Server Status: 0x0002
        .... .... .... ...0 = In transaction: Not set
        .... .... .... ..1. = AUTO_COMMIT: Set
        .... .... .... .0.. = Multi query / Unused: Not set
        .... .... .... 0... = More results: Not set
        .... .... ...0 .... = Bad index used: Not set
        .... .... ..0. .... = No index used: Not set
        .... .... .0.. .... = Cursor exists: Not set
        .... .... 0... .... = Last row sent: Not set
        .... ...0 .... .... = Database dropped: Not set
        .... ..0. .... .... = No backslash escapes: Not set
        .... .0.. .... .... = Metadata changed: Not set
        .... 0... .... .... = Query was slow: Not set
        ...0 .... .... .... = PS Out Params: Not set
        ..0. .... .... .... = In Trans Readonly: Not set
        .0.. .... .... .... = Session state changed: Not set
    Warnings: 0

```
