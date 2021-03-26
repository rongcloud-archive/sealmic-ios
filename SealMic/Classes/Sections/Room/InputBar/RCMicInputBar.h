//
//  RCMicInputBar.h
//  RongEnterpriseApp
//
//  Created by 杜立召 on 16/8/3.
//  Copyright © 2016年 rongcloud. All rights reserved.
//

#import "RCMicEmojiBoardView.h"
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <RongIMLibCore/RongIMLibCore.h>
#import <UIKit/UIKit.h>

/*!
 输入工具栏的输入模式
 */
typedef NS_ENUM(NSInteger, RCEBottomBarStatus) {
    /*!
     初始状态
     */
    RCEBottomBarDefaultStatus = 0,
    /*!
     文本输入状态
     */
    RCEBottomBarKeyboardStatus,
    /*!
     表情输入模式
     */
    RCEBottomBarEmojiStatus
};
@protocol RCMicInputBarControlDelegate;
@interface RCMicInputBar : UIView

@property(nonatomic, weak) id<RCMicInputBarControlDelegate> delegate;
/*!
 表情View
 */
@property(nonatomic, strong) RCMicEmojiBoardView *emojiBoardView;
- (void)setText:(NSString *)text;

- (id)initWithFrame:(CGRect)frame;

- (void)setInputBarStatus:(RCEBottomBarStatus)Status;

- (void)setPlaceholder:(NSString *)placeholder;

- (void)changeInputBarFrame:(CGRect)frame;

- (void)clearInputView;

- (BOOL)resignFirstResponderIfNeed;

- (void)becomeFirstResponderIfNeed;
@end

/*!
 输入工具栏的点击监听器
 */
@protocol RCMicInputBarControlDelegate <NSObject>

@optional
#pragma mark - 输入框及外部区域事件

/**
 输入工具栏尺寸（高度）发生变化的回调

 @param frame 输入工具栏最终需要显示的Frame
 @param duration 高度改变动画时间
 @param curve 动画方式
 */
- (void)onInputBarControlContentSizeChanged:(CGRect)frame
                      withAnimationDuration:(CGFloat)duration
                          andAnimationCurve:(UIViewAnimationCurve)curve;
/*!
 输入框中内容将要发生变化的回调

 @param inputTextView 文本输入框
 @param range         当前操作的范围
 @param text          插入的文本
 */
- (void)onInputTextView:(UITextView *)inputTextView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text;

/**
 输入框中内容变化完毕的回调

 @param inputTextView 文本输入框
 */
- (void)onInputTextViewDidChange: (UITextView *)inputTextView;

#pragma mark - 输入框事件

/**
 *  点击键盘回车或者emoji表情面板的发送按钮执行的方法
 *  @param inputBar 输入工具栏
 *  @param text 输入框的内容
 */
- (void)inputBar:(RCMicInputBar *)inputBar
     didTouchsendButton:(NSString *)text;

@end
