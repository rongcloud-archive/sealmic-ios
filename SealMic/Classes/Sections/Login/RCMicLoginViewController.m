//
//  RCMicLoginViewController.m
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicLoginViewController.h"
#import "RCMicPhoneVerificationView.h"
#import "RCMicMacro.h"
#import "RCMicUtil.h"
#import "RCMicActiveWheel.h"
#import "RCMicLoginViewModel.h"

@interface RCMicLoginViewController ()<VerificationInputDelegate>
@property (nonatomic, strong) RCMicPhoneVerificationView *verificationView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UIImageView *logoTitleImageView;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) NSString *currentPhoneNumber;
@property (nonatomic, strong) RCMicLoginViewModel *viewModel;
@end

@implementation RCMicLoginViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addSubviews];
    [self addConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //判断当前设备是否是 iphone 5/se 如果是的话 不做输入框跟随。
    if (RCMicScreenWidthEqualTo320){
        return;
    }
    //键盘将弹出的时候获取通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //键盘将隐藏的时候获取通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //判断当前设备是否是 iphone 5/se 如果是的话 不做输入框跟随。
    if (RCMicScreenWidthEqualTo320){
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyBoardWillShow:(NSNotification *)notifi{
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notifi.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    /*
     -60      是登录按钮距离屏幕底部的距离
     +42.5    是按钮距离键盘的距离
     */
    CGFloat keyBoardHeight = keyBoardBounds.size.height - 60 + 42.5;
    // 获取键盘动画时间
    CGFloat animationTime = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        self.loginBtn.transform = CGAffineTransformMakeTranslation(0, - keyBoardHeight);
    };
    if (animationTime >0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

- (void)keyBoardWillHidden:(NSNotification *)notifi{
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notifi.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        self.loginBtn.transform = CGAffineTransformIdentity;
    };
    if (animationTime >0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark - Action
- (void)loginAction {
    [self.viewModel loginWithPhoneNumber:self.verificationView.phoneInputField.text verifyCode:self.verificationView.codeInputField.text success:^{
        RCMicMainThread(^{
            [self.navigationController popToRootViewControllerAnimated:true];
        });
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)backAction {
    [self.navigationController popToRootViewControllerAnimated:true];
}

#pragma mark - VerificationInputDelegate
/// 输入框视图登录按钮状态改变
- (void)notificationChangesLoginButtonStatus:(BOOL)isClick {
    [self.loginBtn setSelected:isClick];
    [self.loginBtn setEnabled:isClick];
}

- (void)sendCode:(NSString *)phoneNumber {
    [self.viewModel sendVerificationCodeWithPhoneNumber:phoneNumber];
}

- (void)currentPhoneNumber:(NSString *)phoneNumber {
    self.currentPhoneNumber = phoneNumber;
}

#pragma mark - Private method
- (void)addSubviews {
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.logoTitleImageView];
    [self.view addSubview:self.verificationView];
    [self.view addSubview:self.loginBtn];
}

- (void)addConstraints {
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat margin = [RCMicUtil statusBarHeight] + 10;
        make.top.equalTo(self.view).with.offset(margin);
        make.left.mas_equalTo(5);
        make.width.mas_equalTo(66);
        make.height.mas_equalTo(24);
    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat margin = [RCMicUtil statusBarHeight] + 65;
        make.top.equalTo(self.view).with.offset(margin);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(80);
    }];
    
    [self.logoTitleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImageView.mas_bottom).offset(14.5);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(68);
        make.height.mas_equalTo(15);
    }];
    
    [self.verificationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoTitleImageView.mas_bottom).offset(45.78);
        make.left.mas_equalTo(36);
        make.right.mas_equalTo(-36);
        make.height.mas_equalTo(120);
    }];
    
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-60);
        make.left.mas_equalTo(36);
        make.right.mas_equalTo(-36);
        make.height.mas_equalTo(50);
    }];
}

#pragma mark - Getters & Setters

- (RCMicLoginViewModel *)viewModel {
    if (!_viewModel){
        _viewModel = [[RCMicLoginViewModel alloc] init];
    }
    return _viewModel;
}

- (RCMicPhoneVerificationView *)verificationView {
    if (!_verificationView) {
        _verificationView = [[RCMicPhoneVerificationView alloc] initWithFrame:CGRectZero];
        _verificationView.verificationDelegate = self;
    }
    return _verificationView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_backBtn setTitle:RCMicLocalizedNamed(@"login_button") forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
        [_backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [_backBtn.titleLabel setFont:RCMicFont(15, @"PingFangSC-Regular")];
    }
    return _backBtn;
}

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _logoImageView.image = [UIImage imageNamed:@"sealmic_logo"];
    }
    return _logoImageView;
}

- (UIImageView *)logoTitleImageView {
    if (!_logoTitleImageView) {
        _logoTitleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _logoTitleImageView.image = [UIImage imageNamed:@"sealmic_title"];
    }
    return _logoTitleImageView;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_loginBtn setTitle:RCMicLocalizedNamed(@"login_button") forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //默认不可点击
        [_loginBtn setEnabled:false];
        [_loginBtn setSelected:false];
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"login_button_bg"] forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"login_button_selected_bg"] forState:UIControlStateSelected];
        _loginBtn.layer.cornerRadius = 46/2;
    }
    return _loginBtn;
}

@end
