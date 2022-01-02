---
title: "0x00 引言"
date: 2021-12-15T23:42:00+08:00
tags: ["golang", "go"]
categories: ["go"]
---

最近要写一个可以跨平台执行又不依赖运行时的程序，所以就把golang又捡起来了。

<!--more-->

说实话如果不是写公司的项目，Java实在是一个让人喜欢不起来的语言，主要maven这一套搞起来太麻烦，而且还需要在运行的机器上安装一个jre，这又增加了使用门槛，如果要给非开发人员写一个拿来即用的程序，go确实是一个不错的选择。

我要写的这个程序主要功能包括以下几部分

1. 引用现成的包 go mod
1. 有命令行交互 cobra
1. 处理网络请求，包括Cookie、Get、Post请求以及不同的参数传递方式 resty/colly
1. 下载图片并展示 resty/exec
1. 识别图片验证码，本来希望能完美识别，但测试了tessocr之后觉得效果不好就没再深究了 tessocr
1. 加快执行速度（最开始没有考虑） goroutine
1. 处理配置文件，包括ini和yaml viper
1. 连接数据库，仅仅是检查连通性 sql
1. 将配置文件打包到可执行文件内 packr

所以我就想就着这些需求，把这几天重温golang的过程记录一下。

