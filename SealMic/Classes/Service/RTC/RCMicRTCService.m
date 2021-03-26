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
            [RCRTCEngine sharedInstance].statusReportDelegate = pDefaultClient;
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

- (void)joinRoom:(NSString *)roomId roleType:(RCRTCLiveRoleType)roleType success:(void (^)(RCRTCRoom * _Nonnull))successBlock error:(void (^)(RCRTCCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"join rtc room error, roomId is null");
    }
    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType= RCRTCRoomTypeLive;
    config.liveType = RCRTCLiveTypeAudio;
    config.roleType = roleType;
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

- (void)subscribeAudioStreams:(RCRTCRoom *)room streams:(NSArray<RCRTCInputStream *> *)streams success:(void (^)(void))successBlock error:(void (^)(RCRTCCode))errorBlock {
    if (!room) {
        RCMicLog(@"subscribe participant streams error, room is null");
    }
    [room.localUser subscribeStream:streams tinyStreams:nil completion:^(BOOL isSuccess, RCRTCCode desc) {
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
- (void)didReportStatusForm:(RCRTCStatusForm*)form {
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
