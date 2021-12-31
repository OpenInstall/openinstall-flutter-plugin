# openinstall flutter plugin


openinstall插件封装了openinstall平台原生SDK，集成了 **渠道统计,携带参数安装,快速安装与一键拉起** 功能，目前渠道支持 **H5渠道**，**广告平台渠道** 以及 **Apple Search Ads (ASA) 渠道**。  
使用openinstall可实现以下多种场景：  
![实现场景](https://res.cdn.openinstall.io/doc/scene.jpg)  

## 一、配置
前往 [openinstall控制台](https://developer.openinstall.io/) 创建应用并获取 openinstall 为应用分配的` appkey` 和 `scheme` 以及 iOS的关联域名（Associated Domains）  
![appkey和scheme](https://res.cdn.openinstall.io/doc/ios-appkey.png)

### Android 平台配置

#### 配置 appkey
在 `/android/app/build.gradle` 中添加代码设置appkey：
``` groovy
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
修改 `/android/app/src/main/AndroidMenifest.xml` 文件，在跳转 `Activity` 标签内添加 `intent-filter`
``` xml
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>

    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>

    <data android:scheme="openinstall为应用分配的scheme"/>
</intent-filter>
```
如果跳转与启动页面是同一 `Activity` ，则配置示例如图：  
![flutter-android-manifest.jpg](https://res.cdn.openinstall.io/doc/flutter-android-manifest.jpg)

### iOS 平台配置
#### 配置 appkey
在Flutter工程下的 `ios/Runner/Info.plist` 文件中配置 `appKey` 键值对，如下：
``` xml
<key>com.openinstall.APP_KEY</key>
<string>openinstall 分配给应用的 appkey</string>
```
#### 一键拉起配置

##### universal links 相关配置

1. 开启Associated Domains服务

对于iOS，为确保能正常跳转，AppID必须开启Associated Domains功能，请到[苹果开发者网站](https://developer.apple.com/ "苹果开发者网站")，选择Certificate, Identifiers & Profiles，选择相应的AppID，开启Associated Domains。

**注意：当AppID重新编辑过之后，需要更新相应的mobileprovision证书。**

![开启Associated Domains](https://res.cdn.openinstall.io/doc/ios-ulink-1.png)

2.  配置universal links关联域名（iOS 9以后推荐使用）

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

Xcode中快速添加：  
![添加associatedDomains](https://res.cdn.openinstall.io/doc/ios-associated-domains.png)

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

##### scheme 配置
添加应用对应的 scheme，可在工程“TARGETS -> Info -> URL Types” 里快速添加，图文请看

![scheme配置](https://res.cdn.openinstall.io/doc/ios-scheme.png)

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

### 初始化
`init(EventHandler wakeupHandler)`

初始化时，需要传入**拉起回调** 获取 web 端传过来的动态参数

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
### 获取安装参数
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

效果点建立在渠道基础之上，主要用来统计终端用户对某些特殊业务的使用效果。调用此接口时，请使用后台创建的 “效果点ID” 作为 pointId 

示例：
``` dart
_openinstallFlutterPlugin.reportEffectPoint("effect_test", 1);
```

## 三、导出apk/ipa包并上传

集成完毕后，导出iOS/Android安装包上传[openinstall控制台](https://developer.openinstall.io/)，openinstal会检查应用的集成配置  
![上传ipa安装包](https://res.cdn.openinstall.io/doc/upload-ipa-jump.png)


上传完成后即可开始在线模拟测试，体验完整的App安装/跳转流程  
![在线测试](https://res.cdn.openinstall.io/doc/js-test.png)


---

## 广告接入补充文档

### Android平台
1、针对广告平台接入，新增配置接口，在调用 `init` 之前调用。参考 [广告平台对接Android集成指引](https://www.openinstall.io/doc/ad_android.html)  
``` dart
    var adConfig = new Map();
    adConfig["adEnabled"] = true;
	_openinstallFlutterPlugin.configAndroid(adConfig);
```
**注意： `_openinstallFlutterPlugin.config(adEnabled, oaid, gaid)` 接口已废弃，请使用新的配置接口**

可选参数说明：   

| 参数名| 参数类型 | 描述 |  
| --- | --- | --- |
| adEnabled| bool | 广告平台接入开关（必须） |
| macDisabled | bool | 是否禁止 SDK 获取 mac 地址 |
| imeiDisabled | bool | 是否禁止 SDK 获取 imei |
| gaid | string | 通过 google api 获取到的 advertisingId，SDK 将不再获取gaid |
| oaid | string | 通过移动安全联盟获取到的 oaid，SDK 将不再获取oaid |
  
2、针对广告平台，为了精准地匹配到渠道，需要获取设备唯一标识码（IMEI），因此需要在 AndroidManifest.xml 中添加权限声明 
 
```
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
```

3、在权限申请成功后，再进行openinstall初始化。**无论终端用户是否同意，都要调用初始化**  
代码示例如下：  
``` dart
// 使用 permission_handler
if (await Permission.phone.request().isGranted) {
  // 获取到了权限
}
_openinstallFlutterPlugin.init(wakeupHandler);
```
**注意：** `_openinstallFlutterPlugin.init(wakeupHandler, permission);` 接口已废弃，请自行处理权限请求


### iOS平台

#### 广告平台渠道和ASA渠道的配置
1、工程目录下新建plugins文件夹用来存放本地插件，拷贝`openinstall_flutter_plugin`插件到plugins文件夹独自引用

![新建文件夹](https://res.cdn.openinstall.io/doc/flutterForder.png)  

2、在工程中找到pubspec.yaml，修改为本地插件引用方式

![本地插件引用](https://res.cdn.openinstall.io/doc/flutterYaml.png)  

3、将 `ios/Classes/OpeninstallFlutterPlugin.m` 文件替换为 `example/ad-track/OpeninstallFlutterPlugin.m` 文件

![文件替换](https://res.cdn.openinstall.io/doc/flutterAdTrack.png)  

4、需要在Info.plist文件中配置权限  
``` xml
<key>NSUserTrackingUsageDescription</key>
<string>请允许，以获取和使用您的IDFA</string>
```

**备注：** 2021年iOS14.5苹果公司将正式启用idfa新隐私政策，详情可参考：[广告平台对接iOS集成指引](https://www.openinstall.io/doc/ad_ios.html)

ASA渠道相关详细文档参考：[ASA渠道使用指南](https://www.openinstall.io/doc/asa.html)
