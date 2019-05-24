//
//  RoomMemberChangedMessage.h
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN
#define RoomMemberChangedMessageIdentifier @"SM:RMChangeMsg"
@interface RoomMemberChangedMessage : RCMessageContent
@property (nonatomic, assign) MemberChangeAction action;
//-1 无效，>=0 有效的麦位
@property (nonatomic, assign) int targetPosition;
@property (nonatomic, copy) NSString *userId;
@end

NS_ASSUME_NONNULL_END
