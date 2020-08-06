---
title: "Flink 0x01"
date: 2020-07-22T20:20:07+08:00
tags: []
draft: true
categories: []
---

到现在为止我已经写了两个在线上运行的flink应用了，但对flink的概念还是有些模糊。今天下午看到这片文档豁然开朗。看来还是应该多看官方文档，而不是去找那些二手知识。
<!--more-->

> 本文翻译自[Flink Architecture](https://ci.apache.org/projects/flink/flink-docs-release-1.11/concepts/flink-architecture.html).

# Flink系统架构

Flink是一个依赖高效的分配和管理计算资源来执行流式应用的分布式系统。它集成了所有通用的资源管理框架，比如[Hadoop Yarn](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/YARN.html)，[Apache Mesos](https://mesos.apache.org/)和[Kubernetes](https://kubernetes.io/)，当然也可以设置作为单机集群甚至类库来运行。

## Flink集群剖析
Flink运行时由两种类型的进程组成：一个JobManager和一个或者多个TaskManager。

> 译者注：JobManager就是boss，管理TaskManager的。TaskManager就是干活儿的，或者说是包工头，因为它里面还有更细的task slots的概念。

![Flink集群剖析](https://ci.apache.org/projects/flink/flink-docs-release-1.11/fig/processes.svg)

客户端并不是运行时和程序执行的组成部分，但它用于准备和发送数据流到JobManager。之后客户端就可以断开（分离模式），或者保持连接来接收进度报告（连接模式）。客户端既可以是Java/Scala程序的用于触发执行的部分，也可以是命令行进程，如`bin/flink run ...`。

JobManager和TaskManager可以用多种方式启动：直接以[单机集群](https://ci.apache.org/projects/flink/flink-docs-release-1.11/ops/deployment/cluster_setup.html)方式，在容器中，或者通过资源管理框架如[Yarn](https://ci.apache.org/projects/flink/flink-docs-release-1.11/ops/deployment/yarn_setup.html)或者[Mesos](https://ci.apache.org/projects/flink/flink-docs-release-1.11/ops/deployment/mesos.html)。TaskManagers连接到JobManagers，声明自己处于可用状态，然后被分配工作。
