//
//  RCMicParticipantInfo.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/8.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
//麦位数量
#define RCMicParticipantCount 8
//麦位状态
typedef NS_ENUM(NSInteger, RCMicParticipantState) {
    RCMicParticipantStateNormal = 0,//正常状态
    RCMicParticipantStateClosed,//关闭状态（不允许上人）
    RCMicParticipantStateSilent,//禁言状态
};

/// 参会者（麦位）信息
@interface RCMicParticipantInfo : NSObject<NSCopying>
@property (nonatomic, copy) NSString *userId;//当前麦位上的用户 ID
@property (nonatomic, assign) BOOL isHost;//是否是主持人麦位
@property (nonatomic, assign) NSInteger position;//当前麦位编号
@property (nonatomic, assign) RCMicParticipantState state;//当前麦位状态
@property (nonatomic, assign) BOOL speaking;//当前麦位是否正在发言
@end

NS_ASSUME_NONNULL_END
