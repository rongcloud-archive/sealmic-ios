//
//  MicPositionControlMessage.m
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "MicPositionControlMessage.h"

@implementation MicPositionControlMessage
- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if(dic) {
        self.type = [dic[@"cmd"] integerValue];
        self.targetPosition = [dic[@"fromPosition"] intValue];
        self.targetUserId = dic[@"targetUserId"];
        NSDictionary *micPositionsJson  = dic[@"micPositions"];
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *json in micPositionsJson) {
            MicPositionInfo *info = [MicPositionInfo micPositionInfoFromJson:json];
            if (info) {
                [mutableArray addObject:info];
            }
        }
        self.micPositions = mutableArray.copy;
    }
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

+ (NSString *)getObjectName {
    return MicPositionControlMessageIdentifier;
}
@end
