//
//  ClassroomService.m
//  SealMic
//
//  Created by Sin on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ClassroomService.h"
#import "HTTPUtility.h"
#import "UserInfo.h"
#import "RoomInfo.h"
#import "RoomBackgroundNotifyMessage.h"
#import "MicPositionControlMessage.h"
#import "RoomMemberChangedMessage.h"
#import "MicPositionChangeMessage.h"
#import "RoomActiveMessage.h"
#import "RoomDestroyMessage.h"
@interface ClassroomService ()
@property (nonatomic, copy) NSString *auth;
@property (nonatomic, strong) RoomInfo *currentRoom;
@property (nonatomic, strong) UserInfo *currentUser;
@end

@implementation ClassroomService
+ (instancetype)sharedService {
    static ClassroomService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[self alloc] init];
        service.currentUserCanAnime = YES;
    });
    return service;
}

#pragma mark - IM
- (void)registerCommandMessages {
    [IMClient registerMessageType:[RoomBackgroundNotifyMessage class]];
    [IMClient registerMessageType:[MicPositionControlMessage class]];
    [IMClient registerMessageType:[RoomMemberChangedMessage class]];
    [IMClient registerMessageType:[MicPositionChangeMessage class]];
    [IMClient registerMessageType:[RoomDestroyMessage class]];
    [IMClient registerMessageType:[RoomActiveMessage class]];
}
- (BOOL)isHoldMessage:(RCMessage *)message {
    BOOL isHold = NO;
    if([message.content isKindOfClass:[RoomBackgroundNotifyMessage class]]) {
        isHold = YES;
        [self onReceiveBackgroundNotifyMessage:(RoomBackgroundNotifyMessage*)message.content];
    }else if([message.content isKindOfClass:[MicPositionControlMessage class]]) {
        isHold = YES;
        [self onReceiveMicPositionControlMessage:(MicPositionControlMessage*)message.content];
    }else if([message.content isKindOfClass:[RoomMemberChangedMessage class]]) {
        isHold = NO;
        [self onReceiveMemberChangedMessage:(RoomMemberChangedMessage*)message.content];
    }else if([message.content isKindOfClass:[MicPositionChangeMessage class]]) {
        isHold = YES;
        [self onReceiveMicPositionChangeMessage:(MicPositionChangeMessage*)message.content];
    }else if([message.content isKindOfClass:[RoomDestroyMessage class]]) {
        isHold = YES;
        [self onReceiveRoomDestroyMessage:(RoomDestroyMessage*)message.content];
    }
    return isHold;
}

#pragma mark - Server API
- (void)login:(NSString *)deviceId success:(void (^)(UserInfo *currentUser,NSString *imToken))successBlock error:(void(^)(ErrorCode code))errorBlock {
    if(deviceId.length <= 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:deviceId forKey:@"deviceId"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost URLString:@"/user/login/" parameters:dic response:^(HTTPResult *result) {
        if (result.success) {
            NSDictionary *resultDic = result.content[@"result"];
            self.auth = resultDic[@"authorization"];
            [HTTPUtility setAuthHeader:self.auth];
            UserInfo *user = [[UserInfo alloc] init];
            user.userId = resultDic[@"userId"];
            user.nickname = resultDic[@"userName"];
            NSString *imToken = resultDic[@"imToken"];
            self.currentUser = user;
            SealMicLog(@"CurrentUserId:%@",self.currentUser.userId);
            if (successBlock) {
                dispatch_main_async_safe(^{
                    successBlock(user,imToken);
                })
            }
        } else {
            if (errorBlock) {
                dispatch_main_async_safe(^{
                    errorBlock(result.errorCode);
                })
            }
        }
    }];
}

- (void)createRoom:(NSString *)subject type:(int)type success:(void (^)(RoomInfo *room))successBlock error:(void(^)(ErrorCode code))errorBlock {
    if(subject.length <= 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:subject forKey:@"subject"];
    [dic setObject:@(type) forKey:@"type"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost URLString:@"/room/create" parameters:dic response:^(HTTPResult *result) {
        if (result.success) {
            NSDictionary *resultDic = result.content[@"result"];
            RoomInfo *room = [RoomInfo roomInfoFromJson:resultDic];
            dispatch_main_async_safe(^{
                self.currentRoom = room;
                if (successBlock) {
                        successBlock(room);
                }
            })
        } else {
            if (errorBlock) {
                dispatch_main_async_safe(^{
                    errorBlock(result.errorCode);
                })
            }
        }
    }];
}

- (void)getRoomList:(void (^)(NSArray<RoomInfo *> *roomList))successBlock  error:(void(^)(ErrorCode code))errorBlock {
    [HTTPUtility requestWithHTTPMethod:HTTPMethodGet URLString:@"/room/list" parameters:nil response:^(HTTPResult *result) {
        if (result.success) {
            NSArray *dataArr = result.content[@"result"];
            NSMutableArray *resultArr = [NSMutableArray new];
            for(NSDictionary *dic in dataArr) {
                RoomInfo *room = [RoomInfo roomInfoFromJson:dic];
                [resultArr addObject:room];
            }
            if (successBlock) {
                dispatch_main_async_safe(^{
                    successBlock(resultArr);
                })
            }
        } else {
            if (errorBlock) {
                dispatch_main_async_safe(^{
                    errorBlock(result.errorCode);
                })
            }
        }
    }];
}

- (void)getRoomInfo:(NSString *)roomId success:(void (^)(RoomInfo *room))successBlock error:(void(^)(ErrorCode code))errorBlock {
    if(roomId.length <= 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSString *url = [NSString stringWithFormat:@"/room/detail?roomId=%@",roomId];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodGet URLString:url parameters:nil response:^(HTTPResult *result) {
        if (result.success) {
            NSDictionary *resultDic = result.content[@"result"];
            RoomInfo *room = [RoomInfo roomInfoFromJson:resultDic];
            self.currentRoom = room;
            if (successBlock) {
                dispatch_main_async_safe(^{
                    successBlock(room);
                })
            }
        } else {
            if (errorBlock) {
                dispatch_main_async_safe(^{
                    errorBlock(result.errorCode);
                })
            }
        }
    }];
}

- (void)destroyRoom:(NSString *)roomId success:(void (^)(void))successBlock error:(void(^)(ErrorCode code))errorBlock {
    if(roomId.length <= 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:roomId forKey:@"roomId"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost URLString:@"/room/destroy" parameters:dic response:^(HTTPResult *result) {
        if (result.success) {
            if (successBlock) {
                dispatch_main_async_safe(^{
                    successBlock();
                })
            }
        } else {
            if (errorBlock) {
                dispatch_main_async_safe(^{
                    errorBlock(result.errorCode);
                })
            }
        }
    }];
}

- (void)joinRoom:(NSString *)roomId success:(void (^)(RoomInfo *room))successBlock error:(void(^)(ErrorCode code))errorBlock {
    if(roomId.length <= 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:roomId forKey:@"roomId"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost URLString:@"/room/join" parameters:dic response:^(HTTPResult *result) {
        if (result.success) {
            NSDictionary *resultDic = result.content[@"result"];
            RoomInfo *room = [RoomInfo roomInfoFromJson:resultDic];
            dispatch_main_async_safe(^{
                self.currentRoom = room;
                if (successBlock) {
                        successBlock(room);
                }
            })
        } else {
            if (errorBlock) {
                dispatch_main_async_safe(^{
                    errorBlock(result.errorCode);
                })
            }
        }
    }];
}

- (void)leaveRoom:(NSString *)roomId success:(void (^)(void))successBlock error:(void(^)(ErrorCode code))errorBlock {
    if(roomId.length <= 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:roomId forKey:@"roomId"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost URLString:@"/room/leave" parameters:dic response:^(HTTPResult *result) {
        if (result.success) {
            dispatch_main_async_safe(^{
                self.currentRoom = nil;
                if(successBlock) {
                        successBlock();
                }
            })
        } else {
            if (errorBlock) {
                dispatch_main_async_safe(^{
                    errorBlock(result.errorCode);
                })
            }
        }
    }];
}

- (void)joinMic:(NSString *)roomId position:(int)p success:(void (^)(void))successBlock error:(void(^)(ErrorCode code))errorBlock {
    if(roomId.length <= 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:roomId forKey:@"roomId"];
    [dic setObject:@(p) forKey:@"targetPosition"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost URLString:@"/room/mic/join" parameters:dic response:^(HTTPResult *result) {
        if (result.success) {
            dispatch_main_async_safe(^{
                MicPositionInfo *info = [MicPositionInfo new];
                info.userId = self.currentUser.userId;
                info.roomId = roomId;
                info.position = p;
                info.state = MicStateHold;
                [self.currentRoom addMicPosition:info];
                if (successBlock) {
                        successBlock();
                }
            })
        } else {
            if (errorBlock) {
                dispatch_main_async_safe(^{
                    errorBlock(result.errorCode);
                })
            }
        }
    }];
}

- (void)leaveMic:(NSString *)roomId position:(int)p success:(void (^)(void))successBlock error:(void(^)(ErrorCode code))errorBlock {
    if(roomId.length <= 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:roomId forKey:@"roomId"];
    [dic setObject:@(p) forKey:@"targetPosition"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost URLString:@"/room/mic/leave" parameters:dic response:^(HTTPResult *result) {
        if (result.success) {
            dispatch_main_async_safe(^{
                [self.currentRoom removeMicPosition:p];
                if (successBlock) {
                    successBlock();
                }
            })
        } else {
            if (errorBlock) {
                dispatch_main_async_safe(^{
                    errorBlock(result.errorCode);
                })
            }
        }
    }];
}

- (void)changeMic:(NSString *)roomId from:(int)from to:(int)to success:(void (^)(void))successBlock error:(void(^)(ErrorCode code))errorBlock {
    if(roomId.length <= 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:roomId forKey:@"roomId"];
    [dic setObject:@(from) forKey:@"fromPosition"];
    [dic setObject:@(to) forKey:@"toPosition"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost URLString:@"/room/mic/change" parameters:dic response:^(HTTPResult *result) {
        if (result.success) {
            dispatch_main_async_safe(^{
                MicPositionInfo *info = [MicPositionInfo new];
                info.userId = self.currentUser.userId;
                info.roomId = roomId;
                info.position = to;
                info.state = MicStateHold;
                [self.currentRoom removeMicPosition:from];
                [self.currentRoom addMicPosition:info];
                if (successBlock) {
                        successBlock();
                }
            })
        } else {
            if (errorBlock) {
                dispatch_main_async_safe(^{
                    errorBlock(result.errorCode);
                })
            }
        }
    }];
}

- (void)controlMic:(NSString *)roomId targetId:(NSString *)userId behavior:(MicBehaviorType)be position:(int)p success:(void (^)(void))successBlock error:(void(^)(ErrorCode code))errorBlock {
    if(roomId.length <= 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:roomId forKey:@"roomId"];
    [dic setObject:@(be) forKey:@"cmd"];
    [dic setObject:@(p) forKey:@"targetPosition"];
    if (userId.length > 0) {
        [dic setObject:userId forKey:@"targetUserId"];
    }
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost URLString:@"/room/mic/control" parameters:dic response:^(HTTPResult *result) {
        if (result.success) {
            dispatch_main_async_safe(^{
                if (successBlock) {
                        successBlock();
                }
            })
        } else {
            if (errorBlock) {
                dispatch_main_async_safe(^{
                    errorBlock(result.errorCode);
                })
            }
        }
    }];
}

- (void)getMemeberList:(NSString *)roomId success:(void (^)(NSArray <UserInfo *> *users))successBlock error:(void(^)(ErrorCode code))errorBlock {
    if(roomId.length <= 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSString *url = [NSString stringWithFormat:@"/room/member/list?roomId=%@",roomId];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodGet URLString:url parameters:nil response:^(HTTPResult *result) {
        if (result.success) {
            NSArray *dataArr = result.content[@"result"];
            NSMutableArray *resultArr = [NSMutableArray new];
            for(NSDictionary *dic in dataArr) {
                UserInfo *user = [UserInfo userInfoFromJson:dic];
                [resultArr addObject:user];
            }
            if (successBlock) {
                dispatch_main_async_safe(^{
                    successBlock(resultArr);
                })
            }
        } else {
            if (errorBlock) {
                dispatch_main_async_safe(^{
                    errorBlock(result.errorCode);
                })
            }
        }
    }];
}

- (void)changeRoomBackground:(NSString *)roomId bgId:(int)bgId success:(void (^)(void))successBlock error:(void(^)(ErrorCode code))errorBlock {
    if(roomId.length <= 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:roomId forKey:@"roomId"];
    [dic setObject:@(bgId) forKey:@"bgId"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost URLString:@"/room/background" parameters:dic response:^(HTTPResult *result) {
        if (result.success) {
            if (successBlock) {
                dispatch_main_async_safe(^{
                    successBlock();
                })
            }
        } else {
            if (errorBlock) {
                dispatch_main_async_safe(^{
                    errorBlock(result.errorCode);
                })
            }
        }
    }];
}


- (NSArray<NSNumber *> *)getMicBehaviorList:(int)position {
    MicPositionInfo *pInfo = [self.currentRoom getMicPositionInfoAt:position];
    if (!pInfo) {
        pInfo = [[MicPositionInfo alloc] init];
    }
    RoomInfo *roomInfo = self.currentRoom;
    UserInfo *curUserInfo = self.currentUser;
    //如果当前用户是房主
    if([roomInfo.creatorId isEqualToString:curUserInfo.userId]) {
        return [self _getCreatorMicBehaviorList:pInfo];
    }else {
        return [self _getUserMicBehaviorList:pInfo];
    }
    
    return nil;
}

#pragma mark - message response
- (void)onReceiveBackgroundNotifyMessage:(RoomBackgroundNotifyMessage *)content {
    dispatch_main_async_safe(^{
        if([self.classroomDelegate respondsToSelector:@selector(classroomService: backgroundDidChange:)]) {
            [self.classroomDelegate classroomService:self backgroundDidChange:content.backgroundId];
        }
    })
}

- (void)onReceiveMicPositionControlMessage:(MicPositionControlMessage *)content {
    dispatch_main_async_safe(^{
        [self.currentRoom updateMicPositions:content.micPositions];
        if([self.classroomDelegate respondsToSelector:@selector(classroomService:micDidControl:behavior:position:)]) {
            [self.classroomDelegate classroomService:self micDidControl:content.targetUserId behavior:content.type position:content.targetPosition];
        }
    })
}

- (void)onReceiveMemberChangedMessage:(RoomMemberChangedMessage *)content {
    dispatch_main_async_safe(^{
        if(content.action == MemberChangeActionJoin) {
            [self.currentRoom addAudience:content.userId];
            if([self.classroomDelegate respondsToSelector:@selector(classroomService:userDidJoin:)]) {
                [self.classroomDelegate classroomService:self userDidJoin:content.userId ];
            }
        }else if(content.action == MemberChangeActionLeave) {
            [self.currentRoom removeAudience:content.userId];
            if([self.classroomDelegate respondsToSelector:@selector(classroomService:userDidLeave:)]) {
                [self.classroomDelegate classroomService:self userDidLeave:content.userId];
            }
        }else if(content.action == MemberChangeActionKick) {
            [self.currentRoom removeAudience:content.userId];
            if([self.classroomDelegate respondsToSelector:@selector(classroomService:userDidKicked:)]) {
                [self.classroomDelegate classroomService:self userDidKicked:content.userId];
            }
        }

    })
}

- (void)onReceiveMicPositionChangeMessage:(MicPositionChangeMessage *)content {
    dispatch_main_async_safe(^{
        [self.currentRoom updateMicPositions:content.micPositions];
        if([self.classroomDelegate respondsToSelector:@selector(classroomService:micDidChange:behavior:from:to:)]) {
            [self.classroomDelegate classroomService:self micDidChange:content.targetUserId behavior:content.type from:content.fromPosition to:content.toPosition];
        }
    })
}

- (void)onReceiveRoomDestroyMessage:(RoomDestroyMessage *)content{
    dispatch_main_async_safe(^{
        if([self.classroomDelegate respondsToSelector:@selector(classroomDidDesory)]) {
            [self.classroomDelegate classroomDidDesory];
        }
    })
}
#pragma mark - private
- (void)_notifyUserDidSpeak:(NSString *)userId {
    if([self.classroomDelegate respondsToSelector:@selector(classroomService:userDidSpeak:)]) {
        [self.classroomDelegate classroomService:self userDidSpeak:userId];
    }
}

- (void)callbackFailureDescription:(ErrorCode)code {
    dispatch_main_async_safe(^{
        if ([self.classroomDelegate respondsToSelector:@selector(classroomService:errorDidOccur:)]) {
            [self.classroomDelegate classroomService:self errorDidOccur:code];
        }
    });
}

- (NSArray <NSNumber *> *)_getCreatorMicBehaviorList:(MicPositionInfo *)pInfo {
    NSMutableArray *list = [NSMutableArray new];
    MicState state = pInfo.state;
    if(state & MicStateLocked){
        [list addObject:@(MicBehaviorTypeUnlockMic)];
    }else{
        if (state & MicStateHold && pInfo.userId.length > 0){
            [list addObject:@(MicBehaviorTypeKickOffMic)];
            [list addObject:@(MicBehaviorTypeJumpDownMic)];
        }else{
            [list addObject:@(MicBehaviorTypePickupMic)];
        }
        [list addObject:@(MicBehaviorTypeLockMic)];
    }
    
    if(state & MicStateForbidden){
        [list addObject:@(MicBehaviorTypeUnForbidMic)];
    }else{
        [list addObject:@(MicBehaviorTypeForbidMic)];
    }
    return list;
}

- (NSArray <NSNumber *> *)_getUserMicBehaviorList:(MicPositionInfo *)pInfo {
    NSMutableArray *list = [NSMutableArray new];
        MicState state = pInfo.state;
        UserInfo *curUser = self.currentUser;
        MicPositionInfo *curUserMic = [self.currentRoom getMicPositionInfo:curUser.userId];
        if(!(state & MicStateLocked)){
            if (pInfo.userId.length > 0 && (state & MicStateHold)) {
                if([curUser.userId isEqualToString:pInfo.userId]) {
                    //麦位的用户就是当前用户，那么下麦
                    [list addObject:@(MicBehaviorTypeJumpDownMic)];
                }
            }else{
                if (curUserMic) {
                    //当前用户存在一个麦位，跳麦
                    [list addObject:@(MicBehaviorTypeJumpToMic)];
                }else{
                    //当前用户不存在一个麦位，上麦
                    [list addObject:@(MicBehaviorTypeJumpOnMic)];
                }
            }
        }
  
    return list;
}
@end
