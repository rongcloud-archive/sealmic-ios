//
//  RTCEnumDefine.h
//  SealMic
//
//  Created by 杜立召 on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#ifndef RTCEnumDefine_h
#define RTCEnumDefine_h

/**
 *  网络通话控制类型
 */
typedef NS_ENUM(NSInteger, RTCControlResourceType){
    /**
     *  音频
     */
    RTCControlType_Audio      = 1,
    /**
     *  视频
     */
    RTCControlType_Video      = 2,
    /**
     *  音频和视频
     */
    RTCControlType_Audio_Video      = 3,
    
    /**
     *  录像
     */
    RTCControlType_Record = 4,
};

/**
 *  网络通话控制类型
 */
typedef NS_ENUM(NSInteger, RTCControlRecourseStatus){
    /**
     *  开启
     */
    RTCControlRecourseStatus_Open    = 1,
    /**
     *  关闭
     */
    RTCControlRecourseStatus_Close      = 2,
};

/**
 *  网络通话控制类型
 */
typedef NS_ENUM(NSInteger, RTCControlType){
    /**
     *  操作不需要经过对方同意
     */
    RTCControlType_Normal    = 1,
    
    /**
     *  操作后对方收到响应后回复确认
     */
    RTCControlType_NeedFeedback    = 2,
    
    /**
     * 操作需要对方同意
     */
    RTCControlType_NeedAgree      = 3,
};


#endif /* RTCEnumDefine_h */
