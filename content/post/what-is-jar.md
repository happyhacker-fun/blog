---
title: "聊聊jar包"
date: 2020-05-18T22:18:51+08:00
tags: ["java", "jar"]
categories: ["research"]
---

jar包应该是java应用使用最多的分发形式了，jar包中包含什么东西，怎么创建和执行它呢？

<!--more-->

## jar包是什么

Jar包全称Java Archive File，是以zip格式打包的一个压缩包，和普通的压缩包最本质的区别是——后缀不一样，一个是`.jar`，一个是`.zip`。但区分jar包和其他zip包的本质区别是jar包包含一个`META-INF/MANIFEST.MF`文件，这个清单文件是包含了以下内容

- jar包的版本
- 创建人
- Class-Path类搜索路径
- Main-Class属性（表示Main方法的入口）

### 为什么要用jar包

通常我们写一个HelloWord类之后会做以下操作
```java
// 保存为HelloWorld.java
public class HelloWorld {
	public static void main(String[] args) {
		System.out.println("Hello World!");
	}
}
```
```bash
javac HelloWorld.java # 会生成一个HelloWorld.class文件
java HelloWorld
# output
Hello World!
```
这里`HelloWorld.class`其实才是我们需要的东西，也就是Java所谓的“字节码”，Java的最大卖点**Write Once, Run Anywhere**的特点就来自这里了。需要注意的是，所谓跨平台，并不是指Java（jdk）本身跨平台，而是由jdk编译而来的class文件跨平台。所以也就需要针对不同平台的jdk了。

当我们的应用只有一个文件时当然可以这样发布，但这肯定是不可能的。如果应用有其他的依赖，用这种原始的方式将会很难维护，因此，jar包就应运而生了。

下面简单写一个带有依赖的例子，入口类`App`，小狗类`Dog`。

```java
package entity;

public class Dog {
    private String name;
    private int age;

    public Dog(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public String getName() {
        return name;
    }

    public int getAge() {
        return age;
    }
}
```

```java
import entity.Dog;

public class App {
    public static void main(String[] args) {
        Dog aDog = new Dog("Bailey", 11);
        System.out.println("I am " + aDog.getName() + " and I am " + aDog.getAge() + " years old");
    }
}
```

目录结构如下：
```
.
├── App.java
└── entity
    └── Dog.java
```

如果没有jar包，就需要执行如下命令

```
➜  demo javac App.java entity/Dog.java
➜  demo tree
.
├── App.class
├── App.java
└── entity
    ├── Dog.class
    └── Dog.java

1 directory, 4 files
➜  demo java App                      
I am Bailey and I am 11 years old
```

这时候源码(.java)已经不需要了，删了它们一样可以运行。为了更方便的分发，可以把这些.class文件打包成jar包，并指定运行的入口类

```
➜  demo jar cvfe App.jar App entity/*.class App.class
added manifest
adding: entity/Dog.class(in = 442) (out= 286)(deflated 35%)
adding: App.class(in = 784) (out= 476)(deflated 39%)
➜  demo jar -tf App.jar                              
META-INF/
META-INF/MANIFEST.MF
entity/Dog.class
App.class
```
这时候执行`java -jar App.jar`，输出如下
```
➜  demo java -jar App.jar
I am Bailey and I am 11 years old
```
这时候把这个压缩包发给别人，别人就可以直接这样执行了。

### 添加和修改清单属性

如果第一次打包的时候没有添加MANIFEST文件，jar会自动添加一个`META-INF/MANIFEST.MF`文件，但其中只包含`Manifest-Version`和`Created-By`两个属性，在执行的时候还要在命令行传入入口才可以执行。所以这时如果要给MANIFEST文件添加属性，可以这么做。

1. 创建一个新的清单文件，比如MANIFEST-ADDITION.MF
2. 将需要添加的属性假如新的清单文件
3. 执行`jar ufvm App.jar MANIFEST-ADDITION.MF`

```
Main-Class: App
Author: happyhakcer
```
然后通过vim打开这个jar包就可以看到其中的清单文件已经更新了。

另外，如果是打包前就已经手动写好了完整的清单文件，也可以通过`jar cfvm`的方式直接把清单文件打包进jar包。

需要注意一点，在执行`jar vcfme`这种命令时，`f` `m` `e`这三个选项的顺序也决定了后面传入的参数表示的含义，`f`表示目标文件（jar包的名称），`m`表示清单文件，`e`(entry)则表示入口点。
比如可以是
```
jar vcfme app.jar MANIFEST.MF App App.class entity/*.class
```
> 这里是为了说明问题，如果MANIFEST.MF中已经指定了`Main-Class`属性，则在执行上面的命令时会因为又通过`e`选项指定了入口点而执行失败。

## jar包的官方标准

现在我们已经有了一个标准的jar包了，下面打开它看看这个清单文件中究竟包含了什么信息
```
Manifest-Version: 1.0
Created-By: 1.8.0_252 (AdoptOpenJDK)
Main-Class: App
```
> 由于entity目录位于App.class所在目录的子目录中，所以无需指定`Class-Path`

### jar包的其他标准

本节其实是为了说明标准的jar包和Springboot打包的FAT JAR的区别。

通常一个jar包只包含了**应用代码**（区别于依赖），但Springboot的jar包则动辄几百MB，其实就是因为它把所有的依赖全部都打到jar包里了。一个典型的Springboot应用的jar包的清单文件内容如下
![](/images/2020-05-18-23-25-37.png)
可以看到，下面有波浪线的其实就是标准的清单文件中不包含的部分。而Springboot能从jar包启动，核心就在于`Main-Class`配置。关于`org.springframework.boot.loader.JarLauncher`的原理，详见[Springboot启动](/post/springboot-chapter-01)

## jar包和war包的区别

最本质的区别就是war包是一个典型的web包，所谓典型也就是早年间把接口和页面等其他静态资源打包到一起的包，tomcat就是用来运行war包的。由于现在war包用的不多了，这里不再赘述。


## 总结

本文简单介绍了jar包的结构和一些简单的应用，主要帮助初学者理解一些概念。

