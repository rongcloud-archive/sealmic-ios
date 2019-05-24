//
//  MicPositionChangeMessage.h
//  AFNetworking
//
//  Created by 张改红 on 2019/5/8.
//

#import <RongIMLib/RongIMLib.h>
#import "MicPositionInfo.h"
NS_ASSUME_NONNULL_BEGIN
#define MicPositionChangeMessageIdentifier @"SM:MPChangeMsg"
@interface MicPositionChangeMessage : RCMessageContent
@property (nonatomic, assign) MicBehaviorType type;
@property (nonatomic, assign) int fromPosition;
@property (nonatomic, assign) int toPosition;
@property (nonatomic, copy) NSString *targetUserId;
@property (nonatomic, strong) NSArray <MicPositionInfo *> *micPositions;
@end

NS_ASSUME_NONNULL_END
