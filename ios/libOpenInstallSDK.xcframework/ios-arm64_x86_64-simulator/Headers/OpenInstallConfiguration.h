//
//  OpenInstallConfiguration.h
//  OpenInstallSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 宿主应用在 SDK 初始化前传入的配置。
 *
 * 隐私开关默认保持 SDK 的历史行为。
 * 标识符和归因参数仅在宿主应用主动传入时使用。
 */
@interface OpenInstallConfiguration : NSObject <NSCopying>

/// 是否允许 SDK 读取剪贴板进行渠道匹配，默认开启。
@property (nonatomic, assign, getter=isClipboardEnabled) BOOL clipboardEnabled;

/// 是否允许 SDK 读取 UIDevice 的 identifierForVendor，默认开启。
@property (nonatomic, assign, getter=isIdfvEnabled) BOOL idfvEnabled;

/// 是否允许 SDK 枚举本地网络 IP 地址，默认开启。
@property (nonatomic, assign, getter=isLocalIPEnabled) BOOL localIPEnabled;

/// 宿主应用传入的广告标识符（IDFA）。
@property (nonatomic, copy, nullable) NSString *idfa;

/// 宿主应用传入的 Apple Search Ads Token。
@property (nonatomic, copy, nullable) NSString *asaToken;

/// 宿主应用传入的 CAID 参数。
@property (nonatomic, copy, nullable) NSString *caid1;
@property (nonatomic, copy, nullable) NSString *caid2;

/// 是否启用 ASA 开发者模式下的延长超时时间。
@property (nonatomic, assign, getter=isASADeveloperMode) BOOL asaDeveloperMode;

/// 隐私开关默认全部开启，不读取 Info.plist 的 OpenInstallClipboardEnabled；推荐使用。
- (instancetype)init;

/// 隐私开关默认全部开启，clipboardEnabled 遵循 Info.plist 的 OpenInstallClipboardEnabled。
+ (instancetype)defaultConfiguration;

@end

NS_ASSUME_NONNULL_END
