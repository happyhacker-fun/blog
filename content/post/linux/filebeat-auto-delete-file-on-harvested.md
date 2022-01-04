---
title: "Filebeat 自动删除已经收集完的文件"
date: 2022-01-04T11:46:03+08:00
tags: ["linux", "filebeat", "go", "golang", "devops"]
categories: ["in-action"]
---

用Filebeat收集日志一直有一个痛点，就是不知道要什么时候才能把要收集的文件删除。

<!--more-->

之前的解决方案是定时删除文件，但删除的时候其实也不保证已经收集了，所以肯定是有概率会删除正在收集中的文件，这时候其实文件句柄正在被filebeat持有，所以删除也不能释放空间。

简单的搜索就发现了这篇文章[FileBeats -Are there any ways we can delete the log files after file beat harvest the data to logstash ](https://discuss.elastic.co/t/filebeats-are-there-any-ways-we-can-delete-the-log-files-after-file-beat-harvest-the-data-to-logstash/177997)。

总结下来原理很简单，就是比较registry中的文件对应的offset，如果offset和当前文件的size相同，就表示已经收集完成（只是表示已经收集到文件最后的位置，并不表示文件不再继续写入了），这时候就可以删除文件了。

而基于之前升级filebeat的经验，我们把所有filebeat实例配置都放在同一个目录下，我们的代码就只需要便利这个目录下所有的`data/registry/filebeat/log.json`文件，分析其中的数据即可。这里放一个简单的例子

> 这个文件虽然是叫`log.json`，但其实内容是多行json，也就是每行是一个json串，这里要注意一下。

```json
{"k":"filebeat::logs::native::361-2055","v":{"timestamp":[698286230,1641268968],"ttl":-1,"type":"log","FileStateOS":{"inode":361,"device":2055},"source":"path/to/log.log","offset":153040051,"identifier_name":"native","id":"native::361-2055","prev_id":""}}
{"op":"set","id":8250639157}
```

这里面需要处理的就是`v.source`和`v.offset`。处理过程中需要注意很多异常，但多数都是可以忽略的，主要是因为可能这个文件已经不存在了，但是registry信息还在这个`log.json`里面。

不得不说用golang处理这种问题简直是“干净又卫生”，比用shell处理降低了非常多的心智负担，而且非常快速就能解决问题。在Mac上写的代码打一个linux的包放在`/etc/cron.hourly`目录下就能每小时执行一次了。

