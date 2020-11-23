---
title: "Java日志演化梳理"
date: 2020-11-21T15:21:05+08:00
tags: ["java", "log", "log4j", "logback", "log4j2", "slf4j"]
categories: ["java"]
---

Java日志真是一个过于复杂的问题了，花了大量的时间在这个本不应该花时间的地方。

<!--more-->

## 开篇

据说上古时期Java标准库内并没有日志类，所以社区就搞出来了log4j，后来Apache想着把log4j合并到JDK中去，但这Java官方肯定不想让别人制定标准而自己做别人标准的遵守者，所以就搞了`java.util.logging`，后来就越发混乱了，Apache就又搞了个Commons Logging，这应该就是最早的“日志门面”了，它和后来的slf4j解决的问题是一样的。

想象一下这个场景，你的项目依赖了两个包，其中一个依赖log4j，另外一个依赖jul，但很显然你是想把项目中所有日志放在一起管理的，如果没有一个统一的框架去管理，是很难维护一个大型项目的。

## 问题初现

那么问题来了，历史原因，别人的包就是不想换日志框架，那不能改变别人就只能改变自己了，所以我们有2个选择：
1. 把这两个实现选一个作为真正的实现，通过某种方式将另一个日志框架的调用转发到这个真正的实现上
2. 这两个我谁都不用，我要用第三个，所有第三方的库写的日志都转发到我自己用的这个日志框架上

这就是所谓的bridge了，具体来说如下
```java
package fun.happyhacker;

import java.util.logging.Logger;

public class JULTest {
    private static final Logger LOG = Logger.getLogger(JULTest.class.getCanonicalName());
    public static void main(String[] args) {
        log();
    }

    public static void log() {
        LOG.info("hello log from JUL");
    }
}
```

![](/images/2020-11-21-16-05-19.png)

```java
package fun.happyhacker;

import org.apache.log4j.Logger;

public class Log4jTest {
    private static final Logger LOG = Logger.getLogger(Log4jTest.class);

    public static void main(String[] args) {
        log();
    }

    public static void log() {
        LOG.info("hello log from log4j");
    }
}
```
![](/images/2020-11-21-15-40-36.png)

## 神奇的桥接

据说jul的性能比较差，我不想用，那么就需要把所有对它的调用转发到log4j上，但实际上没有所谓的`jul-to-log4j` ，但我们可以用`jul-to-slf4j`，然后再把`slf4j`的实现绑定到`log4j`，问题开始变得复杂了。简单画一下

![](/images/2020-11-21-15-50-59.png)

就现在的例子来说，加上
```xml
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
            <version>1.7.30</version>
        </dependency>
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>jul-to-slf4j</artifactId>
            <version>1.7.30</version>
        </dependency>
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-log4j12</artifactId>
            <version>1.7.30</version>
        </dependency>
```
这些依赖再执行`JULTest`类，发现还是一样的结果。。。。这是怎么回事儿呢。。。原来它不能自动桥接，还需要做一些改动。这里我们是将`JULTest`作为依赖使用的，也就是假设我们不能改变它的源码，所以只能改我们自己的应用。我们的应用原本是这样的
```java
package fun.happyhacker;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class App {
    private static final Logger LOG = LoggerFactory.getLogger(App.class);

    public static void main(String[] args) {
        JULTest.log();
    }
}
```
执行的结果如下
![](/images/2020-11-21-16-08-44.png)

还需要改成这样

```java
package fun.happyhacker;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.bridge.SLF4JBridgeHandler;

import java.util.logging.LogManager;

public class App {
    private static final Logger LOG = LoggerFactory.getLogger(App.class);
    static {
        LogManager.getLogManager().reset();
        SLF4JBridgeHandler.install();
    }

    public static void main(String[] args) {
        JULTest.log();
    }
}
```
![](/images/2020-11-21-16-11-14.png)

官方文档专门强调了一点，jul到slf4j是有很大的性能损失的（本来jul的性能就差，这么一搞就更差了）因为其他的日志框架到slf4j的桥接都是通过重新实现相应的接口来完成的，但因为双亲委派机制的限制，我们是无法重新实现`java.util.logging`中的接口的，所以实际它是把jul中的`LogRecord`替换成了slf4j中的等价对象，这层转换在日志这个本不应该消耗太多资源的场景下就消耗了太多的资源。

好消息是并没有太多的应用使用jul。所以啊，即便你是官方的实现，也不一定那么受欢迎。

### 延伸

多数情况可能是要用`log4j-over-slf4j`来将对log4j的直接调用转调到slf4j-api上，然后再通过其他的日志框架，比如logback来写日志。这里可以简单的追踪以下调用过程。

```java
package fun.happyhacker;

import org.apache.log4j.Logger;

public class Log4jTest {
    private static final Logger LOG = Logger.getLogger(Log4jTest.class);

    public static void main(String[] args) {
        LOG.info("hello from log4j");
    }
}
```

配合相应的log4j.properties就能有相应的输出。那么如果我不想改这块代码，而想让它直接通过logback输出，就需要引入另外两个依赖
```xml
    <dependency>
      <groupId>ch.qos.logback</groupId>
      <artifactId>logback-classic</artifactId>
      <version>1.2.3</version>
    </dependency>
    <dependency>
      <groupId>org.slf4j</groupId>
      <artifactId>log4j-over-slf4j</artifactId>
      <version>1.7.25</version>
    </dependency>
```
这时在上述代码的第9行打个断点进入debug模式，走到第一步`Category.java`，就会发现上面会有一个提示，如图所示
![](/images/2020-11-23-22-20-22.png)

但当你真的选了第二个源码文件的时候它又会有另一个提示
![](/images/2020-11-23-22-20-55.png)

这说明它在执行的时候还是用的log4j包中的class文件，而不是log4j-over-slf4j。这时候把依赖中的log4j去掉（实际项目中应该是exclude掉）。再次执行就会发现没有这个提示了，取而代之的是代码的调用直接进入了log4j-over-slf4j中的，打开这个包的源码你就会发现它的包结构和log4j是一致的
![](/images/2020-11-23-22-25-14.png)

所以其实就是用log4j-over-slf4j中的类“偷偷”的替换了log4j中的类，其实已经变成了基于slf4j中的实现。



## 更实际的情况

上面讲述的这种情况很少见，但更常见的是什么呢？其中一个就是[配置Spymemcached的日志级别](/post/java/set-log-level-of-spymemcached)。更复杂的场景在下面。

SpringBoot可能是现在最常见的应用类型了，我们知道它默认的日志框架是logback。 而我这里还有一个基于Flink的应用，二者要复用一部分代码，也就是说需要在Flink应用里创建一个Spring容器。Spring用的是logback，Flink用的是log4j，又需要在二者中选择一个了。

但这个问题其实又没有那么复杂，因为他们其实都是通过slf4j写日志的，也就是说我们没有`log4j-to-slf4j`或者`logback-to-slf4j`这种转换，而只需要选择一个实现即可。

正常使用logback的应用会引入`logback-classic`包，它提供了`slf4j-api`和`log4j-over-slf4j`等依赖，所以当`logback-classic`和`slf4j-log4j12`同时存在时就会出现下面的报错
![](/images/2020-11-21-16-34-57.png)

也就是说现在classpath中存在了两个`LoggerFactoryBinder`的实现，我们要做的就是把它们中的屏蔽一个。比如如果你不想用logback，只需要在spring相关依赖中添加
```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
            <version>2.3.1.RELEASE</version>
            <exclusions>
                <exclusion>
                    <groupId>ch.qos.logback</groupId>
                    <artifactId>logback-classic</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
```

相应的，如果要用logback而不是log4j，就把`slf4j-log4j12`排除即可。

## 一点提示

前面我们说到了，如果想把直接调用log4j的请求转发到slf4j-api上，再根据实际情况决定最终底层用哪个日志框架。而slf4j-log4j12就是那个决定让slf4j使用log4j写日志的包，那么如果这两个包同时出现又会怎么样呢？

![](/images/2020-11-21-16-50-17.png)

```xml
    <dependencies>
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-log4j12</artifactId>
            <version>1.7.30</version>
        </dependency>
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>log4j-over-slf4j</artifactId>
            <version>1.7.30</version>
        </dependency>
    </dependencies>
```

再执行`App`，就会像下面这样崩溃了
![](/images/2020-11-21-16-52-24.png)

简单说就是出现了死循环，要出现栈溢出错误了。道理很简单，这里不再赘述了。

## 总结

这篇基本就把Java日志里出现的几种情况解释清楚了。下面会开一篇具体说说这几种日志框架各自的配置方式。