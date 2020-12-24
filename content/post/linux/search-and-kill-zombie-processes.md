---
title: "Search and Kill Zombie Processes"
date: 2020-12-18T14:35:53+08:00
tags: []
draft: true
categories: []
---

<!--more-->

```bash
ps -e -o pid,ppid,stat | grep defunct

ps -ef | grep defunct | grep -v grep | wc -l

ps -e -o ppid,stat | grep Z | cut -d" " -f2 | xargs kill -9

kill -HUP $(ps -A -ostat,ppid | grep -e '^[Zz]' | awk '{print $2}')
```

