//
//  UserInfo.m
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
+ (instancetype)userInfoFromJson:(NSDictionary *)dic{
    UserInfo *info = [[UserInfo  alloc] init];
    info.joinDate = [dic[@"joinDt"] longLongValue];
//    info.avatarResourceId = [dic[@"role"] intValue];//
    info.userId = dic[@"userId"];
//    info.nickname = [dic[@"roomType"] intValue];
    return info;
}

- (BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[UserInfo class]]) {
        UserInfo *info = (UserInfo *)object;
        if ([info.userId isEqualToString:self.userId]) {
            return YES;
        }
    }else if ([object isKindOfClass:[NSString class]]){
        NSString *info = (NSString *)object;
        if ([info isEqualToString:self.userId]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"[UserInfo]:userId=%@,nickname=%@,joinDate=%@,avatarResourceId=%@", self.userId,self.nickname,@(self.joinDate),@(self.avatarResourceId)];
}
@end
