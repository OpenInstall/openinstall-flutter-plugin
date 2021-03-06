# openinstall flutter plugin

## 一、配置
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

对于iOS，为确保能正常跳转，AppID必须开启Associated Domains功能，请到[苹果开发者网站](https://developer.apple.com/ "苹果开发者网站")，选择Certificate, Identifiers & Profiles，选择相应的AppID，开启Associated Domains。注意：当AppID重新编辑过之后，需要更新相应的mobileprovision证书。(图文配置步骤请看[Flutter接入指南](https://www.openinstall.io/doc/flutter_sdk.html "iOS集成指南"))。

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

**注意：插件版本>=1.3.1开始，iOS通用链接原生代码已在插件内部完成**  
1） 1.3.1之前版本升级后可不做任何改动  
2）首次集成插件的用户，如果拉起无法获取到参数，是因为方法被其它插件覆盖导致（openinstall插件不会覆盖其它插件），可以有两种方法解决：  
- 第一种方法，提早加载openinstall插件，无效的话使用第二种方法  
- 第二种方法，将所有插件的拉起代理方法的逻辑，统一在AppDelegate文件中来处理，代码如下：  

在头部引入
``` objc
//如果是swift，请在桥接文件（一般命名为XXX-Bridging-Header.h）中引入
#import <openinstall_flutter_plugin/OpeninstallFlutterPlugin.h>

```
添加如下方法  
``` objc
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
    //处理通过openinstall一键唤起App时传递的数据
    [OpeninstallFlutterPlugin continueUserActivity:userActivity];
    //其他第三方回调:
    return YES;
}
```
swift代码：  
``` swift
//swift4.2之前版本
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool{
    //处理通过openinstall一键唤起App时传递的数据
    OpeninstallFlutterPlugin.continue(userActivity)
    //其他第三方回调:
    return true
}
//swift4.2版本开始，系统方法修改为：
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool{
    //处理通过openinstall一键唤起App时传递的数据
    OpeninstallFlutterPlugin.continue(userActivity)
    //其他第三方回调:
    return true
}
```


- **openinstall完全兼容微信openSDK1.8.6以上版本的通用链接跳转功能，详情请看[iOS常见问题](https://www.openinstall.io/doc/ios_sdk_faq.html)**

##### scheme 配置
在 `ios/Runner/Info.plist` 文件中，在 `CFBundleURLTypes` 数组中添加应用对应的 scheme，或者在工程“TARGETS -> Info -> URL Types” 里快速添加，图文配置请看 [Flutter接入指南](https://www.openinstall.io/doc/flutter_sdk.html "iOS集成指南")
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

**注意：插件版本>=1.3.1开始，iOS通用链接原生代码已在插件内部完成**  
1） 1.3.1之前版本升级后可不做任何改动  
2）首次集成插件的用户，如果拉起无法获取到参数，是因为方法被其它插件覆盖导致（openinstall插件不会覆盖其它插件），可以有两种方法解决：  
- 第一种方法，提早加载openinstall插件，无效的话使用第二种方法  
- 第二种方法，将所有插件的拉起代理方法的逻辑，统一在AppDelegate文件中来处理，代码如下：  

在 `ios/Runner/AppDelegate.m` 中头部引入：
``` objc
//如果是swift，请在桥接文件（一般命名为XXX-Bridging-Header.h）中引入
#import <openinstall_flutter_plugin/OpeninstallFlutterPlugin.h>
```

在 `ios/Runner/AppDelegate.m` 中添加方法：  

``` objc
//适用目前所有iOS版本
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    //判断是否通过OpenInstall URL Scheme 唤起App
    [OpeninstallFlutterPlugin handLinkURL:url];
    //其他第三方回调；
    return YES;
}

//iOS9以上，会优先走这个方法
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary *)options{
    //判断是否通过OpenInstall URL Scheme 唤起App
    [OpeninstallFlutterPlugin handLinkURL:url];
    //其他第三方回调；
     return YES;
}
```

swift代码：  
``` swift
//swift引用OC方法时，最好根据系统代码提示来写
//适用目前所有iOS版本
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        OpeninstallFlutterPlugin.handLinkURL(url)
        return true
    }
//iOS9以上，会优先走这个方法
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        OpeninstallFlutterPlugin.handLinkURL(url)
        return true
    }
//注意，swift4.2版本开始，系统方法修改为：
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool{}
```

## 二、使用

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

## 三、导出apk/api包并上传
- 代码集成完毕后，需要导出安装包上传openinstall后台，openinstall会自动完成所有的应用配置工作。  
- 上传完成后即可开始在线模拟测试，体验完整的App安装/拉起流程；待测试无误后，再完善下载配置信息。


---

## 广告接入补充文档

### Android平台
#### 广告平台配置
针对广告平台接入，新增配置接口，在调用 `init` 之前调用。参考 [广告平台对接Android集成指引](https://www.openinstall.io/doc/ad_android.html)  
``` js
    /**
    * adEnabled 为 true 表示 openinstall 需要获取广告追踪相关参数，默认为 false
    * oaid 为 null 时，表示交由 openinstall 获取 oaid， 默认为 null
    * gaid 为 null 时，表示交由 openinstall 获取 gaid， 默认为 null
    */
    _openinstallFlutterPlugin.config(true, "通过移动安全联盟获取到的 oaid", "通过 google api 获取到的 advertisingId");
```
例如： 开发者自己获取到了 oaid，但是需要 openinstall 获取 gaid，则调用代码为
``` js
    // f32a09dc-3312-d43e-6583-62fac13f33ae 是通过移动安全联盟获取到的 oaid
    _openinstallFlutterPlugin.config(true, "f32a09dc-3312-d43e-6583-62fac13f33ae", null);
```
#### 设备唯一标识码获取  
针对广告平台，为了精准地匹配到渠道，需要获取设备唯一标识码（IMEI），因此需要做额外的权限申请。  
1、声明权限    
在 `AndroidMainfest.xml` 配置文件中添加了需要申请的权限 `<uses-permission android:name="android.permission.READ_PHONE_STATE"/>`

2、申请权限并初始化  
可使用插件提供的 api 进行权限申请，调用初始化 api，第二个参数 `permission=true` 表示插件进行权限申请
``` dart
_openinstallFlutterPlugin.init(wakeupHandler, true);
```
也可在 `Flutter` 自行进行权限申请，只需要确保在初始化之前申请权限，例如
``` dart
// 使用 permission_handler
if (await Permission.phone.request().isGranted) {
  // 获取到了权限
}
_openinstallFlutterPlugin.init(wakeupHandler);
```

### iOS平台

1、将 `ios/Classes/OpeninstallFlutterPlugin.m` 文件替换为 `example/ad-track/OpeninstallFlutterPlugin.m` 文件

2、需要在Info.plist文件中配置权限  
``` xml
<key>NSUserTrackingUsageDescription</key>
<string>请允许，以获取和使用您的IDFA</string>
```

备注：2021年iOS14.5苹果公司将正式启用idfa新隐私政策，详情可参考：[广告平台对接iOS集成指引](https://www.openinstall.io/doc/ad_ios.html)
