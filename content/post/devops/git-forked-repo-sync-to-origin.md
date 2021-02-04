---
title: "Fork的repo保持和原repo同步"
date: 2021-02-03T12:35:16+08:00
tags: ["git"]
categories: ["git"]
---

有时候fork了一个项目，过几天发现原项目已经更新了，这时候要保持和原始项目的同步。

<!--more-->

比如原始项目是`https://github.com/apache/flink.git`，而我fork的项目是`git@github.com:lovelock/flink.git`，这时在我自己的本地仓库可以执行这些命令

```bash
git remote add remote https://github.com/apache/flink.git
git fetch remote master
git merge remote/master
# 上面两步也可以简化成 git pull remote master
git push origin master
```

> 其实我觉得这个功能应该是让Github提供才更合适，干嘛要在本地操作呢？直接加个按钮，同步上游代码不就行了。
