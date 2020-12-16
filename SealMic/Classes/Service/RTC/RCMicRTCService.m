//
//  RCMicRTCService.m
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicRTCService.h"
#import "RCMicMacro.h"
@interface RCMicRTCService()
@property (nonatomic, strong) NSHashTable *rtcMonitorTable;
@end

@implementation RCMicRTCService

+ (instancetype)sharedService {
    static dispatch_once_t onceToken;
    static RCMicRTCService *pDefaultClient;
    dispatch_once(&onceToken, ^{
        if (pDefaultClient == nil) {
            pDefaultClient = [[RCMicRTCService alloc] init];
            [RCRTCEngine sharedInstance].monitorDelegate = pDefaultClient;
            [pDefaultClient setupMediaServerURL];
        }
    });
    return pDefaultClient;
}

- (void)setupMediaServerURL {
    if (MediaServer_URL.length > 0){
        [[RCRTCEngine sharedInstance] setMediaServerUrl:MediaServer_URL];
    }
}

#pragma mark - Public method

- (void)addRTCActivityMonitorDelegate:(id<RCMicRTCActivityMonitorDelegate>)delegate {
    [self.rtcMonitorTable addObject:delegate];
}

- (void)joinRoom:(NSString *)roomId success:(void(^)(RCRTCRoom *room))successBlock error:(void(^)(RCRTCCode code))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"join rtc room error, roomId is null");
    }
    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType= RCRTCRoomTypeLive;
    config.liveType = RCRTCLiveTypeAudio;
    [[RCRTCEngine sharedInstance] joinRoom:roomId config:config completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
       if (code == RCRTCCodeSuccess) {
            successBlock ? successBlock(room) : nil;
        } else {
            RCMicLog(@"join rtc room complete with error, code:%ld, roomId:%@, config:%@",(long)code, roomId, config);
            errorBlock ? errorBlock(code) : nil;
        }
    }];
}

- (void)leaveRoom:(NSString *)roomId success:(void (^)(void))successBlock error:(void (^)(RCRTCCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"leave rtc room error, roomId is null");
    }
    [[RCRTCEngine sharedInstance] leaveRoom:roomId completion:^(BOOL isSuccess, RCRTCCode code) {
        if (isSuccess) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"leave rtc room complete with error, code:%ld, roomId:%@",(long)code, roomId);
            errorBlock ? errorBlock(code) : nil;
        }
    }];
}

- (void)publishAudioStream:(RCRTCRoom *)room success:(void (^)(RCRTCLiveInfo *liveInfo))successBlock error:(void (^)(RCRTCCode))errorBlock {
    if (!room) {
        RCMicLog(@"publish audio stream error, room is null");
    }
    
    [room.localUser publishLiveStream:[RCRTCEngine sharedInstance].defaultAudioStream completion:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo) {
        if (isSuccess) {
            successBlock ? successBlock(liveInfo) : nil;
        } else {
            RCMicLog(@"publish audio stream complete with error, code:%ld",(long)desc);
            errorBlock ? errorBlock(desc) : nil;
        }
    }];
}

- (void)subscribeRoomStream:(NSString *)liveUrl success:(void(^)(RCRTCInputStream *stream))successBlock error:(void(^)(RCRTCCode code))errorBlock {
    if (liveUrl.length == 0) {
        RCMicLog(@"subscribe room strean error, live url is null");
    }
    [[RCRTCEngine sharedInstance] subscribeLiveStream:liveUrl streamType:RCRTCAVStreamTypeAudio completion:^(RCRTCCode desc, RCRTCInputStream * _Nullable inputStream) {
        if (desc == RCRTCCodeSuccess) {
            successBlock ? successBlock(inputStream) : nil;
        } else {
            RCMicLog(@"subscribe room stream complete with error, code:%ld, liveUrl:%@",(long)desc, liveUrl);
            errorBlock ? errorBlock(desc) : nil;
        }
    }];
}

- (void)unsubscribeRoomStream:(NSString *)liveUrl success:(void (^)(void))successBlock error:(void (^)(RCRTCCode))errorBlock {
    [[RCRTCEngine sharedInstance] unsubscribeLiveStream:liveUrl completion:^(BOOL isSuccess, RCRTCCode code) {
       if (isSuccess) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"unsubscribe room stream complete with error, code:%ld, liveUrl:%@",(long)code, liveUrl);
            errorBlock ? errorBlock(code) : nil;
        }
    }];
}

- (void)subscribeParticipantStreams:(RCRTCRoom *)room streams:(NSArray<RCRTCInputStream *> *)streams success:(void (^)(void))successBlock error:(void (^)(RCRTCCode))errorBlock {
    if (!room) {
        RCMicLog(@"subscribe participant streams error, room is null");
    }
    [room.localUser subscribeStream:nil tinyStreams:streams completion:^(BOOL isSuccess, RCRTCCode desc) {
       if (isSuccess) {
            successBlock ? successBlock() : nil;
        } else {
            RCMicLog(@"subscribe participant stream complete with error, code:%ld, tinyStreams:%@",(long)desc, streams);
            errorBlock ? errorBlock(desc) : nil;
        }
    }];
}

- (void)microphoneEnable:(BOOL)enable {
    RCMicLog(@"microphoneEnable enable:%@", enable ? @"YES" : @"NO");
    [[RCRTCEngine sharedInstance].defaultAudioStream setMicrophoneDisable:!enable];
}

- (BOOL)useSpeaker:(BOOL)useSpeaker {
    BOOL result = [[RCRTCEngine sharedInstance] useSpeaker:useSpeaker];
    if (!result) {
        RCMicLog(@"set use speaker failed, useSpaeker:%@", useSpeaker ? @"YES" : @"NO");
    }
    return result;
}

- (BOOL)mixingMusicWithLocalUrl:(NSURL *)url {
    if (!url) {
        RCMicLog(@"mixing music error, url is null");
    }
    return [[RCRTCAudioMixer sharedInstance] startMixingWithURL:url playback:YES mixerMode:RCRTCMixerModeMixing loopCount:NSUIntegerMax];
}

- (BOOL)stopMixingMusic {
    return [[RCRTCAudioMixer sharedInstance] stop];
}

#pragma mark - RongRTCActivityMonitorDelegate
- (void)didReportStatForm:(RCRTCStatisticalForm*)form {
    for (id<RCMicRTCActivityMonitorDelegate> delegate in self.rtcMonitorTable.allObjects) {
        if ([delegate respondsToSelector:@selector(didReportStatForm:)]) {
            [delegate didReportStatForm:form];
        }
    }
}

#pragma mark - Getters & Setters
- (NSHashTable *)rtcMonitorTable {
    if (!_rtcMonitorTable) {
        _rtcMonitorTable = [NSHashTable weakObjectsHashTable];
    }
    return _rtcMonitorTable;
}
@end
