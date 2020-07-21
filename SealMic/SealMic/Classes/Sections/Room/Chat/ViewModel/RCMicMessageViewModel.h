//
//  RCMicMessageViewModel.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
#import "RCMicUserInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCMicMessageViewModel : NSObject
@property (nonatomic, strong) RCMessage *message;
@property (nonatomic, strong) RCUserInfo *senderInfo;

- (instancetype)initWithMessage:(RCMessage *)message;

/**
 * 获取当前消息发送者的用户信息（暂未使用，因为当前消息中已经包含用户信息了）
 *
 * @param completion 结束回调，获取成功返回用户信息，获取失败返回 nil
 *
 * @discussion demo 的策略为在消息中直接携带发送者的用户信息，如果应用需要改为从应用服务器获取而不是消息携带时可以使用这个接口去获取
 */
- (void)getSenderInfo:(void(^)(RCUserInfo * _Nullable userInfo))completion;
@end

NS_ASSUME_NONNULL_END
