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

#### maven

```xml
  <dependencies>
    <dependency>
      <groupId>org.apache.kafka</groupId>
      <artifactId>kafka-log4j-appender</artifactId>
      <version>2.6.0</version>
    </dependency>
    <dependency>
      <groupId>net.logstash.log4j</groupId>
      <artifactId>jsonevent-layout</artifactId>
      <version>1.7</version>
    </dependency>
    <dependency>
      <groupId>com.fasterxml.jackson.core</groupId>
      <artifactId>jackson-databind</artifactId>
      <version>2.11.2</version>
    </dependency>
    <dependency>
      <groupId>com.fasterxml.jackson.core</groupId>
      <artifactId>jackson-core</artifactId>
      <version>2.11.2</version>
    </dependency>
  </dependencies>
```
#### log4j配置

```properties
log4j.rootLogger=INFO, console

log4j.logger.org.apache.kafka=WARN
log4j.category.fun.happyhacker=DEBUG, kafka
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
log4j.appender.kafka.layout=net.logstash.log4j.JSONEventLayoutV1
log4j.appender.kafka.layout.UserFields=log_index:project-1
```

#### json数据

我们想写的日志数据理想情况下是这样的
```json
{
    "class": "fun.happyhacker.App",
    "message": "this is a log message",
    "mdc": {
        "request_id": 1394904904094,
        "action": "add"
    }
}
```
包含了关键信息和索引ID(`mdc.request_id`)，但实际上这在实际操作中还是比较难实现的。因为mdc的设置是线程级别的，在一个线程内设置之后在同一个线程内就是相同的，这对于多线程环境处理HTTP请求是合适的，但对于Flink这种流式处理框架就不太合适了，因为通常数据是成批被处理的，就难以区分开每条数据了。@todo 待研究。

#### 重点问题

1. 你当然不会希望Kafka本身的日志再被Kafka收集，所以最好不要在`log4j.rootLogger=DEBUG, console`里加上kafka，而是通过`log4j.category.fun.happyhacker=INFO, kafka`来让你自己的应用的日志通过写入Kafka。这一点很重要。
2. 在我测试过程中发现，如果目标Kafka没有认证，第一条是否这么配无所谓，都可以实现；但如果需要认证，即使是最简单的用户名和密码认证，如果直接配置`log4j.rootLogger=DEBUG, console, kafka`这样，也是无法正常写入的，会一直卡在`- [Producer clientId=producer-1] Starting Kafka producer I/O thread.`或者`org.apache.kafka.common.errors.TimeoutException`异常。这个问题很诡异，花了我很久的时间。

仔细观察这个`kafka-log4j-appender`就会发现，其实这个库非常简单，就是实现了`AppenderSkeleton`而已，里面重写的几个方法也很直观，主要就是那个append方法，直接指定了数据如何写出去。

### logback

### log4j 2