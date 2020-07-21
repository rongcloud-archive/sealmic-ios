//
//  RCMicInputView.h
//  RongEnterpriseApp
//
//  Created by 杜立召 on 16/8/3.
//  Copyright © 2016年 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define Height_ChatSessionInputBar 50.0f
#import "RCMicTextView.h"

/*!
 输入工具栏的点击监听器
 */
@protocol RCMicInputViewDelegate;

/*!
 输入工具栏
 */
@interface RCMicInputView : UIView

/*!
 输入工具栏的点击回调监听
 */
@property(weak, nonatomic) id<RCMicInputViewDelegate> delegate;

/*!
 容器View
 */
@property(strong, nonatomic) UIImageView *inputContainerView;

/*!
 文本输入框
 */
@property(strong, nonatomic) RCMicTextView *inputTextView;

/*!
 表情的按钮
 */
@property(strong, nonatomic) UIButton *emojiButton;

/*!
 所处的会话页面View
 */
@property(weak, nonatomic, readonly) UIView *contextView;

/*!
 Frame 起点Y坐标
 */
@property(assign, nonatomic) float originalPositionY;

/*!
 文本输入框的高度
 */
@property(assign, nonatomic) float inputTextview_height;

- (id)initWithFrame:(CGRect)frame;

- (void)setPlaceholder:(NSString *)placeholder;

- (void)resetInputBar;

- (void)clearInputText;

/**
 获取textView的高度

 @param lines 输入框中文字的行数
 @return textView对应的高度
 */
- (CGFloat)getTextViewHeightWithLines: (NSInteger)lines;

/**
 调整inputTextView和emojiButton的位置大小
 */
- (void)refreshSubviewFrame;

@end

/*!
 输入工具栏的点击监听器
 */
@protocol RCMicInputViewDelegate <NSObject>

@optional

/*!
 键盘即将显示的回调

 @param keyboardFrame 键盘最终需要显示的Frame
 */
- (void)keyboardWillShowWithFrame:(CGRect)keyboardFrame;

/*!
 键盘即将隐藏的回调
 */
- (void)keyboardWillHide;

/*!
 输入工具栏尺寸（高度）发生变化的回调

 @param frame 输入工具栏最终需要显示的Frame
 */
- (void)chatSessionInputBarControlContentSizeChanged:(CGRect)frame;

/*!
 点击键盘Return按钮的回调

 @param inputTextView 文本输入框
 @param text         当前输入框中国的文本内容
 */
- (void)didTouchKeyboardReturnKey:(UITextView *)inputTextView text:(NSString *)text;

/*!
 点击表情按钮的回调

 @param sender 表情按钮
 */
- (void)didTouchEmojiButton:(UIButton *)sender;

/*!
 输入框中内容将要发生变化的回调

 @param inputTextView 文本输入框
 @param range         当前操作的范围
 @param text          插入的文本
 */
- (void)inputTextView:(UITextView *)inputTextView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text;

/**
 输入框内容变化完毕的回调

 @param inputTextView 文本输入框
 */
- (void)inputTextViewDidChange: (UITextView *)inputTextView;

@end
