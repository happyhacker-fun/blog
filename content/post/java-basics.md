---
title: "Java基础"
date: 2020-04-21T23:28:34+08:00
tags: ["java"]
categories: ["theory"]
---

前段时间写Java一直忙于做工程上的工作，还是得停下来看看理论的东西。

<!--more-->

## 基本类型

类型 | 存储需求 | 取值范围 | 备注
---|---|---|---
`int` | 4 Bytes | $-2^{31}$ ~ $2^{31}-1$
`short` | 2 Bytes | $-2^{15}$ ~ $2^{15}-1$
`long` | 8 Bytes | $-2^{63}$ ~ $2^{63}-1$
`byte` | 1 Byte | $-2^7$ ~ $2^7-1$
`float` | 4 Bytes | 大约 $3.40282347E+38F$（有效位数6～7位）| 只有很少场景可以用到`float`
`double` | 8 Bytes | 大约 $1.79769313486231570E+308$（有效位数15位）| 带小数点的默认是`double`
`char` | - | | `char`描述了UTF-16编码中的一个**代码单元**，尽量不要使用
`boolean` | 1 bit | true 和 false | 

## 位运算

1. `&` and
2. `|` or
3. `^` xor
4. `~` not

以`(n & 0b1000) / 0b1000`为例，如果整数`n`的二进制表示从左到右第4位是1，结果就是1，其余情况则为0。利用`&`并结合适当的2的幂，可以把其他位mask掉，而只留下其中一位。

`>>`和`<<`运算符可以将位模式左移或者右移，需要建立位模式来完成掩码时，这两个运算符很方便。

`1 << 3 == 0b1000 == 8`

`>>>`运算符会用0填充高位，这与`>>`不同，后者用符号填充高位。不存在`<<<`运算符。

## 输入输出

`Scanner`就不多说了，只说比较有意思也最可能出现问题的Console.

```java

package fun.happyhacker.java.basics;

import java.io.Console;
import java.util.Scanner;

public class IO {
    public static void main(String[] args) {
        IO io = new IO();
        io.console();
    }

    private void scanner() {
        Scanner in = new Scanner(System.in);
        System.out.println("What is your name?");
        String name = in.nextLine();

        System.out.println("How old are you?");
        int age = in.nextInt();

        System.out.println("Hello " + name + ", you'll be " + (age + 1) + " next year!");
    }

    private void console() {
        Console console = System.console();
        String username = console.readLine("User name: ");
        char[] password = console.readPassword("Password: ");
        System.out.println(username);
        System.out.println(password);
    }
}
```

然后很开心的执行一下，结果发现报错了

```
Exception in thread "main" java.lang.NullPointerException
	at fun.happyhacker.java.basics.IO.console(IO.java:25)
	at fun.happyhacker.java.basics.IO.main(IO.java:9)

Process finished with exit code 1
```
这个原因是
> "If the virtual machine is started from an interactive command line without redirecting the standard input and output streams then its console will exist and will typically be connected to the keyboard and display from which the virtual machine was launched. If the virtual machine is started automatically, for example by a background job scheduler, then it will typically not have a console."

简单说就是如果它是从命令行直接启动的就没问题，而如果是从一个【后台工作调度器】，其实也就是IDEA的工作线程启动的，就没有console了。所以要执行带有console的应用，就需要`javac App.java && java App`了。

## 数组

`Arrays`和`List`在Java中是不同的数据类型（神奇的是为什么还有一个`ArrayList`）。。。
Array数组表示的是【定长的数组，一旦确定了长度就不能再改变了】，而List列表则表示可以改变长度的列表。
Array的创建方式有很多，如下：

```java
package fun.happyhacker.java.basics;

import java.util.Arrays;

public class Array {
    public static void main(String[] args) {
        // 总之数组就是定长的，要么给定长度，要么给定元素让它自己计算长度
        int[] a = new int[10];
        int n = 100;
        int[] b = new int[n];

        int[] c = {1,2,3,4,};
        int[] d = new int[]{1,2,3,4,};

        // 还有一点需要注意，下面的e和f两个变量会共用同一个数组，所以改变其中一个也会改变另外一个
        int[] e = {1,2,3,4,};
        int[] f = e;
        f[2] = 5;
        System.out.println(Arrays.toString(e));
        System.out.println(Arrays.toString(f));
        // 如果要拷贝数组，则需要用Arrays.copy方法
        int[] g = {1,2,3,4,};
        int[] h = Arrays.copyOf(g, g.length);
        h[2] = 8;
        System.out.println(Arrays.toString(g));
        System.out.println(Arrays.toString(h));

    }
}
```