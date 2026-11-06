//
//  CPOIThirdPartyIntegration.h
//  OpenInstallSDK
//
//  第三方插件集成专用：请在编译 SDK 前修改本头文件中的宏定义。
//  原生 iOS 正式 SDK 发布包通常不包含此头文件；插件版 SDK 随源码一并提供。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 平台类型
#ifndef OI_THIRD_PARTY_PLATFORM_TYPE
#define OI_THIRD_PARTY_PLATFORM_TYPE 11
#endif

// 第三方平台 SDK 版本
#ifndef OI_THIRD_PARTY_SDK_VERSION
#define OI_THIRD_PARTY_SDK_VERSION @"2.6.1"
#endif

/**
 * SDK 日志回调，event 仅包含以下两个字符串字段：
 * level：@"error"、@"warning"、@"info" 或 @"debug"；message：格式化后的日志描述。
 */
typedef void (^OpenInstallLogHandler)(NSDictionary<NSString *, NSString *> * _Nonnull event);

@interface CPOIThirdPartyIntegration : NSObject

/// 合法则返回 平台类型
+ (nullable NSNumber *)platformTypeForConfig;

/// 第三方平台 SDK 版本
+ (nullable NSString *)thirdSdkVersionForConfig;

/**
 * 为第三方平台设置日志回调桥接。
 *
 * @param handler 日志回调；传入 nil 移除监听，重复设置会替换之前的回调
 */
+ (void)setThirdPartyLogHandler:(nullable OpenInstallLogHandler)handler;

@end

NS_ASSUME_NONNULL_END
