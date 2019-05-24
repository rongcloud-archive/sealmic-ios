//
//  MicPositionChangeMessage.m
//  AFNetworking
//
//  Created by 张改红 on 2019/5/8.
//

#import "MicPositionChangeMessage.h"

@implementation MicPositionChangeMessage
- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if(dic) {
        self.type = [dic[@"cmd"] integerValue];
        self.fromPosition = [dic[@"fromPosition"] intValue];
        self.toPosition = [dic[@"toPosition"] intValue];
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
    return MicPositionChangeMessageIdentifier;
}
@end
