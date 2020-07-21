//
//  RCMicParticipantViewModel.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/7.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCMicParticipantInfo.h"
#import "RCMicUserInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCMicParticipantViewModel : NSObject
@property (nonatomic, strong) RCMicParticipantInfo *participantInfo;
@property (nonatomic, strong) RCMicUserInfo *userInfo;

- (instancetype)initWithParticipantInfo:(RCMicParticipantInfo *)participantInfo;

/**
 * 获取当前参会者（麦位）的用户信息
 */
- (void)getUserInfo:(void(^)(RCMicUserInfo * _Nullable userInfo))completion;
@end

NS_ASSUME_NONNULL_END
