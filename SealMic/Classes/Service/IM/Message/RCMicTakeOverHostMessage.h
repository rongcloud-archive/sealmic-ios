//
//  RCMicTakeOverHostMessage.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/18.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, RCMicTakeOverHostMessageType) {
    RCMicTakeOverHostMessageTypeRequest = 0,//operatorId 对应用户请求接管 targetUserId 对应用户的主持人麦位
    RCMicTakeOverHostMessageTypeResponseRefuse,//operatorId 对应用户拒绝 targetUserId 对应的用户所发起的接管
    RCMicTakeOverHostMessageTypeResponseAccept,//operatorId 对应用户同意 targetUserId 对应用户所发起的接管
};

/// 接管主持人消息（端上只负责接收）
@interface RCMicTakeOverHostMessage : RCMessageContent
@property (nonatomic, assign) RCMicTakeOverHostMessageType type;
@property (nonatomic, copy) NSString *operatorId;
@property (nonatomic, copy) NSString *operatorName;
@property (nonatomic, copy) NSString *targetUserId;
@property (nonatomic, copy) NSString *targetUserName;

@end

NS_ASSUME_NONNULL_END
