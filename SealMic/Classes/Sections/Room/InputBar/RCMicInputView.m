//
//  RCMicInputView.m
//  RongEnterpriseApp
//
//  Created by 杜立召 on 16/8/3.
//  Copyright © 2016年 rongcloud. All rights reserved.
//

#import "RCMicInputView.h"
#import "RCMicMacro.h"
#import <RongIMLibCore/RongIMLibCore.h>

#define RC_IOS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define RC_IOS_SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#define TextViewLineHeight 19.f//输入框每行文字高度
#define TextViewSpaceHeight_LessThanMax 17.f//输入框小于最大行时除文字外上下空隙高度
#define TextViewSpaceHeight 13.f//输入框大于等于最大行时除文字外上下空隙高度
#define TextViewMaxLines 4//输入框最大行数

@interface RCMicInputView () <UITextViewDelegate,RCMicTextViewDelegate>

/*!
 文本输入框的高度
 */
@property(assign, nonatomic) float current_InputTextview_height;

@property(nonatomic, strong) UIView *lineDown;
@end

@implementation RCMicInputView

#pragma mark - Lift cycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self resetInputBar];
        self.originalPositionY = frame.origin.y;

        self.inputTextview_height = 36.0f;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)resetInputBar {
    if (self.inputTextView) {
        [self.inputTextView removeFromSuperview];
        self.inputTextView = nil;
    }
    if (self.emojiButton) {
        [self.emojiButton removeFromSuperview];
        self.emojiButton = nil;
    }
    
    if (self.inputContainerView) {
        [self.inputContainerView removeFromSuperview];
        self.inputContainerView = nil;
    }
    
    [self addSubview:self.inputContainerView];
    [self.inputContainerView addSubview:self.emojiButton];
    [self.inputContainerView addSubview:self.inputTextView];
    [self refreshSubviewFrame];
    [self registerForNotifications];
}

- (void)registerForNotifications {
    [self unregisterForNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveKeyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveKeyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self.delegate inputTextView:textView shouldChangeTextInRange:range replacementText:text];
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didTouchKeyboardReturnKey:text:)]) {
            NSString *_needToSendText = textView.text;
            NSString *_formatString =
            [_needToSendText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (0 == [_formatString length]) {
                //                UIAlertView *notAllowSendSpace = [[UIAlertView alloc]
                //                        initWithTitle:nil
                //                              message:NSLocalizedStringFromTable(@"whiteSpaceMessage",
                //                              @"RongCloudKit", nil)
                //                             delegate:self
                //                    cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                //                    otherButtonTitles:nil, nil];
                //                [notAllowSendSpace show];
            } else {
                [self.delegate didTouchKeyboardReturnKey:textView text:[_needToSendText copy]];
            }
        }
        
        return NO;
    }
    
    [self changeInputViewFrame:text textView:textView range:range];
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if (RC_IOS_SYSTEM_VERSION_GREATER_THAN(@"6.1")) {
        CGRect r = [textView caretRectForPosition:textView.selectedTextRange.end];
        CGFloat caretY =  MAX(r.origin.y - textView.frame.size.height + r.size.height + 8, 0);
        if (textView.contentOffset.y < caretY && r.origin.y != INFINITY) {
            textView.contentOffset = CGPointMake(0, caretY);
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.delegate inputTextViewDidChange:textView];
//    CGRect line = [textView caretRectForPosition:textView.selectedTextRange.start];
//    CGFloat overflow = line.size.height - (textView.contentOffset.y + textView.bounds.size.height -
//                                           textView.contentInset.bottom - textView.contentInset.top);
//    if (overflow > 0) {
//        // We are at the bottom of the visible text and introduced a line feed,
//        // scroll down (iOS 7 does not do it)
//        // Scroll caret to visible area
//        CGPoint offset = textView.contentOffset;
//        // offset.y += overflow + 7; // leave 7 pixels margin
//        // Cannot animate with setContentOffset:animated: or caret will not appear
//        [UIView animateWithDuration:.2
//                         animations:^{
//                             [textView setContentOffset:offset];
//                         }];
//    }
    
    //    NSRange range;
    //    range.location = self.inputTextView.text.length;
    //    [self changeInputViewFrame:self.inputTextView.text textView:self.inputTextView range:range];
    [self changeInputViewFrame:nil textView:self.inputTextView range:NSMakeRange(self.inputTextView.text.length, 0)];
}

#pragma mark - RCMicTextViewDelegate

- (void)rcMicTextView:(RCMicTextView *)textView textDidChange:(NSString *)text {
    
    [self.inputTextView layoutIfNeeded];
    [self changeInputViewFrame:nil textView:self.inputTextView range:NSMakeRange(self.inputTextView.text.length, 0)];
}

#pragma mark - Target action

- (void)didTouchEmojiDown:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTouchEmojiButton:)]) {
        [self.delegate didTouchEmojiButton:sender];
    }
}

#pragma mark - Notification selector

- (void)didReceiveKeyboardWillShowNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardBeginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (!CGRectEqualToRect(keyboardBeginFrame, keyboardEndFrame)) {
        UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        NSInteger animationCurveOption = (animationCurve << 16);
        
        double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:animationDuration
                              delay:0.0
                            options:animationCurveOption
                         animations:^{
                             if ([self.delegate respondsToSelector:@selector(keyboardWillShowWithFrame:)]) {
                                 [self.delegate keyboardWillShowWithFrame:keyboardEndFrame];
                             }
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
}

- (void)didReceiveKeyboardWillHideNotification:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardBeginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (!CGRectEqualToRect(keyboardBeginFrame, keyboardEndFrame)) {
        UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        NSInteger animationCurveOption = (animationCurve << 16);
        
        double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:animationDuration
                              delay:0.0
                            options:animationCurveOption
                         animations:^{
                             if (!CGRectEqualToRect(keyboardBeginFrame, keyboardEndFrame)) {
                                 if ([self.delegate respondsToSelector:@selector(keyboardWillHide)]) {
                                     [self.delegate keyboardWillHide];
                                 }
                             }
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
}

#pragma mark - UI相关处理

- (void)setPlaceholder:(NSString *)placeholder {
    [self.inputTextView setPlaceholder:placeholder color:[UIColor lightGrayColor] font:[UIFont systemFontOfSize:15]];
}

- (void)refreshSubviewFrame {
    CGRect totalRect = self.frame;
    CGFloat emojiButtonWidth = 30;
    CGFloat inputViewWidth = totalRect.size.width - 12 - emojiButtonWidth - 12 - 12;
    self.inputTextView.frame = CGRectMake(12, 7, inputViewWidth, totalRect.size.height - 14);
    self.emojiButton.frame = CGRectMake(CGRectGetMaxX(self.inputTextView.frame) + 12, totalRect.size.height - emojiButtonWidth - 10, emojiButtonWidth, emojiButtonWidth);
}

- (void)clearInputText {
    self.inputTextView.text = @"";
    
    _inputTextview_height = 36.0f;
    
    CGRect totalRect = self.frame;
    totalRect.size.height = Height_ChatSessionInputBar;
    totalRect.origin.y = _originalPositionY;
    [self setFrame:totalRect];
    
    CGRect containerRect = self.inputContainerView.frame;
    containerRect.size.height = totalRect.size.height;
    self.inputContainerView.frame = containerRect;
    
    [self refreshSubviewFrame];
    
    if ([self.delegate respondsToSelector:@selector(chatSessionInputBarControlContentSizeChanged:)]) {
        [self.delegate chatSessionInputBarControlContentSizeChanged:totalRect];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO; //隐藏系统默认的菜单项
}

#pragma mark 输入框内容改变后相关处理

- (void)changeInputViewFrame:(NSString *)text textView:(UITextView *)textView range:(NSRange)range {
    if (textView.isHidden) {
        return;
    }
    //默认只有一行
    self.inputTextview_height = [self getTextViewHeightWithLines:1];
    if (self.inputTextView.contentSize.height > [self getTextViewHeightWithLines:1] && self.inputTextView.contentSize.height <= [self getTextViewHeightWithLines:TextViewMaxLines-1]) {
        self.inputTextview_height = self.inputTextView.contentSize.height;
    }
    if (self.inputTextView.contentSize.height > [self getTextViewHeightWithLines:TextViewMaxLines-1]) {
        self.inputTextview_height = [self getTextViewHeightWithLines:TextViewMaxLines];
    }
    
    //本函数在"text will change"时和"text did change"时都会被调用。"text did change"时不需要算高度。
    //!(text == nil && range.location == textView.text.length && range.length == 0)隐含的意思就是在"text will
    //change"状态
    //删除时（text.length=0)且高度为所限制的最大高度时需要重写计算高度，输入时（text.length>0)且高度小于需要限制的最大高度时，需要算高度。
    if (!(text == nil && range.location == textView.text.length && range.length == 0) &&
        (((text.length == 0 && self.inputTextview_height == [self getTextViewHeightWithLines:TextViewMaxLines]) ||
          (text.length > 0 && self.inputTextview_height < [self getTextViewHeightWithLines:TextViewMaxLines])))) { //"text will chagne" and high may change
        NSString *resultStr = [textView.text stringByReplacingCharactersInRange:range withString:text];
        CGFloat textAreaWidth = self.inputTextView.frame.size.width - self.inputTextView.textContainer.lineFragmentPadding * 2;
        CGSize textViewSize =
        [self TextViewAutoCalculateRectWith:resultStr FontSize:16.0 MaxSize:CGSizeMake(textAreaWidth, [self getTextViewHeightWithLines:TextViewMaxLines])];
        NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                           decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                           scale:0
                                           raiseOnExactness:NO
                                           raiseOnOverflow:NO
                                           raiseOnUnderflow:NO
                                           raiseOnDivideByZero:YES];
        NSDecimalNumber *subtotal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%lf", textViewSize.height]];
        NSDecimalNumber *discount = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",@(TextViewLineHeight)]];
        NSDecimalNumber *total = [subtotal decimalNumberByDividingBy:discount withBehavior:roundUp];
        self.inputTextview_height = [self getTextViewHeightWithLines:total.integerValue];
    }
    
    float animateDuration = 0.5;
    __weak typeof(self) weakSelf = self;
    __weak typeof(textView) weakTextView = textView;
    if(self.current_InputTextview_height != self.inputTextview_height){
        [UIView animateWithDuration:animateDuration
                         animations:^{
                             BOOL heightChanged = NO;
                             if (weakSelf.inputTextView.frame.size.height < weakSelf.inputTextview_height) {
                                 heightChanged = YES;
                             }
                             weakSelf.current_InputTextview_height = weakSelf.inputTextview_height;
                             //调整总体frame
                             CGRect totalRect = weakSelf.frame;
                             totalRect.size.height = Height_ChatSessionInputBar + (weakSelf.inputTextview_height - [self getTextViewHeightWithLines:1]);
                             totalRect.origin.y -= (weakSelf.inputTextview_height - [self getTextViewHeightWithLines:1]);
                             weakSelf.frame = totalRect;
                             //调整inputContainerView的frame
                             CGRect containerRect = weakSelf.inputContainerView.frame;
                             containerRect.size.height = totalRect.size.height;
                             weakSelf.inputContainerView.frame = containerRect;
                             //调整inputTextView和emojiButton的frame
                             [self refreshSubviewFrame];
                             
                             if ([weakSelf.delegate respondsToSelector:@selector(chatSessionInputBarControlContentSizeChanged:)]) {
                                 [weakSelf.delegate chatSessionInputBarControlContentSizeChanged:totalRect];
                             }
                             if (weakSelf.inputTextview_height > [self getTextViewHeightWithLines:TextViewMaxLines]) {
                                 weakTextView.contentOffset = CGPointMake(0, 100);
                             }
                             if (heightChanged) {
                                 [weakTextView scrollRangeToVisible:[weakTextView selectedRange]];
                             }
                         }];
    }
}

- (CGFloat)getTextViewHeightWithLines: (NSInteger)lines{
    CGFloat extra_H = lines >= TextViewMaxLines ? TextViewSpaceHeight : TextViewSpaceHeight_LessThanMax;
    return lines * TextViewLineHeight + extra_H;
}

- (CGSize)TextViewAutoCalculateRectWith:(NSString *)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize {
    if (text.length <= 0) {
        return CGSizeZero;
    }
    return [text boundingRectWithSize:maxSize
                              options:(NSStringDrawingTruncatesLastVisibleLine |
                                       NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}
                              context:nil].size;
}

#pragma mark - Getters and Setters

- (UIImageView *)inputContainerView {
    if (!_inputContainerView) {
        _inputContainerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"input_background"]];
        _inputContainerView.frame = self.bounds;
        _inputContainerView.userInteractionEnabled = YES;
    }
    return _inputContainerView;
}

- (UIButton *)emojiButton {
    if (!_emojiButton) {
        _emojiButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_emojiButton setImage:[UIImage imageNamed:@"input_emoji_normal"]
                      forState:UIControlStateNormal];
        [_emojiButton setImage:[UIImage imageNamed:@"input_emoji_select"]
                      forState:UIControlStateSelected];
        [_emojiButton setExclusiveTouch:YES];
        [_emojiButton addTarget:self action:@selector(didTouchEmojiDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiButton;
}

- (RCMicTextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[RCMicTextView alloc] initWithFrame:CGRectZero];
        _inputTextView.delegate = self;
        _inputTextView.textChangeDelegate = self;
        [_inputTextView setExclusiveTouch:YES];
        [_inputTextView setTextColor:[UIColor blackColor]];
        [_inputTextView setFont:[UIFont systemFontOfSize:16]];
        [_inputTextView setReturnKeyType:UIReturnKeySend];
        _inputTextView.backgroundColor = [UIColor whiteColor];
        _inputTextView.enablesReturnKeyAutomatically = YES;
        _inputTextView.layer.cornerRadius = 18;
        _inputTextView.layer.masksToBounds = YES;
        [_inputTextView setAccessibilityLabel:@"chat_input_textView"];
        if (RC_IOS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            _inputTextView.layoutManager.allowsNonContiguousLayout = NO;
        }
        UIEdgeInsets insets = _inputTextView.textContainerInset;
        insets.left = 5;
        insets.right = 5;
        _inputTextView.textContainerInset = insets;
    }
    return _inputTextView;
}
@end
