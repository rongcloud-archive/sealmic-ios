//
//  RCMicKickOutMessage.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/22.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicKickOutMessage.h"
#import "RCMicUtil.h"
#import "RCMicUserInfo.h"

#define ObjectName @"RCMic:chrmSysMsg"
@implementation RCMicKickOutMessage
#pragma mark - RCMessageCoding
- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dict = [RCMicUtil dictionaryWithData:data];
    self.type = [dict[@"type"] integerValue];
    self.operatorId = dict[@"operatorId"];
    self.operatorName = dict[@"operatorName"];
    self.roomId = dict[@"roomId"];
}

+ (NSString *)getObjectName {
    return ObjectName;
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

#pragma mark - RCMessagePersistentCompatible
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}
@end
