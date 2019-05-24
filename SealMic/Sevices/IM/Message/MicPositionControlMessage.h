//
//  MicPositionControlMessage.h
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#import "MicPositionInfo.h"
NS_ASSUME_NONNULL_BEGIN
#define MicPositionControlMessageIdentifier @"SM:MPCtrlMsg"

@interface MicPositionControlMessage : RCMessageContent
@property (nonatomic, assign) MicBehaviorType type;
@property (nonatomic, assign) int targetPosition;
@property (nonatomic, copy) NSString *targetUserId;
@property (nonatomic, strong) NSArray <MicPositionInfo *> *micPositions;
@end

NS_ASSUME_NONNULL_END
