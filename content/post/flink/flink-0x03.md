---
title: "Flink环境初始化"
date: 2020-08-06T15:07:48+08:00
tags: ["flink", "hadoop", "yarn"]
categories: ["bigdata"]
---

通常Flink会运行在yarn上，需要在Flink中配置一下Hadoop的安装路径。
<!--more-->

修改`flink/bin/config.sh`，在第一行非注释的内容前添加以下内容

```sh
export HADOOP_HOME=${HADOOP_HOME:-/usr/hdp/3.1.0.0-78/hadoop}
export HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-/usr/hdp/3.1.0.0-78/hadoop/conf}
export HADOOP_CLASSPATH=`/usr/hdp/current/hadoop-client/bin/hadoop classpath`
export JAVA_HOME=/usr/java/jdk1.8.0_231-amd64
```

这里使用的是cloudera提供的yarn安装工具，后面有时间写一个教程介绍这个过程。

