---
title: "关闭Firefox浏览器中使用鼠标缩放网页的功能"
date: 2020-05-16T00:49:00+08:00
tags: ["firefox"]
categories: ["in-action"]
---

火狐浏览器有个很奇怪的设定，在Windows下按住Ctrl（macOS下按住Cmd）加上鼠标滚轮会缩放网页。
<!--more-->

有些人可能觉得是个很有用的功能，但我觉得这个功能让我很烦恼，有时候有不自觉的放在Cmd上，鼠标滚动一下网页就变成了200%，原来是可以通过配置修改关闭这项功能的

1. 在地址栏输入`about:config`
2. 搜索`mousewheel.with_meta.action`，把3改成0
3. 如果是windows，则搜索`mousewheel.with_control.action`，同样把3改成0
4. 改完立即生效，不需要重启浏览器

![](/images/2020-05-16-00-52-12.png)

![](/images/2020-05-16-00-53-02.png)