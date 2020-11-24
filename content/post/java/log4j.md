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

Appender就是日志输出的目的地。可以支持控制台、文件、图形化组件、远程socket服务等等，它也可以异步记日志。

这里有个比较难理解的additive的概念，是因为log4j里面的继承关系，如`log4j.logger.fun.happyhacker.a=INFO, console`，而`log4j.logger.fun.happyhacker.a.b=INFO, file`，这时候由于后者继承了前者，`fun.happyhacker.a.b`包中的日志就会同时在`console`和`file`两个appender中出现，多数情况下我们是不希望这种结果的，所以就需要使用`log4j.additivity.*=false`来避免这个重复的结果。

## Layout

layout是依附在appender上的，appender用来控制日志输出到什么地方，而layout来控制输出的日志的格式。

下面详细描述一下layout格式配置中的各个占位符的意义

占位符 | 作用 
---｜---
`c` | 以前叫Category，现在叫Logger，Logger也是从Category继承来的，其实就是打印这条日志所在的类。可以直接写`%c`，也可以带一个数字，用来表示只展示最后几层的类，比如logger是`a.b.c.LogTest`，默认`%c`就会展示`a.b.c.LogTest`，如果是`%c{2}`就展示`c.LogTest`，如果是`%c{1}`就展示`LogTest`。
`C` | 调用者的类名，和`c`的情况差不多，但这是获取调用者的类名，所以会需要用到反射相关的技术，性能会差一些，如果没有必要就不要用这个。
`d` | 日期，默认是ISO8601的日期，就是这样的`2020-11-24 23:20:24,442`。`SimpleDateFormat`的性能很差。
`F` | 调用的文件名，性能会非常差
`L` | 产生日志所在的行数，性能很差
`m` | 日志消息的本体
`M` | 调用日志所在的方法名，性能很差
`n` | 打印平台独有的分隔符，也就是换行符，建议使用，当然是在最后用了
`p` | 日志的优先级，可以写成`%-5p`，表示从左到右占用5个字符，相当于是给`DEBUG`留出了空间
`r` | 从日志对象创建到当前这条日志过的时间，注意不是从应用程序启动开始
`t` | 线程的名字
`x` | 打印NDC
`X` | 打印MDC，必须得用`%X{clientNumber}`这种格式，大括号内是MDC中的key
`%` | `%%`打印百分号

## 定义不同的日志级别

