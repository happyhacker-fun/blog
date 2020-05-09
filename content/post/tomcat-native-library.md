---
title: "Tomcat配置nativelib"
date: 2020-04-26T15:02:04+08:00
tags: ["java", "springboot", "tomcat"]
draft: true
categories: ["in-action"]
---

Springboot在本地使用embeded tomcat启动时，总是提示找不到`libtcnative`，就查一下到底是什么原因。【具体看一下报错信息是什么】

<!--more-->

## tomcat的三种运行模式
### bio
### nio
### apr
下面的操作以CentOS8为例。

```bash
dnf -y install vim java-1.8.0-openjdk-headless java-1.8.0-openjdk java-1.8.0-openjdk-devel 
export JAVA_HOME=$(alternatives --list | grep java_sdk_openjdk | awk '{print $3}')
wget https://mirror.bjtu.edu.cn/apache/tomcat/tomcat-connectors/native/1.2.23/source/tomcat-native-1.2.23-src.tar.gz
tar xzvf tomcat-native-1.2.23-src.tar.gz
dnf -y install gcc make redhat-rpm-config apr-devel openssl-devel
dnf -y install gcc make redhat-rpm-config apr-devel openssl-devel
cd tomcat-native-1.2.23-src/native && ./configure --with-apr=/usr/bin/apr-1-config \
        --with-ssl=yes \
        --with-java-home=$(alternatives --list | grep java_sdk_openjdk | awk '{print $3}') \
        --prefix=/path/to/tomcat && make && make install
```

```bash
#!/usr/bin/env bash
#setenv.sh

export JAVA_OPTS="$JAVA_OPS -Djava.library.path=/path/to/libtcnative"
```

遇到SSL的问题可以修改`service.xml`

```xml
<Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
```

改成

```xml
<Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="off" />
```

即可。