//
//  RCMicTransferHostMessage.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/18.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicTransferHostMessage.h"
#import "RCMicUtil.h"

#define ObjectName @"RCMic:transferHostMsg"

@implementation RCMicTransferHostMessage

#pragma mark - RCMessageCoding
- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dict = [RCMicUtil dictionaryWithData:data];
    self.type = (RCMicTransferHostMessageType)[dict[@"cmd"] integerValue];
    self.operatorId = dict[@"operatorId"];
    self.operatorName = dict[@"operatorName"];
    self.targetUserId = dict[@"targetUserId"];
    self.targetUserName = dict[@"targetUserName"];
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
