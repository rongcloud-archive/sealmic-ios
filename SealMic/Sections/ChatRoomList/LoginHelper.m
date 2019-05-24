//
//  LoginHelper.m
//  SealClass
//
//  Created by 张改红 on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "LoginHelper.h"
#import "IMService.h"
#import "RoomActiveMessage.h"
@interface LoginHelper()<RongRTCRoomDelegate, RCConnectionStatusChangeDelegate>
@property (nonatomic, assign) BOOL loginSuccess;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *imToken;
@end

@implementation LoginHelper
+ (instancetype)sharedInstance {
    static LoginHelper *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[self alloc] init];
        [IMClient setRCConnectionStatusChangeDelegate:service];
    });
    return service;
}

#pragma mark - Api
- (void)login{
    SealMicLog(@"login start");
    [[ClassroomService sharedService] login:[UIDevice currentDevice].identifierForVendor.UUIDString success:^(UserInfo * _Nonnull currentUser, NSString * _Nonnull imToken) {
        self.imToken = imToken;
        if (self.delegate && [self.delegate respondsToSelector:@selector(roomDidLogin)]) {
            [self.delegate roomDidLogin];
        }
        SealMicLog(@"login suceess");
        [self connectIM];
    } error:^(ErrorCode code) {
        SealMicLog(@"login classroom error:%@",@(code));
        if(self.delegate && [self.delegate respondsToSelector:@selector(roomDidOccurError:)]){
            [self.delegate roomDidOccurError:MicLocalizedNamed(@"LoginFailure")];
        }
    }];
}

- (void)create:(NSString *)roomName type:(int)type{
    if (![self connectionIsAvailable]) {
        return;
    }
    [[ClassroomService sharedService] createRoom:roomName type:type success:^(RoomInfo * _Nonnull room) {
        self.roomId = room.roomId;
        [self joinRongRTCRoom];
    } error:^(ErrorCode code) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(roomDidOccurError:)]){
            [self.delegate roomDidOccurError:MicLocalizedNamed(@"CreateRoomFailure")];
        }
    }];
}

- (void)join:(NSString *)roomId{
    if (![self connectionIsAvailable]) {
        return;
    }
    [[ClassroomService sharedService] joinRoom:roomId success:^(RoomInfo * _Nonnull room) {
        self.roomId = room.roomId;
        [self joinRongRTCRoom];
    } error:^(ErrorCode code) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(roomDidOccurError:)]){
//            [self.delegate roomDidOccurError:MicLocalizedNamed(@"JoinRoomFailure")];
        }
    }];
}

- (void)logout:(LogoutChatRoomType)type success:(void (^)(void))success error:(void (^)(NSInteger))error{
    SealMicLog(@"logout start");
    [self stopActive];
    if (type == LogoutChatRoomTypeLeave) {
        [self leave:success error:error];
    }else if (type == LogoutChatRoomTypeDetory){
        [self destory:success error:error];
    }else if (type == LogoutChatRoomTypeHasDetory){
        [self logoutIMAndRTCRoom:success error:error];
    }
}

#pragma mark - RCConnectionStatusChangeDelegate
- (void)onConnectionStatusChanged:(RCConnectionStatus)status{
    if (status == ConnectionStatus_Connected) {
        SealMicLog(@"connect im success");
    }
}

#pragma mark - Helper
- (void)connectIM{
    __weak typeof(self) weakSelf = self;
    SealMicLog(@"connect im start");
    [IMClient connectWithToken:self.imToken success:^(NSString *userId) {
    } error:^(RCConnectErrorCode status) {
        SealMicLog(@"connect im error:%@",@(status));
        if (status != RC_CONN_REDIRECTED) {
            dispatch_main_async_safe(^{
                SealMicLog(@"IM connect error");
                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(roomDidOccurError:)]){
//                    [weakSelf.delegate roomDidOccurError:MicLocalizedNamed(@"ConnectIMFailure")];
                }
            });
        }
    } tokenIncorrect:^{
        SealMicLog(@"connect im token incorrect");
        dispatch_main_async_safe(^{
            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(roomDidOccurError:)]){
                [weakSelf.delegate roomDidOccurError:MicLocalizedNamed(@"IMTokenIncorrect")];
            }
        });
    }];
}

- (void)joinRongRTCRoom{
    SealMicLog(@"join rtc room start");
    [[RTCService sharedService] joinRongRTCRoom:self.roomId success:^(RongRTCRoom * _Nonnull room) {
        SealMicLog(@"join rtc room success");
        [self joinIMChatRoom];
    } error:^(RongRTCCode code) {
        SealMicLog(@"join rtc room error:%@",@(code));
        dispatch_main_async_safe(^{
            if(self.delegate && [self.delegate respondsToSelector:@selector(roomDidOccurError:)]){
                [self.delegate roomDidOccurError:MicLocalizedNamed(@"JoinRTCRoomFailure")];
            }
        });
    }];
}

- (void)joinIMChatRoom{
    SealMicLog(@"start joinIMChatRoom");
    [[IMService sharedService] joinIMChatRoom:self.roomId success:^{
        SealMicLog(@"joinIMChatRoom success");
        [self keepChatRoomActive];
        dispatch_main_async_safe(^{
            if(self.delegate && [self.delegate respondsToSelector:@selector(roomDidCreateOrJoin)]){
                [self.delegate roomDidCreateOrJoin];
            }
        });
    } error:^(int errCode) {
        SealMicLog(@"joinIMChatRoom error:%d",errCode);
        dispatch_main_async_safe(^{
            if(self.delegate && [self.delegate respondsToSelector:@selector(roomDidOccurError:)]){
                [self.delegate roomDidOccurError:MicLocalizedNamed(@"JoinIMChatRoomFailure")];
            }
        });
    }];
}

- (void)leave:(void (^)(void))success error:(void (^)(NSInteger code))error {
    SealMicLog(@"leave chatroom start");
    [[ClassroomService sharedService] leaveRoom:self.roomId success:^{
        SealMicLog(@"leave chatroom success");
        [self logoutIMAndRTCRoom:success error:error];
    } error:^(ErrorCode code) {
        SealMicLog(@"leave chatroom error:%@",@(code));
        if (error) {
            error(code);
        }
    }];
}

- (void)destory:(void (^)(void))success error:(void (^)(NSInteger code))error {
    SealMicLog(@"destory chatroom start");
    [[ClassroomService sharedService] destroyRoom:self.roomId success:^{
        SealMicLog(@"destory chatroom success");
        [self logoutIMAndRTCRoom:success error:error];
    } error:^(ErrorCode code) {
        SealMicLog(@"destory chatroom error:%@",@(code));
        if (error) {
            error(code);
        }
    }];
}

- (void)logoutIMAndRTCRoom:(void (^)(void))success error:(void (^)(NSInteger code))error{
    SealMicLog(@"logoutIMAndRTCRoom start");
    [[RTCService sharedService] leaveRongRTCRoom:self.roomId success:^{
        SealMicLog(@"leave rtc room success");
        [[IMService sharedService] quitIMChatRoom:self.roomId success:success error:^(RCErrorCode status) {
            dispatch_main_async_safe(^{
                if (error) {
                    error(status);
                }
            });
        }];
    } error:^(RongRTCCode code) {//todo
        SealMicLog(@"leave rtc room error:%@",@(code));
        dispatch_main_async_safe(^{
            if (error) {
                error(code);
            }
        });
    }];
}

- (void)keepChatRoomActive{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10*60 target:self selector:@selector(sendChatRoomActiveMessage) userInfo:nil repeats:YES];
    [self.timer setFireDate:[NSDate distantPast]];
}

- (void)stopActive{
    [self.timer setFireDate:[NSDate distantFuture]];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)sendChatRoomActiveMessage{
    RoomActiveMessage *message = [[RoomActiveMessage alloc] init];
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_CHATROOM targetId:self.roomId content:message pushContent:nil pushData:nil success:^(long messageId) {
        SealMicLog(@"sendChatRoomActiveMessage success");
    } error:^(RCErrorCode nErrorCode, long messageId) {
        SealMicLog(@"sendChatRoomActiveMessage error:%ld",nErrorCode);
    }];
}

- (BOOL)connectionIsAvailable{
    if ([RCIMClient sharedRCIMClient].getConnectionStatus == ConnectionStatus_Connected) {
        return YES;
    }else{
        if(self.delegate && [self.delegate respondsToSelector:@selector(roomDidOccurError:)]){
//            [self.delegate roomDidOccurError:MicLocalizedNamed(@"IMUnconnected")];
        }
        if (self.imToken.length > 0){
            [self connectIM];
        }else{
            [self login];
        }
    }
    return NO;
}
@end
