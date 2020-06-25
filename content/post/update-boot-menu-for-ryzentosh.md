---
title: "黑苹果bootmenu"
date: 2020-06-14T15:49:21+08:00
tags: ["ryzentosh"]
categories: ["in-action"]
---

更新完黑苹果之后发现进BIOS的时候多了一个选项，看起来很奇怪。
<!--more-->

其实是因为在安装Windows或者Windows进行系统更新时，会覆盖`/EFI/BOOT/BOOTx64.efi`文件，这个配置就是为了保护这个文件不被修改的，具体的原因我没有研究，因为暂时还没有安装Windows。（其实是因为安装不上，在Mac上创建的WindowsInstaller总是无法启动，不是刚需也就没有再继续研究了）

多了个`OpenCore`，经过在[Reddit](https://www.reddit.com/r/hackintosh/comments/h8oiff/theres_a_new_bootdevice_in_bios_entry/)上发帖求助，发现原因可能是更新到0.5.9的时候复制了一个配置来 `Misc -> Security -> BootProtect`，~~现在的配置是`Bootstrap`，改成`none`即可~~，但如果安装了Windows系统，每当windows系统更新时就会破坏OpenCore的启动顺序。

![](/images/2020-06-14-15-54-04.png)

所以这其实是OpenCore的保护机制，也就不难理解它是一个【启动安全】选项的原因了。不过我暂时没有安装Windows，所以也用不到这个选项。不过明白了，也就不再纠结了，暂时就不改它了，免得将来装了Windows但忘了这个事儿，净是给自己挖坑。

