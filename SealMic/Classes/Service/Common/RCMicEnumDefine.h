//
//  RCMicEnumDefine.h
//  SealMic
//
//  Created by 杜立召 on 2020/5/28.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#ifndef RCMicEnumDefine_h
#define RCMicEnumDefine_h

/**
 *  网络通话控制类型
 */
typedef NS_ENUM(NSInteger, RCMicRoleType){
    /**
     *  主持人
     */
    RCMicRoleType_Host      = 1,
    /**
     *  参会者
     */
    RCMicRoleType_Participant      = 2,
    /**
     *  听众
     */
    RCMicRoleType_Audience      = 3,
};

/**
 * 网络请求相关状态码
 */
typedef NS_ENUM (NSInteger, RCMicHTTPCode) {
    /**
     * 请求失败
     */
    RCMicHTTPCodeFailure = -1,
    
    /**
     * 参数错误
     */
    RCMicHTTPCodeParamIllegal = 0,
    
    /**
     * 请求成功
     */
    RCMicHTTPCodeSuccess = 10000,
    
    /**
     * 系统内部错误
     */
    RCMicHTTPCodeErrOther = 10001,
    
    /**
     * 请求参数缺失或无效
     */
    RCMicHTTPCodeErrRequestParaErr = 10002,
    
    /**
     * 认证信息无效或已过期
     */
    RCMicHTTPCodeErrInvalidAuth = 10003,
    
    /**
     * 无权限操作
     */
    RCMicHTTPCodeErrAccessDenied = 10004,
    /**
     * 错误的请求
     */
    RCMicHTTPCodeErrBadRequest = 10005,
    
    /**
     * 获取 IM Token 失败
     */
    RCMicHTTPCodeErrUserImTokenError = 20000,
    
    /**
     * 发送短信请求过于频繁
     */
    RCMicHTTPCodeErrUserSendCodeOverFrequency = 20001,
    
    /**
     * 短信发送失败
     */
    RCMicHTTPCodeErrUserFailureExternal = 20002,
    
    /**
     * 手机号无效
     */
    RCMicHTTPCodeErrUserInvalidPhoneNumber = 20003,
    
    /**
     * 短信验证码尚未发送
     */
    RCMicHTTPCodeErrUserNotSendCode = 20004,
    
    /**
     * 短信验证码无效
     */
    RCMicHTTPCodeErrUserVerifyCodeInvalid = 20005,
    
    /**
     * 验证码不能为空
     */
    RCMicHTTPCodeErrUserVerifyCodeEmpty = 20006,
    
    /**
     * 房间创建失败
     */
    RCMicHTTPCodeErrRoomCreateRoomError = 30000,
    
    /**
     * 房间不存在
     */
    RCMicHTTPCodeErrRoomNotExist = 30001,
    
    /**
     * 用户id个数不能超过 20
     */
    RCMicHTTPCodeErrRoomUserIdsSizeExceed = 30002,
    
    /**
     * 封禁用户失败
     */
    RCMicHTTPCodeErrRoomAddBlockUserError = 30003,
    
    /**
     * 用户不在房间
     */
    RCMicHTTPCodeErrRoomUserIsNotIn = 30004,
    
    /**
     * 用户已在麦位
     */
    RCMicHTTPCodeErrRoomUserIsAlreadyInMic = 30005,
    
    /**
     * 用户已在排麦列表
     */
    RCMicHTTPCodeErrRoomUserIsAppliedForMic = 30006,
    
    /**
     * 用户没有申请排麦
     */
    RCMicHTTPCodeErrRoomUserIsNotAppliedForMic = 30007,
    
    /**
     * 用户不在麦位
     */
    RCMicHTTPCodeErrRoomUserIsNotInMic = 30008,
    
    /**
     * 没有可用麦位
     */
    RCMicHTTPCodeErrRoomNoMicAvailable = 30009,
    
    /**
     * 您已是主持人
     */
    RCMicHTTPCodeErrRoomUserAlreadyTheHost = 30010,
    
    /**
     * 主持人转让信息已失效
     */
    RCMicHTTPCodeErrRoomTransferInfoInvalid = 30011,
    
    /**
     * 禁言用户失败
     */
    RCMicHTTPCodeErrRoomUserAddGagUserError = 30012,
    
    /**
     * 接管主持人信息已失效
     */
    RCMicHTTPCodeErrRoomTakeoverInfoInvalid = 30013,
    
    /**
     * 没有新版本
     */
    RCMicHTTPCodeErrAppNoNewVersions = 40002,
    
    /**
     * 房间已锁定（客户端单加的）
     */
    RCMicHTTPCodeErrRoomLocked = 90001,
    
    /**
     * 房间名称格式有误（客户端单加的）
     */
    RCMicHTTPCodeErrRoomNameInvalid = 90002,
};

#endif /* RCMicEnumDefine_h */
