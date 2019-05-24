//
//  RoomActiveMessage.m
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RoomActiveMessage.h"

@implementation RoomActiveMessage
- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

+ (NSString *)getObjectName {
    return RoomActiveMessageIdentifier;
}
@end
