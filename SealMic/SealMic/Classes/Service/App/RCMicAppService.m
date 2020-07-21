//
//  RCMicAppService.m
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicAppService.h"
#import "RCMicMacro.h"
#import "RCMicIMService.h"
#import "RCMicRTCService.h"
#import "RCMicMemoryCache.h"
#define UserInfoKey @"userInfo"

NSString *const RCMicKickedOfflineNotification = @"RCMicKickedOffline";
NSString *const RCMicLoginSuccessNotification = @"RCMicLoginSuccess";
NSString *const RCMicKickedOutNotification = @"RCMicKickedOut";
static RCMicAppService *appService = nil;
static NSInteger refreshTokenCount = 0;

@interface RCMicAppService()<RCMicIMConnectionStatusChangeDelegate, RCMicMessageHandleDelegate>
@property (nonatomic, strong) RCMicMemoryCache *userInfoCache;
@end

@implementation RCMicAppService

+ (instancetype)sharedService {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appService = [[RCMicAppService alloc] init];
        [[RCMicIMService sharedService] addIMConnectionStatusChangeDelegate:appService];
        [[RCMicIMService sharedService] addMessageHandleDelegate:appService];
    });
    return appService;
}

#pragma mark - Public method
#pragma mark - 用户相关
- (void)configUserEnvironment:(RCMicCachedUserInfo *)userInfo {
    self.currentUser = userInfo;
    [RCMicHTTPUtility setAuthHeader:userInfo.authorization];
    NSData *cachedData = [RCMicUtil secureArchivedDataWithObject:userInfo];
    [[NSUserDefaults standardUserDefaults] setObject:cachedData forKey:UserInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    /*
        每次配置用户信息的时候，先断开IM链接。
        如果userInfo有值的话，根据新的userInfo token进行重新链接，
        如果没有值的话 直接断开 IM 链接。不需要调用 IM 链接。
     */
    [self disconnectIM];
    if (userInfo){
        [self connectIMWithToken:userInfo.token];
    }
}

- (void)visitorLogin:(NSString *)name portrait:(NSString *)portrait deviceId:(NSString *)deviceId success:(void (^)(RCMicCachedUserInfo * _Nonnull))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (name.length == 0 || portrait.length == 0 || deviceId.length == 0) {
        RCMicLog(@"visitor login error, name or portrait or deviceId is empty");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSDictionary *param = @{@"userName":name, @"portrait":portrait, @"deviceId":deviceId};
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:@"user/visitorLogin" parameters:param response:^(RCMicHTTPResult *result) {
        if (result.success) {
            RCMicCachedUserInfo *cachedInfo = [self generateCachedUserInfoWithDict:result.content];
            successBlock ? successBlock(cachedInfo) : nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:RCMicLoginSuccessNotification object:nil];
        } else {
            errorBlock ? errorBlock(result.errorCode) : nil;
            RCMicLog(@"visitor login complete with error, code:%ld",(long)result.errorCode);
        }
    }];
}

- (void)userLogin:(NSString *)name portrait:(NSString *)portrait deviceId:(NSString *)deviceId phoneNumber:(NSString *)phoneNumber verifyCode:(NSString *)verifyCode success:(void (^)(RCMicCachedUserInfo * _Nonnull))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (name.length == 0 || portrait.length == 0 || deviceId.length == 0 || phoneNumber.length == 0 || verifyCode.length == 0) {
        RCMicLog(@"user login error, param illegal");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSDictionary *paramDict = @{@"userName":name, @"portrait":portrait, @"deviceId":deviceId, @"mobile":phoneNumber, @"verifyCode":verifyCode};
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:@"user/login" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            RCMicCachedUserInfo *cachedInfo = [self generateCachedUserInfoWithDict:result.content];
            successBlock ? successBlock(cachedInfo) : nil;
        } else {
            RCMicLog(@"user login complete with error, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)sendVerificationCode:(NSString *)phoneNumber success:(void(^)(void))successBlock error:(void(^)(RCMicHTTPCode))errorBlock {
    if (phoneNumber.length == 0) {
        RCMicLog(@"send verification code error, phone number is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSDictionary *paramDict = @{@"mobile":phoneNumber};
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:@"user/sendCode" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"send verification code complete with eror, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)getUserInfo:(NSString *)userId success:(void (^)(RCMicUserInfo * _Nonnull))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (userId.length == 0) {
        RCMicLog(@"get user info error, userId is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    //缓存有直接取缓存
    if ([self.userInfoCache containsObjectForKey:userId]) {
        successBlock ? successBlock([self.userInfoCache objectForKey:userId]) : nil;
        return;
    }
    //缓存没有从网络加载
    NSDictionary *paramDict = @{@"userIds":@[userId]};
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:@"user/batch" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            RCMicUserInfo *userInfo = [[RCMicUserInfo alloc] init];
            if (((NSArray *)result.content).count > 0) {
                [userInfo setValuesForKeysWithDictionary:result.content[0]];                
            }
            successBlock ? successBlock(userInfo) : nil;
        } else {
            RCMicLog(@"get user info complete with error, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

#pragma mark - 房间相关
- (void)createRoomWithName:(NSString *)name themeImage:(NSString *)imageURL success:(void (^)(RCMicRoomInfo * _Nonnull))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (name.length == 0 || imageURL.length == 0) {
        RCMicLog(@"create room error, name or imageURL is empty");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    
    NSDictionary *paramDict = @{@"name":name, @"themePictureUrl":imageURL};
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:@"room/create" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            NSDictionary *data = result.content;
            RCMicRoomInfo *roomInfo = [[RCMicRoomInfo alloc] init];
            [roomInfo setValuesForKeysWithDictionary:data];
            successBlock ? successBlock(roomInfo) : nil;
        } else {
            RCMicLog(@"create room complete with error, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)getRoomListWithLimit:(NSInteger)limit latestRoom:(NSString *)roomId success:(void (^)(NSArray<RCMicRoomInfo *> * _Nonnull))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (limit < 0) {
        RCMicLog(@"get room list error, limit is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSDictionary *paramDict = @{@"fromRoomId":roomId.length > 0 ? roomId : @"", @"size":@(limit)};
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodGet URLString:@"room/list" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            NSMutableArray *roomArray = [NSMutableArray array];
            for (NSDictionary *roomDict in result.content[@"rooms"]) {
                RCMicRoomInfo *roomInfo = [[RCMicRoomInfo alloc] init];
                [roomInfo setValuesForKeysWithDictionary:roomDict];
                [roomArray addObject:roomInfo];
            }
            successBlock ? successBlock([roomArray copy]) : nil;
        } else {
            RCMicLog(@"get room list complete with error, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)getRoomInfo:(NSString *)roomId success:(void (^)(RCMicRoomInfo * _Nonnull))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"get room info error, roomId is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSString *url = [NSString stringWithFormat:@"room/%@",roomId];
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodGet URLString:url parameters:nil response:^(RCMicHTTPResult *result) {
        if (result.success) {
            RCMicRoomInfo *info = [[RCMicRoomInfo alloc] init];
            [info setValuesForKeysWithDictionary:result.content];
            successBlock ? successBlock(info) : nil;
        } else {
            RCMicLog(@"get room info complete with error, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)setRoomAttribute:(NSString *)roomId freeJoinRoom:(NSInteger)freeJoinRoom freeJoinMic:(NSInteger)freeJoinMic success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"set room attribute error, roomId is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setValue:roomId forKey:@"roomId"];
    if (freeJoinRoom >= 0) {
        freeJoinRoom = freeJoinRoom > 0 ? 1 : 0;
        [paramDict setValue:@(freeJoinRoom) forKey:@"allowedJoinRoom"];
    }
    if (freeJoinMic >= 0) {
        freeJoinMic = freeJoinMic > 0 ? 1 : 0;
        [paramDict setValue:@(freeJoinMic) forKey:@"allowedFreeJoinMic"];
    }
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPut URLString:@"room/setting" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"set room attribute complete with error, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)getRoomUserList:(NSString *)roomId success:(void (^)(NSArray<RCMicUserInfo *> * _Nonnull))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"get room user list error, roomId is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSString *url = [NSString stringWithFormat:@"room/%@/members",roomId];
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodGet URLString:url parameters:nil response:^(RCMicHTTPResult *result) {
        if (result.success) {
            NSMutableArray *userArray = [NSMutableArray array];
            for (NSDictionary *userDict in result.content) {
                RCMicUserInfo *userInfo = [[RCMicUserInfo alloc] init];
                [userInfo setValuesForKeysWithDictionary:userDict];
                [userArray addObject:userInfo];
            }
            successBlock ? successBlock([userArray copy]) : nil;
        } else {
            RCMicLog(@"get room user list complete with error, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)getMicWaitingUserList:(NSString *)roomId success:(void (^)(NSArray<RCMicUserInfo *> * _Nonnull))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"get mic waiting user list error, roomId is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSString *url = [NSString stringWithFormat:@"room/%@/mic/apply/members",roomId];
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodGet URLString:url parameters:nil response:^(RCMicHTTPResult *result) {
        if (result.success) {
            NSMutableArray *userArray = [NSMutableArray array];
            for (NSDictionary *userDict in result.content) {
                RCMicUserInfo *userInfo = [[RCMicUserInfo alloc] init];
                [userInfo setValuesForKeysWithDictionary:userDict];
                [userArray addObject:userInfo];
            }
            successBlock ? successBlock([userArray copy]) : nil;
        } else {
            RCMicLog(@"get mic waiting user list complete with error, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)getBannedUserList:(NSString *)roomId success:(void (^)(NSArray<RCMicUserInfo *> * _Nonnull))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"get banned user list error, roomId is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSString *url = [NSString stringWithFormat:@"room/%@/gag/members",roomId];
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodGet URLString:url parameters:nil response:^(RCMicHTTPResult *result) {
        if (result.success) {
            NSMutableArray *userArray = [NSMutableArray array];
            for (NSDictionary *userDict in result.content) {
                RCMicUserInfo *userInfo = [[RCMicUserInfo alloc] init];
                [userInfo setValuesForKeysWithDictionary:userDict];
                [userArray addObject:userInfo];
            }
            successBlock ? successBlock([userArray copy]) : nil;
        } else {
            RCMicLog(@"get banned user list complete with error, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)kickUserOut:(NSString *)roomId userIds:(NSArray<NSString *> *)userIds success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0 || userIds.count == 0) {
        RCMicLog(@"kick user out error, roomId or userIds is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSDictionary *paramDict = @{@"roomId":roomId, @"userIds":userIds};
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:@"room/kick" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"kick user out complete with error, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)setUserStateInRoom:(NSString *)roomId userIds:(NSArray<NSString *> *)userIds canSendMessage:(BOOL)canSend success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0 || userIds.count == 0) {
        RCMicLog(@"set user state in room error, roomId or userIds is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSString *operation = canSend ? @"remove" : @"add";
    NSDictionary *paramDict = @{@"roomId":roomId, @"operation":operation, @"userIds":userIds};
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:@"room/gag" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"set user state in room complete with error, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

#pragma mark - 麦位相关
- (void)applyParticipant:(NSString *)roomId success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"apply participant error, roomId is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSDictionary *paramDict = @{@"roomId":roomId};
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:@"room/mic/apply" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"apply participant complete with error, code%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)giveUpParticipant:(NSString *)roomId success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"give up participant error, roomId is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSDictionary *paramDict = @{@"roomId":roomId};
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:@"room/mic/quit" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"give up participant complete with error, code%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)takeOverHost:(NSString *)roomId success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"apply take over host error, roomId is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSDictionary *paramDict = @{@"roomId":roomId};
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:@"room/mic/takeOverHost" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"apply take over host complete with error, code%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)dealWithHostTransfer:(NSString *)roomId accept:(BOOL)accept success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"deal with host transfer error, roomId is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSDictionary *paramDict = @{@"roomId":roomId};
    NSString *url = accept ? @"room/mic/transferHost/accept" : @"room/mic/transferHost/reject";
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:url parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"deal with host transfer complete with error, code%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)dealWithParticipantApply:(NSString *)roomId userId:(NSString *)userId accept:(BOOL)accept success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0 || userId.length == 0) {
        RCMicLog(@"deal with participant apply error, roomId or userId is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSDictionary *paramDict = @{@"roomId":roomId, @"userId":userId};
    NSString *url = accept ? @"room/mic/apply/accept" : @"room/mic/apply/reject";
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:url parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"deal with participant apply complete with error, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)inviteParticipant:(NSString *)roomId userId:(NSString *)userId success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0 || userId.length == 0) {
        RCMicLog(@"invite participant error, roomId or userId is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSDictionary *paramDict = @{@"roomId":roomId, @"userId":userId};
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:@"room/mic/invite" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"invite participant complete with error, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)transferHost:(NSString *)roomId toUser:(NSString *)userId success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0 || userId.length == 0) {
        RCMicLog(@"transfer host error, roomId or userId is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSDictionary *paramDict = @{@"roomId":roomId, @"userId":userId};
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:@"room/mic/transferHost" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"transfer host complete with error, code%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)dealWithHostTakeOver:(NSString *)roomId accept:(BOOL)accept userId:(NSString *)userId success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0 || userId.length == 0) {
        RCMicLog(@"deal with host take over error, roomId or userId is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSDictionary *paramDict = @{@"roomId":roomId, @"userId":userId};
    NSString *url = accept ? @"room/mic/takeOverHost/accept" : @"room/mic/takeOverHost/reject";
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:url parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"deal with host take over complete with error, code%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)kickParticipantOut:(NSString *)roomId userId:(NSString *)userId success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0 || userId.length == 0) {
        RCMicLog(@"kick participant out error, roomId or userId is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSDictionary *paramDict = @{@"roomId":roomId, @"userId":userId};
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:@"room/mic/kick" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"kick participant out complete with error, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)setParticipantState:(NSString *)roomId state:(RCMicParticipantState)state position:(NSInteger)position success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (roomId.length == 0 || position < 0 || position > RCMicParticipantCount) {
        RCMicLog(@"set participant state error, param illegal");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSDictionary *paramDict = @{@"roomId":roomId, @"state":@(state), @"position":@(position)};
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPut URLString:@"room/mic/state" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"set participant state complete with error, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)sendBroadcastMessage:(NSString *)userId objectName:(NSString *)objectName content:(NSString *)content success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (objectName.length == 0 || content.length == 0) {
        RCMicLog(@"send broadcast message error, object name or content is null");
        errorBlock ? errorBlock(RCMicHTTPCodeParamIllegal) : nil;
        return;
    }
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    if (userId.length > 0) {
        [paramDict setValue:userId forKey:@"fromUserId"];
    }
    [paramDict setValue:objectName forKey:@"objectName"];
    [paramDict setValue:content forKey:@"content"];
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:@"room/message/broadcast" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"send broadcast message complete with error, code:%ld",(long)result.errorCode);
            errorBlock ? errorBlock(result.errorCode) : nil;
        }
    }];
}

- (void)checkVersion:(void (^)(RCMicVersionInfo * _Nullable))completionBlock {
    NSString *versionCode = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleVersion"];
    NSDictionary *paramDict = @{@"platform":@"iOS", @"versionCode":versionCode.length > 0 ? versionCode : @"202007031616"};
    [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodGet URLString:@"appversion/latest" parameters:paramDict response:^(RCMicHTTPResult *result) {
        if (result.success) {
            RCMicVersionInfo *versionInfo = [[RCMicVersionInfo alloc] init];
            [versionInfo setValuesForKeysWithDictionary:result.content];
            completionBlock ? completionBlock(versionInfo) : nil;
        } else {
            RCMicLog(@"check version complete with error, code:%ld",(long)result.errorCode);
            completionBlock ? completionBlock(nil) : nil;
        }
    }];
}

#pragma mark - Private method
- (void)connectIMWithToken:(NSString *)token {
    [[RCMicIMService sharedService] connectWithToken:token];
}

- (void)disconnectIM {
    [[RCMicIMService sharedService] disconnect];
}

/// 刷新链接 IM 时用的 token
- (void)refreshToken {
    //如果 server 返回的 token 一直有问题，重复 10 次或者根据应用实际情况确定的次数之后就不再继续刷新了，一般是 server 跟端上 appkey 不符了
    if (refreshTokenCount <= 10) {
        [RCMicHTTPUtility requestWithHTTPMethod:RCMicHTTPMethodPost URLString:@"user/refreshToken" parameters:nil response:^(RCMicHTTPResult *result) {
            if (result.success) {
                [self connectIMWithToken:result.content[@"imToken"]];
            } else {
                //这里可根据应用实际情况决定是否需要重新获取以及重新获取几次
                RCMicLog(@"refresh token complete with error, code:%ld",(long)result.errorCode);
            }
        }];
    } else {
        //这里可根据应用实际需求决定是否要有 UI 上的提示
    }
    refreshTokenCount ++;
}

- (RCMicCachedUserInfo *)generateCachedUserInfoWithDict:(NSDictionary *)dict {
    RCMicUserInfo *userInfo = [[RCMicUserInfo alloc] init];
    [userInfo setValuesForKeysWithDictionary:dict];
    RCMicCachedUserInfo *cachedInfo = [[RCMicCachedUserInfo alloc] init];
    cachedInfo.userInfo = userInfo;
    cachedInfo.token = dict[@"imToken"];
    cachedInfo.authorization = dict[@"authorization"];
    
    return cachedInfo;
}

#pragma mark - RCMicIMConnectionStatusChangeDelegate
- (void)onConnectionStatusChanged:(RCConnectionStatus)status {
    //以下几种异常场景需结合应用实际情况处理
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        // 当前用户在其他设备上登录，此设备被踢下线
        [[NSNotificationCenter defaultCenter] postNotificationName:RCMicKickedOfflineNotification object:nil];
    } else if (status == ConnectionStatus_TOKEN_INCORRECT) {
        [self refreshToken];
    } else if (status == ConnectionStatus_DISCONN_EXCEPTION) {
    } else if (status == ConnectionStatus_Connected) {
        RCMicLog(@"im connected");
    }
}

#pragma mark - RCMicMessageHandleDelegate
- (BOOL)handleMessage:(RCMessage *)message {
    if ([message.content isKindOfClass:[RCMicKickOutMessage class]]) {
        RCMicKickOutMessage *kickOutMessage = (RCMicKickOutMessage *)message.content;
        [[NSNotificationCenter defaultCenter] postNotificationName:RCMicKickedOutNotification object:nil userInfo:@{@"roomId":kickOutMessage.roomId}];
        return YES;
    }
    return NO;
}

#pragma mark - Getters & Setters
- (RCMicCachedUserInfo *)currentUser {
    if (!_currentUser) {
        NSData *cachedInfo = [[NSUserDefaults standardUserDefaults] objectForKey:UserInfoKey];
        RCMicCachedUserInfo *userInfo = (RCMicCachedUserInfo *)[RCMicUtil secureUnarchiveObjectOfClass:[RCMicCachedUserInfo class] fromData:cachedInfo];
        _currentUser = userInfo;
    }
    return _currentUser;
}

- (RCMicMemoryCache *)userInfoCache {
    if (!_userInfoCache) {
        _userInfoCache = [[RCMicMemoryCache alloc] init];
        _userInfoCache.countLimit = 100;
    }
    return _userInfoCache;
}
@end
