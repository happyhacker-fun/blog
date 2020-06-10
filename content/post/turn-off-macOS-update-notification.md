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

## 总结

macOS和iPhone的升级速度快（指最新版本的更新率高）的原因就是这么不停提醒吧，太讨厌了。这种方法亲测有效。
