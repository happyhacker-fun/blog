---
title: "Flink的新特性——Unaligned Checkpoints"
date: 2021-02-04T22:55:48+08:00
tags: ["flink"]
categories: ["flink"]
---

终于看到Flink承认自己在背压高的时候Checkpoint慢的事实了。甚至详细介绍的文章都才只写了第一篇。

<!--more-->

关于**Unaligned Checkpoint**（非对齐检查点）的详细介绍官网上已经有很多了，前段时间刚发布了系列文章的第一篇[
From Aligned to Unaligned Checkpoints - Part 1: Checkpoints, Alignment, and Backpressure](https://flink.apache.org/2020/10/15/from-aligned-to-unaligned-checkpoints-part-1.html)。其中明确提到了以下内容

> Despite all these great properties, Flink’s checkpointing method has an Achilles Heel: the speed of a completed checkpoint is determined by the speed at which data flows through the application. When the application backpressures, the processing of checkpoints is backpressured as well (Appendix 1 recaps what is backpressure and why it can be a good thing). In such cases, checkpoints may take longer to complete or even time out completely.

之前一直觉得Flink在流式计算领域是神一样的存在，没有缺点。但实际用了之后才发现就这一点就够喝一壶了。所谓流式数据其实就是（没有边界的）消息队列了，那么消息队列的一大用途就是**削峰填谷**，好了，这里面的_消峰_就是在流量高峰的时候能以其极高的性能扛住压力，保证在数据压力降下来之前数据的不丢失。没错，Kafka在这里扛住了，但Flink掉链子了。

所谓背压（有的叫反压，原文Back Pressure），对于数据源（DataSource）来说，其实就是下游的消费能力不足，导致上游数据无法完成整个流程（从数据源流入数据汇DataSink），具体到Kafka的这个场景来说就是业务处理的流程慢。

正常来说，我们是希望当数据流量大的时候系统能加快处理，比如设计处理能力是1000tps，实际平时只有300tps，那么当流量上来时我们是期望它能按设计处理能力消费数据，让数据高峰尽快消散的，但实际情况是当数据量增大时，处理能力从300tps变成了2tps。

是的，堆积越多处理越慢。反过来处理越慢，堆积越快。陷入了死循环。

上面文章里也说了，导致这个结果的原因并不是真的是业务代码处理的慢，确确实实就是在背压出现时，Checkpoint变慢了。所以在新版本推出了非对齐检查点模式。

这里有一个Inflight-data的概念，我理解就是新的检查点方式是把每个TaskManager中处理的数据都快照下来了，也不用管水位线什么的，直接搞起，完成一个删除上一个，带来的效果就是完成检查点的速度和背压没有太直接的关系了，实际的使用也验证了这一点。但和预期还是有稍稍的不同，从Kafka监控来看，按照之前对齐检查点方式，每个检查点完成后立即就能看到监控上的消费波峰，但非对齐检查点的完成和波峰就没有直接关系，不过它起码比对齐检查点好在不会在数据流量高峰到来时全部超时，导致系统瘫痪。

带来的好处直观而明显，但不方便之处也是有的。

1. 对检查点存储后端的压力会非常大。

之前每个检查点大小是24K左右，而改成新的方式后就达到了200MB左右，对IO的压力增加可想而知，不过由于我们用的是rocksdb后端，所以这个压力可以承受。

2. 这种情况下自动创建的检查点不能用来扩容/缩容。

由于没有对齐，就没办法做内部的rescale，重启前后的TaskManager数量必须一致。但好在可以通过人工生成SavePoint的方式来创建一个完整的保存点，用保存点保证重启过程的数据不丢失。

## 总结

总之Flink的这个新功能还是非常有用的，在使用这个功能之前数据量增大的时候只能祈祷它不超时，然而总是事与愿违。
看文档说后面的目标是把非对齐检查点作为默认的检查点模式，从目前看还有很长的路要走。
