---
title: "Springboot配置热加载"
date: 2020-04-27T22:42:19+08:00
tags: ["java", "springboot", "config", "spring-cloud"]
draft: true
categories: ["in-action"]
---

我们当然不想每次更新配置都要重启服务，毕竟Springboot应用重启一次要很久，而且服务会中断，本文讨论如何更好的实践Springboot配置部署。

<!--more-->

## 最基本的配置

一般来说，我们有至少两种使用配置的方式，使用`@Value`注解和使用`PropertySource`。

### @Value注解
```java
package fun.happyhacker.configrefresh.config;

import lombok.Data;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
@Data
public class ValueConfig {
    @Value(value = "${foo.bar}")
    private String bar;
}
```

### `PropertySource`

```java
package fun.happyhacker.configrefresh.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "hello")
@Data
public class HelloProperties {

    private String bob;

    private String star;
}
```
这样配置之后就可以在Bean里引用相应的配置了。

```java
package fun.happyhacker.configrefresh.controller;

import fun.happyhacker.configrefresh.config.HelloProperties;
import fun.happyhacker.configrefresh.config.ValueConfig;
import org.json.JSONObject;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ConfigController {
    private ValueConfig valueConfig;
    private HelloProperties properties;

    public ConfigController(ValueConfig valueConfig, HelloProperties properties) {
        this.valueConfig = valueConfig;
        this.properties = properties;
    }

    @GetMapping(path = "/demo")
    public String demo() {
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("bob", properties.getBob());
        jsonObject.put("star", properties.getStar());
        jsonObject.put("bar", valueConfig.getBar());

        return jsonObject.toString();
    }
}
```

[6fd9bcc6](https://github.com/lovelock/JavaPlayground/commit/6fd9bcc616a1b3f35aa960a1e2f873c6682fdb48)

## 为什么要实现配置热更新

那我们的配置如果需要更新时该怎么办呢？通常我们认为application.properties是在服务启动时加载的，最直接的做法肯定是在配置更新之后重启服务了，这对于对可用性要求不高的服务无关紧要，但还是要对自己的服务提出更高的要求。

### 了解actuator
actuator为Spring服务提供了一系列管理的endpoints，可用于监控服务的一系列状态，同时也提供了管理接口，比如`/actuator/refresh`，用于刷新配置；`/actuator/env`用于查看服务的所有配置。

本文主要用到这两个，还有一个更厉害的后面再说。

该功能的依赖
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

默认开启了以下端点(endpoints)
```json
GET http://localhost:8080/actuator

HTTP/1.1 200 
Content-Type: application/vnd.spring-boot.actuator.v3+json
Transfer-Encoding: chunked
Date: Mon, 27 Apr 2020 15:33:31 GMT
Keep-Alive: timeout=60
Connection: keep-alive

{
  "_links": {
    "self": {
      "href": "http://localhost:8080/actuator",
      "templated": false
    },
    "health": {
      "href": "http://localhost:8080/actuator/health",
      "templated": false
    },
    "health-path": {
      "href": "http://localhost:8080/actuator/health/{*path}",
      "templated": true
    },
    "info": {
      "href": "http://localhost:8080/actuator/info",
      "templated": false
    }
  }
}
```

不包含我们我们需要的，所以要在`application.properties`中添加如下配置
```ini
management.endpoints.web.exposure.include=env,refresh
```

重启服务，就能看到我们要的两个端点了
```json
GET http://localhost:8080/actuator

HTTP/1.1 200 
Content-Type: application/vnd.spring-boot.actuator.v3+json
Transfer-Encoding: chunked
Date: Mon, 27 Apr 2020 15:35:58 GMT
Keep-Alive: timeout=60
Connection: keep-alive

{
  "_links": {
    "self": {
      "href": "http://localhost:8080/actuator",
      "templated": false
    },
    "env": {
      "href": "http://localhost:8080/actuator/env",
      "templated": false
    },
    "env-toMatch": {
      "href": "http://localhost:8080/actuator/env/{toMatch}",
      "templated": true
    },
    "refresh": {
      "href": "http://localhost:8080/actuator/refresh",
      "templated": false
    }
  }
}

Response code: 200; Time: 98ms; Content length: 314 bytes
```

这时通过`/actuator/env`可以看到上面我们添加的三个配置
```json
{
    "name": "applicationConfig: [classpath:/application.properties]",
    "properties": {
    "management.endpoints.web.exposure.include": {
        "value": "env,refresh",
        "origin": "class path resource [application.properties]:1:43"
    },
    "foo.bar": {
        "value": "hello world",
        "origin": "class path resource [application.properties]:4:9"
    },
    "hello.bob": {
        "value": "SpongeBob SquarePants",
        "origin": "class path resource [application.properties]:6:11"
    },
    "hello.star": {
        "value": "Patrick Start",
        "origin": "class path resource [application.properties]:7:12"
    }
    }
}
```

修改`application.properties`中的3个自定义配置，再调用`/actuator/refresh`是没有效果的（注意要用POST请求）。

### 原因分析

那为什么没有效果呢？

服务是通过`java -jar xxx.jar`的方式启动的，也就是说，修改之前的`application.properties`已经打包进了jar包，我们修改的是没有打包进jar包的文件，当然不会对它产生影响。

### 外置配置

为了解决上面的问题，我们要把application.properties外置，这通过`--spring.config.location`选项实现，为了实现这个配置，可以参考[Springboot使用外部配置文件](/post/springboot-external-config)。

```
cd config-refresh
mvn clean package -Dmaven.test.skip=true
java -cp . -jar target/config-refresh-0.0.1-SNAPSHOT.jar --spring.config.location=file:/tmp/external-config/bootstrap.properties,/tmp/external-config/application.properties
```
> bootstrap.properties是spring-cloud默认的配置文件，这里的配置是让springboot服务不去访问默认的`localhost:8888`端口去找配置服务器，不配置也可以，会报WARNING，但不影响服务。

### 引入依赖

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-config</artifactId>
</dependency>
```
> `/actuator/refresh`端口要同时引入`spring-boot-starter-actuator`和`spring-cloud-starter-config`。

### 验证

把`/tmp/external-config/application.properties`中的`hello.star`改成`Patrick Star`，再请求`/actuator/refresh`，再执行`/actuator/env`，就能看到配置已经更新了。同样的道理，修改`foo.bar`也可以正常更新。

**网上很多人说需要在乱七八糟的地方加上`@RefreshScope`，但我这里完全没有加这个配置，也能正常更新。后面会详细分析该机制的原理。

## 实际应用

当然我们实现动态更新肯定不会只是为了在actuator中查看，一个典型的使用场景是数据库切库，只需要改变数据库配置，而不需要改变代码。

### 配置数据库

### 源码分析

## 扩展

### 搭建配置服务

#### 使用git作为配置后端