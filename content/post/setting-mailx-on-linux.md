---
title: "最简单的命令行发邮件方式"
date: 2020-07-20T17:10:43+08:00
tags: ["linux", "mailx"]
categories: ["in-action"]
---

用newman搞了个自动化测试脚本，测试出错的时候需要发邮件提醒，但之前尝试配置了sendmail有各种神奇的问题，这次换了思路，尝试用mailx。

<!--more-->

## 安装软件包

```
yum install -y mailx
```

## 配置发件人信息

安装完成后会生成一个`/etc/mail.rc`配置文件，前面的那些都不用看，直接无脑在最后添加以下内容

```
set from="myname@happyhacker.fun"
set smtp="mail.happyhacker.fun"
set smtp-auth-user="myname@happyhacker.fun"
set smtp-auth-password="this is a strong password"
set smtp-auth=login
```

## 测试几种不同方式

### 不带附件

#### 管道

```
echo "这是正文" | mail -s "这是标题" myname@happyhacker.fun
```

#### 重定向

```
mail -s "这是标题" myname@happyhacker.fun < /path/to/a/text/file
```

这样会把指定的文件中的内容当作邮件的正文发出

### 带附件

```
mail -a 附件.docx -s "这是标题" myname@happyhacker.fun < /path/to/a/text/file
```

这些就可以应付大部分场景了。
