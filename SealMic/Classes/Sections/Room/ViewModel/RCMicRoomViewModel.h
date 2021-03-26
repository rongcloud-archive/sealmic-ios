//
//  RCMicRoomViewModel.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/8.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCMicIMService.h"
#import "RCMicMessageViewModel.h"
#import "RCMicParticipantViewModel.h"
#import "RCMicRTCService.h"
#import "RCMicAppService.h"

typedef NS_ENUM(NSInteger, RCMicMessageChangedType) {
    RCMicMessageChangedTypeAdd = 0,
    RCMicMessageChangedTypeDelete,
};
NS_ASSUME_NONNULL_BEGIN

@interface RCMicRoomViewModel : NSObject
@property (nonatomic, strong) RCMicRoomInfo *roomInfo;
@property (nonatomic, assign) RCMicRoleType role;//当前用户角色
@property (nonatomic, assign) BOOL useMicrophone;//当前是否开启麦克风
@property (nonatomic, assign) BOOL useSpeaker;//当前是否打开扬声器
@property (nonatomic, assign) BOOL debugDisplay;//当前是否展示调试信息
@property (nonatomic, copy) NSMutableArray<RCMicMessageViewModel *> *messageDataSource;//消息数据源
@property (nonatomic, copy) NSMutableDictionary<NSString *, RCMicParticipantViewModel *>*participantDataSource;//参会者（麦位）数据源

#pragma mark - UI 更新相关

/// 加入聊天室后 KV 同步完成的回调，此回调触发后就可以从聊天室 KV 中获取相关信息了
@property (nonatomic, copy) void(^kvSyncCompleted)(void);

/// 消息数据源变化回调，携带变化的类型及索引（需要在主线程操作，因为涉及到和 cell 增删的同步）
@property (nonatomic, copy) void(^messageChanged)(RCMicMessageChangedType type, NSArray *indexs);

/// 参会者（麦位）数据源变化回调，携带发生变化的麦位在聊天室 KV 中对应的 key
@property (nonatomic, copy) void(^participantChanged)(NSArray<NSString *> *keys);

/// 当前用户身份变化后的回调（只有持麦情况变化时会触发，在麦位上的身份互换不会触发）
@property (nonatomic, copy) void(^didHoldOrGiveUpMic)(BOOL isHold);

/// RTC 统计出的延迟信息发生变化回调，携带变化后的延迟
@property (nonatomic, copy) void(^delayInfoChanged)(NSInteger delay);

/// Debug 相关数据变化回调（只有开启 debug 模块时才会回调）
@property (nonatomic, copy) void(^debugInfoChanged)(NSArray *array);

/// 房间在线人数发生变化回调，携带变化后的人数
@property (nonatomic, copy) void(^onlineCountChanged)(NSInteger onlineCount);

/// 排麦人员状态变化回调，只有当前有人排麦和没人排麦的区别，不携带具体人数
@property (nonatomic, copy) void(^waitingStateChanged)(BOOL waiting);

/// 收到礼物消息的回调，携带所收到的礼物消息
@property (nonatomic, copy) void(^receivedGiftMessage)(RCMicGiftMessage *giftMessage);

/// 收到跨房间礼物消息的回调，携带所收到的消息
@property (nonatomic, copy) void(^receivedBroadcastMessage)(RCMicBroadcastGiftMessage *broadcastMessage);

/// 麦位上的禁言状态变化回调，携带当前是否被主持人禁言
@property (nonatomic, copy) void(^microPhoneStateChanged)(BOOL enable);

/// 收到主持人转让的请求回调，携带主持人名字及 Id
@property (nonatomic, copy) void(^hostTransferRequest)(NSString *name, NSString *userId);

/// 收到接管主持人的请求回调，携带请求者的名字及 Id
@property (nonatomic, copy) void(^takeOverHostRequest)(NSString *name, NSString *userId);

/// 收到被转让用户响应的回调，携带对方的名字、Id、是否同意接管主持人
@property (nonatomic, copy) void(^hostTransferResponse)(NSString *name, NSString *userId, BOOL result);

/// 收到被接管用户响应的回调，携带对方名字、Id、是否同意主持人被接管
@property (nonatomic, copy) void(^takeOverHostResponse)(NSString *name, NSString *userId, BOOL result);

/// 上下麦过程中关键点 error 回调，携带麦位转换中 RTC 及 IM 层出现的错误描述
@property (nonatomic, copy) void(^showTipWithErrorInfo)(NSString *description);

#pragma mark - 初始化及销毁
- (instancetype)initWithRoomInfo:(RCMicRoomInfo *)roomInfo role:(RCMicRoleType)role;

/// 销毁房间时调用，释放资源
- (void)descory;

#pragma mark - 房间相关
/**
 * 加入房间（分两步，先加入 IM 聊天室，成功后加入 RTC 房间）
 *
 * @param successBlock 成功回调
 * @param imErrorBlock 加入 im 聊天室失败回调
 * @param rtcErrorBlock 加入 rtc 房间失败回调
 */
- (void)joinMicRoom:(void(^)(void))successBlock
            imError:(void(^)(void))imErrorBlock
           rtcError:(void(^)(void))rtcErrorBlock;

/**
 * 退出房间（退出当前页面时必须调用，否则会影响下次加入房间后相关功能的使用）
 */
- (void)quitMicRoom:(void(^)(void))successBlock error:(void(^)(void))errorBlock;

/**
 * 发布或订阅音频流（需要加入房间成功后才能发布或订阅成功）
 */
- (void)publishOrSubscribeAudioStream:(void(^)(void))successBlock error:(void(^)(void))errorBlock;

/**
 * 同步当前排麦情况
 */
- (void)syncParticipantWaitingState:(void(^)(void))successBlock error:(void(^)(void))errorBlock;

/**
 * 同步当前在线人数
 */
- (void)syncOnlineCount:(void(^)(void))successBlock error:(void(^)(void))errorBlock;

#pragma mark - 消息模块
/**
 * 发送文本消息
 *
 * @param text 要发送的文本内容
 */
- (void)sendTextMessage:(NSString *)text error:(void (^)(RCErrorCode errorCode))errorBlock;

/**
 * 发送礼物消息
 *
 * @param content 礼物消息发送时在聊天窗口显示的提示信息
 */
- (void)sendGiftMessage:(NSString *)content giftInfo:(RCMicGiftInfo *)giftInfo success:(void (^)(RCMessage *message))successBlock error:(void (^)(RCErrorCode errorCode, RCMessage *message))errorBlock;

/**
 * 发送广播礼物消息
 *
 * @param gift 要发送的礼物信息
 */
- (void)sendBroadcastGiftMessage:(RCMicGiftInfo *)gift;

/**
 * 撤回指定消息
 */
- (void)recallMessageWithMessageViewModel:(RCMicMessageViewModel *)messageViewModel error:(void(^)(RCErrorCode errorCode))errorBlock;

#pragma mark - 麦位模块
/**
  获取所有当前在麦位上的用户信息 userId
*/
- (NSArray *)currentParticipantUserIds;

/**
 * 加载所有麦位信息
 */
- (void)loadAllParticipantViewModel:(void(^)(void))successBlock error:(void(^)(RCErrorCode errorCode))errorBlock;

/**
 * 将麦位在聊天室中对应的 key 转换为麦位索引
 */
- (NSInteger)transformEntryKeyToPosition:(NSString *)key;

/**
 * 当前用户下麦
 */
- (void)giveUpParticipant:(void(^)(void))successBlock error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

#pragma mark - 主持人相关
/**
 * 转让主持人
 */
- (void)transferHost:(NSString *)userId
             success:(void(^)(void))successBlock
               error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 是否同意主持人位置被接管
 */
- (void)agreeHostTakeOver:(BOOL)agree
                   userId:(NSString *)userId
                    error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 邀请用户连麦
 */
- (void)inviteParticipant:(NSString *)userId error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 设置用户是否被禁言
*/
- (void)enableSendMessage:(BOOL)enable
                     user:(NSString *)userId
                    error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 设置参会者（麦位）状态（设置自己麦位的状态时传 -1）
*/
- (void)changeParticipantState:(RCMicParticipantState)state
                   position:(NSInteger)position
                    success:(void(^)(void))successBlock
                      error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 将用户踢出房间
 */
- (void)kickUserOut:(NSString *)userId
            success:(void(^)(void))successBlock
              error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 排麦
 */
- (void)applyParticipant:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 将用户下麦
 */
- (void)kickParticipantOut:(NSString *)userId error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

#pragma mark - 非主持人相关
/**
 * 接管主持人
 */
- (void)takeOverHost:(void(^)(BOOL showWheel))successBlock error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 是否接受主持人的转让（YES：接受，NO：拒绝）
 */
- (void)acceptHostTransfer:(BOOL)accept error:(void(^)(RCMicHTTPCode errorCode))errorBlock;
@end

NS_ASSUME_NONNULL_END
