---
title: 反向代理FRPC模块
date: 2026-03-12 15:54:40 +0800
comments: true
tags:
  - magisk模块
  - root
  - frpc
categories: []
description: 实际测试环境为SuKisu ultra
pin: false
math: false
mermaid: false
---
[下载模块](obsidian/attachments/frpc.zip)
## 安装须知
刚下载模块后, 不要直接使用, 请修改里面的frpc.toml配置文件后, 才在管理器中安装.
## 安全问题
如果你不相信我提供的压缩包里面的二进制文件frpc, 你可以自行前往[FRP官网Releases界面](https://github.com/fatedier/frp/releases/)下载压缩包,然后解压并替换`frpc`,`frpc.toml`两个文件