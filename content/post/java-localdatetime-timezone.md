---
title: "Java时区问题的排查和分析"
date: 2020-04-01T12:48:50+08:00
tags: ["java", "timezone"]
draft: true
categories: ["in-action"]
---

用Java开发新项目，遇到了很多之前没见过的问题，时区算是第二头疼的一个。

<!--more-->

## 现象

数据库中的时间是`2020-03-20 00:00:00`，但查询时需要`2020-03-21 08:00:00`才能查到。这明显是差了8个时区。

## 排查过程

### JDBC连接

`serverTimezone=GMT%2B8`

### 数据库服务器的时间

### 服务器本地时间

### 运行服务的容器时间

### Java的LocalDateTime

因为LocalDateTime是和时区无关的时间，jvm默认它就是UTC时间，所以传过来的`2020-03-20 00:00:00`会被转换成`2020-03-19 16:00:00`，这就是最上面的问题的答案了。

可以通过以下方式验证
```java
import java.time.LocalDateTime;

public class TimeZoneTest {

    public static void main(String[] args) {
        System.out.println(LocalDateTime.now());
    }
}
```
执行`javac TimeZoneTest.java && java -cp TimeZoneTest`，会发现和预期不符合，准确的说是比当前时间慢了8小时。

```java
import java.time.LocalDateTime;
import java.util.TimeZone;

public class TimeZoneTest {

    public static void main(String[] args) {
        TimeZone tz = TimeZone.getTimeZone("GMT+8");
        TimeZone.setDefault(tz);
        System.out.println(LocalDateTime.now());
    }
}
```
同样执行`javac TimeZoneTest.java && java -cp TimeZoneTest`，就会发现和当前时间一致了。

## 解决方案

找到了问题的根本原因，就容易解决了。

### Springboot

```java
@SpringBootApplication
public class WebApplication {
    public static void main(String[] args) {
        SpringApplication.run(WebApplication.class, args);
    }

    @PostConstruct
    void setDefaultTimeZone() {
        TimeZone.setDefault(TimeZone.getTimeZone("GMT+8"));
    }
}
```

### 设定Java命令行参数

`java -Duser.timezone=GMT+8 TimeZoneTest`

### 
