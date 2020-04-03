---
title: "实现一个全功能的Response封装"
date: 2020-04-01T01:30:59+08:00
tags: []
draft: true
categories: []
---

作为一个有追求的服务，肯定要统一Response输出，方便调用方统一处理数据。

<!--more-->

一个完整的Response需要考虑解决哪些问题？需要包含哪些部分？

## Respnose解决的问题

1. 返回业务数据
2. 告知业务状态
3. debug/exception信息（仅调试阶段）
4. HTTP状态

