//
//  RCMicEmojiBoardView.h
//  RCIM
//
//  Created by Heq.Shinoda on 14-5-29.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCMicEmojiPageControl;
@class RCMicEmojiBoardView;

/*!
 表情输入的回调
 */
@protocol RCMicEmojiViewDelegate <NSObject>
@optional

/*!
 点击表情的回调

 @param emojiView 表情输入的View
 @param string    点击的表情对应的字符串编码
 */
- (void)didTouchEmojiView:(RCMicEmojiBoardView *)emojiView touchedEmoji:(NSString *)string;

- (void)didSendButtonEvent;

@end

/*!
 表情输入的View
 */
@interface RCMicEmojiBoardView : UIView <UIScrollViewDelegate> {
    /*!
     PageControl
     */
    RCMicEmojiPageControl *pageCtrl;

    /*!
     当前所在页的索引值
     */
    NSInteger currentIndex;
}

/*!
 表情背景的View
 */
@property(nonatomic, strong) UIScrollView *emojiBackgroundView;

/*!
 表情输入的回调
 */
@property(nonatomic, weak) id<RCMicEmojiViewDelegate> delegate;

/*!
 加载表情Label
 */
- (void)loadLabelView;
/*!
发送按钮是否可点击
 */
- (void)enableSendButton:(BOOL)sender;

/**
 修改发送按钮的title

 @param title title
 */
- (void)setEmojiSendBtnTitle:(NSString *)title;

@end
