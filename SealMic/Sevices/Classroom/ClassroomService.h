//
//  ClassroomService.h
//  SealMic
//
//  Created by Sin on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ErrorCode.h"
#import "MicDefine.h"
#import "RoomInfo.h"
#import "UserInfo.h"
@class RCMessage,ClassroomService;

NS_ASSUME_NONNULL_BEGIN
@protocol ClassroomDelegate <NSObject>
@optional
//user
- (void)classroomService:(ClassroomService *)service userDidJoin:(NSString *)userId;
- (void)classroomService:(ClassroomService *)service userDidLeave:(NSString *)userId;
- (void)classroomService:(ClassroomService *)service userDidKicked:(NSString *)userId;
- (void)classroomService:(ClassroomService *)service userDidSpeak:(NSString *)userId;
//mic
- (void)classroomService:(ClassroomService *)service micDidChange:(NSString *)userId behavior:(MicBehaviorType)type from:(int)fPosition to:(int)tPostion;
- (void)classroomService:(ClassroomService *)service micDidControl:(NSString *)userId behavior:(MicBehaviorType)type position:(int)p;
//bg
- (void)classroomService:(ClassroomService *)service backgroundDidChange:(int)bgId;
//error
- (void)classroomService:(ClassroomService *)service errorDidOccur:(ErrorCode)code;
- (void)classroomDidDesory;
@end

@interface ClassroomService : NSObject
@property (nonatomic, weak) id<ClassroomDelegate> classroomDelegate;
@property (nonatomic, strong, readonly) RoomInfo *currentRoom;
@property (nonatomic, strong, readonly) UserInfo *currentUser;
@property (nonatomic, assign) BOOL currentUserCanAnime;

+ (instancetype)sharedService;
- (void)registerCommandMessages;
- (BOOL)isHoldMessage:(RCMessage *)message;
- (void)login:(NSString *)deviceId success:(void (^)(UserInfo *currentUser,NSString *imToken))successBlock error:(void(^)(ErrorCode code))errorBlock;

- (void)createRoom:(NSString *)subject type:(int)type success:(void (^)(RoomInfo *room))successBlock error:(void(^)(ErrorCode code))errorBlock;

- (void)getRoomList:(void (^)(NSArray<RoomInfo *> *roomList))successBlock  error:(void(^)(ErrorCode code))errorBlock;

- (void)getRoomInfo:(NSString *)roomId success:(void (^)(RoomInfo *room))successBlock error:(void(^)(ErrorCode code))errorBlock;

- (void)destroyRoom:(NSString *)roomId success:(void (^)(void))successBlock error:(void(^)(ErrorCode code))errorBlock;

- (void)joinRoom:(NSString *)roomId success:(void (^)(RoomInfo *room))successBlock error:(void(^)(ErrorCode code))errorBlock;

- (void)leaveRoom:(NSString *)roomId success:(void (^)(void))successBlock error:(void(^)(ErrorCode code))errorBlock;

- (void)joinMic:(NSString *)roomId position:(int)p success:(void (^)(void))successBlock error:(void(^)(ErrorCode code))errorBlock;

- (void)leaveMic:(NSString *)roomId position:(int)p success:(void (^)(void))successBlock error:(void(^)(ErrorCode code))errorBlock;

- (void)changeMic:(NSString *)roomId from:(int)from to:(int)to success:(void (^)(void))successBlock error:(void(^)(ErrorCode code))errorBlock;

- (void)controlMic:(NSString *)roomId targetId:(NSString *)userId behavior:(MicBehaviorType)be position:(int)p success:(void (^)(void))successBlock error:(void(^)(ErrorCode code))errorBlock;

- (void)getMemeberList:(NSString *)roomId success:(void (^)(NSArray <UserInfo *> *users))successBlock error:(void(^)(ErrorCode code))errorBlock;

- (void)changeRoomBackground:(NSString *)roomId bgId:(int)bgId success:(void (^)(void))successBlock error:(void(^)(ErrorCode code))errorBlock;

//获取特定位置 mic 的操作权限，结果是 MicBehaviorType 的数组
- (NSArray<NSNumber *> *)getMicBehaviorList:(int)position;

#pragma mark - private
- (void)_notifyUserDidSpeak:(NSString *)userId;
@end

NS_ASSUME_NONNULL_END
