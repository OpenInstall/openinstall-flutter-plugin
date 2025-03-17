#import <UIKit/UIKit.h>

#import "OpeninstallFlutterPlugin.h"

#import "OpenInstallSDK.h"
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>//苹果新隐私政策
#import <AdServices/AAAttribution.h>//ASA

typedef NS_ENUM(NSUInteger, OpenInstallSDKPluginMethod) {
    OpenInstallSDKMethodInit,
    OpenInstallSDKMethodGetInstallParams,
    OpenInstallSDKMethodReportRegister,
    OpenInstallSDKMethodReportEffectPoint,
    OpenInstallSDKMethodConfig,
    OpenInstallSDKMethodReportShare,
    OpenInstallSDKMethodGetOpid
};

@interface OpeninstallFlutterPlugin () <OpenInstallDelegate>
@property (strong, nonatomic, readonly) NSDictionary *methodDict;
@property (strong, nonatomic) FlutterMethodChannel * flutterMethodChannel;
@property (assign, nonatomic) BOOL isOnWakeup;
@property (copy, nonatomic)NSDictionary *cacheDic;

@property (assign, nonatomic) BOOL adEnable;//必要，是否开启广告平台统计功能
@property (assign, nonatomic) BOOL ASAEnable;//必要，是否开启苹果ASA功能
@property (assign, nonatomic) BOOL ASADebug;//可选，ASA测试debug模式，注意：正式环境中请务必关闭
@property (copy, nonatomic) NSString *idfaStr;//可选，通过其它插件获取的idfa字符串一般格式为xxxx-xxxx-xxxx-xxxx

@end

static FlutterMethodChannel * FLUTTER_METHOD_CHANNEL;

@implementation OpeninstallFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel * channel = [FlutterMethodChannel methodChannelWithName:@"openinstall_flutter_plugin" binaryMessenger:[registrar messenger]];
    OpeninstallFlutterPlugin* instance = [[OpeninstallFlutterPlugin alloc] init];
    [registrar addApplicationDelegate:instance];
    instance.flutterMethodChannel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)initData {
    _methodDict = @{
                    @"registerWakeup"         :      @(OpenInstallSDKMethodInit),
                    @"getInstall"             :      @(OpenInstallSDKMethodGetInstallParams),
                    @"reportRegister"         :      @(OpenInstallSDKMethodReportRegister),
                    @"reportEffectPoint"      :      @(OpenInstallSDKMethodReportEffectPoint),
                    @"config"                 :      @(OpenInstallSDKMethodConfig),
                    @"reportShare"            :      @(OpenInstallSDKMethodReportShare),
                    @"getOpid"                :      @(OpenInstallSDKMethodGetOpid)
                    };
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSNumber *methodType = self.methodDict[call.method];
    if (methodType) {
        switch (methodType.intValue) {
            case OpenInstallSDKMethodInit:
            {
                [self initOpenInstall];
                
                NSDictionary *dict;
                @synchronized(self){
                    if (self.cacheDic) {
                        dict = [self.cacheDic copy];
                    }
                }
                self.isOnWakeup = YES;
                if (dict.count != 0) {
                    [self.flutterMethodChannel invokeMethod:@"onWakeupNotification" arguments:dict];
                    self.cacheDic = nil;
                }
                break;
            }
            case OpenInstallSDKMethodGetInstallParams:
            {
                NSNumber *timeNum = (NSNumber *) call.arguments[@"timeout"];
                double time = [timeNum doubleValue];
                if (time <= 10) {
                    time = 15;
                }
                [[OpenInstallSDK defaultManager] getInstallParmsWithTimeoutInterval:time completed:^(OpeninstallData * _Nullable appData) {
                    [self installParamsResponse:appData];
                }];
                break;
            }
            case OpenInstallSDKMethodReportRegister:
            {
                [OpenInstallSDK reportRegister];
                break;
            }
            case OpenInstallSDKMethodReportEffectPoint:
            {
                NSDictionary * args = call.arguments;
                NSNumber * pointValue = (NSNumber *) args[@"pointValue"];
                if ([args.allKeys containsObject:@"extras"]) {
                    [[OpenInstallSDK defaultManager] reportEffectPoint:(NSString *)args[@"pointId"] effectValue:[pointValue longValue] effectDictionary:(NSDictionary *)args[@"extras"]];
                }else{
                    [[OpenInstallSDK defaultManager] reportEffectPoint:(NSString *)args[@"pointId"] effectValue:[pointValue longValue]];
                }
                break;
            }
            case OpenInstallSDKMethodConfig:
            {
                NSDictionary * args = call.arguments;
                self.adEnable = [args[@"adEnable"] boolValue];
                self.ASAEnable = [args[@"ASAEnable"] boolValue];
                self.idfaStr = args[@"idfaStr"];
                self.ASADebug = [args[@"ASADebug"] boolValue];
                
                break;
            }
            case OpenInstallSDKMethodReportShare:
            {
                NSDictionary * args = call.arguments;
                [[OpenInstallSDK defaultManager] reportShareParametersWithShareCode:(NSString *)args[@"shareCode"] sharePlatform:(NSString *)args[@"platform"] completed:^(NSInteger code, NSString * _Nullable msg) {
                    BOOL shouldRetry = NO;
                    if (code==-1) {
                        shouldRetry = YES;
                    }
                    NSDictionary * resultDic = @{@"shouldRetry":@(shouldRetry),@"message":msg};
                    result(resultDic);
                }];
                break;
            }
            case OpenInstallSDKMethodGetOpid:
            {
                NSString *opid = [[OpenInstallSDK defaultManager] getOpId];
                result(opid);
                break;
            }
            default:
            {
                break;
            }
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - Openinstall Notify Flutter Mehtod
- (void)installParamsResponse:(OpeninstallData *) appData {
    NSDictionary *args = [self convertInstallArguments:appData];
    [self.flutterMethodChannel invokeMethod:@"onInstallNotification" arguments:args];
}

- (void)wakeUpParamsResponse:(OpeninstallData *) appData {
    NSDictionary *args = [self convertInstallArguments:appData];
    if (self.isOnWakeup) {
        [self.flutterMethodChannel invokeMethod:@"onWakeupNotification" arguments:args];
    }else{
        @synchronized(self){
            self.cacheDic = [[NSDictionary alloc]init];
            self.cacheDic = args;
        }
    }
}

- (NSDictionary *)convertInstallArguments:(OpeninstallData *) appData {
    NSString *channelCode = @"";
    NSString *bindData = @"";
    if (appData.channelCode != nil) {
        channelCode = appData.channelCode;
    }
    if (appData.data != nil) {
        bindData = [self jsonStringWithObject:appData.data];
    }
    BOOL shouldRetry = NO;
    if (appData.opCode==OPCode_timeout) {
        shouldRetry = YES;
    }
    NSDictionary * dict = @{@"channelCode":channelCode,@"bindData":bindData,@"shouldRetry":@(shouldRetry)};
    return dict;
}

- (NSString *)jsonStringWithObject:(id)jsonObject {
    id arguments = (jsonObject == nil ? [NSNull null] : jsonObject);
    NSArray* argumentsWrappedInArr = [NSArray arrayWithObject:arguments];
    NSString* argumentsJSON = [self cp_JSONString:argumentsWrappedInArr];
    if (argumentsJSON.length>2) {argumentsJSON = [argumentsJSON substringWithRange:NSMakeRange(1, [argumentsJSON length] - 2)];}
    return argumentsJSON;
}

- (NSString *)cp_JSONString:(NSArray *)array {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if ([jsonString length] > 0 && error == nil){
        return jsonString;
    } else {
        return @"";
    }
}

#pragma mark - Openinstall API
//通过OpenInstall获取已经安装App被唤醒时的参数（如果是通过渠道页面唤醒App时，会返回渠道编号）
-(void)getWakeUpParams:(OpeninstallData *) appData{
    [self wakeUpParamsResponse:appData];
}

+ (BOOL)handLinkURL:(NSURL *) url {
    return [OpenInstallSDK handLinkURL:url];
}

+ (BOOL)continueUserActivity:(NSUserActivity *) userActivity {
    return [OpenInstallSDK continueUserActivity:userActivity];
}

- (void)initOpenInstall{
    //iOS14.5苹果隐私政策正式启用
    if (self.adEnable) {
        if (@available(iOS 14, *)) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                [self OpInit];
            }];
        }else{
            [self OpInit];
        }
    }else{
        [self OpInit];
    }
    
}

- (void)OpInit{
    //ASA广告归因
    NSMutableDictionary *config = [[NSMutableDictionary alloc]init];
    if (@available(iOS 14.3, *)) {
        NSError *error;
        NSString *token = [AAAttribution attributionTokenWithError:&error];
        if (self.ASAEnable) {
            [config setValue:token forKey:OP_ASA_Token];
        }
        if (self.ASADebug) {
            [config setValue:@(YES) forKey:OP_ASA_isDev];
        }
    }
    //第三方广告平台统计代码
    NSString *idfaStr;
    if (self.adEnable) {
        if (self.idfaStr.length > 0) {
            idfaStr = self.idfaStr;
        }else{
            idfaStr = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
        [config setValue:idfaStr forKey:OP_Idfa_Id];
    }
    
    if (!self.ASAEnable && !self.adEnable) {
        [OpenInstallSDK initWithDelegate:self];
    }else if (!self.ASAEnable && self.adEnable){
        [OpenInstallSDK initWithDelegate:self advertisingId:idfaStr];
    }else if (self.ASAEnable && !self.adEnable){
        [OpenInstallSDK initWithDelegate:self adsAttribution:config];
    }else if (self.ASAEnable && self.adEnable){
        [OpenInstallSDK initWithDelegate:self adsAttribution:config];
    }
    
}


#pragma mark - Application Delegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [OpeninstallFlutterPlugin handLinkURL:url];
    return NO;
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [OpeninstallFlutterPlugin handLinkURL:url];
    return NO;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
#if defined(__IPHONE_12_0)
    restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring> > * _Nullable restorableObjects))restorationHandler
#else
    restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
#endif
{
    [OpeninstallFlutterPlugin continueUserActivity:userActivity];
    return NO;
}

+ (void)setUserActivityAndScheme:(NSDictionary *)launchOptions{
    if (launchOptions[UIApplicationLaunchOptionsUserActivityDictionaryKey]) {
        NSDictionary *activityDic = [NSDictionary dictionaryWithDictionary:launchOptions[UIApplicationLaunchOptionsUserActivityDictionaryKey]];

        if ([activityDic[UIApplicationLaunchOptionsUserActivityTypeKey] isEqual: NSUserActivityTypeBrowsingWeb]&&activityDic[@"UIApplicationLaunchOptionsUserActivityKey"]) {
            NSUserActivity *activity = [[NSUserActivity alloc]initWithActivityType:NSUserActivityTypeBrowsingWeb];
            activity = (NSUserActivity *)activityDic[@"UIApplicationLaunchOptionsUserActivityKey"];
            [OpeninstallFlutterPlugin continueUserActivity:activity];
        }
    }else if (launchOptions[UIApplicationLaunchOptionsURLKey]){
        NSURL *url = [[NSURL alloc]init];
        if ([launchOptions[UIApplicationLaunchOptionsURLKey] isKindOfClass:[NSURL class]]) {
            url = launchOptions[UIApplicationLaunchOptionsURLKey];
        }else if ([launchOptions[UIApplicationLaunchOptionsURLKey] isKindOfClass:[NSString class]]){
            url = [NSURL URLWithString:launchOptions[UIApplicationLaunchOptionsURLKey]];
        }
        [OpeninstallFlutterPlugin handLinkURL:url];
    }
}


@end
