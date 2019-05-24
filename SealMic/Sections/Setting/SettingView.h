//
//  SettingView.h
//  SealMic
//
//  Created by 孙浩 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SettingViewDelegate <NSObject>

- (void)settingViewChangeBackground;
- (void)settingViewQuitChatRoom;

@end

@interface SettingView : UIView

@property (nonatomic, weak) id<SettingViewDelegate> settingDelegate;

- (void)showSettingViewInView:(UIView *)view;
- (void)hiden;

@end

NS_ASSUME_NONNULL_END
