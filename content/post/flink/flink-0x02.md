---
title: "Flink配置文件详解"
date: 2020-07-27T11:25:19+08:00
tags: ["flink", "hadoop"]
categories: ["bigdata"]
---

本章重点解析一下flink的配置文件`conf/flink-conf.yaml`。

<!--more-->

> 正常情况下一个TM挂掉不会影响整个系统的运行，顶多是原来这个任务有8个TM，每个TM中有2个slots，这样就一共有16个slots，如果挂掉一个TM就只剩下14个slots可用，但整个系统还可以运行。这时JM会尝试另外申请一个包含两个slots的TM来替代已经挂掉的那个TM来工作，但如果系统资源不足，申请不到，则就会一直少一个TM。
> 相反，JM如果挂了整个任务就会挂掉，如果开启HA模式的时候，JM会把任务的快照发送到ZK，这样如果JM挂了，ZK会协助重新启动一个JM，并将ZK内部存储的快照用于恢复任务执行。

## 1. 通用配置

只有单机运行时才有用，正常线上这个配置是没有用的，也不需要配置

```yml
jobmanager.rpc.address: localhost
jobmanager.rpc.port: 6123
```

## 2. JobManager配置

JobManager的堆内存大小，正常默认配置就够了，但如果任务的state比较大，可能就需要调整这个大小了

```yaml
jobmanager.heap.size: 1024m
```

## 3. TaskManager配置

整个TaskManager可用的所有内存大小，其中包括JVM的metaspace和其他开销
```yml
taskmanager.memory.process.size: 1728m
taskmanager.memory.jvm-metaspace.size: 512m
```

一个TaskManager中的TaskSlots的个数。假设一个集群有8台机器，其中7台是NodeManager，每台NodeManager有8个核心，也就是每台NodeManager可以最多提供8个Slots，一共可以提供56个TaskSlots。如果一个任务配置的所有并行度加起来是50，按照默认配置，就需要启动50个TaskManager，本质上每个TaskManager都是一个JVM进程，假设JVM的metaspace设置为256M，那应用启动的时候就需要至少 `256MB*50` 的内存空间，并且TaskManager太多也会增加它们之间通信的开销。相应的，每个TaskManager都是隔离的，一个挂了对另外一个影响也是最小的。但如果把这个值改成8，就只需要启动7个TaskManager，也就是7个JVM进程，任务启动时需要的metaspace就是 `256MB*7` 的内存空间。（注意7个TaskManager会有56个TaskSlots，所以就会有6个空闲的），这样节省了内存空间，但TaskSlots之间的耦合度增加了，如果一个TaskManager挂了，会导致8个TaskSlots都挂了。所以需要在实际应用中对效率和资源隔离作出取舍。
```yml
taskmanager.numberOfTaskSlots: 1
```

## 4. CheckPoint配置

需要保留的CheckPoint的数量，默认保留最新的一个CheckPoint，这样故障恢复时就只恢复最新的。有些情况下发现数据处理出错，可能需要恢复几个小时前的数据，就需要保留多个CheckPoint了。从指定的CheckPoint启动任务可以用：`bin/flink run -s hdfs://namenode01.td.com/flink-1.11.1/flink-checkpoints/582e17d2cc343e6c56255d111bae0191/chk-860/_metadata flink-app-jobs.jar`

后面三个是state保存的路径，默认是被注释掉的，前期使用HDFS(filesystem)即可，后面如果遇到state太大，无法快速完成checkpoint，可以尝试使用RocksDB替换HDFS。
开启了savepoint之后，在cancel任务时会将savepoint写入指定的地址，在启动时指定该地址即可。通常用于版本升级过程。

```yml
state.checkpoints.num-retained: 20
state.backend: filesystem
state.checkpoints.dir: hdfs:///flink-checkpoints
state.savepoints.dir: hdfs:///flink-savepoints
```
## 5. 重启策略

这个参数就很表意了，按固定时间间隔尝试重启，最多尝试10次。可以根据需求调整配置。

```yml
restart-strategy: fixed-delay
restart-strategy.fixed-delay.attempts: 10
restart-strategy.fixed-delay.delay: 10s
```

## 6. 超时配置

之前是没有想写这个配置的，但在实际运行过程中确实发现了这个问题。其实在前面也说过了，就是因为每个task一个slot，然后开了100个taskmanager，这样就有100个taskmanager线程都需要和jobmanager交互，每个都不超时的概率就很低了。所以改了`numberOfTaskSlots`来减少taskmanager线程的同时也调整了以下这个超时时间。

```yml
akka.ask.timeout: 100 s
web.timeout: 100000
```

## 7. 高可用配置

敬请期待