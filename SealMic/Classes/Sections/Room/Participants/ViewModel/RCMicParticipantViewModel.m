//
//  RCMicParticipantViewModel.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/7.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicParticipantViewModel.h"
#import "RCMicAppService.h"
@interface RCMicParticipantViewModel()
@end

@implementation RCMicParticipantViewModel

- (instancetype)initWithParticipantInfo:(RCMicParticipantInfo *)participantInfo {
    self = [super init];
    if (self) {
        [self setParticipantInfo:participantInfo];
    }
    return self;
}

- (void)setParticipantInfo:(RCMicParticipantInfo *)participantInfo {
    _participantInfo = participantInfo;
    if (participantInfo.userId.length > 0) {
        [self getUserInfo:^(RCMicUserInfo * _Nullable userInfo) {
        }];
    }
}

- (void)getUserInfo:(void (^)(RCMicUserInfo * _Nullable))completion {
    //participantInfo 对象可能会实时变动
    if ([self.userInfo.userId isEqualToString:self.participantInfo.userId] && self.userInfo) {
        completion ? completion(self.userInfo) : nil;
        return;
    }
    [[RCMicAppService sharedService] getUserInfo:self.participantInfo.userId success:^(RCMicUserInfo * _Nonnull userInfo) {
        self.userInfo = userInfo;
        completion ? completion(userInfo) : nil;
    } error:^(RCMicHTTPCode errorCode) {
        completion ? completion(nil) : nil;
    }];
}
@end
