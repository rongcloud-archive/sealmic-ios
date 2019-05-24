//
//  RoomMemberChangedMessage.m
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RoomMemberChangedMessage.h"

@implementation RoomMemberChangedMessage
- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if(dic) {
        self.action = [dic[@"cmd"] integerValue];
        self.targetPosition = [dic[@"targetPosition"] intValue];
        self.userId = dic[@"targetUserId"];
    }
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

+ (NSString *)getObjectName {
    return RoomMemberChangedMessageIdentifier;
}
@end
