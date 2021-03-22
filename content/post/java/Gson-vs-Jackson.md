---
title: "Gson 和 Jackson 对比"
date: 2021-03-05T15:29:09+08:00
tags: ["gson", "jackson", "json"]
categories: ["in-action"]
---

工作中难免经常会用到这两个库，简单来说Gson的用法比较无脑，而Jackson的则比较绕。这里对比几个比较典型的用法。

<!--more-->

## 0. 准备工作

1. 引入相关依赖

```xml
<dependencies>
    <dependency>
      <groupId>com.google.code.gson</groupId>
      <artifactId>gson</artifactId>
      <version>2.8.6</version>
    </dependency>
    <dependency>
      <groupId>com.fasterxml.jackson.core</groupId>
      <artifactId>jackson-databind</artifactId>
      <version>2.12.1</version>
    </dependency>
    <dependency>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok</artifactId>
      <version>1.18.18</version>
    </dependency>
    <dependency>
      <groupId>org.apache.logging.log4j</groupId>
      <artifactId>log4j-core</artifactId>
      <version>2.14.0</version>
    </dependency>
    <dependency>
      <groupId>com.github.javafaker</groupId>
      <artifactId>javafaker</artifactId>
      <version>1.0.2</version>
    </dependency>
    <dependency>
      <groupId>org.apache.logging.log4j</groupId>
      <artifactId>log4j-api</artifactId>
      <version>2.14.0</version>
    </dependency>
  </dependencies>
```

2. 两个POJO

```java
package fun.happyhacker;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class Person {
    private Integer id;
    private Integer age;
    private String address;
    private String title;
    private Job job;
}
```

```java
package fun.happyhacker;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class Job {
    private String name;
    private String domain;
}
```

3. 启动类

```java
package fun.happyhacker;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.javafaker.Faker;
import com.google.gson.Gson;
import lombok.extern.log4j.Log4j2;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Log4j2
public class App {
    private static final Faker FAKER = Faker.instance();
    private static final Gson GSON = new Gson();
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    public static void main(String[] args) {
    }
}
```

## 1. 将POJO序列化为json




## 2. 将json反序列化为POJO

### 2.1. Jackson 从字符串读取json转成POJO对象

```java
    private static void jacksonJson2Pojo() {
        try {
            JsonNode jsonNode = OBJECT_MAPPER.readTree(JSON_POJO);
            log.info(jsonNode.toPrettyString());

            Person person = OBJECT_MAPPER.readValue(JSON_POJO, Person.class);
            log.info("person {}", person);

            Person person1 = OBJECT_MAPPER.convertValue(jsonNode, Person.class);
            log.info("person {}", person1);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
    }
```

### 2.2. Jackson 从文件读取json内容转成POJO对象

```java
    private static void jacksonReadFromFile() {
        List<Person> personList = new BufferedReader(new InputStreamReader(Objects.requireNonNull(Thread.currentThread().getContextClassLoader().getResourceAsStream("person.data"))))
        .lines()
                .map(e -> {

                    try {
                        return OBJECT_MAPPER.readValue(e, Person.class);
                    } catch (JsonProcessingException jsonProcessingException) {
                        jsonProcessingException.printStackTrace();
                    }

                    return new Person();
                })
                .collect(Collectors.toList());
        log.info("{}", personList);
    }
```

### 2.2. Gson 从字符串读取json转成POJO对象

```java
    private static void gsonJson2Pojo() {
        Person person = GSON.fromJson(PERSON_JSON, Person.class);
        log.info("person {}", person);

        JsonObject jsonObject = JsonParser.parseString(PERSON_JSON).getAsJsonObject();
        log.info("json object {}", jsonObject);
        Person person1 = GSON.fromJson(jsonObject, Person.class);
        log.info("person person1 {}", person1);
    }
```

从文件读取的类似，区别只是在于`map()`中的方法不一样。

> 这里发现了一个小特点，在用Jackson测试的时候，json字符串最后多了一位"}"，Gson会报错，而Jackson不报错，而且结果也是对的。

## 3. 涉及集合的场景

写PHP的时候没有这个意识，写Java多了对这个感受就特别深了。因为在PHP里不管是List还是Map通通都是Array，甚至Object**用起来**也和Array没啥区别，所以对于上面的例子，经常会生成这种json

```json
{
  "1": {
    "id": 1,
    "age": 34,
    "address": "2255 Monahan Mount, Batzton, MS 43857-6615",
    "title": "qpzzi",
    "job": {
      "name": "trkfem",
      "domain": "fwun"
    }
  },
  "2": {
    "id": 2,
    "age": 35,
    "address": "Suite 408 736 Chantel Estate, Port Kathyfurt, CA 72201",
    "title": "itdpt",
    "job": {
      "name": "akuhbv",
      "domain": "ckwz"
    }
  },
  "3": {
    "id": 3,
    "age": 28,
    "address": "87147 Kutch Summit, Andreaport, NV 24529-3219",
    "title": "lmudd",
    "job": {
      "name": "fbjadr",
      "domain": "damu"
    }
  }
}
```

因为这样在取id的时候会方便一些。但在Java中处理这种数据就比较蛋疼了。

### 3.1. 简单的Map

### 3.2. List of Map