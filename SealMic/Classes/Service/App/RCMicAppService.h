//
//  RCMicAppService.h
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCMicHTTPUtility.h"
#import "RCMicCachedUserInfo.h"
#import "RCMicRoomInfo.h"
#import "RCMicParticipantInfo.h"
#import "RCMicGiftInfo.h"
#import "RCMicVersionInfo.h"

NS_ASSUME_NONNULL_BEGIN

/// 登录成功通知
FOUNDATION_EXPORT NSString *const RCMicLoginSuccessNotification;
/// 退出登录通知（认证信息过期，需要重新认证）
FOUNDATION_EXPORT NSString *const RCMicUserNotLoginNotification;
/// 当前用户从房间中被移除的通知，通知的中携带被移除的房间号：{@"roomId":roomId}
FOUNDATION_EXPORT NSString *const RCMicKickedOutNotification;
/// 当前用户被别处登录挤下线通知
FOUNDATION_EXPORT NSString *const RCMicKickedOfflineNotification;

@interface RCMicAppService : NSObject

/// 当前登录用户的信息（如果内存中没有会从本地读取）
@property (nonatomic, strong) RCMicCachedUserInfo *currentUser;

+ (instancetype)sharedService;

#pragma mark - 用户相关
/**
 * 根据当前登录的用户配置相应环境
 *
 * @param userInfo 当前登录的用户信息
 *
 * @discussion 此方法会同时将此信息缓存到本地，每次启动或者切换用户需要重新配置
 */
- (void)configUserEnvironment:(nullable RCMicCachedUserInfo *)userInfo;

/**
 * 登录 AppServer
 *
 * @param name 用户名
 * @param portrait 用户头像
 * @param deviceId 设备 UUID
 * @param successBlock 成功回调，携带用于本地缓存的用户信息
 * @param errorBlock 失败回调，携带错误码
 *
 * @discussion 登录成功后需要调用 configUserEnvironment 方法配置当前环境
 */
- (void)visitorLogin:(NSString *)name
            portrait:(NSString *)portrait
            deviceId:(NSString *)deviceId
             success:(void(^)(RCMicCachedUserInfo * userInfo))successBlock
               error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 注册用户登录
 *
 * @param name 用户名
 * @param portrait 用户头像
 * @param deviceId 设备 UUID
 * @param phoneNumber 手机号
 * @param verifyCode 验证码
 * @param successBlock 成功回调，携带用于本地缓存的用户信息
 * @param errorBlock 失败回调，携带错误码
 *
 * @discussion 登录成功后需要调用 configUserEnvironment 方法配置当前环境
 */
- (void)userLogin:(NSString *)name
         portrait:(NSString *)portrait
         deviceId:(NSString *)deviceId
      phoneNumber:(NSString *)phoneNumber
       verifyCode:(NSString *)verifyCode
          success:(void(^)(RCMicCachedUserInfo * userInfo))successBlock
            error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 发送验证码
 *
 * @param phoneNumber 指定手机号
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)sendVerificationCode:(NSString *)phoneNumber
                     success:(void(^)(void))successBlock
                       error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 获取用户信息
 *
 * @param userId 用户 Id
 * @param successBlock 成功回调，携带获取到的用户信息
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)getUserInfo:(NSString *)userId
            success:(void(^)(RCMicUserInfo *userInfo))successBlock
              error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

#pragma mark - 房间相关
/**
 * 创建房间
 *
 * @param name 房间名称
 * @param imageURL 房间主题图片地址
 * @param successBlock 成功回调，携带所创建的 roomInfo
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)createRoomWithName:(NSString *)name
                themeImage:(NSString *)imageURL
                   success:(void(^)(RCMicRoomInfo *roomInfo))successBlock
                     error:(void(^)(RCMicHTTPCode errorCode))errorBlock;
/**
 * 分页获取房间列表
 *
 * @param limit 要获取的数量
 * @param roomId 本地最新一条房间的 roomId，本地没有房间时可直接传 nil
 * @param successBlock 成功回调，携带获取到的 RCMicRoomInfo 对象数组
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)getRoomListWithLimit:(NSInteger)limit
                    latestRoom:(nullable NSString *)roomId
                     success:(void(^)(NSArray<RCMicRoomInfo *> *roomList))successBlock
                       error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 获取单个房间信息
 *
 * @param roomId 需要获取的房间 Id
 * @param successBlock 成功回调，携带获取到的 RCMicRoomInfo 对象
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)getRoomInfo:(NSString *)roomId
            success:(void(^)(RCMicRoomInfo *roomInfo))successBlock
              error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 设置房间属性（是否允许自由加入房间以及是否允许自由上麦）
 *
 * @param roomId 需要设置的房间 Id
 * @param freeJoinRoom 是否允许自由加入房间（0 ：允许，1：不允许，-1：不设置此属性）
 * @param freeJoinMic 是否允许自由上麦（0 ：允许，1：不允许，-1：不设置此属性）
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)setRoomAttribute:(NSString *)roomId
            freeJoinRoom:(NSInteger)freeJoinRoom
             freeJoinMic:(NSInteger)freeJoinMic
                 success:(void(^)(void))successBlock
                   error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 获取房间成员列表
 *
 * @param roomId 房间 Id
 * @param successBlock 成功回调，携带获取到的用户列表
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)getRoomUserList:(NSString *)roomId
                success:(void(^)(NSArray<RCMicUserInfo *> *userList))successBlock
                  error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 获取房间排麦成员列表
 *
 * @param roomId 房间 Id
 * @param successBlock 成功回调，携带获取到的用户列表
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)getMicWaitingUserList:(NSString *)roomId
                      success:(void(^)(NSArray<RCMicUserInfo *> *userList))successBlock
                        error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 获取禁言成员列表
 *
 * @param roomId 房间 Id
 * @param successBlock 成功回调，携带获取到的用户列表
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)getBannedUserList:(NSString *)roomId
                  success:(void(^)(NSArray<RCMicUserInfo *> *userList))successBlock
                    error:(void(^)(RCMicHTTPCode errorCode))errorBlock;
/**
 * 将用户踢出房间
 *
 * @param roomId 房间 Id
 * @param userIds 需要踢出的用户 Id 数组
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)kickUserOut:(NSString *)roomId
            userIds:(NSArray<NSString *> *)userIds
            success:(void(^)(void))successBlock
              error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 设置用户在 IM 聊天室发言状态
 *
 * @param roomId 房间 Id
 * @param userIds 需要设置的用户 Id 数组
 * @param canSend 是否能发消息
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)setUserStateInRoom:(NSString *)roomId
                   userIds:(NSArray<NSString *> *)userIds
            canSendMessage:(BOOL)canSend
                   success:(void(^)(void))successBlock
                     error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

#pragma mark - 非主持人相关麦位操作
/**
 * 申请上麦
 *
 * @param roomId 房间号
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 *
 * @discussion 不管当前房间是否可以自由上麦都只需要调用这一个接口，如果此时不允许自由上麦 server 直接扔到排麦列表，如果此时允许自由上麦 server 会将最先申请的直接扔到麦位上
 */
- (void)applyParticipant:(NSString *)roomId
                 success:(void(^)(void))successBlock
                   error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 下麦
 *
 * @param roomId 房间号
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)giveUpParticipant:(NSString *)roomId
                  success:(void(^)(void))successBlock
                    error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 申请接管主持人
 *
 * @param roomId 房间号
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)takeOverHost:(NSString *)roomId
             success:(void(^)(void))successBlock
               error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 处理主持人的转让操作
 *
 * @param roomId 房间号
 * @param accept  是否接受主持人身份，YES：接受，NO：拒绝
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)dealWithHostTransfer:(NSString *)roomId
                      accept:(BOOL)accept
                     success:(void(^)(void))successBlock
                       error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

#pragma mark - 主持人相关麦位操作
/**
 * 处理用户上麦申请
 *
 * @param roomId 房间号
 * @param userId 申请上麦的用户 Id
 * @param accept 是否同意用户上麦 YES：同意，NO：拒绝
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)dealWithParticipantApply:(NSString *)roomId
                          userId:(NSString *)userId
                          accept:(BOOL)accept
                         success:(void(^)(void))successBlock
                           error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 邀请用户上麦
 *
 * @param roomId 房间号
 * @param userId 邀请上麦的用户 Id
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)inviteParticipant:(NSString *)roomId
                   userId:(NSString *)userId
                  success:(void(^)(void))successBlock
                    error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 转让主持人
 *
 * @param roomId 房间号
 * @param userId 转让至用户的 userId
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)transferHost:(NSString *)roomId
              toUser:(NSString *)userId
             success:(void(^)(void))successBlock
               error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 处理接管主持人的申请
 *
 * @param roomId 房间号
 * @param accept 是否同意将主持人身份转让出去 YES：接受，NO：拒绝
 * @param userId 操作所对应的申请者 Id（比如：同意 A 接管主持人的申请则传 A 的 userId）
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)dealWithHostTakeOver:(NSString *)roomId
                      accept:(BOOL)accept
                      userId:(NSString *)userId
                     success:(void(^)(void))successBlock
                       error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 将用户下麦
 *
 * @param roomId 房间号
 * @param userId 需要踢下麦的用户 Id
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)kickParticipantOut:(NSString *)roomId
                    userId:(NSString *)userId
                   success:(void(^)(void))successBlock
                     error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 设置参会者（麦位）状态
 *
 * @param roomId 房间号
 * @param state 需要设置的状态
 * @param position 要设置的麦位
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)setParticipantState:(NSString *)roomId
                      state:(RCMicParticipantState)state
                   position:(NSInteger)position
                    success:(void(^)(void))successBlock
                      error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

#pragma mark - 消息相关
/**
 * 发送聊天室广播消息
 *
 * @param userId 发送者 Id，不传则会以固定的系统用户 Id 发送
 * @param objectName 要发送的消息的 objectName
 * @param content 要发送的消息内容 Json 串
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)sendBroadcastMessage:(nullable NSString *)userId
                  objectName:(NSString *)objectName
                     content:(NSString *)content
                     success:(void(^)(void))successBlock
                       error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

#pragma mark - 版本升级相关
/**
 * 检查是否有新版本
 *
 * @param completionBlock 结果回调，有新版本时返回对应的版本信息，获取失败或没有新版本返回 nil
 */
- (void)checkVersion:(void(^)(RCMicVersionInfo *_Nullable newVersion))completionBlock;
@end

NS_ASSUME_NONNULL_END
