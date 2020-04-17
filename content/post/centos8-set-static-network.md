---
title: "CentOS8配置静态地址"
date: 2020-04-17T23:02:34+08:00
tags: ["centos", "linux", "运维"]
categories: ["in-action"]
---

CentOS 8又搞出这么幺蛾子，不过这个接口还挺好用，我喜欢。
<!--more-->

AMD的黑苹果没办法安装Docker，只好虚拟机搞起了，还要硬件性能够强，这点性能损耗不算什么。装的服务器版本的当然要ssh登录，所以需要用桥接的网络接口
![](/images/2020-04-17-23-25-34.png)
默认是dhcp的配置，所以每次开机IP都会变，这样很不方便，于是要给它一个固定的地址。然后就发现CentOS 8又搞了一个`nmcli`，虽然又是一个轮子，但不得不说，这个接口设计的还挺好。

## 预期配置
下面是要给虚拟机的配置
IP: 192.168.0.108
Mask: 255.255.255.0
网关: 192.168.0.1
DNS: 114.114.114.114

## 命令
不出意外的话，第一个网络接口应该是`enp0s3`，所以下面的命令一气呵成就可以配置成功了

```
[root@localhost network-scripts]# nmcli con
NAME    UUID                                  TYPE      DEVICE
enp0s3  f131fbc3-12a2-4d96-bb3a-623aad5c4fda  ethernet  enp0s3
[root@localhost network-scripts]# nmcli con mod enp0s3 ipv4.addresses 192.168.0.108/24 # 配置IP和Mask
[root@localhost network-scripts]# nmcli con mod enp0s3 ipv4.gateway 192.168.0.1        # 配置网关
[root@localhost network-scripts]# nmcli conn mod enp0s3 ipv4.dns "114.114.114.114"     # 配置DNS
[root@localhost network-scripts]# nmcli con mod enp0s3 ipv4.method manual              # 取消dhcp，使用静态地址
[root@localhost network-scripts]# nmcli con up enp0s3                                  # 重启网络接口
```

## 配置key登录

然后就可以愉快的在macOS上通过以下命令生成配置使用key登录虚拟机了

```
$ ssh-copy-id frost@192.168.0.108
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/Users/frost/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
frost@192.168.0.108's password:

Number of key(s) added:        1

Now try logging into the machine, with:   "ssh 'frost@192.168.0.108'"
and check to make sure that only the key(s) you wanted were added.
```

## 配置快捷登录方式

接着在macOS的`$HOME/.ssh/config`中添加以下内容

```
Host *
ControlMaster auto
ControlPath  /tmp/ssh-%r@%h

Host dev
HostName 192.168.0.108
User frost
```
这样就可以通过`ssh dev`这条简短的命令登录了。虽然用key做认证倒也无所谓，不过通常还是配置上上述内容中的前三行，让登录到同一个主机的ssh共享session，也就是说在使用密码登录时，只有第一次需要输入密码，在保留第一个连接时，后续的连接都可以免密。

## 总结
每次配置ssh都想起来几年前写的这个小工具[ic](https://github.com/lovelock/ic)，当时是为了更简单的配置本地端口转发，实现sftp上传文件，后来公司不让用这种方式了也就作罢了。不过当时还研究了下go语言和ssh的配置，还有homebrew的打包方式，虽然现在都不记得了。。。。