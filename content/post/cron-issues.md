---
title: "crontab配置的一个常见错误"
date: 2020-04-14T22:40:01+08:00
tags: ["linux", "crontab"]
categories: ["in-action"]
---

如果你遇到了crontab不能按预期执行的问题，可以参考本文的内容。

<!--more-->

crontab是运维工作中经常需要做的，多数时候只需要执行`crontab -e`来编辑即可，当面对更复杂的场景时，这种方式就显得不够用了。  
> 关于crontab更多的内容可以通过查看`man 8 cron`和`man 5 crontab`来获取。

## crontab的分类

一般来说，crontab可以分为三种，分别位于以下三个目录中

- `/var/spool/cron/`
- `/etc/cron.d`
- `/etc/cron.{hourly,daily,weekly,monthly}`

## 不同的crontab的作用

### `/var/spool/cron/`

这里就是存储我们最常用的`crontab -e`编辑的文件的地方了，这里保存着和执行这个命令的用户名相同的文件，所以当需要用某一个用户名执行cron时，有两种方式，以用户名`frost`为例

- 执行`crontab -e`
- `vim /var/spool/cron/frost`

这两种方式本质上是一样的。值得注意的是，它的文件内容格式如下
```crontab
* * * * * /path/to/command
```

先记住这个格式，后面会做对比。

### `/etc/cron.d`

这里存储的是更通用的配置，每一行可以由不同的用户执行，没有了用户名做区分应该怎么做呢？这就是它的文件内容和前面的不同的地方了，放在这个目录种的cron文件想要被执行，需要满足下面的格式

```crontab
* * * * * ${username} /path/to/command
```

也就是说，在**时间格式后面需要指定执行命令所用的用户名**，这是非常重要的，因为如果没有这个用户名，这行命令就不会被执行。  
个人认为，这种方式其实更适合批量执行的环境，从中心节点下发crontab相关的配置时，都放在一个文件会导致该文件功能众多，难以维护，相反如果把不同功能的配置文件以不同的名字下发到`/etc/cron.d`中，则更为清晰，可维护性更好。  
比如在`/etc/cron.d`中可以有`log`, `check_db`等，分别用于执行压缩/删除日志、检查数据库是否可访问等任务，职责清晰明了。  

### `/etc/cron.{hourly,daily,weekly,monthly}`

这里和前面两种都不同，因为它里面存放的并不是任何类型的crontab的配置，而是脚本，从目录名也可以知道，对应的目录中的脚本会以相应的时间间隔执行。

