---
title: frida脚本在任意软件中动态调用toast
date: 2026-03-14 18:17:33 +0800
comments: true
tags:
  - 千问大模型
  - AI
  - 脚本
  - javascript
  - 动态调试
categories: []
description:
pin: false
math: false
mermaid: false
---
代码如下:
```js
// 带用法示例的 Android Toast 显示器
setTimeout(function() {
    Java.perform(function() {
        var context = null;
        var initialized = false;
        
        // 静默初始化上下文
        function initContext() {
            try {
                var ActivityThread = Java.use('android.app.ActivityThread');
                var app = ActivityThread.currentApplication();
                if (app) {
                    context = app.getApplicationContext();
                    initialized = true;
                    return;
                }
            } catch(e) {}
            
            try {
                Java.choose('android.app.Activity', {
                    onMatch: function(instance) {
                        if (instance && !context) {
                            try {
                                context = instance.getApplicationContext();
                                if (context) {
                                    initialized = true;
                                }
                            } catch(e) {}
                        }
                    },
                    onComplete: function() {}
                });
            } catch(e) {}
        }
        
        // 静默 Toast 显示
        function showToastSilent(message, duration) {
            if (!initialized) {
                initContext();
                if (!initialized) return;
            }
            
            if (!context) return;
            
            Java.perform(function() {
                try {
                    var Toast = Java.use('android.widget.Toast');
                    var String = Java.use('java.lang.String');
                    
                    var javaMsg = String.$new(message);
                    var durationValue = (duration === 'long') ? 1 : 0;
                    
                    Java.scheduleOnMainThread(function() {
                        try {
                            var toast = Toast.makeText(context, javaMsg, durationValue);
                            toast.show();
                        } catch(e_make) {
                            try {
                                var toastInstance = Toast.$new();
                                toastInstance.setContext(context);
                                toastInstance.setText(javaMsg);
                                toastInstance.setDuration(durationValue);
                                toastInstance.show();
                            } catch(e_construct) {}
                        }
                    });
                } catch(e) {}
            });
        }
        
        // 初始化
        initContext();
        
        // RPC 接口
        rpc.exports = {
            showToast: function(message, duration) {
                showToastSilent(message, duration || 'short');
            },
            
            showToasts: function(messages) {
                messages.forEach(function(msg, index) {
                    var text = typeof msg === 'string' ? msg : (msg.text || "默认");
                    var dur = (typeof msg === 'object' && msg.duration === 'long') ? 'long' : 'short';
                    
                    setTimeout(function() {
                        showToastSilent(text, dur);
                    }, index * 600);
                });
            },
            
            ping: function() {
                return 'pong';
            },
            
            getContextStatus: function() {
                return {
                    initialized: initialized,
                    hasContext: !!context,
                    contextClass: context ? context.getClass().getName() : 'null'
                };
            },
            
            forceInit: function() {
                initialized = false;
                context = null;
                initContext();
                return this.getContextStatus();
            }
        };
    });
    
    // 显示用法示例
    console.log('');
    console.log('╔════════════════════════════════════════════════╗');
    console.log('║              Toast 显示器已加载              ║');
    console.log('╠════════════════════════════════════════════════╣');
    console.log('║                                            ║');
    console.log('║ 用法示例:                                   ║');
    console.log('║ > rpc.exports.showToast("Hello World","long") ║');
    console.log('║ > rpc.exports.showToast("短消息","short")       ║');
    console.log('║ > rpc.exports.showToasts(["消息1","消息2"])     ║');
    console.log('║ > rpc.exports.ping()                        ║');
    console.log('║ > rpc.exports.getContextStatus()             ║');
    console.log('║                                            ║');
    console.log('╚════════════════════════════════════════════════╝');
    console.log('');
}, 100);
```