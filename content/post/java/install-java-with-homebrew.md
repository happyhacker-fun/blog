---
title: "通过 homebrew 安装 JDK"
date: 2021-01-14T16:28:04+08:00
tags: ["jdk", "homebrew", "java"]
categories: ["java"]
---

Oracle JDK 现在收费了，macOS 上安装个 JDK 还挺麻烦。
<!--more-->

## TL；DR

简单来讲，可以直接运行`brew search openjdk`

![Oracle OpenJDK](/images/2021-01-14-17-13-40.png)

这样搜索出来的是 Oracle 发布的 OpenJDK。其中`openjdk`就是最新版本的，带`@`的就是指定版本的，其中 8 和 11 是 LTS 版本，所以可以拥有姓名，至于其他的短期版本，这里就干脆也没有了。

## AdoptOpenJDK

这个名字有点长，其实是 Eclipse 基金会在维护的发行版，它和 Oracle OpenJDK 的关系有点类似于 MIUI 和 Andriod AOSP 的关系，功能上应该是一样的，不过添加了一些特色的功能，如图所示

![AdoptOpenJDK](/images/2021-01-14-17-17-47.png)

它提供了不同的垃圾收集器和所有的版本号，社区应该也比较流行吧（好吧，其实更多人还是会去下载 Oracle JDK，只是它的免费的 JDK1.8 永远的停留在了8u231）。

参考这个[https://github.com/AdoptOpenJDK/homebrew-openjdk](https://github.com/AdoptOpenJDK/homebrew-openjdk)

强烈推荐使用这个脚本

```bash
jdk() {
        version=$1
        export JAVA_HOME=$(/usr/libexec/java_home -v"$version");
        java -version
 }
```

可以让你在不同版本的 JDK 中自由切换。