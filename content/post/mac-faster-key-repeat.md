---
title: "macOS设置Key Repeat和Delay Until Repeat"
date: 2020-11-21T22:48:25+08:00
tags: ["key-repeat"]
categories: ["macOS"]
---

macOS上用Vim觉得很卡顿，不流畅，终于找到原因了。

<!--more-->

有两个相关设置
![](/images/2020-11-21-22-50-28.png)

这两个把`Key Repeat`设置到最快，把`Delay Until Repeat`设置到最短，但实际上这么设置之后还是不够，再小就不能通过配置页面设置了，只能通过命令行设置了。我觉得合适的配置是这样的

```
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1
```

这样之后再操作就明显流畅多了。