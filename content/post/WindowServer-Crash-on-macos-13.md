---
title: "WindowServer Crash on Macos 13"
date: 2022-11-29T23:28:48+08:00
tags: ["macos", "Ventura"]
categories: ["macos"]
---


公司发的2020款M1芯片MacBook Pro前几天升级了macOS 13.0.1，噩梦开始了。

<!--more-->

是从官网看到新版本的macOS更新了更好用的Spotlight、邮件等app，觉得是挺好用的新特性，加上已经更新了一个小的bugfix版本，就更新了，结果遇到了以下问题

1. 无端突然黑屏隔几秒后回到登录界面，输入密码登录后提示WindowServer crash，一大堆没什么用的信息
2. Spotlight反应明显慢亿拍，这是我每天用几十次的功能，结果现在变成了唤起之后输入等5秒左右才显示在输入框里，然后开始搜索，所以是反向升级了

这是非常影响工作的，几乎变成不可用的状态了，毕竟一崩溃所有正在用的窗口全都异常关闭，好在没出现数据异常丢失的情况。而且最常用的功能反应慢了那么多。

问了周围几个同事，有的很早之前就更新了也没有出现这个问题，我就纳闷了，后来发现好像他们都不是M1芯片。

Reddit上扒了一些帖子，发现遇到这个问题的还不在少数，而且目前看起来13.1Beta2也没有解决。好在有[网友发现了问题的根源](https://www.reddit.com/r/MacOSBeta/comments/yq0mwd/ventura_131_beta_2_completely_breaks_external/)，按照这个帖子删除以下两个文件

```
~/Library/Preferences/ByHost/com.apple.windowserver.displays.<LONG HEX STRING>.plist
/Library/Preferences/com.apple.windowserver.displays.plist
```

重启，就好了。不过这只是解决了黑屏崩溃的问题，并没有解决Spotlight反应慢的问题。

其实中间想着降级来着，但不知道为什么已经回不到出厂的10.12 Monterey版本了，重新装了一遍13.0.1（已经备份的数据的情况），数据没有丢，问题也没有解决。好在现在这个最严重的问题解决了，就记录一下。

