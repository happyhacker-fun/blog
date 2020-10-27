---
title: "JVM类加载器"
date: 2020-10-27T22:04:17+08:00
tags: ["Java", "JVM"]
categories: ["in-action"]
---

刚看完《Java高并发编程详解——多线程与架构设计》的第10章，实验一下类似Tomcat的热加载的方法。

<!--more-->

这一章的主要内容如下图

![JVM内置类加载器](/images/JVM内置类加载器.png)

## 背景

讲到基于类的加载和卸载来实现功能热更新时，我就想到了Tomcat可以检测webapps中的war包的变化来重新加载新的应用，所以就通过本章介绍的内容扩展一下，自己实现一个热加载功能。

## 需求

当指定目录下的class文件发生变化时，系统能及时感知并重新加载。

## 实现

1. 指定一个存放class文件的目录，如`/tmp/classloader/`
2. 在其中放一个class文件，如`Child.class`，开始时只有一个`walk()`方法
3. 系统每隔1秒中检测一次该目录中文件是否更新，如果更新了则重新加载
4. 看是否可以通过反射拿到新类的方法列表

## 源码

```java
package fun.happyhacker;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class MyClassLoader extends ClassLoader {
    private static final Path CLASS_DIR = Paths.get("/tmp/classloader/");

    private final Path classDir;

    public MyClassLoader() {
        super();
        this.classDir = CLASS_DIR;
    }

    public MyClassLoader(String classDir) {
        this.classDir = Paths.get(classDir);
    }

    public MyClassLoader(ClassLoader parent) {
        super(parent);
        this.classDir = CLASS_DIR;
    }

    public MyClassLoader(ClassLoader parent, String classDir) {
        super(parent);
        this.classDir = Paths.get(classDir);
    }

    @Override
    protected Class<?> findClass(String name) throws ClassNotFoundException {
        byte[] classBytes = this.readClassBytes(name);
        if (classBytes.length == 0) {
            throw new ClassNotFoundException("Can not load the class " + name);
        }

        return this.defineClass(name, classBytes, 0, classBytes.length);
    }

    private byte[] readClassBytes(String name) throws ClassNotFoundException {
        String classPath = name.replace(".", "/");
        Path classFullPath = classDir.resolve(Paths.get(classPath + ".class"));
        if (!classFullPath.toFile().exists()) {
            throw new ClassNotFoundException("The class " + name + " not found");
        }

        try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
            Files.copy(classFullPath, baos);
            return baos.toByteArray();
        } catch (IOException e) {
            throw new ClassNotFoundException("load the class " + name + " occur error.", e);
        }
    }

    @Override
    public String toString() {
        return "MyClassLoader";
    }
}

```
```java
package fun.happyhacker;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.concurrent.TimeUnit;

public class Daemon {
    private static final String CLASS_PATH = "/tmp/classloader/";

    private static final String CLASS_NAME = "a.b.c.Child";
    private static final int CHECK_INTERVAL = 5;

    private long lastModified;

    private ClassLoader classLoader;
    private Class<?> klass;

    public static void main(String[] args) throws InterruptedException, ClassNotFoundException, NoSuchMethodException, InvocationTargetException, InstantiationException, IllegalAccessException {
        Daemon daemon = new Daemon();
        daemon.listen();
    }

    private void run() throws ClassNotFoundException, IllegalAccessException, InstantiationException, NoSuchMethodException, InvocationTargetException {
        if (classLoader == null) {
            classLoader = new MyClassLoader();
        }
        if (klass == null) {
             klass = classLoader.loadClass(CLASS_NAME);
        }
        Class<?> child = klass;

        System.out.println(child.getClassLoader());

        Object instance = child.newInstance();
        System.out.println(instance);

        Method[] methods = child.getDeclaredMethods();
        for (Method method : methods) {
            Method m = child.getMethod(method.getName());
            m.invoke(instance);
        }
    }

    private void listen() throws InterruptedException, ClassNotFoundException, NoSuchMethodException, InvocationTargetException, InstantiationException, IllegalAccessException {
        while (true) {
            Path classPath = Paths.get(CLASS_PATH);
            Path classFullPath = classPath.resolve(Paths.get(CLASS_NAME.replace(".", "/") + ".class"));
            System.out.println("class path " + classFullPath.toFile().getAbsolutePath());
            long newLastModified = classFullPath.toFile().lastModified();
            System.out.println("exists " + classFullPath.toFile().exists());
            System.out.println("new last modified: " + newLastModified);
            if (newLastModified > lastModified) {
                reload();
                run();
            }
            lastModified = newLastModified;
            TimeUnit.SECONDS.sleep(CHECK_INTERVAL);
        }
    }

    private void reload() {
        classLoader = null;
        klass = null;
    }
}
```
```java
package a.b.c;

public class Child {
    public void walk() {
        System.out.println("I can walk");
    }

    public void speak() {
        System.out.println("I can talk");
    }

    public void write() {
        System.out.println("I can write");
    }
}
```

在`/tmp/classloader/a/b/c`中修改`Child.java`，修改之后执行`javac Child.java`会引起`Child.class`文件的变化，从而触发系统自动重新加载新的class文件，执行新的方法。

## 总结

对于Tomcat会更复杂一些，但也就是把加载一个单独的class文件升级成加载一个war包，原理是一样的。

不过我不太理解的是，为什么Tomcat不能实现热更新，也就是为什么不能像Nginx那样有一段时间是新老服务共存，等已经连接到老的服务上的请求完成之后再停掉老服务呢？这个答案只能从Tomcat的源码中寻找了。


