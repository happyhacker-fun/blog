---
title: "Springboot过滤器"
date: 2020-04-01T01:10:02+08:00
tags: ["springboot", "java"]
draft: true
categories: ["in-action"]
---

接口写好了需要把之前一直在用的接口认证方式集成进来（从PHP移植到Java），由于有之前基于PHP的Slim框架二次开发的经验，就想到了一个概念Middleware。

<!--more-->

搜索了一下Springboot Middleware，发现原来Middleware这个概念在Springboot里叫做**Filter**，但又有一些不同。主要总结了以下几点：  

## Springboot的Filter和Slim的Middleware的异同

1. Filter中无法直接返回Response
   在Slim的Middleware模型中，命中的某种条件的请求是可以直接返回给调用方而不用经过后续的middleware，但Filter在执行完当前的doFilter方法的逻辑之后只能被`chain.doFilter(request, response)`带到下一个Filter中。而这一点最显而易见的一个结果就是Filter这种方式在重定向时容易写出死循环。
   
   比如在`AuthFilter`中，如果直接按如下实现

    ```java
    @Component
    class AuthFilter implements Filter {

        @Override
        ...doFilter(...) {
            if (!param.containsKey(APP_KEY)) {
                response.sendRedirect("/error/unauthenticated");
                filterChain.doFilter(request, response);
                return;
            }
        }
    }
    ```
    我本意是想让请求在命中这种情况时可以直接返回报错信息给前端，但在Filter中无法直接返回Response，请求只能继续向下传递。相当于是301重定向到`/error/unauthenticated`这个请求了，而由于不加判断的加载了整个Filter，就会重新进入这个判断，重新重定向，导致无限循环。后面讲述如何解决这个问题。



## 如何实现一个Filter

### 最简单的Filter

### 指定Filter的加载顺序

### 按profile决定是否加载

### 根据请求url决定是否加载

### 在Filter中对请求和响应的处理

#### 实现自定义的Request/Response wrapper

