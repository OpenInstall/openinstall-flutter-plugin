# openinstall flutter plugin

## 配置
请先从 [openinstall平台](https://developer.openinstall.io/) 申请开发者账号并创建应用，获取 `AppKey` 和 `scheme`

### Android 平台配置

#### 配置appkey
在 `/android/app/build.gradle` 中添加下列代码：
``` gradle
android: {
  ....
  defaultConfig {
    ...
    manifestPlaceholders = [
        OPENINSTALL_APPKEY : "openinstall为应用分配的appkey",
    ]
  }    
}
```

#### 配置 scheme
修改 `/android/app/src/main/AndroidMenifest.xml` 文件，在 `activity` 标签内添加 `intent-filter` (一般为 `MainActivity`)
``` xml
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>

    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>

    <data android:scheme="openinstall为应用分配的scheme"/>
</intent-filter>
```

### iOS 平台配置
#### 配置APP_KEY
在Flutter工程下的 `ios/Runner/Info.plist` 文件中配置 `appKey` 键值对，如下：
``` xml
<key>com.openinstall.APP_KEY</key>
<string>openinstall 分配给应用的 appkey</string>
```
#### 以下为 一键拉起 功能相关配置和代码

##### universal links 相关配置

* 开启Associated Domains服务

对于iOS，为确保能正常跳转，AppID必须开启Associated Domains功能，请到[苹果开发者网站](https://developer.apple.com/ "苹果开发者网站")，选择Certificate, Identifiers & Profiles，选择相应的AppID，开启Associated Domains。注意：当AppID重新编辑过之后，需要更新相应的mobileprovision证书。(图文配置步骤请看[iOS集成指南](https://www.openinstall.io/doc/ios_sdk.html "iOS集成指南"))。

* 配置universal links关联域名（iOS 9以后推荐使用）

关联域名(Associated Domains) 的值请在openinstall控制台获取（openinstall应用控制台->iOS集成->iOS应用配置）

该文件是给iOS平台配置的文件，在 ios/Runner 目录下创建文件名为 Runner.entitlements 的文件，Runner.entitlements 内容如下：

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.associated-domains</key><!--固定key值-->
    <array>
        <!--这里换成你在openinstall后台的关联域名(Associated Domains)-->
        <string>applinks:xxxxxx.openinstall.io</string>
    </array>
</dict>
</plist>
```

* 在 `ios/Runner/AppDelegate.m` 中添加通用链接（Universal Link）回调方法，委托插件来处理：

在头部引入
``` objc
#import <openinstall_flutter_plugin/OpeninstallFlutterPlugin.h>

```
添加如下方法
``` objc
//添加此方法以获取拉起参数
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
    //判断是否通过OpenInstall Universal Link 唤起App
    if ([OpeninstallFlutterPlugin continueUserActivity:userActivity]){//如果使用了Universal link ，此方法必写
        return YES;
    }
    //其他第三方回调；
    return YES;
}
```

##### scheme 配置
在 `ios/Runner/Info.plist` 文件中，在 `CFBundleURLTypes` 数组中添加应用对应的 scheme，或者在工程“TARGETS -> Info -> URL Types” 里快速添加，图文配置请看 [iOS集成指南](https://www.openinstall.io/doc/ios_sdk.html "iOS集成指南")
``` xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>openinstall</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>"从openinstall官网后台获取应用的scheme"</string>
        </array>
    </dict>
</array>
```

在 `ios/Runner/AppDelegate.m` 中头部引入：
``` objc
#import <openinstall_flutter_plugin/OpeninstallFlutterPlugin.h>
```
在 `ios/Runner/AppDelegate.m` 中添加方法：
``` objc
//适用目前所有iOS版本
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    //判断是否通过OpenInstall URL Scheme 唤起App
    if([OpeninstallFlutterPlugin handLinkURL:url]){//必写
        return YES;
    }
    //其他第三方回调；
    return YES;
}
//iOS9以上，会优先走这个方法
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary *)options{
    //判断是否通过OpenInstall URL Scheme 唤起App
    if  ([OpeninstallFlutterPlugin handLinkURL:url]){//必写
        return YES;
    }
    //其他第三方回调；
    return YES;
}
```

## 使用

#### 初始化
`init(EventHandler wakeupHandler)`

初始化时，需要传入**拉起回调**获取 web 端传过来的动态参数

示例：
``` dart
Future wakeupHandler(Map<String, dynamic> data) async {
    setState(() {
        debugLog = "wakeup result : channel=" +
            data['channelCode'] +
            ", data=" +
            data['bindData'];
    });
}

_openinstallFlutterPlugin.init(wakeupHandler);
```
#### 获取安装参数
`install(EventHandler installHandler, [int seconds = 10])`

在 APP 需要安装参数时（由 web 网页中传递过来的，如邀请码、游戏房间号等动态参数），调用此接口，在回调中获取参数

示例：
``` dart

Future installHandler(Map<String, dynamic> data) async {
    setState(() {
        debugLog = "install result : channel=" +
            data['channelCode'] +
            ", data=" +
            data['bindData'];
    });
}

_openinstallFlutterPlugin.install(installHandler);

```
#### 注册统计
`reportRegister()`

如需统计每个渠道的注册量（对评估渠道质量很重要），可根据自身的业务规则，在确保用户完成 APP 注册的情况下调用此接口

示例：
``` dart
_openinstallFlutterPlugin.reportRegister();
```
#### 效果点统计
`reportEffectPoint(String pointId, int pointValue)`  

效果点建立在渠道基础之上，主要用来统计终端用户对某些特殊业务的使用效果。调用此接口时，请使用后台创建的 “效果点ID” 作为pointId 

示例：
``` dart
_openinstallFlutterPlugin.reportEffectPoint("effect_test", 1);
```