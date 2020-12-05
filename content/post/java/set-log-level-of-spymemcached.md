---
title: "配置Spymemcached的日志级别"
date: 2020-11-21T14:14:29+08:00
tags: ["log4j", "spymemcached"]
categories: ["in-action"]
---

用这个`net.spy.memcached`最恶心的事情就是它的日志了，不管三七二十一先打印一组红色的INFO级别日志。
<!--more-->

![红色的INFO级别日志](/images/2020-11-21-14-17-17.png)

之前也没有研究这个原因，最近在总结日志相关的坑，就把这里详细看了一下。

## 观察现象

首先是这个日志是红色的，INFO级别，而且在log4j.properties中添加
```properties
log4j.logger.net.spy.memcached=ERROR, console
log4j.logger.addivitity.*=false
```
是不起作用的。

## 分析原因

由于之前对log4j的配置文件也不太熟悉，所以一直想着是自己的配置文件没有写对导致的，而忽略了其他原因。昨天弄明白了如果要改变某个指定的包的日志配置就是这样做，所以就确定了配置文件没有问题。那么原因就只可能是这个包记录日志根本就没有用log4j。那它用的是啥呢？不想翻文档就只能debug了。

首先找到记日志的地方，打个断点，执行程序，一步一步往下跟，找到这里

![](/images/2020-11-21-14-23-53.png)

很明显具体拿到的Logger类就是在这里决定的了，这段简单来说就是如果系统没有设置`net.spy.log.LoggerImpl`属性，就用默认的`DefaultLogger`，实际上跟到这里确实也发现就是没有设置这个属性，从而`className`拿到的是个空，所以也就没有log4j什么事儿了。

## 改造方案

既然知道了问题的根源，那么我们就设置一下这个属性就行了，它是从`System.getProperty()`方法获取的，那么我们就从`System.setProperty()`方法设置它。那么要设置成什么呢？打开这个`net.spy.log`目录，就会发现它提供了几个默认的实现

![](/images/2020-11-21-14-28-20.png)

很明显我们要找的就是`net.spy.memcached.compat.log.Log4jLogger`，所以只需要在程序入口加上这行
```java
System.setProperty("net.spy.log.LoggerImpl", "net.spy.memcached.compat.log.Log4JLogger");
```

> 这个很可能是slf4j这种日志门面出现之前的一种自己实现的方案，而slf4j-api/log4j-api就是解决这个问题的了。

即可。加上之后再运行程序就会发现颜色已经和其他的日志一样了。

## 总结

只要把问题回归到我们会的问题上，后面的问题就很容易解决了，前面已经配置了log4j.properties，所以当然也就可以方便的控制它的日志级别了。
