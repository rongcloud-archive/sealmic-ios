//
//  RCMicMessageViewModel.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicMessageViewModel.h"
#import "RCMicAppService.h"
@implementation RCMicMessageViewModel
- (instancetype)initWithMessage:(RCMessage *)message {
    self = [super init];
    if (self) {
        _message = message;
        if (message.content.senderUserInfo) {
            _senderInfo = message.content.senderUserInfo;
        } else {
            [self getSenderInfo:^(RCUserInfo * _Nonnull userInfo) {
            }];
        }
    }
    return self;
}

- (void)getSenderInfo:(void (^)(RCUserInfo * _Nullable))completion {
    if (self.senderInfo) {
        completion ? completion(self.senderInfo) : nil;
    } else {
        [[RCMicAppService sharedService] getUserInfo:self.message.senderUserId success:^(RCMicUserInfo * _Nonnull userInfo) {
            self.senderInfo = (RCUserInfo *)userInfo;
            completion ? completion(userInfo) : nil;
        } error:^(RCMicHTTPCode errorCode) {
            completion ? completion(nil) : nil;
        }];
    }
}
@end
