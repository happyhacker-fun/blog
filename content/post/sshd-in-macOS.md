---
title: "macOS上管理SSH服务"
date: 2020-03-29T10:57:10+08:00
description: "见识一下macOS智障般的服务管理"
tags: ["macOS", "ssh"]
categories: ["in-action"]
---

mac本身安装了ssh服务，默认情况下不会开机自启。本文记录了开启和停止sshd服务的方法。

<!--more-->

### 1. 启动sshd服务：

`sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist`

### 2. 停止sshd服务：

`sudo launchctl unload -w /System/Library/LaunchDaemons/ssh.plist`

### 3. 查看是否启动：

`sudo launchctl list | grep ssh`

如果看到下面的输出表示成功启动了：

```
$ sudo launchctl list | grep ssh
-	0	com.openssh.sshd
```

为什么需要开启macOS上的sshd服务呢？是因为在本地部署flink或者其他某些集群服务时，默认是要通过ssh协议发送文件的。对，传输到本机也是用ssh服务，所以如果没有开通服务就无法正确部署。  
