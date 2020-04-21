---
title: "Springboot使用Hikari集成数据源"
date: 2020-03-28T23:03:18+08:00
description: "Spring datasource config with Hikari"
tags: ["springboot", "java", "hikari", "mybatis"]
draft: true
categories: ["in-action"]
---

Springboot提供了多种方式集成数据源，常用的是Hikari（国外）和Druid（国内）。但二者专注的问题其实都相对简单，没有对多数据源、主从分离做直接支持，而需要使用者自行配置。

<!--more-->

## 概念

首先要明确这里提到的所有东西是干嘛用的。  

### JDBC
这里提到的所有东西的基础是JDBC，它定义了和所有类型的数据库通信的方法，但没有提供实现，需要指定驱动类来和指定的数据库通信。  

### 连接池
Java服务是常驻进程的，这点和PHP不同，所以Java通常要使用连接池来减少频繁连接数据库的开销，当然PHP也想减少，但FPM的运行机制不允许它这么做。Hikari就是做这件事情的。连接池可不是创建之后就不管了，还需要对已经建立的连接进行管理，比如请求量较小时最多允许多少个空闲的连接/请求量较大时最大允许多少个连接/由于连接会被server端关闭（通常由于`wait_timeout`的配置）需要重连/新建连接后是否需要验证连接的有效性等等，但不管怎么样，它做的最本质的工作就是可以让我们从中取出一个JDBC的实例来操作数据库。 

### SqlBuilder/Code generator
至于mybatis，现在直接说mybatis是什么好像不太好说了，因为mybatis社区现在做了太多项目了。我理解原本它就是一个sqlbuilder，定义了一套基于XML的配置，根据定义好的Mapper来生成sql语句。后来整个社区好像都在去XML化，所以就有了Java代码版本的Mapper，然后就发现用Java写Mapper有太多模板代码（看起来差不多但又不完全相同的代码，通常认为是可以避免的）了，每次复制一番也不爽，于是又诞生了mybatis-generator，可以根据指定的表结构生成Mapper文件，加上封装良好的各种`*Statement*Provider`，可以很简单的实现灵活的功能。

### 主从分离
通常数据库会有主从分离，当然也就需要在写主库、读从库，我们当然不想每次指定要用哪个库了，因为已经有了连接池，主从数据库都已经建立了连接，简单理解就是所有`select`操作都从从库的连接池取连接，所有的`insert/update/delete`操作都从主库的连接池取连接，AOP大放异彩的时候就到了。  

### 数据库多实例配置
说起来如果从微服务的角度考虑，每个服务应该只配置一个数据库实例（库或者端口），但当业务没有那么复杂，没有太大的动力去做微服务时，就需要在一个项目中配置多个数据库实例，而Springboot是没有直接提供这种方式的。

解决完上面的问题，其实也就解决了SpringBoot项目在使用数据库过程中的几乎所有问题，那么能不能再把它打一个包，通过starter的方式被引入呢？可以尝试一下。

## JDBC基本操作

## Hikari的配置

## mybatis

### mybatis-generator

### mybatis-dynamic-sql

## 主从切换

## 多数据源配置

## 尝试写一个springboot-hikari-datasource-starter

定义配置，可以让用户简单的实现多数据源的配置
