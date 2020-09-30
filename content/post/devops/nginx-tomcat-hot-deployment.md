---
title: "Nginx和Tomcat配合实现Java Web服务热部署"
date: 2020-08-22T10:56:59+08:00
tags: ["devops", "gitlab", "jenkins", "java"]
categories: ["in-action", "devops"]
---

最终还是得解决Springboot应用热部署的问题。

<!--more-->
## 背景

基于Springboot应用以war包的形式运行在tomcat容器中，当更新war包时会有一段时间服务返回404，这对于线上服务是不可接受的。4层的负载均衡可以自动将80端口关闭的节点下线，但由于内网服务器位于堡垒机后方，根据公司规定不能自行配置SSH服务，所以无法执行远程脚本。所以只能通过别的方式实现。

## 实验素材

![](/images/2020-08-22-14-46-19.png)

1. nginx  作为web server和7层负载均衡
2. tomcat * 2 作为应用后端
3. gitlab-ce 代码版本控制
4. jenkins  发布平台

## 基本原理

基本的原理就是让Nginx后方有2个Tomcat容器，其中1个是active，1个是backup，正常情况下不会访问到backup的容器，但可以通过额外的手段保证backup的容器是可以提供服务的，在发布前先更新所有的backup节点，验证没问题之后更新active的容器，来保证服务不会中断。

## 实际操作

### 创建springboot项目

参考[Springboot使用内置和独立tomcat以及其他思考](../spring-tomcat-tutorial.md)。


### 编写同一个接口的不同版本

```java
// tag v1
@RestController
public class HelloController {
    @GetMapping("/hello")
    public String hello() {
        return "V1";
    }
}
```

```java
// tag v2
@RestController
public class HelloController {
    @GetMapping("/hello")
    public String hello() {
        return "V2";
    }
}
```

### 打包

```
mvn clean package -Dmaven.test.skip=true
```

### 创建两个tomcat容器

```
docker run -itd --name tomcat-active -v /tmp/tomcat/active:/usr/local/tomcat/webapps -p 32771:8080 tomcat
docker run -itd --name tomcat-backup -v /tmp/tomcat/backup:/usr/local/tomcat/webapps -p 32772:8080 tomcat
```

### 将war包拷贝到容器中

可能是docker toolbox的问题，无法挂载目录，所以只好把war包手动拷贝进去。

```
docker cp ~/workspace/spring-demo/target/spring-demo-0.0.1-SNAPSHOT.war tomcat-active:/usr/local/tomcat/webapps/
docker cp ~/workspace/spring-demo/target/spring-demo-0.0.1-SNAPSHOT.war tomcat-backup:/usr/local/tomcat/webapps/
```

### 访问两个容器中的服务

稍等片刻两个容器中的服务会自动部署，就可以分别通过相应的端口访问了，简单压测一下QPS可以达到2000+且没有报错。

```
$ wrk -c 20 -d 10 -t 4 http://192.168.99.100:32771/spring-demo-0.0.1-SNAPSHOT/hello
Running 10s test @ http://192.168.99.100:32771/spring-demo-0.0.1-SNAPSHOT/hello
  4 threads and 20 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    10.20ms    8.70ms 122.66ms   81.20%
    Req/Sec   554.18    167.66     1.04k    63.25%
  22088 requests in 10.02s, 2.43MB read
Requests/sec:   2203.76
Transfer/sec:    247.89KB

$ wrk -c 20 -d 10 -t 4 http://192.168.99.100:32772/spring-demo-0.0.1-SNAPSHOT/hello
Running 10s test @ http://192.168.99.100:32772/spring-demo-0.0.1-SNAPSHOT/hello
  4 threads and 20 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    11.30ms   14.24ms 186.52ms   92.95%
    Req/Sec   557.54    207.91     1.24k    67.17%
  22025 requests in 10.03s, 2.42MB read
Requests/sec:   2196.36
Transfer/sec:    247.05KB
```

### 配置Nginx

```nginx
upstream ha {
	server 192.168.99.100:32771;
	server 192.168.99.100:32772 backup;
}
server {
	listen       80;
	server_name  _;

	location / {
		proxy_next_upstream http_502 http_504 http_404 error timeout invalid_header;
		proxy_pass   http://ha/spring-demo-0.0.1-SNAPSHOT/;
	}
}
```

注意：默认情况下只会转发`GET`/`HEAD`/`PUT`/`DELETE`/`OPTIONS`这种幂等的请求，而不会转发`POST`请求，如果需要对`POST`请求也做转发，就需要加上`non_idempotent`配置，整体配置如下
```nginx
upstream ha {
	server 192.168.99.100:32771;
	server 192.168.99.100:32772 backup;
}
server {
	listen       80;
	server_name  _;

	location / {
		proxy_next_upstream http_502 http_504 http_404 error timeout invalid_header non_idempotent;
		proxy_pass   http://ha/spring-demo-0.0.1-SNAPSHOT/;
	}
}
```

注意`proxy_next_upstream http_502 http_504 http_404 error timeout invalid_header;`这行，这里就是表示把访问当前的upstream返回了这些状态码的请求转发到upstream中的下一台机器，在我们现在的应用场景下，当war包发布时，正在更新war包的tomcat会返回404，也就是对应`http_404`，如果不配置这行，是不会做转发的。
但这样简单的配置还会有一个问题，那就是Nginx不会把出问题的后端从upstream中摘除，也就是说请求还会访问到这个正在更新中的realserver，只是Nginx会再把请求转发到下一台好的realserver上，这样会增加一些耗时。目前有三种方式可以实现对Nginx负载均衡的后端节点服务器进行健康检查，具体参考[Nginx负载均衡](./loadbalance-with-nginx.md)

## 通过Nginx压测

### 基本测试
1. 两个tomcat节点均正常的情况下压测
```
$ wrk -c 20 -d 10 -t 4 http://192.168.99.100:32778/hello
Running 10s test @ http://192.168.99.100:32778/hello
  4 threads and 20 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    57.36ms   32.06ms 335.36ms   71.29%
    Req/Sec    89.29     48.20   390.00     85.25%
  3577 requests in 10.05s, 562.30KB read
Requests/sec:    355.77
Transfer/sec:     55.93KB
```
和上面没有经过Nginx的压测相比，最明显的变化就是QPS下降了84%，平均响应时间增加了5倍，猜测可能是因为Nginx使用的默认配置中`worker_processes 1;`的问题。

2. 在开始压测后立即删除`tomcat-active`容器中的war包和目录，结果如下
```
$ wrk -c 20 -d 10 -t 4 http://192.168.99.100:32778/hello
Running 10s test @ http://192.168.99.100:32778/hello
  4 threads and 20 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    57.29ms   28.69ms 181.88ms   67.38%
    Req/Sec    87.93     39.51   240.00     75.25%
  3521 requests in 10.05s, 553.50KB read
Requests/sec:    350.22
Transfer/sec:     55.05KB
```
同样没有非200的响应，而且整体和正常情况相当。

3. 只有backup节点工作的情况下压测
```
$ wrk -c 20 -d 10 -t 4 http://192.168.99.100:32778/hello
Running 10s test @ http://192.168.99.100:32778/hello
  4 threads and 20 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    72.12ms   35.99ms 240.89ms   68.34%
    Req/Sec    70.04     31.84   180.00     76.50%
  2810 requests in 10.05s, 441.71KB read
Requests/sec:    279.48
Transfer/sec:     43.93KB
```

可以看到，响应时间有明显的增加，QPS也有明显的下降，也验证了上面说的响应是404的请求会被转发到正常工作的节点，但有问题的节点不会被摘除导致的响应时间变长的问题。

### 进一步测试

为了消除上面测试中可能存在war包删除后对服务的影响还没有生效，压测就已经结束的可能，将压测时间调长，增加至60s。

1. 两个节点都正常的情况

```
$ wrk -c 20 -d 60 -t 4 http://192.168.99.100:32778/hello
Running 1m test @ http://192.168.99.100:32778/hello
  4 threads and 20 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    55.53ms   28.10ms 306.58ms   70.07%
    Req/Sec    91.52     39.35   300.00     69.23%
  21906 requests in 1.00m, 3.36MB read
Requests/sec:    364.66
Transfer/sec:     57.32KB
```
整体情况和上面10s的测试相同。查看日志发现backup节点没有接收到任何请求。为了验证是否是`worker_processes`配置导致的，把这个值改成4之后重新测试，结果如下

```
$ wrk -c 20 -d 60 -t 4 http://192.168.99.100:32778/hello
Running 1m test @ http://192.168.99.100:32778/hello
  4 threads and 20 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    41.55ms   24.92ms 227.15ms   72.21%
    Req/Sec   125.06     46.88   373.00     71.76%
  29922 requests in 1.00m, 4.59MB read
Requests/sec:    498.11
Transfer/sec:     78.29KB
```
可以看到，有了将近20%的提升，但还是不太符合预期。

2. 开始测试后立即更新active节点的war包
```
$ wrk -c 20 -d 60 -t 4 http://192.168.99.100:32778/hello
Running 1m test @ http://192.168.99.100:32778/hello
  4 threads and 20 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    54.40ms   33.76ms 329.73ms   70.53%
    Req/Sec    95.85     56.28   420.00     81.60%
  22914 requests in 1.00m, 3.52MB read
Requests/sec:    381.42
Transfer/sec:     59.95KB
```
没有明显变化，测试开始后有一段时间backup节点收到请求，后面请求又全部指向了active节点。可能是因为服务太简单，重新加载的太快，只有很少量（5750）的请求转发到了backup节点，所以对整体结果影响不大。
3. 开始测试后立即删除active节点的war包

```
$ wrk -c 20 -d 60 -t 4 http://192.168.99.100:32778/hello
Running 1m test @ http://192.168.99.100:32778/hello
  4 threads and 20 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    72.11ms   34.33ms 346.24ms   69.54%
    Req/Sec    70.16     29.78   191.00     67.23%
  16813 requests in 1.00m, 2.58MB read
Requests/sec:    279.84
Transfer/sec:     43.99KB
```
删除节点后，所有的请求都会先请求active，然后被Nginx转发至backup，所以吞吐量有明显下降，延迟也有明显的提升。

## 效果测试

1. 直接访问active
   
```
$ wrk -c 20 -d 60 -t 4 http://10.75.1.42:28080/web-0.0.1-SNAPSHOT/hello
Running 1m test @ http://10.75.1.42:28080/web-0.0.1-SNAPSHOT/hello
  4 threads and 20 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     5.56ms   25.16ms 203.83ms   95.82%
    Req/Sec     7.54k     0.91k    8.31k    84.44%
  1803421 requests in 1.00m, 217.03MB read
Requests/sec:  30006.18
Transfer/sec:      3.61MB
```
服务器的性能果然还是比本地强太多。

2. 在进行性能压测期间发布新版本
```
$ wrk -c 20 -d 60 -t 4 http://10.75.1.42:28080/web-0.0.1-SNAPSHOT/hello
Running 1m test @ http://10.75.1.42:28080/web-0.0.1-SNAPSHOT/hello
  4 threads and 20 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     4.47ms   22.31ms 401.95ms   96.67%
    Req/Sec     7.58k     0.88k    8.26k    87.12%
  1811240 requests in 1.00m, 285.84MB read
  Non-2xx or 3xx responses: 72742
Requests/sec:  30181.93
Transfer/sec:      4.76MB
```
发布新版本导致4%的请求失败。

3. 通过Nginx访问服务

```
$ wrk -c 20 -d 60 -t 4 http://10.75.1.42:28010/web/hello
Running 1m test @ http://10.75.1.42:28010/web/hello
  4 threads and 20 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     2.94ms   16.21ms 248.18ms   98.01%
    Req/Sec     6.02k   551.52     6.92k    83.38%
  1437098 requests in 1.00m, 260.33MB read
Requests/sec:  23948.20
Transfer/sec:      4.34MB
```
虽然服务器配置的`worker_processes auto`，实际上开了40个进程，但仍然达不到直接访问Java服务的吞吐量。

4. 通过Nginx压测期间发布新版本
```
$ wrk -c 20 -d 60 -t 4 http://10.75.1.42:28010/web/hello
Running 1m test @ http://10.75.1.42:28010/web/hello
  4 threads and 20 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     4.09ms   20.50ms 402.11ms   97.12%
    Req/Sec     5.89k   733.62     6.86k    84.85%
  1404463 requests in 1.00m, 253.67MB read
Requests/sec:  23401.54
Transfer/sec:      4.23MB
```
可以看到，延迟明显变大了，但总体的QPS没有明显下降，还是因为存在一些转发。

## 思考
原来是一台机器上运行一个tomcat容器，现在要运行两个，那么会对机器的负载造成多大的影响呢？可以通过visualvm连接上远程tomcat来观察对内存和CPU的占用

![压测期间的active节点](/images/2020-08-22-17-06-47.png)
![压测期间的backup节点](/images/2020-08-22-17-07-02.png)

可以看到正常情况下，backup容器对服务器的负载基本可以忽略不计。即便是在发布期间，backup容器也只是在active容器重新载入期间承担职责，之后马上就恢复了。
![压测期间active节点更新版本](/images/2020-08-22-17-10-53.png)
![压测期间backup节点承载一定流量](/images/2020-08-22-17-11-05.png)

新版本在线上正式运行之后为保证下一次发布新版本时backup版本是最新的，需要再发布一下backup版本，当然这时流量都在active节点上，对backup节点的发布更新操作不会对负载有什么影响。

![](/images/2020-08-22-17-14-52.png)

## 总结

可以通过Nginx的backup机制可以保证服务不中断的情况下发布新版本。总体的发布流程如下：

1. 发布新版本到active容器
2. 确认发布的新版本稳定后发布新版本到backup容器

### 优势
1. 任意一台机器上在任意时刻都保证有一个tomcat容器是可用的，保证服务不中断
2. 从直观上的分机器上线改为直接全量上线，并且保证如果上线的新版本有问题时也不会影响线上服务

### 劣势
1. 需要上线两次
2. 需要在tomcat容器所在的机器上安装Nginx和作为backup的tomcat的容器
3. backup容器在“待机”时的消耗

