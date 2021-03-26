//
//  RCMicIMService.h
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLibCore/RongIMLibCore.h>
#import <RongChatRoom/RongChatRoom.h>
#import "RCMicParticipantInfo.h"
#import "RCMicGiftMessage.h"
#import "RCMicTransferHostMessage.h"
#import "RCMicTakeOverHostMessage.h"
#import "RCMicKickOutMessage.h"
#import "RCMicBroadcastGiftMessage.h"

#define RCMicRoomLiveUrlKey @"liveUrl"//直播间合流地址 key

#define RCMicParticipantEntryKey @"sealmic_position_"//麦位相关 key
#define RCMicParticipantUserIdKey @"userId"
#define RCMicParticipantStateKey @"state"
#define RCMicParticipantPositionKey @"position"

#define RCMicParticipantSpeakingEntryKey @"speaking_"//正在发言相关 key
#define RCMicParticipantSpeakingKey @"speaking"
#define RCMicParticipantSpeakingPositionKey @"position"

#define RCMicParticipantWaitingKey @"applied_mic_list_empty"//是否有人在排麦 key

/// 有消息被撤回的通知，通知中携带被撤回的消息对象：{@"message":message}
FOUNDATION_EXPORT NSString *const RCMicRecallMessageNotification;

@protocol RCMicIMConnectionStatusChangeDelegate <NSObject>

/**
 * IM 链接状态改变回调方法
 *
 * @param status 当前状态
 */
- (void)onConnectionStatusChanged:(RCConnectionStatus)status;
@end

@protocol RCMicMessageHandleDelegate <NSObject>

/**
 * 收到消息时回调方法
 *
 * @param message 收到的消息
 * @return 返回 YES 代表接管此消息，返回 NO 将会继续传递给其它代理
 */
- (BOOL)handleMessage:(RCMessage *)message;
@end

@interface RCMicIMService : NSObject

+ (instancetype)sharedService;

/**
 * 链接 IM
 *
 * @param token 用户对应的 token
 */
- (void)connectWithToken:(NSString *)token;

/**
 * 断开 IM 链接
 */
- (void)disconnect;

/**
 * 添加 IM 链接状态监听代理
 *
 * @param delegate 代理对象
 */
- (void)addIMConnectionStatusChangeDelegate:(id<RCMicIMConnectionStatusChangeDelegate>)delegate;

/**
 * 添加消息接收代理（消息被某个代理对象处理后将停止传递）
 *
 * @param delegate 代理对象
 */
- (void)addMessageHandleDelegate:(id<RCMicMessageHandleDelegate>)delegate;

/**
 * 添加聊天室 KV 变化代理
 *
 * @param delegate 代理对象
 */
- (void)addKVStatusChangedDelegate:(id<RCChatRoomKVStatusChangeDelegate>)delegate;

/**
 * 获取指定聊天室最新数量的消息
 *
 * @param roomId 聊天室 ID
 * @param count 需要获取的数量
 * @return 获取到的 RCMessage 对象的数组
 */
- (NSArray<RCMessage *> *)loadLatestMessageWithRoomId:(NSString *)roomId
                                         messageCount:(NSUInteger)count;

/**
 * 发送消息
 *
 * @param conversationType 所发消息对应的会话类型
 * @param targetId 所发消息的会话 ID
 * @param content 所发消息的内容
 * @param pushContent 接收方离线时需要显示的远程推送内容
 * @param pushData 接收方离线时需要在远程推送中携带的非显示数据
 * @param successBlock 消息发送成功的回调，携带发送成功后的消息实体
 * @param errorBlock 消息发送失败的回调，携带错误码及消息实体
 */
- (void)sendMessage:(RCConversationType)conversationType
           targetId:(NSString *)targetId
            content:(RCMessageContent *)content
        pushContent:(NSString *)pushContent
           pushData:(NSString *)pushData
            success:(void (^)(RCMessage *message))successBlock
              error:(void (^)(RCErrorCode errorCode, RCMessage *message))errorBlock;
/**
 * 撤回消息
 *
 * @param message 需要撤回的消息
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)recallMessage:(RCMessage *)message
              success:(void(^)(void))successBlock
                error:(void(^)(RCErrorCode errorCode))errorBlock;

/**
 * 从本地数据库删除指定 id 的消息
 *
 * @param messageIds 需要删除的消息 id 数组
 * @return 操作结果
 */
- (BOOL)deleteMessages:(NSArray<NSNumber *> *)messageIds;

/**
 * 加入聊天室
 *
 * @param roomId 聊天室 Id
 * @param messageCount 加入时要拉取的消息数量
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)joinChatRoom:(NSString *)roomId
        messageCount:(NSInteger)messageCount
             success:(void(^)(void))successBlock
               error:(void(^)(RCErrorCode errorCode))errorBlock;

/**
 * 退出聊天室
 *
 * @param roomId 聊天室 Id
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)quitChatRoom:(NSString *)roomId
             success:(void(^)(void))successBlock
               error:(void(^)(RCErrorCode errorCode))errorBlock;

/**
 * 获取聊天室用户总数
 *
 * @param roomId 聊天室 Id
 * @param successBlock 成功回调，携带获取到的总数
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)getChatRoomUserCount:(NSString *)roomId
                     success:(void(^)(NSInteger count))successBlock
                       error:(void(^)(RCErrorCode errorCode))errorBlock;

#pragma mark - 房间属性 KV 设置相关
/**
 * 获取指定房间的直播音频流地址 liveUrl
 *
 *@param roomId 房间号
 * @param successBlock 成功回调，携带获取到的地址
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)getRoomLiveUrl:(NSString *)roomId
               success:(void(^)(NSString *liveUrl))successBlock
                 error:(void(^)(RCErrorCode errorCode))errorBlock;

/**
 * 设置指定房间的直播音频流地址 liveUrl
 *
 * @param roomId 房间号
 * @param liveUrl 音频流地址
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)setRoomLiveUrl:(NSString *)roomId
                   url:(NSString *)liveUrl
               success:(void(^)(void))successBlock
                 error:(void(^)(RCErrorCode errorCode))errorBlock;

/**
 * 获取指定房间所有的参会者（麦位）信息
 *
 * @param roomId 房间号
 * @param successBlock 成功回调，携带房间中所有的麦位信息，key 格式：sealmic_position_0（最后为 0 - 8，代表 9 个麦位）
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)getAllParticipantInfo:(NSString *)roomId
                      success:(void(^)(NSDictionary<NSString *, RCMicParticipantInfo *> *particitantDict))successBlock
                        error:(void(^)(RCErrorCode errorCode))errorBlock;

/**
 * 设置指定房间指定麦位是否正在讲话
 *
 * @param roomId 房间号
 * @param position 麦位序号
 * @param isSpeaking 是否正在讲话
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)setSpeakingState:(NSString *)roomId
                position:(NSInteger)position
              isSpeaking:(BOOL)isSpeaking
                 success:(void(^)(void))successBlock
                   error:(void(^)(RCErrorCode errorCode))errorBlock;

/**
 * 获取指定房间当前排麦情况（是否有人排麦）
 *
 * @param successBlock 成功回调，携带当前是否有人排麦
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)getParticipantWaitingState:(NSString *)roomId
                           success:(void(^)(BOOL waiting))successBlock
                             error:(void(^)(RCErrorCode errorCode))errorBlock;
@end
