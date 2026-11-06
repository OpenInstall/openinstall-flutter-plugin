//
//  OpenInstallSharePlatform.h
//  OpenInstallSDK
//
//  分享统计接口 sharePlatform 参数可用平台（added in v2.7.0）
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *OP_SharePlatform NS_STRING_ENUM;

#pragma mark - 微信

extern OP_SharePlatform const OP_SharePlatform_WechatSession; // 微信
extern OP_SharePlatform const OP_SharePlatform_WechatTimeline; // 微信朋友圈
extern OP_SharePlatform const OP_SharePlatform_WechatFavorite; // 微信收藏
extern OP_SharePlatform const OP_SharePlatform_WeCom; // 微信办公

#pragma mark - 腾讯系

extern OP_SharePlatform const OP_SharePlatform_QQ; //  QQ
extern OP_SharePlatform const OP_SharePlatform_Qzone; //  QQ空间
extern OP_SharePlatform const OP_SharePlatform_TencentWb; // 腾讯微博
extern OP_SharePlatform const OP_SharePlatform_TencentTim; // 腾讯 TIM

#pragma mark - 国内应用

extern OP_SharePlatform const OP_SharePlatform_Sina; // 新浪微博
extern OP_SharePlatform const OP_SharePlatform_APSession; // 支付宝
extern OP_SharePlatform const OP_SharePlatform_DingDing; // 钉钉
extern OP_SharePlatform const OP_SharePlatform_DouYin; // 抖音
extern OP_SharePlatform const OP_SharePlatform_TikTok; // 抖音火山版
extern OP_SharePlatform const OP_SharePlatform_Kuaishou; // 快手
extern OP_SharePlatform const OP_SharePlatform_Kwai; // 快手火山版
extern OP_SharePlatform const OP_SharePlatform_WatermelonVideo; // 西瓜视频
extern OP_SharePlatform const OP_SharePlatform_BuzzVideo; // 西瓜视频
extern OP_SharePlatform const OP_SharePlatform_Renren; // 人人网
extern OP_SharePlatform const OP_SharePlatform_Douban; // 豆瓣
extern OP_SharePlatform const OP_SharePlatform_YXSession; // 易信
extern OP_SharePlatform const OP_SharePlatform_YXTimeline; // 易信朋友圈
extern OP_SharePlatform const OP_SharePlatform_YXFavorite; // 易信收藏
extern OP_SharePlatform const OP_SharePlatform_MingDao; // 陌陌
extern OP_SharePlatform const OP_SharePlatform_LWSession; // 连信
extern OP_SharePlatform const OP_SharePlatform_LWTimeline; // 连信朋友圈

#pragma mark - 通用渠道

extern OP_SharePlatform const OP_SharePlatform_Email; // 邮箱
extern OP_SharePlatform const OP_SharePlatform_Sms; // 短信
extern OP_SharePlatform const OP_SharePlatform_Copy; // 复制
extern OP_SharePlatform const OP_SharePlatform_Other; // 其他

#pragma mark - 海外社交

extern OP_SharePlatform const OP_SharePlatform_Facebook; // 脸书
extern OP_SharePlatform const OP_SharePlatform_FacebookMessenger; // 脸书 Messenger
extern OP_SharePlatform const OP_SharePlatform_FacebookAccount; // 脸书账号
extern OP_SharePlatform const OP_SharePlatform_Twitter; // 推特
extern OP_SharePlatform const OP_SharePlatform_Instagram; //  Instagram
extern OP_SharePlatform const OP_SharePlatform_Whatsapp; //  WhatsApp
extern OP_SharePlatform const OP_SharePlatform_Youtube; //  YouTube
extern OP_SharePlatform const OP_SharePlatform_SnapChat; //  Snapchat
extern OP_SharePlatform const OP_SharePlatform_Line; //  Line
extern OP_SharePlatform const OP_SharePlatform_Linkedin; //  LinkedIn
extern OP_SharePlatform const OP_SharePlatform_Reddit; //  Reddit
extern OP_SharePlatform const OP_SharePlatform_Tumblr; //  Tumblr   
extern OP_SharePlatform const OP_SharePlatform_Pinterest; //  Pinterest
extern OP_SharePlatform const OP_SharePlatform_KakaoTalk; //  Kakao Talk
extern OP_SharePlatform const OP_SharePlatform_KakaoStory; //  Kakao Story
extern OP_SharePlatform const OP_SharePlatform_Flickr; //  Flickr
extern OP_SharePlatform const OP_SharePlatform_googlePlus; //  Google+
extern OP_SharePlatform const OP_SharePlatform_vkontakte; //  VKontakte

#pragma mark - 笔记与云存储

extern OP_SharePlatform const OP_SharePlatform_YouDaoNote; // 有道笔记
extern OP_SharePlatform const OP_SharePlatform_YinxiangNote; // 印象笔记
extern OP_SharePlatform const OP_SharePlatform_EverNote; //  EverNote
extern OP_SharePlatform const OP_SharePlatform_Pocket; //  Pocket
extern OP_SharePlatform const OP_SharePlatform_dropbox; //  Dropbox
extern OP_SharePlatform const OP_SharePlatform_Instapaper; //  Instapaper

#pragma mark - 其它

extern OP_SharePlatform const OP_SharePlatform_Oasis; //  Oasis
extern OP_SharePlatform const OP_SharePlatform_AppleAccount; //  Apple

NS_ASSUME_NONNULL_END
