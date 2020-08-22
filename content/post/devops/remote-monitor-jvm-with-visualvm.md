---
title: "使用VisualVM监控远程JVM进程"
date: 2020-08-22T17:25:53+08:00
tags: ["jvm", "visualvm", "java"]
categories: ["in-action", "devops"]
---

服务器端没有可视化界面，监控这种事情看CLI界面还是差点意思。
<!--more-->

## 方法
需要看Tomcat的监控，需要远程连接之，只需要在tomcat启动前在`$TOMCAT_HOME/bin`目录下添加`setenv.sh`文件，加上以下内容即可

```
JAVA_OPTS="-Dcom.sun.management.jmxremote=true \
                  -Dcom.sun.management.jmxremote.port=9090 \
                  -Dcom.sun.management.jmxremote.ssl=false \
                  -Dcom.sun.management.jmxremote.authenticate=false \
                  -Djava.rmi.server.hostname=current ip"
```

这样就可以在本地看到这种监控图了
![压测期间的active节点](/images/2020-08-22-17-06-47.png)

## 扩展

既然Tomcat是这么做，其实我们自己的应用当然也可以，只需要在启动的时候加上这些参数即可。

```
➜  tomcat vim Hello.java
➜  tomcat javac Hello.java
➜  tomcat java -Dcom.sun.management.jmxremote=true \
                  -Dcom.sun.management.jmxremote.port=9090 \
                  -Dcom.sun.management.jmxremote.ssl=false \
                  -Dcom.sun.management.jmxremote.authenticate=false \
                  -Djava.rmi.server.hostname=10.75.1.42 Hello
```
![](/images/2020-08-22-17-51-04.png)
果然是可以的。

## 总结

其实很多开源的Java软件，都有类似这种做法，比如Apache Flink用`$FLINK_HOME/bin/config.sh`等，通过这种方式可以很容易的设置一些环境变量。

