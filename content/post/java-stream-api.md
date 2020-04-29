---
title: "Java Stream Api"
date: 2020-04-29T23:23:57+08:00
tags: ["java", "basics"]
categories: ["theory"]
---
Java的stream api真是功能强大，但写的时候总是忘，这里简单记录以下。

<!--more-->

## `map`和`flatMap`

这两个真是最容易搞混的，不过如果要搞清楚他们的区别也很简单：`map`就是一个转换，把原来是a的转换成b，原来是`List<String>`，`map`之后还是`List<String>`（其实是stream，是类型没有变），而`flatMap`会生成一个新的stream把原先的多个stream合并在一起。举例说明下

```java
// 例1
List<String> lower = Arrays.asList("a", "b", "c", "d");
List<String> upper = lower.stream().map(String::toUpperCase).collect(Collectors.toList());
System.out.println(lower);
System.out.println(upper);
```

从这个例子可以看出，通过`map`，让这个`List<String>`中的每个元素都执行了`e.toUpperCase()`方法，输出的结果就是
```
[a, b, c, d]
[A, B, C, D]
```

下面看`flatMap`可以实现什么功能
```java
// 例2
List<List<String>> packed = new ArrayList<>();
packed.add(lower);
packed.add(upper);
System.out.println(packed);

List<String> flat = packed.stream().flatMap(s -> s.stream()).map(String::toUpperCase).collect(Collectors.toList());
System.out.println(flat);
```

这里必须要注意一点，`map()`的输出是stream中的一级元素，像例1中的`String::toUpperCase`显然是输入`a`，输出`A`。而对于`flatMap`而言，它的输入是一个Collection，而输出是一个stream，那怎么形成一个stream呢，像例2中的`packed`，它就是由两个`List<String>`组成的，对他们调用`stream()`方法就让它返回一个stream到`flatMap`的输出了。

举个不太恰当的例子，这里有3包牛奶，`map`方法只能把3包牛奶倒到3个杯子里，而`flatMap`可以把它们倒到1个杯子里。如何实现呢？当然就是在`flatMap`中把每个牛奶的袋子撕开，然后倒出来。

例2的输出如下
```
[[a, b, c, d], [A, B, C, D]]
[A, B, C, D, A, B, C, D]
```

理解到了这一步，基本上就搞清楚了二者的区别了，总之就是记住**一定要让`flatMap()`输出一个stream**。

## Map的stream()

`List`输出到stream的方法很容易理解，因为它本身就是一个一个的元素，但Map是分了key和value的，要怎么才能把它转换成stream呢？答案是`Map.Entry`。可能第一门语言就是Java的同学觉得很理所应当，但熟悉PHP的同学再来理解这个概念就有点对应不上了（因为PHP里基本上不区分`List`和`Map`，一切皆为数组）。先看一个PHP的例子

```php
$a = [
    'a' => 'b',
    'c' => 'd',
];

foreach ($a as $key => $value) {
    echo $key . '=>' . $value, "\n";
}
```

在这个例子中`$key`和`$value`的组合就是Java中`Map.Entry`的概念了，只不过继续遵循**封闭**的原则，给二者都配备了对应的方法`getKey()`和`getValue()`，也就是说，可以从一个`Map`的`Entry`中同时获取当前这个元素的key和value。那么问题又来了，怎么拿到它的`Entry`呢？通过`entrySet()`方法。

对一个`Map`调用`entrySet()`方法，相当于新建了一个`List`，它的元素是这个`Map`的`Entry`，这就又回到了`List`，当然也就可以用stream api了。比如要把一个`Map`的key和value倒过来（PHP的`array_flip`方法）

```java
Map<String, String> g = new HashMap<>();
g.put("k1", "v1");
g.put("k2", "v2");
g.put("k3", "v3");
g.put("k4", "v4");
g.put("k5", "v5");

val h = g.entrySet().stream().collect(Collectors.toMap(Map.Entry::getValue, Map.Entry::getKey));
System.out.println(g);
System.out.println(h);
```
结果如下
```
{k1=v1, k2=v2, k3=v3, k4=v4, k5=v5}
{v1=k1, v2=k2, v3=k3, v4=k4, v5=k5}
```
> 注意这个方法可能会有异常，因为如果原始输入中不同的key对应了相同的value，就无法生成新map了
> ```
> Exception in thread "main" java.lang.IllegalStateException: Duplicate key v3 (attempted merging values k3 and k4)
>	at java.base/java.util.stream.Collectors.duplicateKeyException(Collectors.java:133)
>	at java.base/java.util.stream.Collectors.lambda$uniqKeysMapAccumulator$1(Collectors.java:180)
>	at java.base/java.util.stream.ReduceOps$3ReducingSink.accept(ReduceOps.java:169)
>	at java.base/java.util.HashMap$EntrySpliterator.forEachRemaining(HashMap.java:1746)
>	at java.base/java.util.stream.AbstractPipeline.copyInto(AbstractPipeline.java:484)
>	at java.base/java.util.stream.AbstractPipeline.wrapAndCopyInto(AbstractPipeline.java:474)
>	at java.base/java.util.stream.ReduceOps$ReduceOp.evaluateSequential(ReduceOps.java:913)
>	at java.base/java.util.stream.AbstractPipeline.evaluate(AbstractPipeline.java:234)
>	at java.base/java.util.stream.ReferencePipeline.collect(ReferencePipeline.java:578)
>	at fun.happyhacker.java.stream.MapDemo.main(MapDemo.java:56)
>

`Map`还有一个方法，可以把它的所有key输出到一个`List`，PHPer肯定又想到了`array_keys()`，没错，就是`keySet()`

## collect

很多时候前面的一堆操作都是要把结果收集起来，这个话题太大了，`collect`的方式多种多样，这里也说不完，简单说几个最常用的。

### `collect(Collectors.toList())`

这是最简单的，把一个stream中的所有元素按前面的输出收集到一个`List`中。而这个`List`的类型，当然就取决于这个stream中的元素了，参考例1的代码即可。

### `collect(Collectors.toMap())`

这个就相对复杂一点了，既然把结果收集成`map`，那就肯定得设置`key`和`value`，比如我们要把一个小写字母的列表和它对应的大写字母分别对应起来，

```java
// 例3
List<String> lower = Arrays.asList("a", "b", "c", "d");
val f = lower.stream().collect(Collectors.toMap(e -> e, String::toUpperCase));
System.out.println(f);
```
输出如下
```
{a=A, b=B, c=C, d=D}
```