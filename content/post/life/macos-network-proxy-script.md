---
title: "macOS 网络代理设置脚本"
date: 2020-11-17T22:34:31+08:00
tags: ["macOS", "bash"]
categories: ["macOS"]
---

一直以来我都有个疑问，就是为什么所有操作系统的网络代理设置都不能保存。

<!--more-->

以macOS为例，如果我设置了代理地址，而没有勾选左边的勾选项，那么保存之后再打开也同时没有了已经设置好的代理地址。
![](/images/2020-11-17-22-36-46.png)
而我想要的是可以设置好一个固定的代理地址，我需要开启的时候在一个很明显的入口点一下，就配置上了。不想用的时候关掉即可，不用清空配置。然而我搜遍了全网也没有找到。

于是我就想macOS系统既然脱胎于BSD，那会不会有相应的命令行可以做这件事儿呢，果然被我找到了一系列命令`networksetup`。

先看一下这个命令都有什么功能吧，

```
networksetup -help
```

输出太多了，这里就不贴了，可以自己尝试一下。我们关注的是代理（Proxy），所以在输出的信息里搜索proxy，就会找到以下内容

```
Usage: networksetup -setautoproxyurl <networkservice> <url>
	Set proxy auto-config to url for <networkservice> and enable it.

Usage: networksetup -getautoproxyurl <networkservice>
	Display proxy auto-config (url, enabled) info for <networkservice>.

Usage: networksetup -setautoproxystate <networkservice> <on off>
	Set proxy auto-config to either <on> or <off>.

```

很明显也就看出来各自的用途了，知道这个了就很容写出两个脚本了

**由于我的是黑苹果，使用的是有线网络，所以这里的网络名是en0，你的电脑用的是什么网络需要你自己去发现了**

### 设置代理

```bash
#!/usr/bin/env bash

echo "Enabling auto proxy...."

networksetup -setautoproxyurl "Ethernet Adaptor (en0)" "http://your.host/proxy.pac"
networksetup -setautoproxystate "Ethernet Adaptor (en0)" on
networksetup -getautoproxyurl "Ethernet Adaptor (en0)"

if [ $? -eq 0 ]; then
    echo "Proxy is set"
fi
```

### 关掉代理

```bash
#!/usr/bin/env bash

echo "Disabling auto proxy..."
networksetup -setautoproxystate "Ethernet Adaptor (en0)" off
networksetup -getautoproxyurl "Ethernet Adaptor (en0)"

if [ $? -eq 0 ]; then
    echo "Proxy is disabled"
fi
```

### 设置快捷方式

把这分别保存为`disable_proxy`和`enable_proxy`，放在`$HOME/.local/bin/`目录下，然后在你的`$HOME/.zshrc`或`$HOME/.bashrc`的最后一行追加

```bash
export PATH=$PATH:$HOME/.local/bin
```

再执行`source ~/.zshrc`或`source ~/.bashrc`，就可以生效了。之后就可以通过执行`enable_proxy`开启代理，通过`disable_proxy`来关闭代理了。再也不用找那么深的入口去一遍遍的配置代理了。
