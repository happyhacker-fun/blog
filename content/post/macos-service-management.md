---
title: "使用Homebrew管理macOS上的服务"
date: 2020-03-29T10:53:04+08:00
description: "homebrew真是macOS上的万能神器"
tags: ["homebrew", "macOS"]
categories: ["macOS"]
---

用了5年macOS也一直没有用过苹果原生的服务管理、AppleSript等等，总感觉不够直观，好在还有Homebrew这个神器，帮我解决了很多问题。
<!--more-->

对于通过homebrew安装的服务，可以通过其提供的`brew services`或者服务自带的命令进行管理。这里只记录了两种，其他需要查看启动方法的可以通过`brew info`命令查看。

## MySQL

```
brew install mysql

mysql.server start
mysql.server stop
```

## ZooKeeper

```
brew install zookeeper
brew services start zookeeper # 后台启动
zkServer start # 前台启动
```