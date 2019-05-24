//
//  RTCService.m
//  SealMic
//
//  Created by Sin on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RTCService.h"
#import "ClassroomService.h"

@interface RTCService ()<RongRTCNetworkMonitorDelegate>
@property (nonatomic, strong) RongRTCRoom *rtcRoom;
@property (nonatomic, strong) RongRTCVideoCaptureParam *captureParam;
@property (nonatomic, strong) RongRTCAVCapturer *capturer;
@end

@implementation RTCService
+ (instancetype)sharedService {
    static RTCService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[self alloc] init];
    });
    return service;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [RongRTCEngine sharedEngine].netMonitor = self;
    }
    return self;
}

- (void)setRTCRoomDelegate:(id<RongRTCRoomDelegate>)delegate {
    if(!self.rtcRoom) {
        NSLog(@"尚未加入 rtc room，无法设置代理");
        return;
    }
    self.rtcRoom.delegate = delegate;
}

#pragma mark - 加入/退出 rtc 房间
- (void)joinRongRTCRoom:(NSString *)roomId success:(void (^)( RongRTCRoom  * _Nullable room))success error:(void (^)(RongRTCCode code))error {
    [[RongRTCEngine sharedEngine] joinRoom:roomId completion:^(RongRTCRoom * _Nullable room, RongRTCCode code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(RongRTCCodeSuccess == code) {
                self.rtcRoom = room;
                if(success) {
                    success(room);
                }
            }else if(RongRTCCodeJoinRepeatedRoom == code || RongRTCCodeJoinToSameRoom == code) {
                //当 RTC 出现此类错误时，RTC 不会再下发 room 对象，只能用上次的 room
                if(success) {
                    success(self.rtcRoom);
                }
            }else {
                if(error) {
                    error(code);
                }
            }
        });
    }];
}

- (void)leaveRongRTCRoom:(NSString*)roomId success:(void (^)(void))success error:(void (^)(RongRTCCode code))error {
    [[RongRTCEngine sharedEngine] leaveRoom:roomId completion:^(BOOL isSuccess, RongRTCCode code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"离开 RTCRoom ，code = %ld",(long)code);
            if(isSuccess || RongRTCCodeSuccess == code) {
                self.rtcRoom = nil;
                if(success) {
                    success();
                }
            }else {
                if(error) {
                    error(code);
                }
            }
        });
    }];
}

#pragma mark - 音频流
- (void)pulishCurrentUserAudioStream {
    if(!self.rtcRoom) {
        NSLog(@"尚未加入 rtc room，不能发布音频流");
        return;
    }
    [self.rtcRoom publishDefaultAVStream:^(BOOL isSuccess, RongRTCCode desc) {
        NSLog(@"当前用户发布音频流 %@",@(desc));
    }];
    
    self.captureParam.turnOnCamera = NO;
    [self.capturer setCaptureParam:self.captureParam];
    [self.capturer startCapture];
}

- (void)onAudioVideoTransfer:(NSArray *)memberArray transfer:(NSArray *)localArray{
    
}

- (void)unpublishCurrentUserAudioStream {
    if(!self.rtcRoom) {
        NSLog(@"尚未加入 rtc room，不能取消发布音视频流");
        return;
    }
    [self.rtcRoom unpublishDefaultAVStream:^(BOOL isSuccess, RongRTCCode desc) {
        NSLog(@"当前用户取消发送音视频流 %@",@(desc));
    }];
    [self.capturer stopCapture];
}

- (void)subscribeRemoteUserAudioStream:(NSString *)userId {
    RongRTCRemoteUser *remoteUser = [self getRTCRemoteUser:userId];
    if(!self.rtcRoom || remoteUser.remoteAVStreams.count <= 0) {
        NSLog(@"尚未加入 rtc room 或者远端用户资源不存在，不能订阅音频流");
        NSLog(@"user:%@ streams:%@",remoteUser.userId,remoteUser.remoteAVStreams);
        return;
    }
    [self.rtcRoom subscribeAVStream:remoteUser.remoteAVStreams tinyStreams:nil completion:^(BOOL isSuccess, RongRTCCode desc) {
        BOOL mute = [RTCService sharedService].muteAllVoice;
        for(RongRTCAVInputStream *stream in remoteUser.remoteAVStreams) {
            if(stream.streamType == RTCMediaTypeAudio) {
                stream.disable = mute;
            }
        }
        NSLog(@"订阅流 %@ success:%@ code:%@",remoteUser.userId,@(isSuccess),@(desc));
    }];
}
- (void)unsubscribeRemoteUserAudioStream:(NSString *)userId {
    RongRTCRemoteUser *remoteUser = [self getRTCRemoteUser:userId];
    if(!self.rtcRoom) {
        NSLog(@"尚未加入 rtc room，不能取消订阅音视频流");
        return;
    }
    [self.rtcRoom unsubscribeAVStream:remoteUser.remoteAVStreams completion:^(BOOL isSuccess, RongRTCCode desc) {
        NSLog(@"取消订阅流 %@ success:%@ code:%@",remoteUser.userId,@(isSuccess),@(desc));
    }];
}

- (void)setMicrophoneDisable:(BOOL)disable {
    [self.capturer setMicrophoneDisable:disable];
    [ClassroomService sharedService].currentUserCanAnime = !disable;
}

- (void)useSpeaker:(BOOL)useSpeaker {
    [self.capturer useSpeaker:useSpeaker];
}

- (void)setMuteAllVoice:(BOOL)mute {
    _muteAllVoice = mute;
    for(RongRTCRemoteUser *remoteUser in self.rtcRoom.remoteUsers) {
        for(RongRTCAVInputStream *stream in remoteUser.remoteAVStreams) {
            if(stream.streamType == RTCMediaTypeAudio) {
                stream.disable = mute;
            }
        }
    }
}

- (void)onUserAudioLevel:(NSArray *)levelArray {
    for (NSDictionary *dict in levelArray) {
//        NSInteger audioleval = [dict[@"audioleval"] integerValue];
        NSString *userid = dict[@"userid"];
        int audioleval = [dict[@"audioleval"] intValue];
        if(userid.length > 0 && audioleval > 0) {
            [[ClassroomService sharedService] _notifyUserDidSpeak:userid];
            SealMicLog(@"onUserAudioLevel,userId:%@,audioleval:%d",userid,audioleval);
        }
    }
}

- (RongRTCRemoteUser *)getRTCRemoteUser:(NSString *)userId{
    for (RongRTCRemoteUser *user in self.rtcRoom.remoteUsers) {
        if ([userId isEqualToString:user.userId]) {
            return user;
        }
    }
    return nil;
}
#pragma mark - getter
- (RongRTCAVCapturer *)capturer {
    if(!_capturer) {
        _capturer = [RongRTCAVCapturer sharedInstance];
    }
    return _capturer;
}
- (RongRTCVideoCaptureParam *)captureParam {
    if(!_captureParam) {
        _captureParam = [[RongRTCVideoCaptureParam alloc] init];
        _captureParam.turnOnCamera = NO;
    }
    return _captureParam;
    
}
@end
