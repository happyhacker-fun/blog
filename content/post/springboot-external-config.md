---
title: "Springboot使用外部配置文件"
date: 2020-04-27T23:44:00+08:00
tags: ["java", "springboot", "config", "tomcat"]
draft: true
categories: ["in-action"]
---

Springboot使用外置配置文件的几种方式。
<!--more-->

使用jar包或者war包内的配置文件虽然开发时方便，但修改配置需要重新打包，也就违背了代码和配置分离的初衷。

## 依赖的选项

其实就是通过`--spring.config.location=xxx`来指定配置文件。下面根据文件所在位置的不同和运行环境的不同分别阐述。

## 使用内嵌的WebServer时

## 使用独立的WebServer时

```bash
#!/usr/bin/env bash
# setenv.sh

export SPRING_CONFIG_LOCATION=file:/path/to/application.properties
export SPRING_PROFILES_ACTIVE=prod
```

```bash
#!/usr/bin/env bash
# setenv.sh

export CATALINA_OPTS="-Dspring.config.location=file:/path/to/application.properties -Dspring.profiles.active=prod"
```

