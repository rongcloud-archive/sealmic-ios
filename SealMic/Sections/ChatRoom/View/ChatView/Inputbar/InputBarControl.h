//
//  RCCRInputBar.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/10.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <UIKit/UIKit.h>
#define HeighInputBar 48.0f
/**
 输入工具栏的输入模式
 */
typedef NS_ENUM(NSInteger, InputBarControlStatus) {
    /**
     初始状态
     */
    InputBarControlStatusDefault = 0,
    /**
     文本输入状态
     */
    InputBarControlStatusKeyboard,
};

/**
 输入工具栏的点击监听器
 */
@protocol InputBarControlDelegate <NSObject>

@optional
#pragma mark - 输入框及外部区域事件

/**
 输入工具栏尺寸（高度）发生变化的回调
 
 @param frame 输入工具栏最终需要显示的Frame
 */
- (void)onInputBarControlContentSizeChanged:(CGRect)frame
                      withAnimationDuration:(CGFloat)duration
                          andAnimationCurve:(UIViewAnimationCurve)curve;
/**
 输入框中内容发生变化的回调
 
 @param inputTextView 文本输入框
 @param range         当前操作的范围
 @param text          插入的文本
 */
- (void)onInputTextView:(UITextView *)inputTextView
shouldChangeTextInRange:(NSRange)range
        replacementText:(NSString *)text;

- (void)onTouchSendButton:(NSString *)text;
@end

@interface InputBarControl : UIView


@property(nonatomic, weak) id<InputBarControlDelegate> delegate;

/**
 设置输入工具栏状态

 */
-(void)setInputBarStatus:(InputBarControlStatus)Status;

/**
 重新调整页面布局时需要调用这个方法来设置输入框的frame
 
 @param frame       显示的Frame
 */
-(void)changeInputBarFrame:(CGRect)frame;

/**
 清除输入框内容
 */
-(void)clearInputView;

-(void)resignResponder;

- (id)initWithStatus:(InputBarControlStatus)status;

@end
