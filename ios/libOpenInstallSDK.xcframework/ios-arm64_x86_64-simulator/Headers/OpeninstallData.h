//
//  OpeninstallData.h
//  OpenInstallSDK
//
//  Created by cooper on 2018/4/17.
//  Copyright © 2018年 cooper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenInstallSharePlatform.h"

//added in v2.7.0 用于安装参数返回时的超时判断
typedef NS_ENUM(NSUInteger,OP_Codes) {
    OPCode_normal = 0,//初始化结束，并返回参数，自然安装下参数为空
    OPCode_timeout = 1,//获取参数超时，可在合适时机再去获取（可设置全局标识）
};

extern NSString *const OP_Idfa_Id;//用于第三方广告平台统计
extern NSString *const OP_ASA_Token;//用于苹果ASA搜索广告
extern NSString *const OP_ASA_isDev;//added in v2.5.6 用于ASA debug测试，正式环境下“不要”设置为YES
extern NSString *const app_caid1;
extern NSString *const app_caid2;

@interface OpeninstallData : NSObject<NSCopying>

- (instancetype)initWithData:(NSDictionary *)data
                 channelCode:(NSString *)channelCode;

@property (nonatomic,strong) NSDictionary *data;//动态参数
@property (nonatomic,copy) NSString *channelCode;//渠道编号
@property (nonatomic,assign) OP_Codes opCode;//返回码，用于安装参数返回时的超时判断 (added in v2.7.0)

@end
