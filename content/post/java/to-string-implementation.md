---
title: "实现 toJson() 方法"
date: 2021-01-21T17:53:05+08:00
tags: ["java", "json"]
categories: ["theory"]
---

Java 中 POJO 的`toString()`方法和我们预期的 JSON 格式不符合，而如果直接覆盖它写一个生成 JSON 的又不合适，因为当需要那种格式的时候就没得用的，所以本着各司其职的原则，我们来实现一个`toJson()`方法。

<!--more-->

## 序列化库选择

我比较熟悉的就是 Jackson 和 Gson，其中 Gson 的使用较为简单，所以这里用 Gson 来实现。其实主要原因是 Jackson 在序列化对向的时候会抛出异常，而 Gson 就不会。这里简单验证一下。

```java
package fun.happyhacker.json;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;

public class JsonTest {
    public static void main(String[] args) {
        Employee employee = new Employee();
        employee.setAge(10);
        employee.setId(1);
        employee.setName("John");

        ObjectMapper objectMapper = new ObjectMapper();
        String jackson = "";
        try {
            jackson = objectMapper.writeValueAsString(employee);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
        System.out.println(jackson);

        String gson = new Gson().toJson(employee);
        System.out.println(gson);

        System.out.println(new GsonBuilder().serializeNulls().create().toJson(employee));
    }
}
```

```text
{"id":1,"name":null,"age":10}
{"id":1,"age":10}
{"id":1,"name":null,"age":10}
```

所以，起码在序列化 JSON 这方面，可以认为两个库的作用是一致的，但 Gson 用起来很简单。

## 给每个 POJO 添加`toJson`方法

所以是不是就要人肉给每个 POJO 添加这个方法了，比如上面提到的`Employee`

```java
package fun.happyhacker.json;

import com.google.gson.GsonBuilder;
import lombok.Data;

@Data
public class Employee {
    private int id;
    private String name;
    private int age;

    public String toJson() {
        return new GsonBuilder().serializeNulls().create().toJson(this);
    }
}
```

虽说是可行，但明显有太多了模板代码可以消除了。

## 利用 lombok

其实这个方法我都是在 lombok 相关的帖子下看到的，考虑到目前 lombok 并没有提供类似`@ToJson`这种注解，那么可以利用它的`ExtensionMethod`来实现。

首先创建一个扩展方法集

```java
package fun.happyhacker.json;

import com.google.gson.GsonBuilder;

import java.io.Serializable;

public class Extensions {
    public static <T extends Serializable> String toJson(T t) {
        return new GsonBuilder().serializeNulls().create().toJson(t);
    }
}
```

这里面我加了一点小的限制，让POJO 类必须要可以序列化才能使用`toJson()`方法。

然后在**需要调用 `toJson()` 方法的所在的类上加上 @ExtensionMethod 注解**

```java
package fun.happyhacker.json;

import lombok.experimental.ExtensionMethod;

@ExtensionMethod({Extensions.class})
public class JsonTest {
    public static void main(String[] args) {
        Employee employee = new Employee();
        employee.setAge(10);
        employee.setId(1);
        employee.setName("John");

        System.out.println(employee.toJson());
    }
}
```

这时你会发现 IDEA 识别不了这个`toJson()`方法，但没关系，它是可以正常执行的，这是 IDEA 的 lombok 扩展不支持而已。在这一点上 Eclipse 已经领先了，虽然在其他所有方面 Eclipse 都是惨遭碾压。

简单讲就是 lombok 在编译期把`employee.toJson()`这个方法改写成了`new GsonBuilder().serializeNulls().create().toJson(employee)`，这也解释了为什么`Extensions`中的方法需要是静态的。

## 总结

虽说是解决了一部分问题，但我觉得这个问题解决的不够优雅，按我们正常的思维，这个注解是应该加到`Employee`这个类上的，而不是加到调用它的类上。所以就很尴尬了。~~不知道能不能参与到 lombok 官方项目中，给它加上这个功能。~~

经过简单的搜索发现这个问题已经被讨论过无数遍了，核心问题是核心开发者认为这个和项目设计之初的目标不符合（我觉得这点站不住脚），他们拿`toString()`来做比较，说本来每个类也都有`toString`，只是没有实现，但几乎没有类存在`toJson`这个方法。其实本质上还是因为实现起来太复杂了，没有一个轻量级、高性能的 JSON 序列化库可以用，虽然 Jackson 和 Gson 都可以达成目的，但他们认为都太重了。

所以这已经不是技术问题了，而是哲学问题。可能这些“库”作者压根不能理解我们应用开发者的痛点吧。
