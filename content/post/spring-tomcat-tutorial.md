---
title: "Springboot使用内置和独立tomcat以及其他思考"
date: 2020-03-28T12:56:22+08:00
description: "springboot with or without tomcat in action"
tags: ["springboot", "tomcat", "java", "in-action"]
draft: false
categories: ["tech"]
---

本文探讨了Springboot应用使用jar包和war包的区别，以及使用中的一些思考。我刚开始研究Java，一些想法可能不准确，欢迎提出宝贵意见。

<!--more-->

在开发中我们会使用嵌入式的tomcat容器，~~但实际项目部署中一般不会这么做~~，事实证明大部分都是这么用的，独立的tomcat部署已经被淘汰了。下面在macOS环境下操作以下步骤：

由于实验用的黑苹果不支持docker，以下所有操作需要的应用均使用macOS下的homebrew安装。

## 创建一个简单的Springboot Web应用

使用Spring Initializr创建一个基础的Springboot应用，只选择Web组件。

![image-20200321233213671](/images/image-20200321233213671.png)

![image-20200321233443126](/images/image-20200321233443126.png)

![image-20200321233515184](/images/image-20200321233515184.png)

![image-20200321233707966](/images/image-20200321233707966.png)

以上就是一个最简单的Springboot应用了。

## 在嵌入式tomcat容器中运行Web应用

![image-20200321233903263](/images/image-20200321233903263.png)

可以看到，这个应用已经可以在嵌入式tomcat容器中运行了。注意，这里访问的路径是`http://localhost:8080/v1/hello/world`。

## 打包编写完成的war包

![image-20200321234037615](/images/image-20200321234037615.png)

在Idea中执行`mvn pacakge`，然后在`target`目录中检查生成的war包。

![image-20200321234123292](/images/image-20200321234123292.png)

## 将war包部署到独立的tomcat服务中

这时候就可以关闭Idea中运行的嵌入式tomcat容器了，因为启动独立tomcat服务时默认端口也是8080，会有冲突导致无法启动。

![image-20200321234307345](/images/image-20200321234307345.png)

可以执行`brew services start tomcat`来启动web容器。这里为了观察服务的输出，使用前台运行的方式`catalina run`。

![image-20200321234526625](/images/image-20200321234526625.png)

可以看到tomcat服务已经成功启动，并监听了8080端口。

## 访问独立tomcat服务中的应用

将前面`target`目录中的war包部署到tomcat的webapps目录中。

![image-20200321234837614](/images/image-20200321234837614.png)

![image-20200321234811148](/images/image-20200321234811148.png)

可以看到，服务启动后，直接将war包复制到tomcat的工作目录中，服务就会检测到新war包的加入，并自动运行相应的服务。

这时如果我们还像刚才那样访问`http://localhost:8080/v1/hello/world`会怎样呢？

![image-20200321235028410](/images/image-20200321235028410.png)

可以看到，是不存在这个路径的。

问题出在哪儿呢？我们看一下webapps目录下都有哪些东西。

![image-20200321235109562](/images/image-20200321235109562.png)

可以看到，我们是把应用部署在了web容器中，但web容器中却是有多个应用的，所以，访问应用时需要带上应用的名字。那名字是什么呢？当然就是`spring-in-tomcat-0.0.1-SNAPSHOT`，试一下

![image-20200321235306362](/images/image-20200321235306362.png)

果然可以了。

## 访问应用的不同版本

刚才是应用从不存在到存在，tomcat可以自动检测。我们再测试一下是否可以检测文件的变更。

![image-20200321235604989](/images/image-20200321235604989.png)

这里做了一个微小的变化。

![image-20200321235643172](/images/image-20200321235643172.png)

复制完成之后tomcat马上就检测到了文件的更新。

![image-20200321235735659](/images/image-20200321235735659.png)

可以看到，应用更新也**无感**的完成了。

## 是否真的是无感？

在war包替换期间发生了什么？服务有没有中断呢？再做一个测试

![image-20200322001133216](/images/image-20200322001133216.png)

首先启动30秒的并发请求，然后将重新编辑并打包的war包重新部署，结果发现有大量的非200的返回值。这就证明了并不是“软重启”，而是存在服务中断。那怎么证明不是wrk发起的请求太多，从而导致的服务繁忙呢？在正常情况下再跑一次测试就行了。

![image-20200322001417574](/images/image-20200322001417574.png)

所以，重新部署服务导致服务中断的结论无误。

从这个结论萌生了另外一个想法，这个访问的路径是带版本号的，这里是`0.0.1-SNAPSHOT`，那如果我直接加一个`0.0.2-SNAPSHOT`的版本进来，不就两个都能访问了？然后配合Nginx的反向代理和负载均衡，步进式的切流量，也就同时实现了灰度发布。

![image-20200322002053556](/images/image-20200322002053556.png)

## 在tomcat前部署nginx反向代理

![image-20200322003925168](/images/image-20200322003925168.png)

添加一个如图的配置文件，这时就可以通过nginx访问spring的服务了。不出意外的话，改变nginx的配置并重新reload nginx的过程，服务是不会中断的。

![image-20200322010427797](/images/image-20200322010427797.png)

多次实验结果表明，在并发请求期间reload nginx的server配置，对服务可用性的影响非常小。

关于Nginx的负载均衡相关内容这里不再过多涉及。

## 总结

1. tomcat会自动加载新加入的war包
2. tomcat更新同名的新war包时服务会中断
3. 可以利用tomcat可同时运行多个war包的特性提供不同版本的服务
4. 可以利用Nginx反向代理实现服务不中断
5. 可以利用Nginx的负载均衡实现灰度发布

