---
title: "Java项目的日志收集"
date: 2020-11-17T12:01:52+08:00
tags: ["log4j", "slf4j", "logback", "log4j2", "kafka", "logstash"]
draft: true
categories: ["in-action"]
---

日志只有收集之后可以根据需求查询了才有意义。
<!--more-->

## 背景

在 PHP 世界一般是把日志文件落到本地磁盘，然后配合 filebeat 等日志收集器，将内容写入到 Kafka，再由 Logstash 消费写入到 ElasticSearch，流程如下。

![PHP日志收集流程](/images/2020-11-17-12-14-50.png)

使用这个方案的原因无法考证，我的理解是因为 PHP-FPM 的工作流程决定的，每次请求都要重新建立 Kafka 连接，这个流程太耗时了，如果因为记录日志而严重影响了接口性能就得不偿失了。

但 Java 就不一样了，本身就是常驻进程的服务，也就没有频繁建立连接的问题，所以就可以通过日志框架直接写入 Kafka，省掉部署 filebeat 的流程。

![Java日志收集流程](/images/2020-11-17-12-21-33.png)

## 日志收集
|日志框架 |收集方式 |
|---|---|
|log4j | kafka-log4j-appender | 
|logback | logback-kafka-appender |
|log4j2 | 自己写 |
### log4j

```properties
log4j.rootLogger=DEBUG, console

log4j.logger.org.apache.kafka=WARN
log4j.category.org.example=DEBUG, kafka
log4j.additivity=false
log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%d{HH:mm:ss,SSS} %-5p %-60c %x - %m%n

log4j.appender.kafka=org.apache.kafka.log4jappender.KafkaLog4jAppender
log4j.appender.kafka.brokerList=10.73.33.38:6667,10.73.33.44:6667,10.75.12.85:6667
log4j.appender.kafka.topic=flink_logs
log4j.appender.kafka.clientJaasConf=org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="apassword";
log4j.appender.kafka.saslMechanism=PLAIN
log4j.appender.kafka.securityProtocol=SASL_PLAINTEXT
#log4j.appender.kafka.layout=org.apache.log4j.PatternLayout
#log4j.appender.kafka.layout.ConversionPattern=%d{HH:mm:ss,SSS} %-5p %-60c %x - %m%n
log4j.appender.kafka.layout=net.logstash.log4j.JSONEventLayoutV1
log4j.appender.kafka.layout.UserFields=log_index:project-1
```

### logback

### log4j 2

## json appender

### log4j

### logback

### log4j 2