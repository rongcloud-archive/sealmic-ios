//
//  RCMicInputBar.m
//  RongEnterpriseApp
//
//  Created by 杜立召 on 16/8/3.
//  Copyright © 2016年 rongcloud. All rights reserved.
//

#import "RCMicInputBar.h"
#import "RCMicInputView.h"
#import <CoreText/CoreText.h>
#import <objc/runtime.h>
#import "RCMicUtil.h"

#define Height_EmojBoardView (220.0f+[RCMicUtil bottomSafeAreaHeight])
#define Height_PluginBoardView (220.0f+[RCMicUtil bottomSafeAreaHeight])
 
@interface RCMicInputBar () <RCMicInputViewDelegate, UISplitViewControllerDelegate, RCMicEmojiViewDelegate>
@property(nonatomic) CGRect KeyboardFrame; //记录键盘区域frame
@property(nonatomic) CGRect originalFrame; //初始状态frame
@property(nonatomic) CGRect currentFrame;  //当前frame ，键盘弹起，收回，表情等状态切换时frame
@property(nonatomic, assign) BOOL isClickEmojiButton;
@property(nonatomic, strong) UITapGestureRecognizer *resetBottomTapGesture;
@property(nonatomic) BOOL isIgnoreKeyboardHide;
@property(nonatomic, strong) UIViewController *parentViewController;
@property(nonatomic, strong) UIImagePickerController *curPicker;
@property(nonatomic, assign) BOOL isAudioRecoderTimeOut;
@property(nonatomic) float currentInputBarHeight;
/*!
 会话页面下方的输入工具栏
 */
@property(nonatomic, strong) RCMicInputView *chatSessionInputBarControl;

/*!
 当前输入框状态
 */
@property(nonatomic) RCEBottomBarStatus currentBottomBarStatus;

/**
 *自定义扩展区域，此区域和表情以及加号扩展区域高度相同都为220
 */
@property(nonatomic) UIView *customExpansionView;

/*!
 展示扩展区域
 */
- (void)showCustomExpansionView;

/*!
 隐藏扩展区域
 */
- (void)hideCustomExpansionView;
@end

@implementation RCMicInputBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.KeyboardFrame = CGRectZero;
        _chatSessionInputBarControl =
            [[RCMicInputView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, frame.size.height - [RCMicUtil bottomSafeAreaHeight])];
        _chatSessionInputBarControl.delegate = self;
        self.originalFrame = frame;
        [self addSubview:_chatSessionInputBarControl];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(KeyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(KeyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

//表情区域控件
- (RCMicEmojiBoardView *)emojiBoardView {
    if (!_emojiBoardView) {
        _emojiBoardView =
            [[RCMicEmojiBoardView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, Height_EmojBoardView)];
        _emojiBoardView.delegate = self;
    }
    return _emojiBoardView;
}

//自定义扩展区域控件
- (UIView *)customExpansionView {
    if (!_customExpansionView) {
        _customExpansionView =
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, Height_EmojBoardView)];
    }
    return _customExpansionView;
}

- (void)setInputBarStatus:(RCEBottomBarStatus)Status {
    [self animationLayoutBottomBarWithStatus:Status animated:YES];
}

- (void)changeInputBarFrame:(CGRect)frame {
    self.originalFrame = frame;
    [self setFrame:frame];
    [self setInputBarStatus:RCEBottomBarDefaultStatus];
    [self.chatSessionInputBarControl setFrame:CGRectMake(0, 0, self.bounds.size.width, frame.size.height)];
    _emojiBoardView =
        [[RCMicEmojiBoardView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, Height_EmojBoardView)];
    _emojiBoardView.delegate = self;
    [self.chatSessionInputBarControl resetInputBar];
}
/*!
 展示扩展区域
 */
- (void)showCustomExpansionView {
    [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
    self.chatSessionInputBarControl.inputTextView.inputView = [self customExpansionView];
    CGRect chatInputBarRect = self.chatSessionInputBarControl.frame;
    float bottomY = 0;
    chatInputBarRect.origin.y =
        bottomY - self.chatSessionInputBarControl.bounds.size.height - self.customExpansionView.bounds.size.height;
    _chatSessionInputBarControl.originalPositionY =
        self.bounds.size.height - (Height_ChatSessionInputBar)-Height_EmojBoardView;
    [self.chatSessionInputBarControl.inputTextView reloadInputViews];
}

/*!
 隐藏扩展区域
 */
- (void)hideCustomExpansionView {
    [self.chatSessionInputBarControl.inputTextView resignFirstResponder];
    self.chatSessionInputBarControl.inputTextView.inputView = nil;
}

- (void)KeyboardWillShow:(NSNotification *)notification {
    [[UIMenuController sharedMenuController] setMenuItems:nil];
    CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve =
        [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat keyboardHeight = keyboardBounds.size.height;
    CGRect frame = self.frame;
    frame.origin.y = self.originalFrame.origin.y - keyboardBounds.size.height + [RCMicUtil bottomSafeAreaHeight];
    self.KeyboardFrame = keyboardBounds;
    CGFloat animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         [self setFrame:frame];
                         [UIView commitAnimations];
                     }];
    frame.size.height +=
        keyboardHeight + (self.chatSessionInputBarControl.frame.size.height - Height_ChatSessionInputBar);
    if ([self.delegate respondsToSelector:@selector
                       (onInputBarControlContentSizeChanged:withAnimationDuration:andAnimationCurve:)]) {
        [self.delegate onInputBarControlContentSizeChanged:frame
                                     withAnimationDuration:animationDuration
                                         andAnimationCurve:curve];
    }

    self.currentFrame = self.frame;
    self.currentInputBarHeight = self.frame.size.height;
    [self chatSessionInputBarControlContentSizeChanged:self.chatSessionInputBarControl.frame];
}

- (void)KeyboardWillHide:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector
                       (onInputBarControlContentSizeChanged:withAnimationDuration:andAnimationCurve:)]) {
        CGRect frame = self.originalFrame;

        frame.size.height += self.chatSessionInputBarControl.frame.size.height - Height_ChatSessionInputBar;
        [self setFrame:frame];
        [self.delegate onInputBarControlContentSizeChanged:frame withAnimationDuration:0.1 andAnimationCurve:0];
    }
    if (_isClickEmojiButton == NO) {
        [self animationLayoutBottomBarWithStatus:RCEBottomBarDefaultStatus animated:YES];
    }else{
        [self animationLayoutBottomBarWithStatus:RCEBottomBarEmojiStatus animated:YES];
    }
    self.currentFrame = self.frame;
    self.KeyboardFrame = CGRectZero;
    self.currentInputBarHeight = self.frame.size.height;
    [self chatSessionInputBarControlContentSizeChanged:self.chatSessionInputBarControl.frame];
}

- (void)didTouchSwitchButton:(BOOL)switched {
    _isClickEmojiButton = NO;
    if (switched) {
        [self animationLayoutBottomBarWithStatus:RCEBottomBarDefaultStatus animated:YES];
        if (_currentBottomBarStatus != RCEBottomBarDefaultStatus) {
            [self.chatSessionInputBarControl.inputTextView resignFirstResponder];
        }

    } else {
        [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
    }
}

- (void)didTouchEmojiButton:(UIButton *)sender {
    if (_isClickEmojiButton) {
        [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
        [sender setImage:[UIImage imageNamed:@"input_emoji_normal"]
                forState:UIControlStateNormal];
        _isClickEmojiButton = NO;
        self.chatSessionInputBarControl.inputTextView.inputView = nil;
    } else {
        self.chatSessionInputBarControl.inputTextView.inputView = [self emojiBoardView];
        [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
        _isClickEmojiButton = YES;
        [sender setImage:[UIImage imageNamed:@"input_keyboard_normal"]
                forState:UIControlStateNormal];
        self.isIgnoreKeyboardHide = YES;
        CGRect chatInputBarRect = self.chatSessionInputBarControl.frame;
        float bottomY = 0;
        chatInputBarRect.origin.y =
            bottomY - self.chatSessionInputBarControl.bounds.size.height - self.emojiBoardView.bounds.size.height;
        _chatSessionInputBarControl.originalPositionY =
            self.bounds.size.height - (Height_ChatSessionInputBar)-Height_EmojBoardView;
    }

    if (self.chatSessionInputBarControl.inputTextView.text &&
        self.chatSessionInputBarControl.inputTextView.text.length > 0) {
        [self.emojiBoardView enableSendButton:YES];
    } else {
        [self.emojiBoardView enableSendButton:NO];
    }
    
    [self.chatSessionInputBarControl.inputTextView reloadInputViews];
}

- (void)didTouchKeyboardReturnKey:(UITextView *)inputTextView text:(NSString *)text {
    if ([self.delegate respondsToSelector:@selector(inputBar:didTouchsendButton:)]) {
        [self.delegate inputBar:self didTouchsendButton:text];
    }
}

- (void)inputTextView:(UITextView *)inputTextView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onInputTextView:shouldChangeTextInRange:replacementText:) ]) {
        [self.delegate onInputTextView:inputTextView shouldChangeTextInRange:range replacementText:text];
    }
}

- (void)inputTextViewDidChange:(UITextView *)inputTextView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onInputTextViewDidChange:) ]) {
        [self.delegate onInputTextViewDidChange:inputTextView];
    }
}

-(void)setText:(NSString *)text{
    self.chatSessionInputBarControl.inputTextView.text = text;
}
- (void)animationLayoutBottomBarWithStatus:(RCEBottomBarStatus)bottomBarStatus animated:(BOOL)animated {
    if (bottomBarStatus == RCEBottomBarDefaultStatus) {
        _isClickEmojiButton = NO;
    }
    if (bottomBarStatus != RCEBottomBarEmojiStatus) {
        self.chatSessionInputBarControl.inputTextView.inputView = nil;
        [self.chatSessionInputBarControl.emojiButton
            setImage:[UIImage imageNamed:@"input_emoji_normal"]
            forState:UIControlStateNormal];
    }
    if (bottomBarStatus == RCEBottomBarEmojiStatus && !_emojiBoardView) {
        [self emojiBoardView];
    }

    if (bottomBarStatus == RCEBottomBarKeyboardStatus) {
        [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
    }
    if (animated == YES) {
        [UIView beginAnimations:@"Move_bar" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.25f];
        [UIView setAnimationDelegate:self];
        [self layoutBottomBarWithStatus:bottomBarStatus];
        [UIView commitAnimations];
    } else {
        [self layoutBottomBarWithStatus:bottomBarStatus];
    }
}

- (void)layoutBottomBarWithStatus:(RCEBottomBarStatus)bottomBarStatus {
    if (bottomBarStatus != RCEBottomBarKeyboardStatus) {
        if (self.chatSessionInputBarControl.inputTextView.isFirstResponder) {
            [self.chatSessionInputBarControl.inputTextView resignFirstResponder];
        }
    }

    CGRect chatInputBarRect = self.chatSessionInputBarControl.frame;
    switch (bottomBarStatus) {
    case RCEBottomBarDefaultStatus: {
        CGRect frame = self.originalFrame;
        frame.origin.y =
            frame.origin.y - self.chatSessionInputBarControl.frame.size.height + Height_ChatSessionInputBar;
        frame.size.height += chatInputBarRect.size.height - Height_ChatSessionInputBar;
        [self setFrame:frame];
    } break;
    case RCEBottomBarEmojiStatus:{
        CGRect frame = self.originalFrame;
        frame.origin.y =
        frame.origin.y - self.chatSessionInputBarControl.frame.size.height + Height_ChatSessionInputBar;
        frame.size.height += chatInputBarRect.size.height - Height_ChatSessionInputBar;
        [self setFrame:frame];
    } break;
    default:
        break;
    }

    [self.chatSessionInputBarControl setFrame:chatInputBarRect];
//    self.chatSessionInputBarControl.currentPositionY = self.chatSessionInputBarControl.frame.origin.y;
    _currentBottomBarStatus = bottomBarStatus;
}

#pragma mark - RCMicInputViewDelegate

- (void)chatSessionInputBarControlContentSizeChanged:(CGRect)frame {
    CGRect chatInputBarRect = self.chatSessionInputBarControl.frame;
    chatInputBarRect.origin.y = 0;
    [self.chatSessionInputBarControl setFrame:chatInputBarRect];
    
    CGRect temp = self.currentFrame;
    if (!self.chatSessionInputBarControl.inputTextView.isFirstResponder) {
        temp = self.originalFrame;
    }
    temp.size.height = chatInputBarRect.size.height + [RCMicUtil bottomSafeAreaHeight];
    temp.origin.y = temp.origin.y + Height_ChatSessionInputBar - chatInputBarRect.size.height;
    [self setFrame:temp];

    if ([self.delegate respondsToSelector:@selector
                       (onInputBarControlContentSizeChanged:withAnimationDuration:andAnimationCurve:)]) {
        CGRect newframe = self.frame;
        newframe.size.height = self.KeyboardFrame.size.height + frame.size.height;
        if (newframe.size.height == self.currentInputBarHeight) {
            return;
        }
        self.currentInputBarHeight = newframe.size.height;
        [self.delegate onInputBarControlContentSizeChanged:newframe withAnimationDuration:0.1 andAnimationCurve:0];
    }
}

- (void)dealloc {
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma 点击表情代理
- (void)didTouchEmojiView:(RCMicEmojiBoardView *)emojiView touchedEmoji:(NSString *)string {

    if (nil == string) {
        [self.chatSessionInputBarControl.inputTextView deleteBackward];

    } else {

        NSString *replaceString = string;
        if (replaceString.length < 5000) {
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:replaceString];
            UIFont *font = [UIFont fontWithName:@"Heiti SC-Bold" size:16];
            [attStr addAttribute:(__bridge NSString *)kCTFontAttributeName
                           value:(id)CFBridgingRelease(CTFontCreateWithName((CFStringRef)font.fontName, 16, NULL))
                           range:NSMakeRange(0, replaceString.length)];

            NSInteger cursorPosition;
            if (self.chatSessionInputBarControl.inputTextView.selectedTextRange) {
                cursorPosition = self.chatSessionInputBarControl.inputTextView.selectedRange.location;
            } else {
                cursorPosition = 0;
            }
            //获取光标位置
            if (cursorPosition > self.chatSessionInputBarControl.inputTextView.textStorage.length)
                cursorPosition = self.chatSessionInputBarControl.inputTextView.textStorage.length;
            [self.chatSessionInputBarControl.inputTextView.textStorage insertAttributedString:attStr
                                                                                      atIndex:cursorPosition];

            NSRange range;
            range.location = self.chatSessionInputBarControl.inputTextView.selectedRange.location + string.length;
            range.length = 1;

            self.chatSessionInputBarControl.inputTextView.selectedRange = range;
            {
                CGFloat inputTextview_height = [self.chatSessionInputBarControl getTextViewHeightWithLines:1];
                if (self.chatSessionInputBarControl.inputTextView.contentSize.height > [self.chatSessionInputBarControl getTextViewHeightWithLines:1] && self.chatSessionInputBarControl.inputTextView.contentSize.height <= [self.chatSessionInputBarControl getTextViewHeightWithLines:4-1]) {
                    inputTextview_height = self.chatSessionInputBarControl.inputTextView.contentSize.height;
                }
                if (self.chatSessionInputBarControl.inputTextView.contentSize.height > [self.chatSessionInputBarControl getTextViewHeightWithLines:4-1]) {
                    inputTextview_height = [self.chatSessionInputBarControl getTextViewHeightWithLines:4];
                }

                float animateDuration = 0.5;
                [UIView
                 animateWithDuration:animateDuration
                 animations:^{
                     BOOL heightChanged = NO;
                     if (self.chatSessionInputBarControl.inputTextView.frame.size.height < inputTextview_height) {
                         heightChanged = YES;
                     }
                     //调整总体frame
                     CGRect totalRect = self.chatSessionInputBarControl.frame;
                     totalRect.size.height = 50 + (inputTextview_height - [self.chatSessionInputBarControl getTextViewHeightWithLines:1]);
                     totalRect.origin.y -= (inputTextview_height - [self.chatSessionInputBarControl getTextViewHeightWithLines:1]);
                     self.chatSessionInputBarControl.frame = totalRect;
                     //调整inputContainerView的frame
                     CGRect containerRect = self.chatSessionInputBarControl.inputContainerView.frame;
                     containerRect.size.height = totalRect.size.height;
                     self.chatSessionInputBarControl.inputContainerView.frame = containerRect;
                     //调整inputTextView和emojiButton的frame
                     [self.chatSessionInputBarControl refreshSubviewFrame];


                     if ([self.chatSessionInputBarControl.delegate respondsToSelector:@selector(chatSessionInputBarControlContentSizeChanged:)]) {
                         [self.chatSessionInputBarControl.delegate chatSessionInputBarControlContentSizeChanged:totalRect];
                     }
                     if (inputTextview_height > [self.chatSessionInputBarControl getTextViewHeightWithLines:4]) {
                         self.chatSessionInputBarControl.inputTextView.contentOffset = CGPointMake(0, 100);
                     }
                     if (heightChanged) {
                         [self.chatSessionInputBarControl.inputTextView scrollRangeToVisible:[self.chatSessionInputBarControl.inputTextView selectedRange]];
                     }
                 }];
            }
        }
    }
    
    //输入表情触发文本框变化，更新@信息的range
    if (self.chatSessionInputBarControl.delegate) {
        NSInteger cursorPosition;
        if (self.chatSessionInputBarControl.inputTextView.selectedTextRange) {
            cursorPosition = self.chatSessionInputBarControl.inputTextView.selectedRange.location;
        } else {
            cursorPosition = 0;
        }
        NSRange range = NSMakeRange(cursorPosition, 0);
        if (string) {
            range = NSMakeRange(cursorPosition, string.length);
        }

        [self inputTextView:self.chatSessionInputBarControl.inputTextView
            shouldChangeTextInRange:range
                    replacementText:nil];
        [self inputTextViewDidChange:self.chatSessionInputBarControl.inputTextView];
    }

    if (self.chatSessionInputBarControl.inputTextView.text &&
        self.chatSessionInputBarControl.inputTextView.text.length > 0) {
        [self.emojiBoardView enableSendButton:YES];
    } else {
        [self.emojiBoardView enableSendButton:NO];
    }
}

- (void)didSendButtonEvent {
    NSString *_sendText = self.chatSessionInputBarControl.inputTextView.text;

    NSString *_formatString = [_sendText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if (0 == [_formatString length]) {
        return;
    }
    //    self.chatSessionInputBarControl.inputTextView.text = @"";
    if ([self.delegate respondsToSelector:@selector(inputBar:didTouchsendButton:)]) {
        [self.delegate inputBar:self didTouchsendButton:_sendText];
    }
}

- (void)clearInputView {
    [self.chatSessionInputBarControl clearInputText];
}

- (BOOL)resignFirstResponderIfNeed {
    if ([self.chatSessionInputBarControl.inputTextView isFirstResponder]) {
        return [self.chatSessionInputBarControl.inputTextView resignFirstResponder];
    }
    return NO;
}

- (void)setPlaceholder:(NSString *)placeholder {
    [self.chatSessionInputBarControl setPlaceholder:placeholder];
}

- (void)becomeFirstResponderIfNeed{
    [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        [self chatSessionInputBarControlContentSizeChanged:self.chatSessionInputBarControl.frame];
    }];
}

@end
