---
title: "Hugo支持站内搜索"
date: 2021-01-17T00:11:45+08:00
tags: ["hugo", "blog", "lunr", "搜索引擎", "站内搜索"]
categories: ["in-action"]
---

这个博客也写了不少东西了，但功能还是有些简陋，比如不支持搜索，也不能评论，甚至不知道有多少人访问过。

<!--more-->

逛知乎的时候无意间看到了Maupassant这个主题，总体看上去还挺简洁大方的，主要是信息展示的比较丰富，不像之前的even主题，想看标签和分类还要专门去单独的页面。

所以就开始了改造。

## 访问计数

这个就比较简单了，之前用的even主题里也有这个位置，只是没有打开而已。

```toml
[params]
  [params.busuanzi]         # count web traffic by busuanzi                             # 是否使用不蒜子统计站点访问量
    enable = true
    siteUV = true
    sitePV = true
    pagePV = true
```

## 评论

评论也比较简单，使用的是[utteranc](https://utteranc.es/)

```toml
 [params.utteranc]       # https://utteranc.es/
   enable = true
   repo = "lovelock/blog-comments"               # The repo to store comments
   issueTerm = "pathname"  #表示你选择以那种方式让github issue的评论和你的文章关联。
   theme = "github-light" # 样式主题，有github-light和github-dark两种
   async = true
```
## 站内搜索

重头戏是站内搜索。本来也没想弄，发现这个主题有这个功能就想着把它搞定。但按主题作者的说法配置完成了之后并没有任何效果，所以我就研究了下hugo下实现站内搜索的方案。

首先是打开
```toml
[params]
  localSearch = true
```
然后在`content/search`目录下新建`index.md`文件，并添加以下内容
```markdown
---
title: "搜索"
description: "搜索页面"
type: "search"
---
```

做这些的目的是在使用搜索功能的时候可以跳转到`${baseURL}/search/q=keyword`这个页面，而它对应的页面模板就是`single.html`。我读了下源码，其实它做的事情是在这个页面load完成时从`public/index.xml`中找到所有文章的标题，然后在标题列表中查找相应的关键词。

这存在几个问题
1. 中文分词的支持肯定不好
2. `public/index.html`无法下载

### 选型

所以我就转而去hugo的官网查解决方案了。查了一圈对lunr.js比较感兴趣，好像功能也比较强大，对应也有hugo的小工具。说来也搞笑，hugo本来是要取代hexo作为新一代的静态站点生成引擎的，这是go语言和node的竞争，但当涉及到这个领域时，竟然需要在hugo中引入node模块来解决。不过还好，我对这个也没有洁癖，能工作就行。

原理其实和上面描述的差不多，通过`hugo-lunr-zh`生成一个`index.json`文件，页面加载的时候把这个文件加载过来，通过lunr的搜索功能在里面查到关键词，进而进行下一步的展示。
这个`hugo-lunr-zh`其实项目本身和lunr并无关系，它只是用来生成lunr可以识别的数据而已。而要使用`hugo-lunr-zh`则是为了支持中文分词。

### 行动

既然改了搜索方案，现有的`single.html`也肯定不能用了，先fork一个。然后`npm -g install hugo-lunr-zh`，然后在博客的根目录执行`hugo-lunr-zh`，简直是涕泗横流，跑不通。

搜索了一下确实这个方案是有些问题的，主要是作者也不更新了。但我觉得这个原理很清晰，于是进入了不断的debug阶段。

> 在npm上的版本是1.0.3，而我自己魔改成功运行之后才发现github上的master已经是2.1.0了，但我把master版本下载下来竟然都无法安装。我也没兴趣研究到底哪里出了问题了。

遇到了以下问题
1. 路径解析的不对
2. 在https页面上向http的接口发起请求被浏览器拦截
3. 在`$document.ready(() => {})`中操作`lunr`
4. 为新方案适配页面

#### 1. 路径解析的不对

不知道是为什么作者会设计成这样的，我的文件是在类似`post/life/a.md`、`post/devops/b.md`这种路径，为什么它会认为最终的访问路径是`posts/a`和`posts/b`呢？这个解决的比较简单，就是破坏了原本的设计，主要是我也不认同它的设计。

#### 2. 在https页面上向http的接口发起请求被浏览器拦截

这个问题是我这个站点没有使用https，在配置文件中的`baseURL=http://blog.happyhacker.fun`，也没有用https，相应的搜索框的写法是`{{ "search/" | absURL }}`，经过hugo黑盒的解析之后这个完整的链接变成了`https://blog.happyhacker.fun/search`；由于无法从`public`目录下载`index.json`文件，所以我把它放在`static/js/`目录下了，在页面模板中的写法是`{{ "js/index.json" | absURL }}`，最终的完成链接却变成了`http://blog.happyhacker.fun/js/index.json`。

注意到区别了吗？js目录下的文件没有https，而跳转的页面有https。

所以我干脆就在配置文件里把`baseURL`也改成`https`了，问题就这么解决了。因为所有的请求都变成了https，虽然我并没有配置证书。

#### 3. 在`$document.ready(() => {})`中操作`lunr`

在完成这块之前我是没想着要用到分词的，只是简单分析了在命令行生成的词表的结构，想着干脆把这些内容用空格分开生成一个大列表，然后用`Array.prototype.includes()`方法来实现搜索，后来研究了一下发现用lunr自身的搜索引擎看起来要强大许多。

核心代码如下
```javascript
$(document).ready(function () {
        var q = getUrlParameter("q");
        $("span.keyword").text(q);
        $("article.post").remove();
        $.ajax({
            url: '{{"js/index.json"|absURL}}',
            dataType: "json",
            success: function (data) {
                const idx = lunr(function() {
                    this.ref("uri")
                    this.field("content")
                    this.field("tags")
                    this.field("categories")
                    this.field("title")
                    data.forEach(function(e) {
                        this.add(e);
                    }, this);
                })

                const result = idx.search(q);
                const hitRefs = result.map(e => e.ref);
                console.log(hitRefs)
                result.forEach(e => {
                    const item = data.filter(d => d.uri == e.ref)[0];
                    const oriTitle = item['oriTitle']
                    const content = item['content']
                    const title = item['title']

                    const uri = item['uri']
                    const score = result.filter(f => uri == f.ref)[0]['score']
                    let searchItem =
                        `<article class="post"><header><h1 class="post-title"><a href="` +
                        uri + `">` + oriTitle + `</a></h1></header>`;
                    const pubDate = new Date(item['date'])
                    searchItem += `<date class="post-meta meta-date">` + pubDate
                        .getFullYear() + `年` + (pubDate.getMonth() + 1) + `月` + pubDate
                        .getDate() + `日&nbsp; 匹配度：` + score + `</date>`;
                    searchItem += `<div class="post-content">` + item['content'].replace(/\s*/g,"").substring(0, 100) + `……<p class="readmore"><a href="` +
                        uri + `">阅读全文</a></p></div></article>`;

                    $("div.res-cons").append(searchItem);
                })
            }
        });
```

梳理下逻辑就是拿到词表之后在前端构建一个lunr搜索引擎，从中搜索想要的结果，然后根据结果中的ref再回到原始结果中拿数据，拼页面。

这里提一点，hugo的设计还是很灵活的，可以在`config.toml`中配置`customJs`可以在所有页面引入一个js，简直不要太方便。

#### 4. 为新方案适配页面

代码已经在上面贴出来了，比较简单。

## 总结

开源项目真的是很依赖作者，虽说用的人可能很多，但真正去改它的人可能凤毛麟角。作者一时兴起发起了一个开源项目，后面不想维护了，就把一堆烂摊子丢给了用户。开源免费的东西我们不能要求太多，那就只好自己在前人的基础上研究了，只是要多花些时间。

本次改造中新建了两个repo
1. [Maupassant主题](https://github.com/lovelock/maupassant-hugo)
2. [hugo-lunr-zh](https://github.com/lovelock/hugo-lunr-zh)


