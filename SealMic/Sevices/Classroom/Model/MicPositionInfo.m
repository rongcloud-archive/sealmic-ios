//
//  MicPositionInfo.m
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "MicPositionInfo.h"

@implementation MicPositionInfo
+ (instancetype)micPositionInfoFromJson:(NSDictionary *)dic{
    MicPositionInfo *info = [[MicPositionInfo  alloc] init];
    info.userId = dic[@"uid"];
    if (info.userId.length == 0) {
        info.userId = dic[@"userId"];
    }
    info.state = [dic[@"state"] integerValue];
    info.position = [dic[@"position"] intValue];
    info.roomId = dic[@"rid"];
    return info;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[MicPositionInfo]:roomId=%@,userId=%@,position=%@,state=%@",self.roomId,self.userId,@(self.position),@(self.state)];
}
@end
