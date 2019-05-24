//
//  RTCService.h
//  SealMic
//
//  Created by Sin on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTCService : NSObject
/**
 当前加入的 rtc 房间
 @dicussion 当加入房间成功之后，才会是有效值
 */
@property (nonatomic, strong, readonly) RongRTCRoom *rtcRoom;
@property (nonatomic, assign) BOOL muteAllVoice;


+ (instancetype)sharedService;

- (void)setRTCRoomDelegate:(id<RongRTCRoomDelegate>)delegate;

- (void)joinRongRTCRoom:(NSString *)roomId success:(void (^)( RongRTCRoom *room))success error:(void (^)(RongRTCCode code))error;

- (void)leaveRongRTCRoom:(NSString*)roomId success:(void (^)(void))success error:(void (^)(RongRTCCode code))error;

- (void)pulishCurrentUserAudioStream;
- (void)unpublishCurrentUserAudioStream;

- (void)subscribeRemoteUserAudioStream:(NSString *)userId;
- (void)unsubscribeRemoteUserAudioStream:(NSString *)userId;
- (void)setMicrophoneDisable:(BOOL)disable;
- (void)useSpeaker:(BOOL)useSpeaker;

@end

NS_ASSUME_NONNULL_END
