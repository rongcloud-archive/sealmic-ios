//
//  RCMicTextView.h
//  RongEnterpriseApp
//
//  Created by Sin on 2017/8/16.
//  Copyright © 2017年 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RCMicTextViewDelegate;
@interface RCMicTextView : UITextView
@property(nonatomic, copy) NSString *placeholder;
@property(nonatomic, strong) UIColor *placeholderColor;
@property(nonatomic, strong) UIFont *placeholderFont;
@property(nonatomic, weak) id<RCMicTextViewDelegate>textChangeDelegate;

- (void)setPlaceholder:(NSString *)placeholder color:(UIColor *)color font:(UIFont *)font;
@end

@protocol RCMicTextViewDelegate <NSObject>

@optional
- (void)micTextView:(RCMicTextView *)textView textDidChange:(NSString *)text;

@end
