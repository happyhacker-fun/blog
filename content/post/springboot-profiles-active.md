---
title: "Springboot Profiles Active"
date: 2020-10-22T16:32:44+08:00
tags: ["springboot"]
categories: ["in-action"]
---

Springboot的这个profiles的问题真是让人头疼。

<!--more-->

这个问题在小版本之间来瞎改，又没有明确的说明，不知道浪费了多少人的时间。

首先明确一点，通过
```bash
export SPRING_PROFILES_ACTIVE=prod,web
```
这种方式从始至终都是可行的。而改变的是
```bash
mvn spring-boot:run -Dspring.profiles.active=prod,web
```
这种方式。亲测在springboot 2.3.1已经完全不起作用了。所以保险的方法就是前面提到的第一种。可以这么做

```bash
export SPRING_PROFILES_ACTIVE=prod,web && mvn spring-boot:run
```
