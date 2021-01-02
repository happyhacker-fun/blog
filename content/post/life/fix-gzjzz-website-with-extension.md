---
title: "通过Chrome扩展修复北京工作居住证网站"
date: 2021-01-02T12:37:30+08:00
tags: ["政务", "工作居住证"]
categories: ["life"]
---

工作居住证这个网站不知道是什么时候开发的了，现在用新款的浏览器打开会有各种样式错乱、功能报错，不过这都难不倒我们伟大的人民！

<!--more-->

## 问题一：macOS电脑无法登陆网站

### 解决方案
访问 `http://219.232.200.39/uamsso/SSOSecService?sid=e10adc3949ba59abbe56e057f20f883e&LinkType=online&LinkID=666` 这个地址打开一个可以输入用户名、密码和验证码的页面，虽然页面样式也是错乱的，但不影响。

![](/images/2021-01-02-12-59-34.png)

输入正确的信息之后会跳转到另一个页面，不用管它，再次访问上面的这个链接，就能找到系统的入口了。

到这一步你就能正常填写信息，等待工作居住证审批完成了。现在（2021年1月）已经没有纸质的工作居住证了，办事儿需要自己打印确认单。
![](/images/2021-01-02-13-02-41.png)
这里的功能没有问题，跳过。

## 问题二：无法切换标签页

有时候办事儿还需要提供工作居住证的审批流程，也就是
![](/images/2021-01-02-13-03-20.png)

比如要给孩子办入学手续，就需要有孩子的随往证明，这就需要点击这里
![](/images/2021-01-02-13-04-41.png)

但点击了之后发现页面报错了，查找原因其实是在页面上的js里面有这样一段，有语法错误，导致后面的js无法执行了。我入行晚，也不知道这种写法在以前可不可行，或者在IE浏览器里可以的？

![](/images/2021-01-02-13-06-22.png)

这相当于是要重写系统函数了，反正在Chrome里是无法执行的。

找到了问题的根源就好解决了。

解决方案：

### 方案一
最简单的办法就是把这行错误代码后面的函数定义直接复制到console里面执行一下就好了。

```javascript
function changeSub(flag) {
	if (flag == "education") {
		document.getElementById("education").style.display = "";
		document.getElementById("unit").style.display = "none";
		document.getElementById("achievement").style.display = "none";
		document.getElementById("follows").style.display = "none";
	} else if (flag == "unit") {
		document.getElementById("education").style.display = "none";
		document.getElementById("unit").style.display = "";
		document.getElementById("achievement").style.display = "none";
		document.getElementById("follows").style.display = "none";
	} else if (flag == "achievement") {
		document.getElementById("education").style.display = "none";
		document.getElementById("unit").style.display = "none";
		document.getElementById("achievement").style.display = "";
		document.getElementById("follows").style.display = "none";
	} else if (flag == "follows") {
		document.getElementById("education").style.display = "none";
		document.getElementById("unit").style.display = "none";
		document.getElementById("achievement").style.display = "none";
		document.getElementById("follows").style.display = "";
	}
}

function toMod() {
	window.location = "/yjrc/person/ApplyCardAction.do?formAction=cApply";
}

function back() {
	window.location = "/yjrc/person/ApplyListAction.do?formAction=in&opType=cApply";
}

function queryEdu(id) {
	var goUrl = "/yjrc/person/QueryEduResumAction.do?formAction=in&applyId=" + id;
	window.open(goUrl, 'querywindow', 'width=1030,height=420,top=10,left=10,status=yes,menubar=no,resizable=yes,scrollbars=yes');
}

function queryWork(id) {
	var goUrl = "/yjrc/person/QueryWorkResumAction.do?formAction=in&applyId=" + id;
	window.open(goUrl, 'querywindow', 'width=1030,height=420,top=10,left=10,status=yes,menubar=no,resizable=yes,scrollbars=yes');
}
```
但为了刷新页面之后还能用，还是得把代码“注入”到页面上，这也是方案二要做的。
### 方案二

之前简单了解了Chrome浏览器的扩展开发原理，其实现在面临的这个问题用扩展就很好解决了，在页面加载完成后往页面上写一个`<script>`标签，把那些因为语法错误而中断执行的代码粘贴进去。

只是我上次写的是个非常简单的扩展，只用到了`content_scripts`，这个限制就是**js可以访问页面DOM元素，但DOM元素无法访问js中定义的函数，也无法在js中定义listener**。而前面那些没有执行的代码恰好就是事件的回调函数。所以，整个扩展的目录结构就是这样的：

![](/images/2021-01-02-13-14-02.png)

其中`content-script.js`负责在页面上写入`<script>`标签，并把`extension.js`注入进去，后者里面就是那些需要添加的函数。

如果你选择了方案二，可以继续往下读，如果你选择了方案一，那么你的问题已经解决了。

## 安装扩展

1. 把代码从github上下载下来，找到其中的`chrome-extension`目录
2. 浏览器找到扩展管理页面
![](/images/2021-01-02-13-39-12.png)
3. 点击 **Load Unpacked**，选择上面提到的`chrome-extension`目录
4. 结束

## 总结

我也不知道对于普通用户来说是复制一段js代码更容易还是安装一个浏览器扩展更容易，整个过程也不复杂，参考了网上的一些信息，这里把扩展和源码都贴到github上了。

[https://github.com/lovelock/gzjzz-website-fixer](https://github.com/lovelock/gzjzz-website-fixer)

> 我没有注册过Chrome WebStore的开发者权限，所以打出来的`.crx`包也是不能直接安装的，需要通过目录安装。
