---
title: "瑞虎8车机App升级"
date: 2020-12-30T15:18:16+08:00
tags: ["tiggo8"]
categories: ["life"]
---

瑞虎8自豪版车机里的App可以升级。据说是官方正规的方法。

<!--more-->

**声明：我认为中控屏幕车机和行车安全没有关系，是隔离的系统，但行车系统的一些参数可以通过种控屏设置，如果对安全性有担忧，请勿尝试以下操作**

## 准备工作

### 硬件需求
1. 电脑一台
2. U盘一个（需要FAT32格式），用于存放要安装的包

## 操作流程

### 1. 下载安装包
下载最[新版的高德地图](https://auto.amap.com/download)

![](/images/2020-12-30-16-05-13.png)

### 2. 在U盘上建立必要的目录

在U盘上新建`T1AUpdateNavi/App/`目录，将上述下载的安装包放在里面。

### 3. 车机进入工程模式

车机上有一个隐藏按键，在**设置/存储容量**界面的右侧1/4处的下边缘附近，点击听到“滴”声即是点击成功了。在这个位置连续点击10下，进入工程模式。

![](/images/2021-01-01-17-02-23.png)

随后输入密码 **456258**，其实就是一个十字形。

之后会进入这个界面，点击“升级”
![](/images/2021-01-01-17-03-36.png)

再点击“App升级”
![](/images/2021-01-01-17-05-18.png)

就可以进入U盘中刚才创建的目录了。

![](/images/2021-01-01-17-06-27.png)

找到高德地图的安装包，点击勾选，之后点击右上角的“安装所选”即可开始安装。

> 我这里还自动生成了一个以`.`开头的`apk`包，不知道是什么原因，忽略它即可，选择不以`.`开头的文件。

安装完成后选中条目变成绿色，即完成安装。按照提示重启系统就完成了升级。

## 警告

不建议安装其他“原装车机上不存在的应用”，简单来说就是你安装完也无法找到入口，也就没办法使用。亲测。如果你已经安装了无法使用的其他应用，可以使用Android手机安装一个`Remote ADB Shell`软件来卸载，当然理论上不管它也不会有什么问题。

## 总结

升级后的App色彩更鲜艳，功能上实现了和手机的实时互联，手机上“进入导航”后，车机如果在联网状态会自动同步手机上的导航状态，非常方便。推荐升级。