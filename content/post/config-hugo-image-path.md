---
title: "配置Hugo的图片路径"
date: 2020-03-28T23:44:36+08:00
description: "让VSCode支持Hugo的图片路径"
tags: ["vscode", "hugo", "markdown"]
categories: ["records"]
---

不得不说Hugo的图片路径支持有些不友好，网上也有很多吐槽。简单说就是即便神级的Markdown编辑器Typora都无法适应Hugo的图片路径。由于Typora需要做日常的工作记录，所以就配置了一下VSCode来支持Hugo。

<!--more-->

## Hugo支持两种放置本地图片的方式

本地图片是相对网络图片而言，如果你有图床也就无所谓是否相对路径了

1. `content`目录下  
    例如图片`content/a.png`，在文章`content/post/a.md`中引用就需要是`![](/../a.png)`
2. `static`目录下  
    例如图片`static/images/a.png`，在文章`content/post/a.md`中引用就需要是`![](/images/a.png)`

> 这里还是想吐槽一下，主要是第一种方式，既然在文章中是这样的写法，其实就已经默认是从【当前文章所在目录】向前查找了，那为什么不能放在当前文章目录下？

## 配置VSCode支持两种方式

我还是比较倾向于内容和图片分离，所以就使用上述的第二种方式，方法确定了其实配置方式差别不大。

### 依赖工具

1. VSCode
2. 扩展Paste Image (作者 mushan）

### 配置步骤

1. 配置图片文件存放路径  

`Paste Image: Path`中配置 `${projectRoot}/static/images/`
![](/images/2020-03-28-23-55-33.png)

2. 配置粘贴到文章中的文本  

`Paste Image: Insert Pattern`中配置 `${imageSyntaxPrefix}/images/${imageFileName}${imageSyntaxSuffix}`

![](/images/2020-03-28-23-58-31.png)

这一点我没有仔细看文档，花费了一些时间。

效果图如下

![](/images/2020-03-29-00-01-58.png)

## 存在的问题

当然这样配置还是解决不了【正常的Markdown】编辑器无法识别图片路径从而导致图片无法渲染的问题。但好在Hugo有一个不错的实时预览功能，弥补了这一点。





