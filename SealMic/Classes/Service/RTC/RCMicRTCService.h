//
//  RCMicRTCService.h
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>
#import "RCMicEnumDefine.h"
NS_ASSUME_NONNULL_BEGIN

@protocol RCMicRTCActivityMonitorDelegate <NSObject>
/**
 * 汇报 RTC SDK 统计数据
 *
 *@param form 统计表单对象
 */
- (void)didReportStatForm:(RCRTCStatusForm *)form;
@end

@interface RCMicRTCService : NSObject<RCRTCStatusReportDelegate>

/*!
单例
 */
+ (instancetype)sharedService;

/**
 * 添加 RTC SDK 统计数据监听代理
 *
 * @param delegate 要添加的代理对象
 */
- (void)addRTCActivityMonitorDelegate:(id<RCMicRTCActivityMonitorDelegate>)delegate;

/**
 * 加入 RTC 房间
 *
 * @param roomId 需要加入的房间 Id
 * @param successBlock 成功回调，携带所加入的房间实例
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)joinRoom:(NSString *)roomId
        roleType:(RCRTCLiveRoleType)roleType
         success:(void(^)(RCRTCRoom *room))successBlock
           error:(void(^)(RCRTCCode code))errorBlock;

/**
 * 退出 RTC 房间
 *
 * @param roomId 房间 Id
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)leaveRoom:(NSString *)roomId
          success:(void(^)(void))successBlock
            error:(void(^)(RCRTCCode code))errorBlock;

/**
 * 发布直播音频流
 *
 * @param room 当前所在的房间
 * @param successBlock 成功回调，携带 RongRTCLiveInfo，其中含有发布后的直播地址 liveUrl
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)publishAudioStream:(RCRTCRoom *)room
                   success:(void(^)(RCRTCLiveInfo *liveInfo))successBlock
                     error:(void(^)(RCRTCCode code))errorBlock;

/**
 * 订阅某个房间中指定音频流
 *
 * @param room 需要订阅的房间
 * @param streams 需要订阅的音频流数组
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)subscribeAudioStreams:(RCRTCRoom *)room
                      streams:(NSArray<RCRTCInputStream *> *)streams
                      success:(void (^)(void))successBlock
                        error:(void (^)(RCRTCCode code))errorBlock;

/**
 * 设置麦克风是否可用
 *
 * @param enable YES：可用，NO：不可用
 */
- (void)microphoneEnable:(BOOL)enable;

/**
 * 设置使用扬声器播放
 *
 * @param useSpeaker YES：使用扬声器，NO：使用听筒
 * @return YES：成功，NO：失败，接入外设时, 如蓝牙音箱等
 */
- (BOOL)useSpeaker:(BOOL)useSpeaker;

/**
 * 混音
 *
 * @param url 要播放的音频文件本地路径
 * @return YES：成功，NO：失败
 */
- (BOOL)mixingMusicWithLocalUrl:(NSURL *)url;

/**
 * 结束混音
 *
 * @return YES：成功，NO：失败
 */
- (BOOL)stopMixingMusic;
@end

NS_ASSUME_NONNULL_END
