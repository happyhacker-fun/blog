---
title: "AMD黑苹果上的docker"
date: 2020-07-25T23:35:01+08:00
tags: ["docker"]
categories: ["in-action"]
---

本来选择AMD的黑苹果之前就已经做好了无法使用docker的准备了，没想到那天偶然发现说docker-toolbox是可以用的。
<!--more-->

国内下载docker官方的东西实在是太慢了，还是从阿里云下载的。这里多说一句，阿里云在开源软件镜像架设这方面的贡献远远超过国内其他公司了（BT？不存在的）

## 下载Docker Toolbox

访问[阿里云的Docker Toolbox下载地址](http://mirrors.aliyun.com/docker-toolbox/mac/docker-toolbox/)，下载最新的安装包。

这里同步是有点问题的，官方已经有19.xx版本了，但阿里云的镜像这里还是18.03，不过无所谓了，快才是王道。

## 安装

安装过程就不说了，既然你找到这里了说明你肯定会安装软件了。

![](/images/2020-07-27-12-32-07.png)

## 配置

![](/images/2020-07-25-23-40-15.png)

注意红色部分的提示，乍一看是需要在BIOS里打开AMD-v技术（对标Intel的VT-x），一般是叫SVM，默认通常是不开启的。但我这里已经开启过了，还报这个错只能说是检测脚本并没有适配【AMD黑苹果】这个可能性。

所以直接忽略这个提示。

然后需要创建一个默认的虚拟机，用virtualbox的驱动即可。这里要注意，由于众所周知的原因，我们下载docker的官方镜像非常慢，所以要配置一下国内的代理，建议使用阿里云。注册登陆之后访问这个[镜像加速器](https://cr.console.aliyun.com/undefined/instances/mirrors)，按文档说明执行你的命令即可

> 注意：执行`docker-machine create`命令的时候还是会检查上面提到的有问题的虚拟化技术检查，所以需要加上一个`--virtualbox-no-vtx-check`选项

```
docker-machine create default --engine-registry-mirror=https://yourcode.mirror.aliyuncs.com -d virtualbox --virtualbox-no-vtx-check --virtualbox-memory "8096" --virtualbox-cpu-count "6"
```

> 2020年11月添加：后来使用过程中发现内存会不够用，因为默认是1G内存和1个CPU核心，这明显是不能满足正常的使用需求的，所以就需要加一些资源了。

## 打开Kitematic开始体验docker

哇！原来docker还能这么用？！当你走到这一步了，你一定知道我为什么会感叹。

