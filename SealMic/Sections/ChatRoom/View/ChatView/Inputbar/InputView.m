//
//  RCCRInputView.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/11.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "InputView.h"

@interface InputView () <UITextViewDelegate>

@end

@implementation InputView
//  初始化
- (id)initWithStatus:(InputBarControlStatus)status {
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self initializedSubViews];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [_inputContainerView setFrame:self.bounds];
    [_inputTextView setFrame:CGRectMake(10, 7, self.bounds.size.width - 20, 36)];
}

#pragma mark <UITextViewDelegate>
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([self.delegate respondsToSelector:@selector(inputTextView:shouldChangeTextInRange:replacementText:)]) {
        [self.delegate inputTextView:textView shouldChangeTextInRange:range replacementText:text];
    }
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didTouchKeyboardReturnKey:text:)]) {
            NSString *_needToSendText = textView.text;
            NSString *_formatString =
            [_needToSendText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (0 == [_formatString length]) {
                
            } else {
                //  发送点击事件
                [self.delegate didTouchKeyboardReturnKey:self text:[_needToSendText copy]];
            }
        }
        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length < 1) {
        textView.text = MicLocalizedNamed(@"PleaseSpeakSomething");
        textView.textColor = [UIColor grayColor];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:MicLocalizedNamed(@"PleaseSpeakSomething")]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)didTapTextView{
    [self.inputTextView becomeFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView{
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidChange:)]) {
        [self.delegate inputTextViewDidChange:textView];
    }
}

- (void)clearInputText {
    [_inputTextView setText:MicLocalizedNamed(@"PleaseSpeakSomething")];
    _inputTextView.textColor = [UIColor grayColor];
}

- (void)initializedSubViews {
    [self addSubview:self.inputContainerView];
    [_inputContainerView addSubview:self.inputTextView];
}

#pragma mark - UI

- (UIView *)inputContainerView {
    if (!_inputContainerView) {
        _inputContainerView = [[UIView alloc] init];
    }
    return _inputContainerView;
}

- (UITextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[UITextView alloc] init];
        _inputTextView.text = MicLocalizedNamed(@"PleaseSpeakSomething");
        [_inputTextView setTextColor:[UIColor grayColor]];
        [_inputTextView setFont:[UIFont systemFontOfSize:16]];
        _inputTextView.backgroundColor = [UIColor whiteColor];
        [_inputTextView setReturnKeyType:UIReturnKeySend];
        [_inputTextView setEnablesReturnKeyAutomatically:YES];  //内容为空，返回按钮不可点击
        [_inputTextView.layer setCornerRadius:6];
        [_inputTextView.layer setMasksToBounds:YES];
        [_inputTextView.layer setBorderWidth:0.5f];
        [_inputTextView.layer setBorderColor:HEXCOLOR(0xb2b2b2).CGColor];
        [_inputTextView.layoutManager setAllowsNonContiguousLayout:YES];    //默认从顶部开始显示
        [_inputTextView setDelegate:self];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTextView)];
        [_inputTextView addGestureRecognizer:tapGes];
    }
    return _inputTextView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
