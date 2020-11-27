---
title: "Python的一些实用技巧"
date: 2020-11-27T16:37:50+08:00
tags: ["python", "bash"]
categories: ["linux"]
---

Python虽然简单，但长时间不写还是忘，记录一些常用的片段。

<!--more-->
### 1. 脚本中出现中文时报错

python2默认是不识别中文编码的，头部需要这么写
```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-
```
python3默认就支持UTF-8了，这个也就不需要了。

### 2. 获取本机IP

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

import netifaces as ni

def get_hostname():
	ip = ni.ifaddresses('eth0')[ni.AF_INET][0]['addr']

	ip_split= ip.split('.')
	if ip_split[1] == '73':
		prefix = 'hadoop-tc-'
	else:
		prefix = 'hadoop-yf-'

	return prefix + ip_split[2] + '-' + ip_split[3]
```

### 3. 判断一个包是否已经安装

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os

output = os.popen('rpm -q jdk1.8').readlines()
for line in output:
    print(line)

```

> `os.popen('cmd').readlines()`和`os.system('cmd')`的区别在于前者会把命令的输出保存到`output`中，而后者则不会，所以如果需要关注命令的输出，就用前面这个。

### 4. 下载一个文件

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

import urllib

urllib.urlretrieve(URL_JDK_8, filename='/data1/jdk-8u231-linux-x64.rpm')
```

> 如果文件已经存在，则会覆盖

### 5. 检查文件是否存在

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os

if os.path.isfile('/path/to/file'):
    print('文件存在')

```
