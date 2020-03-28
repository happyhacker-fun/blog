---
title: "Springboot使用Hikari集成数据源"
date: 2020-03-28T23:03:18+08:00
description: "Spring datasource config with Hikari"
tags: ["springboot", "java", "hikari"]
draft: true
categories: ["in-action"]
---

Springboot提供了多种方式集成数据源，常用的是Hikari（国外）和Druid（国内）。但二者专注的问题其实都相对简单，没有对多数据源、主从分离做直接支持，而需要使用者自行配置。

<!--more-->

