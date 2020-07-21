//
//  RCMicActiveWheel.h
//  SealMic
//
//  Created by zhaobingdong on 2017/6/8.
//  Copyright © 2017年 rongcloud. All rights reserved.
//

#import <MBProgressHUD.h>
#import <Foundation/Foundation.h>

@interface RCMicActiveWheel : MBProgressHUD

/**
 正在处理的提示文本，文本颜色问白色
 */
@property(nonatomic, copy) NSString *processString;

/**
 处理失败是的警告文本，文本颜色为红色
 */
@property(nonatomic, copy) NSString *warningString;

/**
 显示转轮在某个视图上

 @param view 视图对象
 @return 返回转轮对象
 @discussion 需要调用dismiss 该转轮才会消失
 */
+ (RCMicActiveWheel *)showHUDAddedTo:(UIView *)view;

/**
 居中显示文本提示，类似android的toast，2s后会自动消失

 @param view 视图对象
 @param text 需要显示的文本
 */
+ (void)showPromptHUDAddedTo:(UIView *)view text:(NSString *)text;

/**
 隐藏以显示的转轮

 @param view 转轮的父视图
 */
+ (void)dismissForView:(UIView *)view;

/**
 延迟隐藏显示转轮

 @param view 转轮父试图
 @param interval 延时时间，单文秒， 如果2 表示2秒后隐藏
 */
+ (void)dismissForView:(UIView *)view delay:(NSTimeInterval)interval;

/**
 延时隐藏并显示文本

 @param interval 延时时间
 @param view 转轮的父试图
 @param text 显示文本内容
 */
+ (void)dismissViewDelay:(NSTimeInterval)interval forView:(UIView *)view processText:(NSString *)text;

/**
 延时隐藏并显示红色的警告文本

 @param interval 延时时间
 @param view 转轮的父试图
 @param text 警告的文本，颜色为红色
 */
+ (void)dismissViewDelay:(NSTimeInterval)interval forView:(UIView *)view warningText:(NSString *)text;



/**
 没有轮转，延时隐藏并显示文本

 @param view 父视图
 @param text 文本
 */
+ (void)hidePromptHUDDelay:(UIView *)view text:(NSString *)text;

@end
