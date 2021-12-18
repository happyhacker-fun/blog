---
title: "0x01 基础命令以及go mod"
date: 2021-12-15T23:50:38+08:00
tags: ["golang", "go"]
categories: ["go"]
---

本篇主要介绍golang的一些基础命令以及如何在大陆合理访问官方以及第三方的包。

<!--more-->

## `go run`

最简单的执行go代码的方法，不需编译。

```go
// main.go
package main

import (
    "fmt"
)

func main() {
    fmt.Println("Hello World!")
}
```
上面的代码写好之后就可以执行`go run main.go`来验证是否正确了。

## `go mod`

我觉得有了mod的go语言才真正算是现代化的语言了，在此之前的第三方的方案不能说不好，但谁让你是第三方呢？

### 初始化一个开启了go mod的项目

`go mod init` 会创建一个简单的`go.mod`文件，这很像是Java的pom.xml，但要简洁的多的多了。

```mod
module github.com/lovelock/go-tutorials

go 1.17
```

### 整理依赖

开发过程中可能会尝试引入一些依赖，后来发现其实是不需要的， 或者直接在代码中引用了，但没有把它加入`go.mod`中，可以通过`go mod tidy`来一键整理项目的依赖。

## `go build`

> ⚠️ 在`GO111MODULE="on"`时也就是开启了go模块后，需要先出实话mod相关的配置才可以执行`go build`
如果想生成一个可执行文件，就要用编译/打包了。这里想多介绍的一点是交叉编译，也就是说在macOS上打包Windows上可以执行的文件。

### 在macOS或Linux上打包

```bash
CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build main.go
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build main.go
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build main.go
```

### 在Windows上打包

```bash
set CGO_ENABLED=0
set GOOS=darwin
set GOARCH=amd64
go build main.go
```

> 想看是否生效，可以用`go env`查看


## `go clean`

`go build`之后会生成二进制可执行文件，执行`go clean`会把已经生成的可执行文件删除掉

## `go install`

如果把`go build`比喻成`mvn package`，那么`go install`就是`mvn install`了。会把二进制文件放在GOPATH中，如果妥善设置了GOPATH，就可以直接用了。

## `go test`

执行单元测试用的，可以用来做功能测试和性能测试，所有测试文件以`_test.go`结尾。
功能测试的方法以`Test`开始，参数是`(t *testing.T)`；
性能测试的方法以`Benchmark`开始，参数是`(b *testing.B)`。

## `go get`

到这才是go modules的关键，它是用来拉取依赖包的，它有一些控制参数，比如`go get -t`表示要打包要安装的包的单元测试，`go get -u`表示安装依赖包的最新的小版本。所谓小版本又涉及到语义化版本了，具体可以看[这里](https://semver.org/lang/zh-CN/)



