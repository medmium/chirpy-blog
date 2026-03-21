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
- [frpc](obsidian/attachments/frpc.zip) 不放心可以自己换里面的二进制文件
网上开源的模块 
- [SSH for Magisk](https://gitlab.com/d4rcm4rc/MagiskSSH_releases/-/blob/main/magisk_ssh_v0.26.zip?ref_type=heads)
- vim for Android: http://bnsmb.de/files/public/Android/vim_9.1.zip

推荐收藏大佬的网站:http://bnsmb.de/

可能会出现的问题:
手机静置一段时间后, adb连接不上, 但ssh, frp能连接上. 本地或远程SSH连上后, 依次执行: 
```shell
stop adbd
```
```shell
start adbd
```
即可恢复.

## adb shell 与 ssh shell 区别

它们大部分功能重叠. 但adb shell能调用Magisk远程安装模块, 能执行截屏并回传到控制端 , ssh shell却不行. ssh shell唯一的优势就是**稳**



## ZereTermux快捷脚本
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

更新版本
```xml
<?xml version="1.0" encoding="utf-8"?>
<zt-menu>
    <group name="针对当前直接adb">

        <item tag="shell"
            name="杀死当前"
            autoRunShell="true"
            click="ztShell:adb shell &quot;su -c 'pkg=\$(dumpsys activity activities 2&gt;/dev/null | grep -E \&quot;ResumedActivity|topRunningActivity\&quot; | head -1 | grep -o \&quot;[a-zA-Z0-9._:]*\&quot; || dumpsys window windows 2&gt;/dev/null | grep -E \&quot;mCurrentFocus|mFocusedApp\&quot; | head -1 | grep -o \&quot;[a-zA-Z0-9._:]*\&quot;); [[ -n \&quot;\$pkg\&quot; ]] &amp;&amp; kill -9 \$(pidof \$pkg 2&gt;/dev/null)'&quot;"
        />
        <item tag="shell"
            name="禁用当前"
            autoRunShell="true"
            click="ztShell:adb shell 'su -c &quot;pkg=\$(dumpsys activity activities 2&gt;/dev/null | grep -E \&quot;ResumedActivity|topRunningActivity\&quot; | head -1 | grep -oE \&quot;[a-zA-Z0-9._-]+/[a-zA-Z0-9._\$-]+\&quot; | cut -d\&quot;/\&quot; -f1 || dumpsys window windows 2&gt;/dev/null | grep -E \&quot;mCurrentFocus|mFocusedApp\&quot; | head -1 | grep -oE \&quot;[a-zA-Z0-9._-]+/[a-zA-Z0-9._\$-]+\&quot; | cut -d\&quot;/\&quot; -f1); [[ -n \&quot;\$pkg\&quot; ]] &amp;&amp; pm disable-user --user 0 \&quot;\$pkg\&quot;&quot;'" />
    </group>

    <group name="shell选择">
        <item tag="shell"
            name="重置连接"
            autoRunShell="true"
            click="ztShell:adb disconnect &amp;&amp;clear" />

        <item tag="shell"
            name="接入本地"
            autoRunShell="true"
            click="ztShell:adb connect 192.168.6.10:5555" />


        <item tag="shell"
            name="接入远程"
            autoRunShell="true"
            click="ztShell:adb connect 24.233.1.203:35555" />


    </group>


    <group name="进入shell">
        <item tag="shell"
            name="进入shell"
            autoRunShell="true"
            click="ztShell:adb shell" />

        <item tag="shell"
            name="su"
            autoRunShell="true"
            click="ztShell:su" />

        <item tag="shell"
            name="回退"
            autoRunShell="true"
            click="ztShell:exit" />

    </group>

    <group name="截屏相关">

        <item tag="shell"
            name="截屏"
            autoRunShell="true"
            click="ztShell:adb exec-out screencap -p > /sdcard/download/screenshot.png" />

        <item tag="shell"
            name="查看截屏"
            icon=""
            activityTitle="本次截屏"
            click="appWebUrl:file:///sdcard/download/screenshot.png" />
    </group>

    <group name="查看基本信息">
        <item tag="shell"
            name="查看当前包名"
            autoRunShell="true"
            click="ztShell:dumpsys activity activities |grep -E ResumedActivity" />

        <item tag="shell"
            name="查看IP"
            autoRunShell="true"
            click="ztShell:ip -4 addr show wlan0 | awk '/inet / {print $2}' | cut -d'/' -f1" />
    </group>


    <group name="针对常用app-shell">

        <item tag="shell"
            name="杀死抖音"
            autoRunShell="true"
            click="ztShell:killall com.ss.android.ugc.aweme" />

        <item tag="shell"
            name="杀死哔哩"
            autoRunShell="true"
            click="ztShell:killall tv.danmaku.bili" />

        <item tag="shell"
            name="杀死微信"
            autoRunShell="true"
            click="ztShell:killall com.tencent.mm" />

        <item tag="shell"
            name="杀死QQ"
            autoRunShell="true"
            click="ztShell:killall com.tencent.mobileqq" />
    </group>

    <group name="音量操作-shell">
        <item tag="shell"
            name="音量↑"
            autoRunShell="true"
            click="ztShell:input keyevent 24" />

        <item tag="shell"
            name="音量↓"
            autoRunShell="true"
            click="ztShell:input keyevent 25" />
    </group>
    <group name="电源操作-shell">

        <item tag="shell"
            name="电源"
            autoRunShell="true"
            click="ztShell:input keyevent 26" />

        <item tag="shell"
            name="息屏"
            autoRunShell="true"
            click="ztShell:input keyevent 6" />

        <item tag="shell"
            name="解锁"
            autoRunShell="true"
            click="ztShell:input keyevent 26&amp;&amp; input keyevent 66&amp;&amp;input text '123123'" />


        <item tag="shell"
            name="重启"
            autoRunShell="true"
            click="ztShell:reboot" />

        <item tag="shell"
            name="关机"
            autoRunShell="true"
            click="ztShell:reboot" />


        <item tag="自定义左侧栏"
            name="修改快捷"
            icon="imgPath:/data/data/com.termux/files/home/ZtInfo/edit_menu.png"
            click="ztEditText:/data/data/com.termux/files/home/ZtInfo/main_menu_path.xml" />


        <!--dialog
        属性只能对于 click 为 ztShell 生效
        dialogConfirm 为 false 则不提示
        -->


    </group>

    <group name="常用功能">
        <item tag="ZT设置"
            click="java:com.termux.zerocore.config.mainmenu.config.ZTSettingsClickConfig" />
    </group>


</zt-menu>
```