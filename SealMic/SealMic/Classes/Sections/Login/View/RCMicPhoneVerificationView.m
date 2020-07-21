//
//  RCMicPhoneVerificationView.m
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicPhoneVerificationView.h"
#import "RCMicMacro.h"

#define RowHeight self.frame.size.height/4
@implementation RCMicPhoneVerificationView

#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addConstraints];
}

#pragma mark - Private method
- (void)initSubviews {
    _phoneInputField = [[UITextField alloc] initWithFrame:CGRectZero];
    _phoneInputField.textColor = [UIColor blackColor];
    _phoneInputField.placeholder = RCMicLocalizedNamed(@"enter_phone_number");
    _phoneInputField.backgroundColor = RCMicColor(HEXCOLOR(0xF4F5F7, 1.0), HEXCOLOR(0xF4F5F7, 1.0));
    _phoneInputField.layer.cornerRadius = 46/2;
    _phoneInputField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneInputField.font = RCMicFont(14, @"PingFangSC-Regular");
    [_phoneInputField addTarget:self action:@selector(changedPhoneTextField:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:_phoneInputField];
    //文字偏移量
    _phoneInputField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 24, 0)];
    //设置显示模式为永远显示(默认不显示)
    _phoneInputField.leftViewMode = UITextFieldViewModeAlways;
    _codeInputField = [[UITextField alloc] initWithFrame:CGRectZero];
    _codeInputField.textColor = [UIColor blackColor];
    _codeInputField.keyboardType = UIKeyboardTypeNumberPad;
    _codeInputField.backgroundColor = RCMicColor(HEXCOLOR(0xF4F5F7, 1.0), HEXCOLOR(0xF4F5F7, 1.0));
    _codeInputField.placeholder = RCMicLocalizedNamed(@"enter_verification_code");
    _codeInputField.font = RCMicFont(14, @"PingFangSC-Regular");
    [_codeInputField addTarget:self action:@selector(changedCodeTextField:) forControlEvents:UIControlEventEditingChanged];
    _codeInputField.layer.cornerRadius = 46/2;
    
    //文字偏移量
    _codeInputField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 24, 0)];
    //设置显示模式为永远显示(默认不显示)
    _codeInputField.leftViewMode = UITextFieldViewModeAlways;
    
    [self addSubview:_codeInputField];
    
    _sendCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sendCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendCodeButton setTitle:RCMicLocalizedNamed(@"verification_code") forState:UIControlStateNormal];
    //默认不可点击
    [_sendCodeButton setEnabled:false];
    [_sendCodeButton setSelected:false];
    _sendCodeButton.titleLabel.font = RCMicFont(14, @"PingFangSC-Regular");
    [_sendCodeButton setBackgroundImage:[UIImage imageNamed:@"verificationcode_bg"] forState:UIControlStateNormal];
    [_sendCodeButton setBackgroundImage:[UIImage imageNamed:@"verificationcode_selected_bg"] forState:UIControlStateSelected];
    [_sendCodeButton addTarget:self action:@selector(sendCodeAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sendCodeButton];
}

//禁止使用第三方输入法
-(BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier{
    return NO;
}

- (void)addConstraints {
    
    [_phoneInputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(0);
    }];
    
    [_codeInputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_phoneInputField.mas_bottom).offset(15);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    [_sendCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_codeInputField.mas_right).offset(-5);
        make.top.equalTo(_codeInputField.mas_top).offset(5);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(34);
    }];
}

#pragma mark -Action
- (void)loginButtonVerification {
    //如果手机号和验证码输入框都有值 登录按钮才可点击
    if(_phoneInputField.text.length >0 && _codeInputField.text.length >0){
        [self.verificationDelegate notificationChangesLoginButtonStatus:true];
    }else {
        [self.verificationDelegate notificationChangesLoginButtonStatus:false];
    }
}

- (void)sendCodeAction {
    //1.设置倒计时
    [self sentPhoneCodeTimeMethod];
    //2.发送请求获取验证码
    /*这里写发送请求部分代码 根据情况写代理协议*/
    [self.verificationDelegate sendCode:self.phoneInputField.text];
}

//计时器发送验证码
-(void)sentPhoneCodeTimeMethod{
    __weak typeof(self) weakSelf = self;
    //倒计时时间 - 60秒
    __block NSInteger timeOut = 59;
    //执行队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //计时器 -》dispatch_source_set_timer自动生成
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (timeOut <= 0) {
            dispatch_source_cancel(timer);
            //主线程设置按钮样式-》
            RCMicMainThread(^{
                [weakSelf.sendCodeButton setTitle:RCMicLocalizedNamed(@"verification_code") forState:UIControlStateNormal];
                weakSelf.sendCodeButton.enabled = YES;
            });
        }else{
            //开始计时
            //剩余秒数 seconds
            NSInteger seconds = timeOut % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.1ld",(long)seconds];
            //主线程设置按钮样式
            RCMicMainThread((^{
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:1.0];
                [weakSelf.sendCodeButton setTitle:[NSString stringWithFormat:@"(%@‘s)",strTime] forState:UIControlStateNormal];
                [UIView commitAnimations];
                //计时器件不允许点击
                weakSelf.sendCodeButton.enabled = NO;
            }));
            timeOut--;
        }
    });
    dispatch_resume(timer);
}

#pragma mark -给每个cell中的textfield添加事件，只要值改变就调用此函数
-(void)changedPhoneTextField:(UITextField *)phoneNumber
{
    [self.verificationDelegate currentPhoneNumber:phoneNumber.text];
    //判断验证码按钮是否可以点击
//    NSLog(@"手机号值是---%@",phoneNumber.text);
    if(phoneNumber.text.length >0){
        [_sendCodeButton setEnabled:true];
        [_sendCodeButton setSelected:true];
    }else {
        [_sendCodeButton setEnabled:false];
        [_sendCodeButton setSelected:false];
    }
    //判断登录按钮是否可以点击
    [self loginButtonVerification];
}

- (void)changedCodeTextField:(UITextField *)code{
//    NSLog(@"验证码值是---%@",code.text);
    [self loginButtonVerification];
}

@end
