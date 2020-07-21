//
//  RCMicGiftMessage.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/18.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicGiftMessage.h"
#import "RCMicUtil.h"

#define ObjectName @"RCMic:gift"

#define Content @"content"
#define Tag @"tag"
#define UserInfo @"user"
@implementation RCMicGiftMessage

+ (instancetype)messageWithContent:(NSString *)content tag:(nonnull NSString *)tag {
    RCMicGiftMessage *message = [[RCMicGiftMessage alloc] init];
    message.content = content;
    message.tag = tag;
    return message;
}

#pragma mark - RCMessageCoding
- (NSData *)encode {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.content) {
        [dict setValue:self.content forKey:Content];
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
    self.content = dict[Content];
    self.tag = dict[Tag];
    [self decodeUserInfo:dict[UserInfo]];
}

+ (NSString *)getObjectName {
    return ObjectName;
}

- (NSArray<NSString *> *)getSearchableWords {
    return @[self.content];
}

#pragma mark - RCMessagePersistentCompatible
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_ISCOUNTED;
}
@end
