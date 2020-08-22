---
title: "Debian Linux快速搭建Java运行环境"
date: 2020-08-22T11:57:03+08:00
tags: ['mvn', 'java']
categories: ['in-action']
---

本文使用docker环境。
<!--more-->

## 修改软件源

```
sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
```

## 安装JDK和maven

```
apt update
apt install openjdk-11-jdk-headless maven vim git curl wget
```

## 配置阿里云maven加速

参考[使用阿里云加速依赖管理](/post/accelerating-maven-downloading-with-aliyun-mirror/)

## 创建一个Java应用

### 使用maven创建一个应用骨架
```
mvn archetype:generate -DgroupId=fun.happyhacker -DartifactId=spring-demo -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -DinteractiveMode=false
```

## 总结

在一个全新的机器上搭建Java开发和运行环境，主要还是网络问题，使用阿里云的加速服务能极大的提高使用体验。
