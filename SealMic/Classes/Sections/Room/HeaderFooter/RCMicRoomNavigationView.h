//
//  RCMicRoomNavigationBar.h
//  SealMic
//
//  Created by lichenfeng on 2020/5/26.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMicRoomViewModel.h"
NS_ASSUME_NONNULL_BEGIN

/**
 * 内部的可点击视图 Tag 枚举
 */
typedef NS_ENUM(NSInteger, RCMicRoomNavigationViewTag) {
    RCMicRoomNavigationViewBackButton = 100,//返回按钮
    RCMicRoomNavigationViewNoticeButton,//公告按钮
    RCMicRoomNavigationViewMicHandleButton,//麦位处理按钮
    RCMicRoomNavigationViewSetButton,//设置按钮
};

@protocol RCMicRoomNavigationViewDelegate;
@interface RCMicRoomNavigationView : UIView

@property(nonatomic, weak) id<RCMicRoomNavigationViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame viewModel:(RCMicRoomViewModel *)viewModel;

/// 更新延迟值
- (void)updateDelay:(NSInteger)delay;

/// 更新呢在线人数
- (void)updateOnlineCount:(NSInteger)count;

/// 是否显示麦位操作按钮右上角红点
- (void)showTipLabel:(BOOL)show;
@end


@protocol RCMicRoomNavigationViewDelegate <NSObject>
@optional
/**
 * 视图内部按钮点击回调
 * @param navigationView 此视图本身
 * @param tag 所点击的控件的 tag
 */
- (void)roomNavigationView:(RCMicRoomNavigationView *)navigationView didSelectItemWithTag:(RCMicRoomNavigationViewTag)tag;
@end
NS_ASSUME_NONNULL_END
