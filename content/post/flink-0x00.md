---
title: "Flink 0x00"
date: 2020-05-20T21:15:22+08:00
tags: []
draft: true
categories: []
---

作为现在如火如荼的实时计算引擎，Flink也是需要了解一下的。本系列文章介绍Flink相关的知识。

<!--more-->

- Flink的概念
- Flink的部署
- Flink应用开发入门
- Flink与其他系统的集成
    - Springboot
        - 所有Flink应用公用一个全局配置类，用于存放`@EnableAutoConfiguration`或`@SpringbootApplication`注解，如`FlinkJobApplication`
        - 在DataSource或Sink的`open()`方法中初始化`ApplicationContext`，具体是`ApplicationContext context = SpringApplication.run(FlinkJobApplication.class); context.getBeansOfType(ABean.class).get("bean's qualifier");`

