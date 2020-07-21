//
//  RCMicBroadcastGiftMessage.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/22.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicBroadcastGiftMessage.h"
#import "RCMicUtil.h"
#define ObjectName @"RCMic:broadcastGift"
#define Name @"roomName"
#define Tag @"tag"
#define UserInfo @"user"
@implementation RCMicBroadcastGiftMessage

+ (instancetype)messageWithRoomName:(NSString *)name tag:(nonnull NSString *)tag {
    RCMicBroadcastGiftMessage *message = [[RCMicBroadcastGiftMessage alloc] init];
    message.roomName = name;
    message.tag = tag;
    return message;
}

#pragma mark - RCMessageCoding
- (NSData *)encode {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.roomName) {
        [dict setValue:self.roomName forKey:Name];
    }
    
    if (self.tag) {
        [dict setValue:self.tag forKey:Tag];
    }
    
    //调用父类方法将发送者的用户信息一起编码
    if (self.senderUserInfo) {
        [dict setValue:[self encodeUserInfo:self.senderUserInfo] forKey:UserInfo];
    }
    
    NSData *data = [RCMicUtil dataWithDictionary:dict];
    return data;
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dict = [RCMicUtil dictionaryWithData:data];
    self.roomName = dict[Name];
    self.tag = dict[Tag];
    [self decodeUserInfo:dict[UserInfo]];
}

+ (NSString *)getObjectName {
    return ObjectName;
}

- (NSArray<NSString *> *)getSearchableWords {
    return @[self.roomName];
}

#pragma mark - RCMessagePersistentCompatible
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}
@end
