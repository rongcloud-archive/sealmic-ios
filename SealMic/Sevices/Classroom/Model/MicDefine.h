//
//  MicDefine.h
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#ifndef MicDefine_h
#define MicDefine_h

typedef NS_ENUM(NSInteger, MicState) {
    MicStateNone = 0,//空闲
    MicStateLocked = 1 << 0,//麦位被锁
    MicStateForbidden = 1 << 1,//麦位被禁
    MicStateHold = 1 << 2,//麦位有人且处于正常状态
};

typedef NS_ENUM(NSInteger, MicBehaviorType) {
    MicBehaviorTypePickupMic = 0,  //抱麦
    MicBehaviorTypeLockMic,    //锁麦
    MicBehaviorTypeUnlockMic,  //解锁
    MicBehaviorTypeForbidMic,  //禁麦
    MicBehaviorTypeUnForbidMic, //解麦
    MicBehaviorTypeKickOffMic, // 踢麦
    MicBehaviorTypeJumpOnMic,  // 上麦
    MicBehaviorTypeJumpDownMic, //下麦
    MicBehaviorTypeJumpToMic, //跳麦
    MicBehaviorTypeUnKnown
};

typedef NS_ENUM(NSUInteger, MemberChangeAction) {
    //加入
    MemberChangeActionJoin = 1,
    //离开
    MemberChangeActionLeave = 2,
    //被踢掉线
    MemberChangeActionKick = 3,
};
#endif /* MicDefine_h */
