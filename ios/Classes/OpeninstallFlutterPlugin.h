#import <Flutter/Flutter.h>

@interface OpeninstallFlutterPlugin : NSObject<FlutterPlugin>

/**
 * 处理 URI schemes
 * @param URL 系统回调传回的URL
 * @return bool URL是否被OpenInstall识别
 */
+ (BOOL)handLinkURL:(NSURL *) url;

/**
 * 处理 通用链接
 * @param userActivity 存储了页面信息，包括url
 * @return bool URL是否被OpenInstall识别
 */
+ (BOOL)continueUserActivity:(NSUserActivity *) userActivity;


+ (void)setUserActivityAndScheme:(NSDictionary *)launchOptions;

@end

