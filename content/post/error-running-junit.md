---
title: "执行单元测试时报错分析及解决"
date: 2020-04-08T00:30:39+08:00
tags: ["junit", "java"]
categories: ["in-action"]
---

Java报错真是多，一不小心单元测试也报错。

<!--more-->

代码是这样的
```java
@SpringBootTest
@Slf4j
@RunWith(SpringJUnit4ClassRunner.class)
public class MyTestClass {

    @Test
    void testShowBatch() {
    }
}
```

执行`mvn test -Dtest=MyTestClass#testShowBatch`报错

```
[INFO] Running MyTestClass
[ERROR] Tests run: 1, Failures: 0, Errors: 1, Skipped: 0, Time elapsed: 0.001 s <<< FAILURE! - in MyTestClass
[ERROR] initializationError  Time elapsed: 0.001 s  <<< ERROR!
org.junit.runners.model.InvalidTestClassError:
Invalid test class 'MyTestClass':
  1. No runnable methods

...
```

事实上这个并不是问题的关键，当时这个问题的原因在于本地代码上传到远端的目录和我执行的目录不在一个地方，所以报错了。。。但总体上在执行单元测试时的用法和下文说的差不多，junit5不需要`@RunWith`注解了。

~~明显是有**runnable methods**的啊，原来是因为`@RunWith(SpringJUnit4ClassRunner.class)`这个注解，它是junit4的用法，加上它，就会查找带有`@org.junit.Test`注解的方法，也就是所谓的**runnable methods**。而我这里的看起来是`@Test`的方法，其实是`@org.junit.jupiter.api.Test`，是junit5的**runnable method**，二者不能兼容，所以就出现了上面的错误。~~

## 总结

在测试Springboot应用时，如果你需要Springboot加载才能执行单元测试代码，可以选择使用junit4或者junit5。

1. 当使用junit4  
   需要的类注解是
    ```java
    @SpringBootTest
    @Slf4j
    @RunWith(SpringJUnit4ClassRunner.class)
    ```

    需要的方法注解是  
    ```java
    @org.junit.Test
    ```

2. 当使用junit5
   需要的类注解是
    ```java
    @SpringBootTest
    @Slf4j
    ```

    需要的方法注解是  
    ```java
    @org.junit.jupiter.api.Test
    ```

    



