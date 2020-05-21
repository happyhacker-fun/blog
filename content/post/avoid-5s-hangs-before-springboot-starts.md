---
title: "避免Springboot应用启动前5秒的等待"
date: 2020-05-21T10:41:26+08:00
tags: ["springboot", "java", "tips"]
categories: ["springboot"]
---

在macOS上开发Springboot应用时发现应用启动前总是等待5秒钟，体现在应用启动的很慢。
<!--more-->

具体的提示信息因为改完之后找不到了，就是一句提示，说使用了5000 milliseconds，建议macOS用户修改/etc/hosts。但具体改什么就没有提到。

其实是因为应用启动时会查询域名`${hostname}`，而macOS上默认是没有配置这个域名的，所以就要等到超时（5秒）才能继续了。知道了问题的原因也就清楚如何解决了，在`/etc/hosts`中添加以下两行

```
127.0.0.1 ${hostname}
::1 ${hostname}
```
其中`${hostname}`要替换成你机器的hostname，要得到它只需要执行`hostname`命令即可，一般是一个以`.local`结尾的字符串。
