//
//  RCMicUtil.h
//  SealMic
//
//  Created by lichenfeng on 2020/5/21.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RCMicActiveWheel.h"
#import "RCMicEnumDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMicUtil : NSObject
/**
 * 获取适应手机当前模式的 UIColor
 *
 * @param lightColor 正常模式 UIColor
 * @param darkColor 暗黑模式 UIColor
 *
 * @return 当前模式下对应的 UIColor
 */
+ (UIColor *)colorWithLight:(UIColor *)lightColor dark:(UIColor *)darkColor;

/// 获取指定大小的 UIFont
+ (UIFont *)fontWithSize:(CGFloat)size name:(nullable NSString *)name;

/// 获取状态栏高度
+ (CGFloat)statusBarHeight;

/// 获取顶部安全区域高度（返回结果包含 navigationBar 高度）
+ (CGFloat)topSafeAreaHeight;

/// 获取底部安全区域高度
+ (CGFloat)bottomSafeAreaHeight;

/// 获取随机用户名
+ (NSString *)randomName;

/// 获取随机用户头像
+ (NSString *)randomPortrait;

/// 获取随机房间主题图片
+ (NSString *)randomRoomTheme;

/// 对象序列化
+ (NSData *)secureArchivedDataWithObject:(id<NSSecureCoding>)object;

/// 对象反序列化
+ (id<NSSecureCoding>)secureUnarchiveObjectOfClass:(Class)cls fromData:(NSData *)data;

/// Json 转字典
+ (NSDictionary *)dictionaryWithData:(NSData *)data;

/// 字典转 Json data
+ (NSData *)dataWithDictionary:(NSDictionary *)dict;

/// 日志重定向
+ (void)redirectLogToLocal;

/// 网络请求错误码提示
+ (void)showTipWithErrorCode:(RCMicHTTPCode)code;
@end

NS_ASSUME_NONNULL_END
