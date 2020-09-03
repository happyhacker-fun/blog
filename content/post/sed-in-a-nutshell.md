---
title: "Sed简单用法"
date: 2020-08-01T16:38:23+08:00
tags: ["sed","linux"]
categories: ["in-action"]
---

有时候需要批量处理一些文件，又不方便打开文件，所以`sed`还是很有用的。简单记录一下常用的使用方法。
<!--more-->

**本文介绍的用法仅仅针对GNU/sed，BSD的版本（macOS）会有不同，这里不涉及**


## 简介

先看一下手册的介绍

```
sed [OPTION]... {script-only-if-no-other-script} [input-file]...
```

### 选项

|选项|解释|
---|---
|`-f`|(*f*ile)将sed命令保存到文件来执行|
|`-i`|(*i*n-place)就地修改，默认是将修改后的目标文件内容输出到**标准输出**，而不会对目标文件进行修改|
|`-n`|取消默认输出，在将目标文件的内容输出到标准输出时，只输出处理过的行|
|`-e`|接下一个sed指令，只有在指定多个sed指令时需要用到|

### 编辑命令

|命令|解释
---|---
`a`|(*a*ppend)追加
`c`|(*c*hange)更改匹配行的内容
`i`|(*i*nsert)向匹配行**前**插入内容
`d`|(*d*elete)删除匹配的行
`s`|替换掉匹配的内容
`p`|(*p*rint)打印匹配的行，通常和`-n`选项一起使用
`=`|用来打印被匹配的行的行号
`n`|(*n*ext)读取下一行，遇到n时会跳入下一行
`r`|(*r*ead)将内容读入文件
`w`|(*w*rite)将匹配内容写入文件

## 示例

原始文本
```txt
sponge
bob
square
patrick
star
```

### 追加

#### 在指定行后面追加

```bash
$ sed '3apants' test.txt
sponge
bob
square
pants
patrick
star
```
其中`3`是行号，`a`是追加，后面是要追加的内容
#### 在匹配行后面追加
```bash
$ sed '/square/apants' test.txt
sponge
bob
square
pants
patrick
star
```
其中用`square`来匹配行，第二个`/`后面的`a`表示追加，后面是追加的内容。如果有多个匹配行，则会在每个匹配行后面都追加

#### 在最后一行追加
```bash
$ sed '$abikini bottom' test.txt
sponge
bob
square
patrick
star
bikini bottom
```
`$`表示最后一行，`a`表示追加，后面是追加的内容

### 插入

#### 在指定行插入
```bash
$ sed '4ipants' test.txt
sponge
bob
square
pants
patrick
star
```
表示在第4行前面插入一行

#### 在匹配行前插入
```bash
$ sed '/patrick/ipants' test.txt
sponge
bob
square
pants
patrick
star
```
如果有多个匹配行，则每个匹配行前面都会插入指定的内容
#### 在最后一行前插入
```bash
$ sed '$iis a pink' test.txt
sponge
bob
square
patrick
is a pink
star
```
### 更改
#### 更改指定的行
```bash
$ sed '1c海绵' test.txt
海绵
bob
square
patrick
star
```

#### 更改匹配的行
```bash
$ sed '/sponge/c海绵' test.txt
海绵
bob
square
patrick
star
```

#### 更改最后一行
```bash
$ sed '$c派大星' test.txt
sponge
bob
square
patrick
派大星
```

### 删除

#### 删除指定的一行
```bash
$ sed '3d' test.txt
sponge
bob
patrick
star
```
#### 删除指定范围行号的多行
```bash
$ sed '1,3d' test.txt
patrick
star
```

#### 从第n行开始，每隔m行删除一行
```bash
$ sed '1~3d' test.txt
bob
square
star
```
即从第一行开始，每隔3行删除一行，所以最终是删除了第1行和第4行。如果是`1~2d`这样会更有意义，也就是会删除奇数行，而`2~2d`则会删除所有的偶数行

#### 删除除满足条件的行之外的所有行
```bash
frost@master:~/workspace/sed
$ cat test.txt
sponge
bob
square
patrick
star
frost@master:~/workspace/sed
$ sed '1~3d' test.txt
bob
square
star
frost@master:~/workspace/sed
$ sed '1~3!d' test.txt
sponge
patrick
```
这个比较复杂，把对应的几种情况放在一起看。

#### 删除某范围之外的所有行
```bash
frost@master:~/workspace/sed
$ cat test.txt
sponge
bob
square
patrick
star
frost@master:~/workspace/sed
$ sed '1,2d' test.txt
square
patrick
star
frost@master:~/workspace/sed
$ sed '1,2!d' test.txt
sponge
bob
```
#### 删除匹配的行
```bash
$ sed '/patrick/d' test.txt
sponge
bob
square
star
```

#### 删除匹配行及其后的n行
```bash
$ sed '/square/,+1d' test.txt
sponge
bob
star
```

#### 删除匹配的行之后的所有行
```bash
$ sed '/patrick/,$d' test.txt
sponge
bob
square
```
可以和上面直接指定行号的对比一下，其实`/patrick/`这部分就是为了定位到这一行的行号，假如这行在第2行，那么这就等价于`2,$d`

#### 删除最后一行
```bash
$ sed '$d' test.txt
sponge
bob
square
patrick
```

#### 删除所有的空行
```bash
frost@master:~/workspace/sed
$ cat test.txt
sponge
bob

square
patrick

star
frost@master:~/workspace/sed
$ sed '/^$/d' test.txt
sponge
bob
square
patrick
star
```

#### 删除匹配多种模式的行
```bash
$ sed '/sp\|bob/d' test.txt
square
patrick
star
```

#### 删除除匹配多种模式以外的所有行
```bash
$ sed '/sp\|bob/!d' test.txt
sponge
bob
```

#### 删除指定行范围内满足条件的行

```bash
$ sed '1,4{/e/d}' test.txt
bob
patrick
star
```
删除了从第1行到第4行中包含`e`的行

### 替换指定字符

终于到了用的最多的场景了。

#### 替换匹配的字符

```bash
frost@master:~/workspace/sed
$ cat test.txt
sponge
bob bob bob
square
patrick
star
frost@master:~/workspace/sed
$ sed 's/bob/宝宝/' test.txt
sponge
宝宝 bob bob
square
patrick
star
```
默认只替换第一个，如果要替换匹配行中所有满足条件的字符，需要加上`g`选项（*g*lobal)

#### 修改匹配行中第n个匹配的字符

```bash
$ sed 's/bob/宝宝/2' test.txt
sponge
bob 宝宝 bob
square
patrick
star
```
替换了该行第2个匹配的字符

#### 全局替换匹配的字符

```bash
frost@master:~/workspace/sed
$ cat test.txt
sponge
bob bob bob
square
patrick
star
frost@master:~/workspace/sed
$ sed 's/bob/宝宝/g' test.txt
sponge
宝宝 宝宝 宝宝
square
patrick
star
```

#### 将修改后的内容输出到文件

```bash
$ sed 's/bob/宝宝/gw 2.txt' test.txt
sponge
宝宝 宝宝 宝宝
square
patrick
star
frost@master:~/workspace/sed
$ cat 2.txt
宝宝 宝宝 宝宝
```

#### 将每行`//`后的内容删除
```bash
frost@master:~/workspace/sed
$ cat a.php
<?php

$a = 20; //这是一个行内注释
frost@master:~/workspace/sed
$ sed 's#//.*##g' a.php
<?php

$a = 20;
```
这是全文里找到符合条件的，还可以指定符合某个前置条件的才执行

#### 符合前置条件的行中，将`//`后面的内容删除

```bash
frost@master:~/workspace/sed
$ cat a.php
<?php

$a = 20; //这是一个行内注释
define('I_AM_A_CONST', 20); // 这是一个常量
frost@master:~/workspace/sed
$ sed '/\$/s/\/\/.*//g' a.php
<?php

$a = 20;
define('I_AM_A_CONST', 20); // 这是一个常量
```

这个例子把有变量定义的行内注释给删除了

#### 替换匹配行倒数n个字符
```bash
frost@master:~/workspace/sed
$ sed 's/..$//g' a.php
<?p

$a = 20; //这是一个行内注�
define('I_AM_A_CONST', 20); // 这是一个常�
frost@master:~/workspace/sed
$ sed 's/....$//g' a.php
<

$a = 20; //这是一个行内�
define('I_AM_A_CONST', 20); // 这是一个�
frost@master:~/workspace/sed
$ sed 's/...$//g' a.php
<?

$a = 20; //这是一个行内注
define('I_AM_A_CONST', 20); // 这是一个常
```
最终目的是达成了，但是要注意一个汉字其实是占了3个字符。

#### 将匹配的行替换为空行

```bash
frost@master:~/workspace/sed
$ cat a.php
<?php

$a = 20; //这是一个行内注释
define('I_AM_A_CONST', 20); // 这是一个常量
# 这是一个不符合规范的注释
frost@master:~/workspace/sed
$ sed 's/^#.*//g' a.php
<?php

$a = 20; //这是一个行内注释
define('I_AM_A_CONST', 20); // 这是一个常量

frost@master:~/workspace/sed
$ sed '/^#/d' a.php
<?php

$a = 20; //这是一个行内注释
define('I_AM_A_CONST', 20); // 这是一个常量
frost@master:~/workspace/sed
```
这里有意和前面讲过的`d`命令做一个比较，可以看到`s`命令做的是替换，将这行的字符替换为空（并没有替换换行符），但这行还在，但`d`是删除整行。

## 总结

上面这些已经能满足大部分的需求了，后面遇到偏门的场景再补充。