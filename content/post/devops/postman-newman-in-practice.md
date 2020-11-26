---
title: "Postman和Newman实操"
date: 2020-11-26T11:46:28+08:00
tags: ["postman", "newman"]
draft: true
categories: ["testing"]
---

作为开发，总免不了也和测试打交道，了解一点测试工具还是有帮助的。

<!--more-->

接口测试最受欢迎的工具可能就是postman了，很多人都在用，但可能大多数人都不知道怎么用它做自动化测试，毕竟图形化的工具做自动化测试还是比较困难的。但实际上它还有一个cli版本，也就是newman。

先介绍一下postman的基本用法，让我们跳过配置params/body的步骤，直接进入**请求前置脚本(Pre-request Script)**配置阶段。


