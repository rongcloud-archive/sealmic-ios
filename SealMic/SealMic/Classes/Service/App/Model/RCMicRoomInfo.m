//
//  RCMicRoomInfo.m
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicRoomInfo.h"

@implementation RCMicRoomInfo
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"themePictureUrl"]) {
        self.themeImageURL = value;
    } else if ([key isEqualToString:@"allowedJoinRoom"]) {
        self.freeJoinRoom = [value boolValue];
    } else if ([key isEqualToString:@"allowedFreeJoinMic"]) {
        self.freeJoinMic = [value boolValue];
    } else if ([key isEqualToString:@"updateDt"]) {
        self.createDt = [value longLongValue];
    }
}
@end
