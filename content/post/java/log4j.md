---
title: "日志框架详解系列之一——Log4j"
date: 2020-11-21T16:55:33+08:00
tags: ["log4j", "log", "slf4j"]
draft: true
categories: ["java"]
---

第一篇当然要先介绍上古神兽log4j了。
<!--more-->

不光是因为它出现的早，更因为后面几乎所有的日志框架都参考了它的实现。包括一些通用的概念，如Logger/Appender/Layout等。

## 一把梭

如果仅仅引入了`slf4j-log4j12`，当然是不能运行的，换句话说，log4j没有默认配置。
```xml
    <dependencies>
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-log4j12</artifactId>
            <version>1.7.30</version>
        </dependency>
    </dependencies>
```
```java
package fun.happyhacker;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class App {
    private static final Logger LOG = LoggerFactory.getLogger(App.class);

    public static void main(String[] args) {
        LOG.info("hello log from slf4j");
    }
}
```
![](/images/2020-11-21-17-00-20.png)

根据错误提示，可以看到是因为我们没有配置Appender。那么Appender是什么呢？

## Appender

Appender

## Layout

## 定义不同的日志级别

