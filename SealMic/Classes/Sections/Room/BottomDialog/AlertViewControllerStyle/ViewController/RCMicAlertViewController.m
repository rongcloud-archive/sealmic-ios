//
//  RCMicAlertViewController.m
//  SealMic
//
//  Created by rongyun on 2020/6/29.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicAlertViewController.h"
#import "RCMicMacro.h"

@interface RCMicAlertViewController ()
/// 弹框视图
@property (nonatomic, strong) UIView *alertView;
/// 弹框背景图片
@property (nonatomic, strong) UIImageView *alertBgImageView;
/// 弹框UI横向分割线
@property (nonatomic, strong) UIView *horizontalLine;
/// 弹框UI纵向分割线
@property (nonatomic, strong) UIView *verticalLine;
/// 同意按钮
@property (nonatomic, strong) UIButton *agreeBtn;
/// 拒绝按钮
@property (nonatomic, strong) UIButton *refuseBtn;
@end

@implementation RCMicAlertViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置类似遮罩的视图背景颜色
    self.view.backgroundColor = [UIColor colorWithRed:3/255.0f green:6/255.0f blue:47/255.0f alpha:0.5];
    [self addSubviews];
    [self addConstraints];
}

#pragma mark - Action

- (void)agreeAction {
    if(self.agreeBtnAction){
        self.agreeBtnAction();
        [self dismissAlert];
    }
}

- (void)refuseAction {
    if(self.refuseBtnAction){
        self.refuseBtnAction();
        [self dismissAlert];
    }
}

- (void)dismissAlert {
    //隐藏当前vc
    [self dismissViewControllerAnimated:true completion:nil];
    //移出弹框
    [self.alertView removeFromSuperview];
}

#pragma mark - Private method

- (void)addSubviews {
    [UIApplication.sharedApplication.keyWindow addSubview:self.alertView];
    //弹框背景图片视图
    [self.alertView addSubview:self.alertBgImageView];
    [self.alertView addSubview:self.alertMessageLabel];
    [self.alertView addSubview:self.horizontalLine];
    [self.alertView addSubview:self.verticalLine];
    [self.alertView addSubview:self.agreeBtn];
    [self.alertView addSubview:self.refuseBtn];
}

- (void)addConstraints {
    
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@157.5);
        make.centerY.equalTo(UIApplication.sharedApplication.keyWindow);
        make.centerX.equalTo(UIApplication.sharedApplication.keyWindow);
        make.width.equalTo(@294);
    }];
    
    [self.alertBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@157.5);
        make.centerY.equalTo(UIApplication.sharedApplication.keyWindow);
        make.centerX.equalTo(UIApplication.sharedApplication.keyWindow);
        make.width.equalTo(@294);
    }];
    
    [self.alertMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@43);
        make.left.equalTo(@5);
        make.right.equalTo(@5);
    }];
    
    [self.horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@-44);
        make.left.right.equalTo(self.alertView);
        make.height.equalTo(@0.5);
    }];
    
    [self.verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.centerX.equalTo(self.alertView);
        make.top.equalTo(@113.5);
        make.width.equalTo(@0.5);
    }];
    
    [self.agreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(@0);
        make.top.equalTo(self.horizontalLine.mas_bottom);
        make.left.equalTo(self.verticalLine.mas_right);
    }];
    
    [self.refuseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(@0);
        make.top.equalTo(self.horizontalLine.mas_bottom);
        make.right.equalTo(self.verticalLine.mas_left);
    }];
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    //隐藏当前vc
//    [self dismissViewControllerAnimated:true completion:nil];
//    //移出弹框
//    [self.alertView removeFromSuperview];
//}

#pragma mark - Getters & Setters
- (UIView *)alertView {
    if(!_alertView) {
        _alertView = [[UIView alloc] init];
//        _alertView.backgroundColor = [UIColor redColor];
    }
    return _alertView;
}

- (UIImageView *)alertBgImageView {
    if(!_alertBgImageView) {
        _alertBgImageView = [[UIImageView alloc] init];
        //默认值
        _alertBgImageView.image = [UIImage imageNamed:@"alertvc_bg"];
    }
    return _alertBgImageView;
}

- (UILabel *)alertMessageLabel {
    if (!_alertMessageLabel){
        _alertMessageLabel = [[UILabel alloc] init];
        _alertMessageLabel.font = RCMicFont(15, @"PingFangSC-Regular");
        _alertMessageLabel.textColor = RCMicColor(HEXCOLOR(0xFFFFFF, 1.0), HEXCOLOR(0xFFFFFF, 1.0));
        _alertMessageLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _alertMessageLabel;
}

- (UIView *)horizontalLine {
    if (!_horizontalLine){
        _horizontalLine = [[UIView alloc] init];
        _horizontalLine.backgroundColor = RCMicColor(HEXCOLOR(0xFFFFFF, 1.0), HEXCOLOR(0xFFFFFF, 1.0));
        _horizontalLine.alpha = 0.2;
    }
    return _horizontalLine;
}

- (UIView *)verticalLine {
    if (!_verticalLine){
        _verticalLine = [[UIView alloc] init];
        _verticalLine.backgroundColor = RCMicColor(HEXCOLOR(0xFFFFFF, 1.0), HEXCOLOR(0xFFFFFF, 1.0));
        _verticalLine.alpha = 0.2;
    }
    return _verticalLine;
}

- (UIButton *)agreeBtn {
    if (!_agreeBtn){
        _agreeBtn = [[UIButton alloc] init];
        _agreeBtn.titleLabel.font = RCMicFont(17, @"PingFangSC-Regular");
        [_agreeBtn setTitleColor:RCMicColor(HEXCOLOR(0x2DF3C1, 1.0), HEXCOLOR(0x2DF3C1, 1.0)) forState:UIControlStateNormal];
        [_agreeBtn setTitle:RCMicLocalizedNamed(@"room_alert_agree") forState:UIControlStateNormal];
        [_agreeBtn addTarget:self action:@selector(agreeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _agreeBtn;
}

- (UIButton *)refuseBtn {
    if (!_refuseBtn){
        _refuseBtn = [[UIButton alloc] init];
        _refuseBtn.titleLabel.font = RCMicFont(17, @"PingFangSC-Regular");
        [_refuseBtn setTitleColor:RCMicColor(HEXCOLOR(0xFFFFFF, 1.0), HEXCOLOR(0xFFFFFF, 1.0)) forState:UIControlStateNormal];
        [_refuseBtn setTitle:RCMicLocalizedNamed(@"room_alert_refuse") forState:UIControlStateNormal];
        [_refuseBtn addTarget:self action:@selector(refuseAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refuseBtn;
}

@end
