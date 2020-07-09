---
title: "lftp记录密码"
date: 2020-04-05T11:32:45+08:00
tags: ["lftp", "macOS", "ftp"]
categories: ["in-action"]
---

简单的工具最好用。

<!--more-->

lftp是我非常喜欢的一个lftp工具，命令简单。为了避免每次输入密码，可以通过在`$HOME/.netrc`中添加一行记录来实现

```
machine 192.168.1.108 login ${my_user_name} password ${my_password}
```

非常简单。而且这个`.netrc`并不是lftp专用的，而是一个用在很多开源软件上的公用配置。

