//
//  CreateRoomViewController.m
//  SealMic
//
//  Created by rongyun on 2020/6/12.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicCreateRoomViewController.h"
#import "RCMicMacro.h"
#import "RCMicCachedUserInfo.h"
#import <SDWebImage/SDWebImage.h>
#import "RCMicRoomViewController.h"
#import "RCMicActiveWheel.h"
#import "RCMicCreateRoomViewModel.h"

@interface RCMicCreateRoomViewController ()
/// 导航栏标题
@property (nonatomic, strong) UILabel *navigationTitle;
/// 返回按钮
@property (nonatomic, strong) UIButton *backBtn;
/// 房间图片
@property (nonatomic, strong) UIImageView *roomImageView;
/// 当前用户登录头像
@property (nonatomic, strong) UIImageView *loginPortraitImageView;
/// 房间主题四个字
@property (nonatomic, strong) UILabel *roomThemeTitle;
/// 房间名字输入框
@property (nonatomic, strong) UITextField *roomNameTextField;
/// 确认按钮
@property (nonatomic, strong) UIButton *okBtn;
@property (nonatomic, strong) RCMicCreateRoomViewModel *viewModel;

@end

@implementation RCMicCreateRoomViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self addSubviews];
    [self addConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //判断当前设备高度根据需求添加输入框跟随通知。
    if (RCMicScreenHeightEqualOrLessTo667){
        return;
    }
    //键盘将弹出的时候获取通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //键盘将隐藏的时候获取通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //判断当前设备高度根据需求添加输入框跟随通知。
    if (RCMicScreenHeightEqualOrLessTo667){
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
    CGFloat keyBoardHeight = keyBoardBounds.size.height  - 60 + 7;
    // 获取键盘动画时间
    CGFloat animationTime = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        self.okBtn.transform = CGAffineTransformMakeTranslation(0, - keyBoardHeight);
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
        self.okBtn.transform = CGAffineTransformIdentity;
    };
    if (animationTime >0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

//禁止使用第三方输入法
-(BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier{
    return NO;
}

#pragma mark - Private method

- (void)addSubviews {
    [self.view addSubview:self.navigationTitle];
    [self.view addSubview:self.loginPortraitImageView];
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.roomImageView];
    [self.view addSubview:self.roomThemeTitle];
    [self.view addSubview:self.roomNameTextField];
    [self.view addSubview:self.okBtn];
}

- (void)addConstraints {
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat margin = [RCMicUtil statusBarHeight] + 10;
        make.top.equalTo(self.view).with.offset(margin);
        make.left.mas_equalTo(5);
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
    }];
    
    [self.navigationTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat margin = [RCMicUtil statusBarHeight] + 11;
        make.top.equalTo(self.view).with.offset(margin);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(26);
    }];
    
    [self.loginPortraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat margin = [RCMicUtil statusBarHeight] + 6;
        make.top.equalTo(self.view).with.offset(margin);
        make.right.mas_equalTo(-16);
        make.width.mas_equalTo(32);
        make.height.mas_equalTo(32);
    }];
    
    [self.roomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        if (RCMicScreenWidthEqualTo320){
            make.top.mas_equalTo(70);
        }
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(126);
        make.height.mas_equalTo(126);
    }];
    
    [self.roomThemeTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.roomImageView.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
    }];
    
    [self.roomNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.roomThemeTitle.mas_bottom).offset(28);
        make.height.mas_equalTo(44);
        make.left.mas_equalTo(36);
        make.right.mas_equalTo(-36);
    }];
    
    [self.okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-60);
        make.left.mas_equalTo(36);
        make.right.mas_equalTo(-36);
        make.height.mas_equalTo(50);
    }];
}

#pragma mark - Action

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)okAction {
    [RCMicActiveWheel showHUDAddedTo:RCMicKeyWindow];
    [self.viewModel createRoomWithRoomName:self.roomNameTextField.text success:^(RCMicRoomInfo * _Nonnull roomInfo) {
                RCMicMainThread(^{
                    [RCMicActiveWheel hideHUDForView:RCMicKeyWindow animated:YES];
                    RCMicRoomViewController *roomVC = [[RCMicRoomViewController alloc] initWithRoomInfo:roomInfo Role:RCMicRoleType_Host];
                    [self.navigationController pushViewController:roomVC animated:YES];
                    //进入房间页需要用此字段标识以便下次回到房间列表主动做一次数据加载
                    RCMicUtil.loadMoreWhenRoomListAppear = YES;
                    //push 之后从导航中移除自身
                    NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
                    [controllers removeObject:self];
                    [self.navigationController setViewControllers:controllers animated:NO];
        })
    } error:^(RCMicHTTPCode errorCode) {
        RCMicMainThread(^{
            [RCMicActiveWheel hideHUDForView:RCMicKeyWindow animated:YES];
            [RCMicUtil showTipWithErrorCode:errorCode];
        })
    }];
}

-(void)changedRoomNameTextField:(UITextField *)roomNameTextField {
    //判断验证码按钮是否可以点击
    //    NSLog(@"房间名称值是---%@",roomNameTextField.text);
    if(roomNameTextField.text.length >0){
        [_okBtn setEnabled:true];
        [_okBtn setSelected:true];
    }else {
        [_okBtn setEnabled:false];
        [_okBtn setSelected:false];
    }
}

#pragma mark - Getters & Setters

- (RCMicCreateRoomViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[RCMicCreateRoomViewModel alloc] init];
    }
    return _viewModel;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        //        [_backBtn setTitle:@"" forState:UIControlStateNormal];
        [_backBtn setBackgroundImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
        [_backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIImageView *)roomImageView {
    if (!_roomImageView) {
        _roomImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_roomImageView sd_setImageWithURL:[NSURL URLWithString:[RCMicUtil randomRoomTheme]] placeholderImage:[UIImage imageNamed:@"roomlist_theme_temp"]];
        _roomImageView.layer.cornerRadius = 20;
        _roomImageView.clipsToBounds = true;
    }
    return _roomImageView;
}

- (UIImageView *)loginPortraitImageView {
    if (!_loginPortraitImageView) {
        _loginPortraitImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        RCMicCachedUserInfo *userInfo = [RCMicAppService sharedService].currentUser;
        [_loginPortraitImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.userInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"login_portrait_default"]];
        _loginPortraitImageView.layer.cornerRadius = 9;
        _loginPortraitImageView.clipsToBounds = true;
    }
    return _loginPortraitImageView;
}

- (UILabel *)navigationTitle {
    if (!_navigationTitle) {
        _navigationTitle = [[UILabel alloc] init];
        //默认值
        //        _navigationTitle.text = @"Seal Mic";
        _navigationTitle.text = RCMicLocalizedNamed(@"createRoom_navigation_title");
        _navigationTitle.font = RCMicFont(19, @"PingFangSC-Regular");
        _navigationTitle.textAlignment = NSTextAlignmentCenter;
        _navigationTitle.textColor = RCMicColor(HEXCOLOR(0x000000, 1.0), HEXCOLOR(0x000000, 1.0));
    }
    return _navigationTitle;
}

- (UILabel *)roomThemeTitle {
    if (!_roomThemeTitle) {
        _roomThemeTitle = [[UILabel alloc] init];
        //默认值
        _roomThemeTitle.text = RCMicLocalizedNamed(@"createRoom_roomTheme_Title");
        _roomThemeTitle.textAlignment = NSTextAlignmentCenter;
        _roomThemeTitle.font = RCMicFont(16, @"PingFangSC-Regular");
        _roomThemeTitle.textColor = RCMicColor(HEXCOLOR(0x000000, 1.0), HEXCOLOR(0x000000, 1.0));
    }
    return _roomThemeTitle;
}

- (UITextField *)roomNameTextField {
    if (!_roomNameTextField) {
        _roomNameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _roomNameTextField.textColor = [UIColor blackColor];
        _roomNameTextField.placeholder = RCMicLocalizedNamed(@"createRoom_name_placeholder");
        _roomNameTextField.leftViewMode = UITextFieldViewModeAlways;
        _roomNameTextField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 24, 0)];
        _roomNameTextField.backgroundColor = RCMicColor(HEXCOLOR(0xF4F5F7, 1.0), HEXCOLOR(0xF4F5F7, 1.0));
        _roomNameTextField.layer.cornerRadius = 46/2;
        _roomNameTextField.font = RCMicFont(14, @"PingFangSC-Regular");
        [_roomNameTextField addTarget:self action:@selector(changedRoomNameTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _roomNameTextField;
}

- (UIButton *)okBtn {
    if (!_okBtn) {
        _okBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_okBtn setTitle:RCMicLocalizedNamed(@"createRoom_ok") forState:UIControlStateNormal];
        [_okBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_okBtn addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
        [_okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //默认不可点击
        [_okBtn setEnabled:false];
        [_okBtn setSelected:false];
        //        [_loginBtn setBackgroundColor:[UIColor cyanColor]];
        [_okBtn setBackgroundImage:[UIImage imageNamed:@"login_button_bg"] forState:UIControlStateNormal];
        [_okBtn setBackgroundImage:[UIImage imageNamed:@"login_button_selected_bg"] forState:UIControlStateSelected];
        _okBtn.layer.cornerRadius = 46/2;
    }
    return _okBtn;
}

@end
