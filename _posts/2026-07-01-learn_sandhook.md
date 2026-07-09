---
title: 这个技术 垂涎已久 
date: 2026-07-01 19:26:10 +0800
comments: true
tags: 
categories: []
description: 
pin: false
math: false
mermaid: false

---
尝试复现

https://github.com/asLody/SandHook/blob/master/doc/doc.md

### 选择寄存器

[](https://github.com/asLody/SandHook/blob/master/doc/doc.md#选择寄存器)

- 为了不破环栈结构，我们在 hook 时，需要使用纯汇编作为跳板，同时使用尽量少的寄存器完成工作
- 如果通过保存恢复现场来保护寄存器和栈，在 ART 中也是不可行的(或者说仅仅在解释器模式下有希望)
- 因为无论是 GC 还是栈回朔，以及其他的一些 ART 的动态行为，都依赖于栈和一些约定寄存器

这里对我的吸引力巨大.. 3年了..

[![inline_flow.png](https://github.com/asLody/SandHook/raw/master/doc/res/inline_flow.png)](https://github.com/asLody/SandHook/blob/master/doc/res/inline_flow.png)

这幅图够我学习N年..

#2026年7月1日 心血来潮, 然后放弃

没摸清楚ART运行软件的原理, 就无法理解文中的说到的函数. 都无法理解了, 如何能学会呢? 

如果要打好基础, 目前应该学习直接在native层, 用c写函数, 然后手动实现函数hook. 然后再去学jvm虚拟机, ART虚拟机. 好麻烦, 还是学医简单一点.. 