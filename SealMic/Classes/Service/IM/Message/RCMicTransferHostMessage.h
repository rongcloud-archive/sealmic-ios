//
//  RCMicTransferHostMessage.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/18.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, RCMicTransferHostMessageType) {
    RCMicTransferHostMessageTypeRequest = 0,//operatorId 对应用户请求转让主持人给 targetUserId 对应用户
    RCMicTransferHostMessageTypeResponseRefuse,//operatorId 对应的用户同意接受 targetUserId 对应用户发起的转让
    RCMicTransferHostMessageTypeResponseAccept,//operatorId 对应的用户拒绝接受 targetUserId 对应用户发起的转让
};
/// 转让主持人消息（端上只负责接收）
@interface RCMicTransferHostMessage : RCMessageContent
@property (nonatomic, assign) RCMicTransferHostMessageType type;
@property (nonatomic, copy) NSString *operatorId;
@property (nonatomic, copy) NSString *operatorName;
@property (nonatomic, copy) NSString *targetUserId;
@property (nonatomic, copy) NSString *targetUserName;
@end

NS_ASSUME_NONNULL_END
