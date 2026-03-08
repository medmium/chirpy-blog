---
title: 记录初次配置obsidian和templater脚本"
date: 2026-03-06
tags:
  - 配置
  - bug
---
截止到现在, 终于搞定了md链接与uri相对错位的问题!!!

罪魁祸首是
```js
_config.yml
```
的这行配置:
```ruby
184 permalink : date
```
把 permalinsssk 从date 改成 单级目录的变量, 我这里用:title
```ruby
184 permalink : :title
```
![](obsidian/attachments/Image_2026-03-07_11-07-00_0xodnni3.zcs.png)
如果是date, 就会导致img src 的属性按照相对位置寻找资源, 但该相对位置被date字段切分成了3级目录, 比如一份md的源名是:
``` js
2026-03-06-***.md
```
, 那么它编译成的文件网页路径就是:
```js
https://yoursite/2026/03/06/***.html
``` 
往往里面的图片资源都是以img超链接的形式存在,也就是:
```bash
<img src="assets/obsidian/attachments/Image_2026-03-07_00-28-09_ganjc11s.0gr.png" alt="">
```
这样会导致该html文件里的图片img 的 src 从目录
```js
https://yoursite/2026/03/06
```
开始查找, 然而正确的资源是放在同级目录
```js
https://yoursite/
```
坑死我了