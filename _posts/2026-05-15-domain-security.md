---
title: 关于域名劫持 
date: 2026-05-15 13:17:46 +0800
comments: true
tags: 
categories: []
description: 无意使用根域名指向github服务器.导致github自动生成了let'sEncrypt证书. 被恶意网站的仓库占用, 删除即可. 懒得追究.
pin: false
math: false
mermaid: false

---
本站主域名`https://medmi.cn` 原本托管在`cloudflare`上, 根域名直接指向github服务器`185.199.108.153`. 没有开启代理. 然后就被DNS污染了...
![](obsidian/attachments/2026-05-15-domain-security.png)
看样子是一个印尼博彩网站, 我叼尼玛!!!!!!!!!!!!!!!!!!!!!!

果断删除指向github的代理!!!
![](obsidian/attachments/Image_2026-05-15_13-22-50_syv2v41x.jci.png)

终于恢复正常
![](obsidian/attachments/Image_2026-05-15_13-23-30_dk20cm5p.ukb.png)
