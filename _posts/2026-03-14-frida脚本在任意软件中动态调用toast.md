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
## Toast
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

## Dialog

```js
// 动态主题适配 Android 对话框生成器, 但是没有任何效果
setTimeout(function() {
    Java.perform(function() {
        // 检查 Activity 是否处于活动状态
        function isActivityValid(activity) {
            try {
                if (!activity) return false;
                
                // 尝试获取 Activity 的基本属性来验证其有效性
                var activityState = activity.isFinishing ? !activity.isFinishing() : true;
                
                // 验证 Activity 是否还在运行
                try {
                    var packageName = activity.getPackageName ? activity.getPackageName() : 'unknown';
                    return packageName !== 'unknown' && activityState;
                } catch(e_check) {
                    return false;
                }
            } catch(e_valid) {
                return false;
            }
        }
        
        // 获取有效 Activity
        function getValidActivity() {
            try {
                // 尝试获取当前活动的 Activity
                var ActivityThread = Java.use('android.app.ActivityThread');
                var currentActivity = ActivityThread.currentActivity();
                
                if (currentActivity && isActivityValid(currentActivity)) {
                    return currentActivity;
                }
            } catch(e_thread) {}
            
            // 遍历所有 Activity 并验证
            var validActivity = null;
            try {
                Java.choose('android.app.Activity', {
                    onMatch: function(instance) {
                        if (isActivityValid(instance)) {
                            validActivity = instance;
                            return "stop"; // 找到一个就停止
                        }
                    },
                    onComplete: function() {}
                });
            } catch(e_enum) {}
            
            return validActivity;
        }
        
        // 获取可用的主题资源ID
        function getAvailableThemeIds(packageName) {
            try {
                // 获取应用的资源包
                var resources = Java.use('android.app.ActivityThread').currentApplication().getResources();
                var packageManager = Java.use('android.app.ActivityThread').currentApplication().getPackageManager();
                
                // 尝试获取应用定义的可用主题
                var themes = [];
                
                // 尝试通过反射获取应用的主题列表
                var ApplicationInfo = Java.use('android.content.pm.ApplicationInfo');
                var applicationInfo = Java.use('android.app.ActivityThread').currentApplication().getApplicationInfo();
                
                // 添加一些通用的系统主题ID
                var systemThemes = [
                    16973831, // android.R.style.Theme_Dialog
                    16973832, // android.R.style.Theme_Holo_Dialog
                    16973835, // android.R.style.Theme_Holo_Light_Dialog
                    16974072, // android.R.style.Theme_Material_Dialog
                    16974073, // android.R.style.Theme_Material_Light_Dialog
                    16974120, // android.R.style.Theme_DeviceDefault_Dialog
                    16974121, // android.R.style.Theme_DeviceDefault_Light_Dialog
                ];
                
                return systemThemes;
            } catch(e_themes) {
                // 如果获取应用特定主题失败，返回通用系统主题
                return [
                    16973831, // android.R.style.Theme_Dialog
                    16973832, // android.R.style.Theme_Holo_Dialog
                    16973835, // android.R.style.Theme_Holo_Light_Dialog
                    16974072, // android.R.style.Theme_Material_Dialog
                    16974073, // android.R.style.Theme_Material_Light_Dialog
                    16974120, // android.R.style.Theme_DeviceDefault_Dialog
                    16974121, // android.R.style.Theme_DeviceDefault_Light_Dialog
                ];
            }
        }
        
        // 创建兼容的 Context
        function createCompatibleContext(originalContext) {
            try {
                var ContextThemeWrapper = Java.use('android.view.ContextThemeWrapper');
                
                // 获取可用的主题ID列表
                var themeIds = getAvailableThemeIds(originalContext.getPackageName());
                
                // 尝试每个主题ID
                for (var i = 0; i < themeIds.length; i++) {
                    try {
                        var themeId = themeIds[i];
                        var compatibleContext = ContextThemeWrapper.$new(originalContext, themeId);
                        
                        // 测试这个 Context 是否能正常工作
                        compatibleContext.getResources();
                        
                        return compatibleContext;
                    } catch(e_theme) {
                        // 这个主题不行，尝试下一个
                        continue;
                    }
                }
                
                // 如果所有主题都失败，返回原始 Context
                return originalContext;
            } catch(e_wrapper) {
                console.log('[!] Context 包装失败: ' + e_wrapper.toString());
                return originalContext;
            }
        }
        
        // 检测当前 Activity 的主题类型
        function detectActivityTheme(activity) {
            try {
                var theme = activity.getTheme();
                var themeResId = activity.getThemeResource();
                
                // 简单检测主题类型
                var themeString = themeResId.toString();
                
                if (themeString.includes('AppCompat')) {
                    return 'appcompat';
                } else if (themeString.includes('Material')) {
                    return 'material';
                } else if (themeString.includes('Holo')) {
                    return 'holo';
                } else {
                    return 'default';
                }
            } catch(e_detect) {
                return 'unknown';
            }
        }
        
        // 显示主题兼容对话框
        function showDialog(title, message, cancelable, positiveBtnText, negativeBtnText) {
            var activity = getValidActivity();
            
            if (!activity) {
                console.log('[!] 未找到有效的 Activity 上下文，应用可能不在前台或已暂停');
                
                // 使用 Toast 作为最后手段
                try {
                    var appContext = Java.use('android.app.ActivityThread').currentApplication().getApplicationContext();
                    var Toast = Java.use('android.widget.Toast');
                    var text = (title ? title + ': ' : '') + (message || '提示');
                    var toast = Toast.makeText(appContext, Java.use('java.lang.String').$new(text), 1);
                    toast.show();
                    
                    console.log('[!] 已使用 Toast 显示消息');
                    return;
                } catch(e_toast) {
                    console.log('[!] 无法显示任何对话框或通知');
                    return;
                }
            }
            
            Java.perform(function() {
                Java.scheduleOnMainThread(function() {
                    try {
                        // 确认 Activity 仍然有效
                        if (!isActivityValid(activity)) {
                            console.log('[!] Activity 上下文已失效');
                            return;
                        }
                        
                        // 检测当前 Activity 的主题
                        var detectedTheme = detectActivityTheme(activity);
                        console.log('[i] 检测到 Activity 主题类型: ' + detectedTheme);
                        
                        // 尝试使用兼容的 Context
                        var compatibleContext = createCompatibleContext(activity);
                        
                        // 根据检测到的主题类型决定使用哪种 AlertDialog
                        var AlertDialogBuilder, AlertDialog;
                        
                        if (detectedTheme === 'appcompat') {
                            // 尝试 AppCompat AlertDialog
                            try {
                                AlertDialogBuilder = Java.use('androidx.appcompat.app.AlertDialog$Builder');
                                AlertDialog = Java.use('androidx.appcompat.app.AlertDialog');
                                
                                // 创建字符串对象
                                var StringClass = Java.use('java.lang.String');
                                var titleStr = title ? StringClass.$new(title) : null;
                                var messageStr = message ? StringClass.$new(message) : null;
                                var positiveStr = positiveBtnText ? StringClass.$new(positiveBtnText) : null;
                                var negativeStr = negativeBtnText ? StringClass.$new(negativeBtnText) : null;
                                
                                // 创建 Builder - 使用兼容的 Context
                                var builder = AlertDialogBuilder.$new(compatibleContext);
                                
                                // 设置标题和消息
                                if (titleStr) {
                                    builder.setTitle(titleStr);
                                }
                                if (messageStr) {
                                    builder.setMessage(messageStr);
                                }
                                
                                // 设置是否可取消
                                builder.setCancelable(cancelable);
                                
                                // 设置按钮
                                if (positiveStr) {
                                    var positiveListener = Java.registerClass({
                                        name: 'frida.PositiveClickListener',
                                        implements: [Java.use('android.content.DialogInterface$OnClickListener')],
                                        methods: {
                                            onClick: function(dialog, which) {
                                                dialog.dismiss();
                                            }
                                        }
                                    });
                                    builder.setPositiveButton(positiveStr, positiveListener.$new());
                                }
                                
                                if (negativeStr) {
                                    var negativeListener = Java.registerClass({
                                        name: 'frida.NegativeClickListener',
                                        implements: [Java.use('android.content.DialogInterface$OnClickListener')],
                                        methods: {
                                            onClick: function(dialog, which) {
                                                dialog.dismiss();
                                            }
                                        }
                                    });
                                    builder.setNegativeButton(negativeStr, negativeListener.$new());
                                }
                                
                                // 显示对话框
                                var dialog = builder.create();
                                dialog.show();
                                
                                return; // 成功显示，退出函数
                            } catch(e_appcompat) {
                                console.log('[!] AppCompat Dialog 失败: ' + e_appcompat.toString());
                            }
                        }
                        
                        // 尝试原生 AlertDialog（适用于非 AppCompat 主题）
                        try {
                            var NativeAlertDialogBuilder = Java.use('android.app.AlertDialog$Builder');
                            var NativeAlertDialog = Java.use('android.app.AlertDialog');
                            
                            // 创建字符串对象
                            var StringClass = Java.use('java.lang.String');
                            var titleStr = title ? StringClass.$new(title) : null;
                            var messageStr = message ? StringClass.$new(message) : null;
                            var positiveStr = positiveBtnText ? StringClass.$new(positiveBtnText) : null;
                            var negativeStr = negativeBtnText ? StringClass.$new(negativeBtnText) : null;
                            
                            // 使用原始 Activity Context 创建 Builder
                            var builder = NativeAlertDialogBuilder.$new(activity);
                            
                            // 设置标题和消息
                            if (titleStr) {
                                builder.setTitle(titleStr);
                            }
                            if (messageStr) {
                                builder.setMessage(messageStr);
                            }
                            
                            // 设置是否可取消
                            builder.setCancelable(cancelable);
                            
                            // 设置按钮
                            if (positiveStr) {
                                var positiveListener = Java.registerClass({
                                    name: 'frida.NativePositiveClickListener',
                                    implements: [Java.use('android.content.DialogInterface$OnClickListener')],
                                    methods: {
                                        onClick: function(dialog, which) {
                                            dialog.dismiss();
                                        }
                                    }
                                });
                                builder.setPositiveButton(positiveStr, positiveListener.$new());
                            }
                            
                            if (negativeStr) {
                                var negativeListener = Java.registerClass({
                                    name: 'frida.NativeNegativeClickListener',
                                    implements: [Java.use('android.content.DialogInterface$OnClickListener')],
                                    methods: {
                                        onClick: function(dialog, which) {
                                            dialog.dismiss();
                                        }
                                    }
                                });
                                builder.setNegativeButton(negativeStr, negativeListener.$new());
                            }
                            
                            // 显示对话框
                            var dialog = builder.create();
                            dialog.show();
                            
                        } catch(e_native) {
                            console.log('[!] 原生 AlertDialog 也失败: ' + e_native.toString());
                            
                            // 最后回退到自定义 Dialog
                            var Dialog = Java.use('android.app.Dialog');
                            var TextView = Java.use('android.widget.TextView');
                            var LinearLayout = Java.use('android.widget.LinearLayout');
                            var Button = Java.use('android.widget.Button');
                            
                            // 创建 Dialog
                            var dialog = Dialog.$new(activity);
                            dialog.requestWindowFeature(1); // FEATURE_NO_TITLE
                            dialog.setCancelable(cancelable);
                            
                            // 创建布局
                            var layout = LinearLayout.$new(activity);
                            layout.setOrientation(1);
                            
                            // 添加内容
                            if (title && title.length > 0) {
                                var titleView = TextView.$new(activity);
                                titleView.setText(Java.use('java.lang.String').$new(title));
                                titleView.setTextSize(18);
                                titleView.setPadding(30, 30, 30, 15);
                                layout.addView(titleView);
                            }
                            
                            if (message && message.length > 0) {
                                var messageView = TextView.$new(activity);
                                messageView.setText(Java.use('java.lang.String').$new(message));
                                messageView.setTextSize(14);
                                messageView.setPadding(30, 15, 30, 15);
                                layout.addView(messageView);
                            }
                            
                            // 添加按钮
                            if (positiveBtnText) {
                                var btn = Button.$new(activity);
                                btn.setText(Java.use('java.lang.String').$new(positiveBtnText));
                                
                                var OnClickListener = Java.use('android.view.View$OnClickListener');
                                var listener = Java.registerClass({
                                    name: 'frida.CustomDialogButtonClickListener',
                                    implements: [OnClickListener],
                                    methods: {
                                        onClick: function(view) {
                                            dialog.dismiss();
                                        }
                                    }
                                });
                                
                                btn.setOnClickListener(listener.$new());
                                layout.addView(btn);
                            }
                            
                            // 设置布局并显示
                            dialog.setContentView(layout);
                            dialog.show();
                        }
                        
                    } catch(e_dialog) {
                        console.log('[!] 对话框显示失败: ' + e_dialog.toString());
                        
                        // 最终回退到 Toast
                        try {
                            var Toast = Java.use('android.widget.Toast');
                            var text = (title ? title + ': ' : '') + (message || '提示');
                            var toast = Toast.makeText(activity, Java.use('java.lang.String').$new(text), 1);
                            toast.show();
                        } catch(e_toast) {
                            console.log('[!] Toast 也失败: ' + e_toast.toString());
                        }
                    }
                });
            });
        }
        
        // RPC 接口
        rpc.exports = {
            showDialog: function(config) {
                var title = config.title || "";
                var message = config.message || "";
                var cancelable = config.cancelable !== undefined ? config.cancelable : true;
                var positiveBtnText = config.positiveBtnText || null;
                var negativeBtnText = config.negativeBtnText || null;
                
                showDialog(title, message, cancelable, positiveBtnText, negativeBtnText);
            },
            
            showConfirmDialog: function(title, message) {
                showDialog(title, message, true, "确定", "取消");
            },
            
            showAlertDialog: function(title, message) {
                showDialog(title, message, true, "确定", null);
            },
            
            showDialogUncancelable: function(title, message) {
                showDialog(title, message, false, "确定", null);
            },
            
            ping: function() {
                return 'dialog pong';
            },
            
            getContextStatus: function() {
                var activity = getValidActivity();
                var themeType = activity ? detectActivityTheme(activity) : 'none';
                return {
                    hasValidContext: !!activity,
                    contextClass: activity ? activity.getClass().getName() : 'null',
                    contextValid: activity ? isActivityValid(activity) : false,
                    detectedTheme: themeType
                };
            }
        };
    });
    
    console.log('');
    console.log('╔════════════════════════════════════════════════════════════════════╗');
    console.log('║                  动态主题适配对话框生成器已加载                   ║');
    console.log('╠════════════════════════════════════════════════════════════════════╣');
    console.log('║                                                                ║');
    console.log('║ 用法示例:                                                       ║');
    console.log('║ > rpc.exports.showAlertDialog("标题","消息内容")                   ║');
    console.log('║ > rpc.exports.showConfirmDialog("确认","是否继续?")                ║');
    console.log('║ > rpc.exports.showDialogUncancelable("提醒","不能取消的对话框")      ║');
    console.log('║ > rpc.exports.showDialog({                                      ║');
    console.log('║     title: "自定义",                                           ║');
    console.log('║     message: "内容",                                           ║');
    console.log('║     cancelable: false,  // false=不可点击外部取消, true=可取消   ║');
    console.log('║     positiveBtnText: "确定",                                   ║');
    console.log('║     negativeBtnText: "取消"                                    ║');
    console.log('║   })                                                           ║');
    console.log('║                                                                ║');
    console.log('║ 注意: 自动检测 Activity 主题类型并适配合适的对话框实现              ║');
    console.log('╚════════════════════════════════════════════════════════════════════╝');
    console.log('');
}, 100);
```