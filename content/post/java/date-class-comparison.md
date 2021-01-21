---
title: "Java日期函数的一个坑"
date: 2021-01-21T16:33:43+08:00
tags: ["java"]
categories: ["theory"]
---

我们知道 Java1.8 推荐使用 `LocalDate`和`LocalDateTime`类来处理日期和时间，但之前的版本是用`GregorianCalendar`。之前一直以为只是易用性上的差别，没想到还有一个神坑。

<!--more-->

## 事情经过

今天发现应用崩了，查日志发现是接收到了一个`Sat Jan 01 00:00:00 +0800 0001`这样的时间，当我用

```java
LocalDateTime.parse('Sat Jan 01 00:00:00 +0800 0001', DateTimeFormatter.ofPattern("EEE MMM dd HH:mm:ss Z yyyy"));
```

来解析的时候报了这样一个错

```text
java.time.format.DateTimeParseException: Text 'Sat Jan 01 00:00:00 +0800 0001' could not be parsed: Conflict found: Field DayOfWeek 1 differs from DayOfWeek 6 derived from 0001-01-01
	at java.time.format.DateTimeFormatter.createError(DateTimeFormatter.java:1920) ~[?:1.8.0_231]
	at java.time.format.DateTimeFormatter.parse(DateTimeFormatter.java:1855) ~[?:1.8.0_231]
	at java.time.LocalDateTime.parse(LocalDateTime.java:492) ~[?:1.8.0_231]
```

看起来像是星期一和星期六有冲突，然后我就去百度**公元0001年 1 月 1 日**到底是星期几，得到的答案有的说是星期一，有的说是星期六，当然是找不到这样一个日历的，网上能找到的日历最多也就到 1900 年，这就勾起了我的兴趣，于是在想这个日期肯定不是人为填写的，那么就只能是因为**生成这个时间**的方法和我现在用的**解析这个时间**的方法有出入。业务方很早之前就开始用 Java 了，而我们是最近刚开始用，所以他们即便可能现在用的是 Java8，里面的很多写法应该还是保留了更早的方式，所以我就验证了一下这个日期

```java
package fun.happyhacker.springbootdemo;

import java.time.LocalDate;
import java.time.Month;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

public class DateTest {
    public static void main(String[] args) {
        Date birthDay = new GregorianCalendar(1, Calendar.JANUARY, 1).getTime();
        System.out.println(birthDay);
        LocalDate birthDay1 = LocalDate.of(1, Month.JANUARY, 1);
        System.out.println(birthDay1.getDayOfWeek());
    }
}
```

执行一下，神奇的事情发生了

```text
Sat Jan 01 00:00:00 CST 1
MONDAY
```

也就是说在`GregorianCalendar`认为这天是星期六，而`LocalDateTime`认为这天是星期一。

## 总结

从这件事儿得出的结论就是，从 JDK7 升级到 JDK8 的过程中，不光要注意什么语法的问题，说不定还会出现这种历史遗留问题。虽然这个日期比较特殊，但保不齐还有其他的特殊情况。
