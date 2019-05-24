//
//  RoomInfo.h
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UserInfo,MicPositionInfo;
NS_ASSUME_NONNULL_BEGIN

@interface RoomInfo : NSObject
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *creatorId;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, assign) int roomType;
@property (nonatomic, assign) int memberCount;
@property (nonatomic, assign) int bgId;
@property (nonatomic, assign) long long createDate;
@property (nonatomic, strong) NSArray<UserInfo *> *members;
@property (nonatomic, strong) NSArray<MicPositionInfo *> *micPositions;
+ (instancetype)roomInfoFromJson:(NSDictionary *)dic;

- (void)addAudience:(NSString *)userId;
- (void)removeAudience:(NSString *)userId;
- (void)addMicPosition:(MicPositionInfo *)mP;
- (void)removeMicPosition:(int)p;
- (void)updateMicPositions:(NSArray<MicPositionInfo *> *)mPositions;
- (MicPositionInfo *)getMicPositionInfo:(NSString *)userId;
- (MicPositionInfo *)getMicPositionInfoAt:(int)position;
- (NSArray *)getAllAudiences;
@end

NS_ASSUME_NONNULL_END
