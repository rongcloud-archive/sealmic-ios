//
//  RCMicEnumDialogDefine.h
//  SealMic
//
//  Created by rongyun on 2020/6/28.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#ifndef RCMicEnumDialogDefine_h
#define RCMicEnumDialogDefine_h

// 弹框操作选项枚举
typedef NS_ENUM(NSInteger,DIALOGOPERATIONTYPE) {
    DIALOGOPERATIONTYPE_GiveGift = 1, //送礼
    DIALOGOPERATIONTYPE_SendMessage,  //发消息
    DIALOGOPERATIONTYPE_ApplyParticipant, //排麦
    DIALOGOPERATIONTYPE_TakeOverHost,     //接管主持
    DIALOGOPERATIONTYPE_KickParticipantOut,     //下麦
    DIALOGOPERATIONTYPE_ParticipantOpen,     //开麦
    DIALOGOPERATIONTYPE_ParticipantClose,     //闭麦
    DIALOGOPERATIONTYPE_TransferHost,     //转让主持人
    DIALOGOPERATIONTYPE_KickUserOut,     //移出房间
    DIALOGOPERATIONTYPE_DeleteMessage,     //删除此条消息
    DIALOGOPERATIONTYPE_SetParticipantLock,     //锁定
    DIALOGOPERATIONTYPE_SetParticipantUnLock,   //解除锁定
    DIALOGOPERATIONTYPE_InvitationConnectMic,   //邀请连麦
    DIALOGOPERATIONTYPE_InvitationParticipant,   //连麦
    DIALOGOPERATIONTYPE_SetUserBanned,   //禁言
    DIALOGOPERATIONTYPE_None,   //无操作
};

//设置开关选项枚举
typedef NS_ENUM(NSInteger,DIALOGOPERATIONSETTYPE) {
    DIALOGOPERATIONSETTYPE_Receiver = 100,        //使用听筒播放
    DIALOGOPERATIONSETTYPE_TurnDebug,             //开启Debug模式
    DIALOGOPERATIONSETTYPE_AllowJoin,             //允许观众加入
    DIALOGOPERATIONSETTYPE_AllowFreeToTheMic,     //允许观众自由上麦
};

#endif /* RCMicEnumDialogDefine_h */
