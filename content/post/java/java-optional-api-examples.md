---
title: "Java Optional Api Examples"
date: 2020-12-23T22:27:03+08:00
tags: []
draft: true
categories: []
---

自从知道了`Optional`的用法，我现在基本上能不用`if/else`就不用了，但现在发现这东西还是有一些局限性。

<!--more-->

## 例子使用的两个类
```java
package fun.happyhacker.optional;

public class Person {
    private int age;
    private String name;

    private Book book;

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Book getBook() {
        return book;
    }

    public void setBook(Book book) {
        this.book = book;
    }
}
```
```java
package fun.happyhacker.optional;

public class Book {
    private String author;

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getIsbn() {
        return isbn;
    }

    public void setIsbn(String isbn) {
        this.isbn = isbn;
    }

    private String isbn;
}
```
## 正常的使用场景

```java
Person person = new Person();
person.setAge(20);
person.setName("Frost");

Book book = Optional.ofNullable(person.getBook()).orElse(new Book());
System.out.println(Optional.ofNullable(book.getAuthor()).orElse("anonymous"));
```

很明显这会输出`anonymous`，但也很明显它的适用场景太局限。

## 不能支持的场景

在上面的例子中，我需要调用两次`Optional.ofNullable`方法才能完成最终的判断，那如果我想这么用呢？

```java
Person person = new Person();
person.setAge(20);
person.setName("Frost");
String author = Optional.ofNullable(person.getBook().getAuthor()).orElse("anonymous");
System.out.println(author);
```

这时就会报错了

```
Exception in thread "main" java.lang.NullPointerException
	at fun.happyhacker.optional.OptionalTest.main(OptionalTest.java:15)
```
也就是说`Optional.ofNullable`的参数中的空值还是不能调别的方法，如果调了还是会抛出异常。
如果只能这么用真就没什么意思了。

查看源码发现也就真的这样了
![](/images/2020-12-23-22-37-56.png)

调用顺序就是1、2、3，其中没有对任何可能发生的NPE做捕获。