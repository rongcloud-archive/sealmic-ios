//
//  RoomBackgroundNotifyMessage.h
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN
#define RoomBackgroundNotifyMessageIdentifier @"SM:RBgNtfyMsg"
@interface RoomBackgroundNotifyMessage : RCMessageContent
@property (nonatomic, assign) int backgroundId;
@end

NS_ASSUME_NONNULL_END
