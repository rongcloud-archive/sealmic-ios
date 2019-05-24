//
//  RoomInfo.m
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RoomInfo.h"
#import "UserInfo.h"
#import "MicPositionInfo.h"
@implementation RoomInfo
+ (instancetype)roomInfoFromJson:(NSDictionary *)dic{
    RoomInfo *roomInfo = [[RoomInfo  alloc] init];
    roomInfo.roomId = dic[@"roomId"];
    roomInfo.creatorId = dic[@"creatorUserId"];
    roomInfo.subject = dic[@"subject"];
    roomInfo.roomType = [dic[@"roomType"] intValue];
    roomInfo.bgId = [dic[@"bgId"] intValue];
    roomInfo.createDate = [dic[@"createDt"] longLongValue];
    roomInfo.members = [self getAudiences:dic[@"audiences"]];
    roomInfo.memberCount = [dic[@"memCount"] intValue];
    roomInfo.micPositions = [self getMicPositions:dic[@"micPositions"]];
    return roomInfo;
}

+ (NSArray *)getAudiences:(NSDictionary *)dic{
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *json in dic) {
        UserInfo *user = [UserInfo userInfoFromJson:json];
        if (user) {
            [array addObject:user];
        }
    }
    return array.copy;
}

+ (NSArray *)getMicPositions:(NSDictionary *)dic{
    NSMutableArray *array = [NSMutableArray array];
     for (NSDictionary *json in dic) {
        MicPositionInfo *positionInfo = [MicPositionInfo micPositionInfoFromJson:json];
        if (positionInfo) {
            [array addObject:positionInfo];
        }
    }
    return array.copy;
}


- (void)addAudience:(NSString *)userId {
    if(!userId) {
        NSLog(@"错误：加入用户参数错误");
        return;
    }
    for(UserInfo *user in self.members) {
        if([user.userId isEqualToString:userId]) {
            NSLog(@"错误：重复加入同一用户！");
            return;
        }
    }
    UserInfo *user = [[UserInfo alloc] init];
    user.userId = userId;
    NSMutableArray *result = [NSMutableArray arrayWithArray:self.members];
    [result addObject:user];
    self.members = [result copy];
}
- (void)removeAudience:(NSString *)userId {
    if(!userId) {
        NSLog(@"错误：移除用户参数错误");
        return;
    }
    int index = -1;
    for(int i=0;i<self.members.count;i++) {
        UserInfo *user = self.members[i];
        if([user.userId isEqualToString:userId]) {
            index = i;
            break;
        }
    }
    if(index >= 0) {
        NSMutableArray *data = [NSMutableArray arrayWithArray:self.members];
        [data removeObjectAtIndex:index];
        self.members = [data copy];
    }
}

- (void)addMicPosition:(MicPositionInfo *)mP {
    if(!mP) {
        NSLog(@"错误：添加麦位参数错误");
        return;
    }
    MicPositionInfo *info = [self getMicPositionInfo:mP.userId];
    if(!info) {
        NSMutableArray *data = [NSMutableArray arrayWithArray:self.micPositions];
        [data addObject:mP];
        self.micPositions = [data copy];
    }
    
}

- (void)removeMicPosition:(int)p {
    int index = -1;
    for(int i=0;i<self.micPositions.count;i++) {
        MicPositionInfo *info = self.micPositions[i];
        if(p == info.position) {
            index = i;
            break;
        }
    }
    if(index >= 0) {
        NSMutableArray *data = [NSMutableArray arrayWithArray:self.micPositions];
        [data removeObjectAtIndex:index];
        self.micPositions = [data copy];
    }
}

- (void)updateMicPositions:(NSArray<MicPositionInfo *> *)mPositions {
    self.micPositions = mPositions;
}

- (UserInfo *)getUserInfo:(NSString *)userId{
    return nil;
}

- (MicPositionInfo *)getMicPositionInfo:(NSString *)userId{
    for (MicPositionInfo *info in self.micPositions) {
        if ([info.userId isEqualToString:userId]) {
            return info;
        }
    }
    return nil;
}

- (MicPositionInfo *)getMicPositionInfoAt:(int)position {
    for(MicPositionInfo *info in self.micPositions) {
        if(info.position == position) {
            return info;
        }
    }
    return nil;
}

- (int)memberCount{
    if (self.members.count == 0) {
        return _memberCount;
    }
    BOOL isContainCreator = NO;
    for (UserInfo *info in self.members) {
        if ([info isEqual:self.creatorId]) {
            isContainCreator = YES;
        }
    }
    return isContainCreator ? (int)(self.members.count) : (int)(self.members.count+1);
}

- (NSArray *)getAllAudiences{
    NSMutableArray *array = self.members.mutableCopy;
    for (UserInfo *user in self.members) {
        if ([user isEqual:self.creatorId]) {
            [array removeObject:user];
        }
        MicPositionInfo *info = [self getMicPositionInfo:user.userId];
        if (info) {
            [array removeObject:user];
        }
    }
    return array.copy;
}
@end
