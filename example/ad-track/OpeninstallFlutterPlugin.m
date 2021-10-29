#import "OpeninstallFlutterPlugin.h"

#import "OpenInstallSDK.h"
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>//苹果新隐私政策
#import <AdServices/AAAttribution.h>//ASA

typedef NS_ENUM(NSUInteger, OpenInstallSDKPluginMethod) {
    OpenInstallSDKMethodInit,
    OpenInstallSDKMethodGetInstallParams,
    OpenInstallSDKMethodReportRegister,
    OpenInstallSDKMethodReportEffectPoint
};

@interface OpeninstallFlutterPlugin () <OpenInstallDelegate>
@property (strong, nonatomic, readonly) NSDictionary *methodDict;
@property (strong, nonatomic) FlutterMethodChannel * flutterMethodChannel;
@property (assign, nonatomic) BOOL isOnWakeup;
@property (copy, nonatomic)NSDictionary *cacheDic;
@end

static FlutterMethodChannel * FLUTTER_METHOD_CHANNEL;

@implementation OpeninstallFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel * channel = [FlutterMethodChannel methodChannelWithName:@"openinstall_flutter_plugin" binaryMessenger:[registrar messenger]];
    OpeninstallFlutterPlugin* instance = [[OpeninstallFlutterPlugin alloc] init];
    [registrar addApplicationDelegate:instance];
    instance.flutterMethodChannel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
    [self initOpenInstall:instance];
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
                    @"reportEffectPoint"      :      @(OpenInstallSDKMethodReportEffectPoint)
                    };
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSNumber *methodType = self.methodDict[call.method];
    if (methodType) {
        switch (methodType.intValue) {
            case OpenInstallSDKMethodInit:
            {
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
                int time = (int) call.arguments[@"timeout"];
                if (time <= 0) {
                    time = 8;
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
                [[OpenInstallSDK defaultManager] reportEffectPoint:(NSString *)args[@"pointId"] effectValue:[pointValue longValue]];
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
    NSDictionary * dict = @{@"channelCode":channelCode, @"bindData":bindData};
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

+ (void)initOpenInstall:(OpeninstallFlutterPlugin *)obj{
    //iOS14.5苹果隐私政策正式启用
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            [self OpInit:obj];
        }];
    }else{
        [self OpInit:obj];
    }
}

+ (void)OpInit:(OpeninstallFlutterPlugin *)obj{
    //ASA广告归因
    NSMutableDictionary *config = [[NSMutableDictionary alloc]init];
    if (@available(iOS 14.3, *)) {
        NSError *error;
        NSString *token = [AAAttribution attributionTokenWithError:&error];
        [config setValue:token forKey:OP_ASA_Token];
    }
    //第三方广告平台统计代码
    NSString *idfaStr = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [config setValue:idfaStr forKey:OP_Idfa_Id];
    
    [OpenInstallSDK initWithDelegate:obj adsAttribution:config];
}

#pragma mark - Application Delegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [OpeninstallFlutterPlugin initOpenInstall:self];
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

@end
