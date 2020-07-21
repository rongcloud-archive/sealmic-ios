//
//  RCMicRoomToolBar.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/4.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMicEnumDefine.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RCMicMicrophoneState) {
    RCMicMicrophoneStateNormal = 0,//麦克风开启
    RCMicMicrophoneStateSilent,//麦克风关闭
};

typedef NS_ENUM(NSInteger, RCMicSpeakerState) {
    RCMicSpeakerStateOpen = 0,//扬声器开启
    RCMicSpeakerStateClose,//扬声器关闭（使用听筒状态）
};

typedef NS_ENUM(NSInteger, RCMicRoomToolBarViewTag) {
    RCMicRoomToolBarMessageButton = 100,// 发消息按钮
    RCMicRoomToolBarMicrophoneButton,// 麦克风按钮
    RCMicRoomToolBarSpeakerButton,// 扬声器按钮
    RCMicRoomToolBarMetaPhoneButton,// 变音按钮
    RCMicRoomToolBarMusicButton,//伴音按钮
    RCMicRoomToolBarGiftButton,//送礼按钮
};
@protocol RCMicRoomToolBarDelegate;

@interface RCMicRoomToolBar : UIView
@property (nonatomic, weak) id<RCMicRoomToolBarDelegate> delegate;
@property (nonatomic, assign) RCMicMicrophoneState microPhoneState;
@property (nonatomic, assign) RCMicSpeakerState speakerState;
- (void)updateWithRoleType:(RCMicRoleType)role;
@end

@protocol RCMicRoomToolBarDelegate <NSObject>
@optional
/**
 * 视图内部按钮点击回调
 * @param toolBar 此视图本身
 * @param tag 所点击的控件的 tag
 */
- (void)roomToolBar:(RCMicRoomToolBar *)toolBar didSelectItemWithTag:(RCMicRoomToolBarViewTag)tag;
@end
NS_ASSUME_NONNULL_END
