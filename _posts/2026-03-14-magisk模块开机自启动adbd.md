---
title: magisk模块开机自启动adbd
date: 2026-03-14 10:23:24 +0800
comments: true
tags:
  - magisk模块
  - 千问大模型
  - AI
categories:
  - magisk模块
description: 让手机开机自启动adbd监听5555端口, 就算服务被杀掉了也会2秒后重启
pin: false
math: false
mermaid: false
---
点击下载: [adb_tcp](obsidian/attachments/adb_tcp.zip)

本质是开机自动执行以下代码
```shell
#!/system/bin/sh

# 确保脚本以 root 运行
[ "$(id -u)" = "0" ] || exit 1

LOG_TAG="ADB_TCP_AUTO"
log() {
    echo "[$LOG_TAG] $*" >> /data/adb/adb_tcp.log
}

log "Starting ADB over TCP auto-restart service..."

# 设置 ADB TCP 端口
setprop service.adb.tcp.port 5555

# 等待系统初始化完成（避免过早操作）
sleep 10

# 启动 adbd 初始状态
stop adbd 2>/dev/null
start adbd 2>/dev/null
log "Initial adbd started."

# 后台循环监控
(
while true; do
    # 检查 5555 端口是否被 adbd 监听
    # netstat 输出示例: tcp6 0 0 :::5555 :::* LISTEN
    if ! netstat -tuln 2>/dev/null | grep -q ':5555 .*LISTEN'; then
        log "Port 5555 not listening. Restarting adbd..."
        stop adbd 2>/dev/null
        start adbd 2>/dev/null
        sleep 1
        # 再次确认
        if netstat -tuln 2>/dev/null | grep -q ':5555 .*LISTEN'; then
            log "adbd restarted successfully."
        else
            log "Failed to restart adbd or port still not open."
        fi
    fi
    sleep 2
done
) &

log "Monitor loop started in background."
```
