---
title: 常用shell命令
categories:
- linux
---

### 查找指定文件并返回结果

    dbhost=`grep -c "nihao" servicesetting.properties`
    echo $dbres
    if [ $dbres -eq '0' ]; then
        echo "nihao Not Found"
    else
        echo "nihao Found!"
    fi

### 判断变量为空

加上引号判断

    if [ ! -n "$para1" ]; then
      echo "IS NULL"
    else
      echo "NOT NULL"
    fi
    【输出结果】"IS NULL"

直接通过变量判断

    para1=
    if [ ! $para1 ]; then
      echo "IS NULL"
    else
      echo "NOT NULL"
    fi
    【输出结果】"IS NULL"

使用 test 判断

    dmin=
    if test -z "$dmin"
    then
      echo "dmin is not set!"
    else
      echo "dmin is set !"
    fi
    【输出结果】"dmin is not set!"

使用""判断

    dmin=
    if [ "$dmin" = "" ]
    then
      echo "dmin is not set!"
    else
      echo "dmin is set !"
    fi
    【输出结果】"dmin is not set!"
