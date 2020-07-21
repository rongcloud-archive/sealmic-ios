//
//  RCMicGiftInfo.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/18.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RCMicGiftType) {
    RCMicGiftTypeSmell = 0,//笑脸
    RCMicGiftTypeAirTicket,//机票
    RCMicGiftTypeHoney,//蜂蜜
    RCMicGiftTypeTreasureBox,//宝箱
    RCMicGiftTypeIce,//冰淇凌
    RCMicGiftTypeLovingCar,//爱心车
    RCMicGiftTypeSavingPot,//存钱罐
    RCMicGiftTypeSportsCar,//豪华跑车
};

@interface RCMicGiftInfo : NSObject
@property (nonatomic, copy) NSString *name;//名字
@property (nonatomic, strong) UIImage *image;//本地对应的图片
@property (nonatomic, assign) RCMicGiftType type;//礼物类型
@property (nonatomic, copy) NSString *tag;//礼物在消息中对应的标识
@property (nonatomic, copy) NSString *bigImageName;//礼物大图名字

/// 根据 type 初始化
- (instancetype)initWithType:(RCMicGiftType)type;


/// 根据 tag 初始化
- (instancetype)initWithTag:(NSString *)tag;
@end

NS_ASSUME_NONNULL_END
