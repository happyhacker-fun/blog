---
title: "Springboot生态学习及实践"
date: 2020-05-18T21:44:33+08:00
tags: ["Springboot"]
draft: true
categories: ["Springboot"]
---

Spring生态真是庞大到爆炸，各种东西看的眼花缭乱。但如果只停留在应用层面，就会总是为各种新出现的问题费劲，所以还是要深入了解其中的原理，才能在遇到新的问题时知道如何分析解决。

<!--more-->

所以我准备编写关于Springboot的一系列文章，把我在工作中遇到的和想到的一些问题记录下来，辅以源码分析，既为自己保留了记忆，也给后来者一个参考。

系列大概分为四部分：
1. 核心源码分析（理论）
    - 简介
        - spring-boot-loader
        - spring-boot-starter-parent和spring-boot-dependencies
        - 嵌入式Web容器
            - Servlet Web容器
                - Tomcat
                    - 三种运行模式的性能测试
                - Jetty
                - Undertow
            - Reactive Web容器
    - Autowire
        - 约定大于配置
        - 注解编程模型
        - 注解驱动设计模式
        - Springboot自动装配
    - SpringApplication
        - 初始化阶段
        - 运行阶段
        - 结束阶段
2. 搭建一个功能复杂的Spring应用
    - profile
        - 基于profile的配置
        - `@Profile`注解
    - 日志配置
        - 不同的输出形式/文件切割
        - 不同的日志级别
        - 不同profile使用不同的日志格式
    - 数据库（HikariCP/Mybatis）
        - 初学者可能遇到的问题
        - 读写分离
        - 分库分表
        - mybatis-generator
    - Redis
        - 连接池
    - Memcached
        - 基于spymemcached开发一个连接池
    - Kafka/ES/ZooKeeper/Hive等
        - 操作Java生态中的其他组件
3. SpringCloud应用
    - 配置中心
    - 服务发现
    - Hystrix
    - 服务网关
    - 服务认证
    - SpringCloudStream
    - 全链路跟踪
4. Spring运维实践
    - 


