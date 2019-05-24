//
//  RCCRInputBar.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/10.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "InputBarControl.h"
#import "InputView.h"
@interface InputBarControl ()<InputViewDelegate>

/*!
 当前输入框状态
 */
@property(nonatomic) InputBarControlStatus currentBottomBarStatus;

/*!
 输入框
 */
@property(nonatomic, strong) InputView *inputBoxView;

@property(nonatomic, assign) CGRect originalFrame;
@end

@implementation InputBarControl

//  初始化
- (id)initWithStatus:(InputBarControlStatus)status {
    self = [super init];
    if (self) {
        [self initializedSubViews];
        [self registerNotification];
        [self setCurrentBottomBarStatus:status];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if(CGRectEqualToRect(self.originalFrame, CGRectZero)){
      self.originalFrame = frame;
    }
    [_inputBoxView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}

-(void)setInputBarStatus:(InputBarControlStatus)Status {
    [self setCurrentBottomBarStatus:Status];
    //  弹出键盘
    if (Status == InputBarControlStatusKeyboard) {
        [_inputBoxView.inputTextView becomeFirstResponder];
    } else {
        //  其他状态隐藏键盘
        if (_inputBoxView.inputTextView.isFirstResponder) {
            [_inputBoxView.inputTextView resignFirstResponder];
        }
    }
}

-(void)changeInputBarFrame:(CGRect)frame{
    
}

#pragma mark - Notification action
- (void)keyboardWillShow:(NSNotification*)notification {
    CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:curve];
        self.frame = CGRectMake(0, self.originalFrame.origin.y-keyboardBounds.size.height,self.bounds.size.width,HeighInputBar);
        [UIView commitAnimations];
    }];
    if ([self.delegate respondsToSelector:@selector(onInputBarControlContentSizeChanged:withAnimationDuration:andAnimationCurve:)]) {
        [self.delegate onInputBarControlContentSizeChanged:self.frame withAnimationDuration:0.5 andAnimationCurve:curve];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:0];
        self.frame = self.originalFrame;
        [UIView commitAnimations];
    }];
    if ([self.delegate respondsToSelector:@selector(onInputBarControlContentSizeChanged:withAnimationDuration:andAnimationCurve:)]) {
        [self.delegate onInputBarControlContentSizeChanged:self.originalFrame withAnimationDuration:0.1 andAnimationCurve:0];
    }
}

#pragma mark - RCCRInputViewDelegate
//  点击发送
- (void)didTouchKeyboardReturnKey:(InputView *)inputControl text:(NSString *)text {
    [self.inputBoxView.inputTextView resignFirstResponder];
    if([self.delegate respondsToSelector:@selector(onTouchSendButton:)]){
        [self.delegate onTouchSendButton:text];
    }
}

//  输入框内容变换
- (void)inputTextView:(UITextView *)inputTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([self.delegate respondsToSelector:@selector(onInputTextView:shouldChangeTextInRange:replacementText:)]){
        [self.delegate onInputTextView:inputTextView shouldChangeTextInRange:range replacementText:text];
    }
}

- (void)inputTextViewDidChange:(UITextView *)textView{
    
}

#pragma mark - UI

- (void)initializedSubViews {
    [self addSubview:self.inputBoxView];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (InputView *)inputBoxView {
    if (!_inputBoxView) {
        _inputBoxView = [[InputView alloc] initWithStatus:InputBarControlStatusDefault];
        [_inputBoxView setDelegate:self];
    }
    return _inputBoxView;
}

- (void)clearInputView {
    [self.inputBoxView clearInputText];
}

- (void)resignResponder {
    if ([self.inputBoxView.inputTextView isFirstResponder]) {
        [self.inputBoxView.inputTextView resignFirstResponder];
    }
}

@end


