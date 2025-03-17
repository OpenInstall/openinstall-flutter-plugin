## 2.5.4
iOS reportShare bug修复

## 2.5.3
Android 更新 SDK 到 2.8.5

## 2.5.2
iOS 补充getOpid获取

## 2.5.1
Android 更新 SDK 到 2.8.4

## 2.5.0
Android 更新 SDK 到 2.8.3    
彻底移除了废弃的接口

## 2.4.4
iOS 集成文档更新

## 2.4.3
iOS 更新本地pod库使SDK升级到2.8.1

## 2.4.2
Android 更新 SDK 到 2.8.2

## 2.4.1
Android 更新 SDK 到 2.8.1   
iOS 更新本地pod库使SDK升级到2.8.0

## 2.4.0
新增裂变分享统计  
getInstall新增返回码shouldRetry，超时返回true  
Android 更新 SDK 到 2.8.0   
iOS 更新本地pod库使SDK升级到2.7.0

## 2.3.1
 iOS  
 端整合了广告平台和ASA统计相关代码，并且由用户手动初始化SDK；   
 广告和ASA详细配置请看文档，由flutter端控制并传参数并给SDK；  
 解决了广告平台统计时，获取隐私权限的弹窗无法弹窗的问题；  
 集成了之前版本插件的用户，注意可能要info.plist配置隐私权限申请。  

## 2.3.0
新增效果点明细API  
Android 更新 SDK 到 2.7.0   
iOS端插件升级后，需要从cocoapod同步升级原生SDK到2.6.0以上

## 2.2.3
Android 更新 SDK 到 2.6.4

## 2.2.2
Android 更新 SDK 到 2.6.3   
iOS 更新 SDK 到 2.5.5   
将 dynamic 替换为 Object

## 2.2.1
Android 更新内容
- 更新 SDK 到 2.6.2
- 解决特殊情况下拉起无回调的问题

## 2.2.0
Android SDK 更新内容
- 优化匹配数据获取，提升参数还原精度
- 适配安卓应用宝 AppLink 功能

## 2.1.3
Android SDK 更新内容   
- 优化初始化逻辑
- 优化匹配逻辑，提升参数还原精度

## 2.1.2
更新ASA集成代码和文档

## 2.1.1
优化文档和示例

## 2.1.0
IOS SDK更新内容
- 增加对ASA渠道的支持

Android SDK更新内容
- 优化广告平台配置

## 2.0.4
修复iOS SDK初始化方法未调用的问题

## 2.0.3
修复插件唤醒回调失败

## 2.0.2
iOS SDK更新到2.5.3版本，优化参数还原精度  
修复json转换报错的问题

## 2.0.1
Android 使用 flutter v2 api

## 2.0.0
支持新特性 null safety

## 1.4.4
Android SDK 更新内容  
- 优化匹配逻辑，提升参数还原精度
- 修复了特殊情况下网络请求异常的问题

## 1.4.3
更新与广告接入相关文件，example/ad-track/OpeninstallFlutterPlugin.m文件

## 1.4.2
SDK 更新内容
- 提升数据安全性
- 优化匹配逻辑

## 1.4.1
修复上次升级导致的 android 编译错误

## 1.4.0
建议所有用户升级

SDK 更新内容
- 优化网络请求
- 优化统计上报

## 1.3.3
iOS 更新内容
- 修复openinstall插件与其它使用了拉起代理的插件兼容问题
- 如果用户是需要在AppDelegate里统一处理拉起代理逻辑，可根据文档直接在AppDelegate中添加相关代码

## 1.3.2
Android 更新内容
- 更新 SDK 到 2.5.0
- 优化拉起处理

## 1.3.1
iOS 更新内容
- 优化了集成流程，用户不需要集成原生代码，如果用户是需要在AppDelegate里统一处理拉起代理逻辑，可根据文档直接在AppDelegate添加相关代码
- 使用之前版本（<1.3.1）的用户，升级插件后，无需修改代码

## 1.3.0
建议所有用户升级

Android 更新内容
- 新增广告平台渠道监测功能
- 提升sdk稳定性

iOS 更新内容
- 新增广告平台渠道监测功能
- 适配iOS14

## 1.2.2
更新Android sdk和iOS sdk

Android 2.3.2 更新内容
- 优化Google Play数据还原
- 优化注册统计

iOS 2.3.1 更新内容
- 优化了SDK逻辑
- 优化了注册统计上报策略

## 1.2.1
修改 OpeninstallFlutterPlugin 为单例

## 1.2.0
更新 Android SDK 到 2.3.1

Android 2.3.1 更新内容  
- 优化初始化逻辑
- 优化携带参数安装
- 针对Google Play，提升参数还原精度

## 1.1.5
完善文档

## 1.1.4
解决iOS客户端杀死情况下的拉起失败

## 1.1.3
Android特殊情况下导致的初始化失败

## 1.1.2
修复ios编译错误

## 1.1.0
更新 openinstall SDK 到 2.3.0

## 1.0.1

修改插件描述

完善iOS示例

## 1.0.0

优化代码

## 0.0.1

提供携带参数安装功能

提供渠道统计功能

提供一键跳转功能




