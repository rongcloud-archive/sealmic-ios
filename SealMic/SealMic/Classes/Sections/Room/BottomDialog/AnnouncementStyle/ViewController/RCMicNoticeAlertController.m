//
//  RCMicNoticeAlertController.m
//  SealMic
//
//  Created by rongyun on 2020/6/8.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicNoticeAlertController.h"
#import "RCMicMacro.h"

@interface RCMicNoticeAlertController ()
/// 弹框背景图片视图
@property (nonatomic, strong) UIImageView *bgImageView;
/// 标题
@property (nonatomic, strong) UILabel *titleLabel;
/// 公告内容
@property (nonatomic, strong) UITextView *contentAnnouncementTextView;
/// 知道了按钮
@property (nonatomic, strong) UIButton *okButton;
///文本框底部背景
@property (nonatomic, strong) UIView *textBgView;

@end

@implementation RCMicNoticeAlertController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置类似遮罩的视图背景颜色
    self.view.backgroundColor = [UIColor colorWithRed:3/255.0f green:6/255.0f blue:47/255.0f alpha:0.5];
    //弹框背景图片视图
    [self.view addSubview:self.bgImageView];
    [self.bgImageView addSubview:self.titleLabel];
    [self.bgImageView addSubview:self.textBgView];
    [self.bgImageView addSubview:self.contentAnnouncementTextView];
    [self.bgImageView addSubview:self.okButton];
    [self addConstraints];
}

#pragma mark - Private method
- (void)addConstraints {
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(257);
        make.width.mas_equalTo(244);
        make.centerY.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgImageView);
        make.top.mas_equalTo(12);
    }];
    
    [self.contentAnnouncementTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        //           make.centerX.equalTo(self.bgImageView);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
        //            make.width.mas_equalTo(237);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(156);
    }];
    
    [self.textBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(156);
    }];
    
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bgImageView.mas_bottom).offset(-13);
        make.centerX.equalTo(self.bgImageView);
        make.height.mas_equalTo(26);
        make.width.mas_equalTo(63);
    }];
}

#pragma mark - Action
- (void)okAction {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Getters & Setters
- (UIImageView *)bgImageView {
    if(!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        //默认值
        _bgImageView.image = [UIImage imageNamed:@"alert_notice_bg"];
        _bgImageView.userInteractionEnabled = true;
    }
    return _bgImageView;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        //默认值
        _titleLabel.text = RCMicLocalizedNamed(@"announcement_title");
        _titleLabel.textColor = RCMicColor(HEXCOLOR(0x2DF3C1, 1.0), HEXCOLOR(0x2DF3C1, 1.0));
        _titleLabel.font = RCMicFont(17, @"PingFangSC-Medium");
    }
    return _titleLabel;
}

- (UITextView *)contentAnnouncementTextView {
    if(!_contentAnnouncementTextView) {
        _contentAnnouncementTextView = [[UITextView alloc] init];
        //默认值
        _contentAnnouncementTextView.text = @"这是房间公告\n\n请文明聊天，可以聊天，唱歌，送礼。                 \n\n禁止黄赌毒，禁止骂人。";
        _contentAnnouncementTextView.textColor = RCMicColor(HEXCOLOR(0xFF333333, 1.0), HEXCOLOR(0xFF333333, 1.0));
        _contentAnnouncementTextView.font = RCMicFont(12, @"PingFangSC-Regular");
        //        _contentAnnouncementTextView.font = RCMicFont(13);
//        _contentAnnouncementTextView.backgroundColor = RCMicColor(HEXCOLOR(0xC9CAD0, 1.0), HEXCOLOR(0xC9CAD0, 1.0));;
        _contentAnnouncementTextView.layer.cornerRadius = 10.5;
        _contentAnnouncementTextView.alpha = 1;
        _contentAnnouncementTextView.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
        [_contentAnnouncementTextView setEditable:false];
        _contentAnnouncementTextView.textContainerInset = UIEdgeInsetsMake(19, 12, 37, 12);
    }
    return _contentAnnouncementTextView;
}

- (UIView *)textBgView {
    if(!_textBgView) {
        _textBgView = [[UIView alloc] init];
        _textBgView.backgroundColor = RCMicColor(HEXCOLOR(0xFFFFFF, 1.0), HEXCOLOR(0xFFFFFF, 1.0));
        _textBgView.layer.cornerRadius = 10.5;
        _textBgView.alpha = 0.4;
//        _textBgView.textContainerInset = UIEdgeInsetsMake(19, 12, 37, 12);
    }
    return _textBgView;
}

- (UIButton *)okButton {
    if(!_okButton){
        _okButton = [[UIButton alloc] init];
        [_okButton setTitle:RCMicLocalizedNamed(@"announcement_know") forState:UIControlStateNormal];
        [_okButton addTarget:self action:@selector(okAction)  forControlEvents:UIControlEventTouchUpInside];
        //      [_okButton setBackgroundColor:RCMicColor([UIColor cyanColor], [UIColor cyanColor])];
        [_okButton setBackgroundImage:[UIImage imageNamed:@"give_btn_bg"] forState:UIControlStateNormal];
        _okButton.layer.cornerRadius = 13;
        _okButton.titleLabel.font = RCMicFont(12, nil);
    }
    return _okButton;
}

@end
