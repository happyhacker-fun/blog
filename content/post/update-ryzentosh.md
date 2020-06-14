---
title: "黑苹果更新升级"
date: 2020-06-14T10:12:22+08:00
tags: ["ryzentosh"]
categories: ["in-action"]
---

装黑苹果的时候是10.15.3，后来经历了两次官方的更新，但我又不太清楚需要的更新过程，现在更新成功之后记录一下。

<!--more-->

## 1. 更新EFI

下载最新的OpenCorePkg，参考[这里](https://dortania.github.io/OpenCore-Desktop-Guide/post-install/update.html)把主要的几个文件更新一下，把EFI更新到系统硬盘之后重启看看能不能正常启动，能正常启动后再进行第二步。

我首次安装的时候是OpenCore0.5.6，更新到0.5.7的时候有一个不兼容的配置，如下图所示

![](/images/2020-06-14-10-16-50.png)

而正好重命名的这个是必须项，所以就需要自己把`FwRuntimeServices.efi`删除，把新的`OpenRuntime.efi`放进来，打开ProperTree，重新加载`config.plist`

![](/images/2020-06-14-10-18-42.png)

## 2. 更新macOS

这就是上述[这里](https://dortania.github.io/OpenCore-Desktop-Guide/post-install/update.html)没有说清楚的地方，因为实在是没什么好说的。就按正常的系统更新流程直接点更新即可！

## 3. 更新成功

![](/images/2020-06-14-10-20-52.png)
