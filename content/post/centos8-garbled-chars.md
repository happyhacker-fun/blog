---
title: "Centos8乱码及解决"
date: 2020-04-03T22:14:19+08:00
tags: ["centos8", "linux"]
categories: ["in-action"]
---

以下操作基于CentOS8, 理论上应该适用于其他版本的操作系统.

<!--more-->

现在终端默认的编码都已经设置成了

```
export LANG=en_US.UTF-8
```

所以, 这里应该是不需要改动的, 只需要安装一下`glibc-langpack-*`包就可以了, 对于我们的实际使用来说, 其实就是中文包

```
yum install -y glibc-langpack-zh
```

即可.