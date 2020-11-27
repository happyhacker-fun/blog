---
title: "Shell的一些实用技巧"
date: 2020-11-27T16:29:38+08:00
tags: ["bash", "python"]
categories: ["linux"]
---

Shell总认为很简单，每到写的时候总是不会写。

<!--more-->

这里总结了写shell脚本时经常会遇到的问题。

### 1. `sudo` 无法修改文件，而`sudo -s`切换到root后可以

比如本来是 `sudo echo 'hahaha' > /etc/abcde`，改成`sudo sh -c "echo 'hahaha' > /etc/abcde"` 即可。

### 2. 从可信站点下载脚本直接执行而不需保存要怎么弄？

1. wget `wget -0 - https://a.b.c/trusted-script.sh | sh`
2. curl `curl -o - https://a.b.c/trusted-script.sh | sh`

> 如果是其他脚本，后面换成相应的解释器如`python`即可
