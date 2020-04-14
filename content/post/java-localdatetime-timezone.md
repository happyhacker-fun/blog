---
title: "Java时区问题的排查和分析"
date: 2020-04-01T12:48:50+08:00
tags: ["java", "timezone"]
categories: ["in-action"]
---

用Java开发新项目，遇到了很多之前没见过的问题，时区算是第二头疼的一个。

<!--more-->

## 现象

数据库中的时间是`2020-03-20 00:00:00`，但查询时需要`2020-03-21 08:00:00`才能查到。这明显是差了8个时区。

## 排查过程

### JDBC连接

搜索该问题，提到的最多的就是在jdbc url中加上时区的配置，应该是`Asia/Shanghai`和`GMT+8`(注意encode)都行，我测试的时候两种都没有解决我的问题。
`serverTimezone=GMT%2B8`

### 数据库服务器的时间

到数据库服务器执行以下命令，得到的输出如下

```
mysql> show variables like '%time_zone%';
+------------------+--------+
| Variable_name    | Value  |
+------------------+--------+
| system_time_zone | CST    |
| time_zone        | SYSTEM |
+------------------+--------+
```

测试环境和线上环境都是这样的配置，看起来问题应该不是出在这里。但还是要提以下这个容易产生混淆的地方，`CST`这个缩写是有歧义的，起码在指时区这一件事情时，就有多种不同的意思

![](/images/2020-04-14-23-39-19.png)

但其实在mysql服务的时区这件事上其实是没有歧义的，就是指`UTC-6:00`的中央标准时间。

### 服务器本地时间和容器的时间

由于我的代码是在docker中执行的，所以其实更应该关注的是容器中的时间。这时候发现了容器中的时间和宿主机相差了8小时，猜测问题可能是由此引起的。

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

## 总结

我最终选择的是在jdbc url中添加时区的同时，在SpringBootApplication中设置默认时区，完美的解决了问题。

