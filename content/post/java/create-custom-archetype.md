---
title: "创建一个自定义的Archetype"
date: 2020-11-18T23:03:17+08:00
tags: ["maven", "java", "archetype"]
categories: ["in-action"]
---

用默认的archetype太烦了，每次都要改很多东西，不如自己创建一个。

<!--more-->

## 为什么要自己定义archetype

当然是因为懒。我一般是用maven-archetype-quickstart创建项目，但每次创建完之后还要改一通，比如JDK版本号、maven插件等等，这些东西本身其实不应该花太多时间去记的。所以自己定义一个就好了。

## 定义archetype的步骤

### 生成模板

1. 从`maven-archetype-quickstart`创建一个正常的maven项目

这个maven项目是什么不重要，重要的是它会帮你生成一个标准的`pom.xml`文件。

2. 修改`pom.xml`文件

比如你几乎所有的项目都需要依赖`log4j2`这套日志套件，那么你就需要这两个依赖

```xml
<dependencies>
  <dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-api</artifactId>
    <version>2.14.0</version>
  </dependency>
  <dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-core</artifactId>
    <version>2.14.0</version>
  </dependency>
</dependencies>
```
那么你就可以在这个生成的`pom.xml`文件中加上这两个依赖。

3. 执行`mvn archetype:create-from-project`

这会在`target`目录中生成一个新的maven项目，进入这个项目，执行`mvn clean install`，你就把新创建的archetype安装到本地了。

4. 使用新创建的模板

执行`mvn archetype:generate -DarchetypeCatalog=local`，会产生一个交互

```
➜  my-project mvn archetype:generate -DarchetypeCatalog=local
[INFO] Scanning for projects...
[INFO]
[INFO] ---------------------< fun.happyhacker:my-project >---------------------
[INFO] Building my-project 1.0-SNAPSHOT
[INFO] --------------------------------[ jar ]---------------------------------
[INFO]
[INFO] >>> maven-archetype-plugin:3.1.2:generate (default-cli) > generate-sources @ my-project >>>
[INFO]
[INFO] <<< maven-archetype-plugin:3.1.2:generate (default-cli) < generate-sources @ my-project <<<
[INFO]
[INFO]
[INFO] --- maven-archetype-plugin:3.1.2:generate (default-cli) @ my-project ---
[INFO] Generating project in Interactive mode
[INFO] No archetype defined. Using maven-archetype-quickstart (org.apache.maven.archetypes:maven-archetype-quickstart:1.0)
Choose archetype:
1: local -> org.apache.flink:flink-quickstart-java (flink-quickstart-java)
2: local -> org.apache.maven.archetypes:maven-archetype-quickstart (quickstart)
3: local -> fun.happyhacker:my-quickstart-1.8-archetype (my-quickstart-1.8)
4: local -> fun.happyhacker:archetype-template-archetype (archetype-template)
Choose a number or apply filter (format: [groupId:]artifactId, case sensitive contains): 2:
```
这时就可以在其中找到刚刚创建的archetype了，在这里就是第4个，所以在交互界面填4，就可以继续选择域名和项目名称，生成一个新的maven项目，在生成的项目中你就会发现你刚刚在第2步中添加的两个依赖已经包含在里面了。

同样的道理，也可以在`pom.xml`中添加相关的maven插件，以使从模板创建的项目更复合平时的需求。


