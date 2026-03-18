---
title: Magisk安装模块以达到adb远控
date: 2026-03-18 17:35:03 +0800
comments: true
tags: 
categories: [分享]
description: 一定只能是Magsik,只有它能挂载系统文件
pin: false
math: false
mermaid: false

---
adb远控用到的Magsik插件


 我自己(借助AI)写的
- [adb-tcp](obsidian/attachments/adb_tcp.zip) 
- [frpc](obsidian/attachments/frpc.zip) 
网上开源的模块 
- [SSH for Magisk](https://gitlab.com/d4rcm4rc/MagiskSSH_releases/-/blob/main/magisk_ssh_v0.26.zip?ref_type=heads)
- [vim for Android](http://bnsmb.de/files/public/Android/vim_9.1.zip)

推荐收藏[大佬的网站](http://bnsmb.de/Magisk_Modules.html):http://bnsmb.de/

手机用的app是[ZeroTermux](https://github.com/hanxinhao000/ZeroTermux)
用的快捷脚本是
```xml
<?xml version="1.0" encoding="utf-8"?>
<zt-menu>

    <group name="快捷键">
        <item tag="shell"
            name="重置连接"
            autoRunShell="true"
            click="ztShell:adb disconnect &amp;&amp;clear" />

        <item tag="shell"
            name="接入本地"
            autoRunShell="true"
            click="ztShell:adb connect 192.168.6.10:5555" />

        <item tag="shell"
            name="回退"
            autoRunShell="true"
            click="ztShell:exit" />

        <item tag="shell"
            name="su"
            autoRunShell="true"
            click="ztShell:su" />
 <item tag="shell"
            name="杀死当前"
            autoRunShell="true"
            click="ztShell:adb shell &quot;su -c 'pkg=\$(dumpsys activity activities 2&gt;/dev/null | grep -E \&quot;ResumedActivity|topRunningActivity\&quot; | head -1 | grep -o \&quot;[a-zA-Z0-9._:]*\&quot; || dumpsys window windows 2&gt;/dev/null | grep -E \&quot;mCurrentFocus|mFocusedApp\&quot; | head -1 | grep -o \&quot;[a-zA-Z0-9._:]*\&quot;); [[ -n \&quot;\$pkg\&quot; ]] &amp;&amp; kill -9 \$(pidof \$pkg 2&gt;/dev/null)'&quot;" />

        <item tag="shell"
            name="音量↑"
            autoRunShell="true"
            click="ztShell:adb shell input keyevent 24" />

        <item tag="shell"
            name="音量↓"
            autoRunShell="true"
            click="ztShell:adb shell input keyevent 25" />

        <item tag="shell"
            name="电源"
            autoRunShell="true"
            click="ztShell:adb shell input keyevent 26" />

        <item tag="shell"
            name="息屏"
            autoRunShell="true"
            click="ztShell:adb shell input keyevent 6" />

        <item tag="shell"
            name="截屏"
            autoRunShell="true"
            click="ztShell:adb exec-out screencap -p > /sdcard/download/screenshot.png" />

        <item tag="shell"
            name="查看截屏"
            icon=""
            activityTitle="本次截屏"
            click="appWebUrl:file:///sdcard/download/screenshot.png" />
       <item tag="shell"
            name="解锁"
            autoRunShell="true"
            click="ztShell:adb shell input keyevent 26&amp;&amp;adb shell input keyevent 66&amp;&amp;adb shell input text '123123'" />
        <item tag="shell"
            name="杀死抖音"
            autoRunShell="true"
            click="ztShell:adb shell su -c 'killall com.ss.android.ugc.aweme'" />

        <item tag="shell"
            name="杀死哔哩"
            autoRunShell="true"
            click="ztShell:adb shell su -c 'killall tv.danmaku.bili'" />

        <item tag="shell"
            name="杀死微信"
            autoRunShell="true"
            click="ztShell:adb shell su -c 'killall com.tencent.mm'" />

        <item tag="shell"
            name="杀死QQ"
            autoRunShell="true"
            click="ztShell:adb shell su -c 'killall com.tencent.mobileqq'" />

        <item tag="shell"
            name="重启"
            autoRunShell="true"
            click="ztShell:adb shell reboot" />

        <item tag="shell"
            name="关机"
            autoRunShell="true"
            click="ztShell:adb shell su -c 'reboot -p'" />
             
        <item tag="自定义左侧栏"
            name="修改快捷"
            icon="imgPath:/data/data/com.termux/files/home/ZtInfo/edit_menu.png"
            click="ztEditText:/data/data/com.termux/files/home/ZtInfo/main_menu_path.xml" />
    </group>
    <group name="常用功能">
        <item tag="ZT设置"
    click="java:com.termux.zerocore.config.mainmenu.config.ZTSettingsClickConfig" />
    </group>


</zt-menu>

```