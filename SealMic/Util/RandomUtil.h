//
//  RandomUtil.h
//  SealMic
//
//  Created by Sin on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RandomUtil : NSObject
//随机房间话题
+ (NSString *)randomSubject;
//随机房间背景图
+ (UIImage *)randomRoomBgImage;
//随机房间封面图
+ (UIImage *)randomRoomCover:(NSString *)roomId;
//随机用户头像
+ (UIImage *)randomPortraitFor:(NSString *)userId;
//随机用户头像名字
+ (NSString *)randomPortraitStringFor:(NSString *)userId;
//随机用户名
+ (NSString *)randomNameFor:(NSString *)userId;
@end

NS_ASSUME_NONNULL_END
