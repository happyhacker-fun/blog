---
title: "彻底关闭macOS系统升级提示"
date: 2020-06-10T10:52:37+08:00
tags: ["macOS", "tips"]
categories: ["in-action"]
---

作为黑苹果用户，不知道直接更新系统会发生什么不可预知的问题，所以还是尽量避免升级。
<!--more-->

## 设置方法

### 1. 在系统偏好设置中关闭自动更新

![](/images/2020-06-10-10-55-42.png)

![](/images/2020-06-10-11-03-03.png)

![](/images/2020-06-10-11-04-06.png)

### 2. 在终端执行以下命令

```
sudo softwareupdate --ignore "macOS Catalina"
defaults write com.apple.systempreferences AttentionPrefBundleIDs 0 
killall Dock 
```

### 3. 补充

最近的不知道哪次更新又带来了一个问题，执行上面的命令的时候会报

```text
Password:
Ignored updates:
(
)

Software Update can only ignore updates that are eligible for installation.
If the label provided to ignore is not in the above list, it is not eligible
to be ignored.

Ignoring software updates is deprecated.
The ability to ignore individual updates will be removed in a future release of macOS.
```

也就是说苹果以后要把这个选项去掉了，可以参考一下这个文章[Apple’s has brought back the nagging — you can no longer ignore major macOS updates](https://www.idownloadblog.com/2020/05/28/apple-removes-ignoring-macos-updates/)，看起来不光是我反感这个事儿，全世界都觉得苹果一点都不在乎用户的感受啊，和微信有点像。


## 总结

macOS和iPhone的升级速度快（指最新版本的更新率高）的原因就是这么不停提醒吧，太讨厌了。这种方法亲测有效。
