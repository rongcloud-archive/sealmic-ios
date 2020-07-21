//
//  RCMicParticipantInfo.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/7.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicParticipantInfo.h"

@implementation RCMicParticipantInfo

- (instancetype)copyWithZone:(NSZone *)zone {
    RCMicParticipantInfo *info = [[RCMicParticipantInfo alloc] init];
    info.userId = self.userId;
    info.isHost = self.isHost;
    info.position = self.position;
    info.state = self.state;
    info.speaking = self.speaking;
    return info;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"userId:%@, isHost:%@, position:%ld, state:%ld, speaking:%@", self.userId, self.isHost ? @"YES" : @"NO", (long)self.position, (long)self.state, self.speaking ? @"YES" : @"NO"];
}
@end
