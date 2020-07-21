//
//  RCMicRoomNavigationBar.m
//  SealMic
//
//  Created by lichenfeng on 2020/5/26.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicRoomNavigationView.h"
#import "RCMicMacro.h"
#import <SDWebImage/SDWebImage.h>

#define BackButtonWidth 24
#define ThemeImageWidth 36
#define RoomTitleLabelHeight 20
#define SignalImageWidth 8
#define SignalLabelHeight 13

#define NoticeButtonWidth 24
#define MicHandleButtonWidth 24
#define RedTipLabelWidth 8
#define SetButtonWidth 24
@interface RCMicRoomNavigationView()
@property (nonatomic, strong) RCMicRoomViewModel *viewModel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIImageView *themeImageView;
@property (nonatomic, strong) UILabel *roomTitleLabe;
@property (nonatomic, strong) UIImageView *signalImageView;
@property (nonatomic, strong) UILabel *signalLabel;//延迟值显示
@property (nonatomic, strong) UILabel *onlineCountLabel;
@property (nonatomic, strong) UIButton *noticeButton;//公告按钮
@property (nonatomic, strong) UIButton *micHandleButton;//麦位操作按钮
@property (nonatomic, strong) UILabel *redTipLabel;//麦位操作按钮右上角红点
@property (nonatomic, strong) UIButton *setButton;
@end

@implementation RCMicRoomNavigationView
- (instancetype)initWithFrame:(CGRect)frame viewModel:(nonnull RCMicRoomViewModel *)viewModel {
    self = [super initWithFrame:frame];
    if (self) {
        _viewModel = viewModel;
        self.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
        [self initSubviews];
        [self addConstraints];
    }
    return self;
}

- (void)initSubviews {
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setImage:[UIImage imageNamed:@"room_back"] forState:UIControlStateNormal];
    _backButton.tag = RCMicRoomNavigationViewBackButton;
    [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backButton];
    
    _themeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _themeImageView.layer.cornerRadius = ThemeImageWidth/2;
    _themeImageView.clipsToBounds = YES;
    [_themeImageView sd_setImageWithURL:[NSURL URLWithString:_viewModel.roomInfo.themeImageURL] placeholderImage:[UIImage imageNamed:@"roomlist_theme_temp"]];
    [self addSubview:_themeImageView];
    
    _roomTitleLabe = [[UILabel alloc] initWithFrame:CGRectZero];
    _roomTitleLabe.textColor = RCMicColor([UIColor whiteColor], [UIColor whiteColor]);
    _roomTitleLabe.text = _viewModel.roomInfo.roomName;
    _roomTitleLabe.font = RCMicFont(14, nil);
    [self addSubview:_roomTitleLabe];
    
    _signalImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _signalImageView.hidden = YES;
    [self addSubview:_signalImageView];
    
    _signalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _signalLabel.textColor = RCMicColor([UIColor whiteColor], [UIColor whiteColor]);
    _signalLabel.font = RCMicFont(9, nil);
    [self addSubview:_signalLabel];
    
    _onlineCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _onlineCountLabel.textColor = RCMicColor([UIColor whiteColor], [UIColor whiteColor]);
    _onlineCountLabel.font = RCMicFont(10, nil);
    [self addSubview:_onlineCountLabel];
    
    _noticeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_noticeButton setImage:[UIImage imageNamed:@"room_notice"] forState:UIControlStateNormal];
    [_noticeButton addTarget:self action:@selector(noticeAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_noticeButton];
    
    _micHandleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_micHandleButton setImage:[UIImage imageNamed:@"room_michandle"] forState:UIControlStateNormal];
    [_micHandleButton addTarget:self action:@selector(micHandleAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_micHandleButton];
    
    _redTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _redTipLabel.backgroundColor = RCMicColor(HEXCOLOR(0xff3737, 1.0), HEXCOLOR(0xff3737, 1.0));
    _redTipLabel.layer.cornerRadius = RedTipLabelWidth/2;
    _redTipLabel.clipsToBounds = YES;
    _redTipLabel.hidden = YES;
    [self addSubview:_redTipLabel];
    
    _setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_setButton setImage:[UIImage imageNamed:@"room_set"] forState:UIControlStateNormal];
    [_setButton addTarget:self action:@selector(setAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_setButton];
}

- (void)addConstraints {
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.size.mas_equalTo(CGSizeMake(BackButtonWidth, BackButtonWidth));
        make.centerY.equalTo(self);
    }];
    
    [_themeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_backButton.mas_right);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(ThemeImageWidth, ThemeImageWidth));
    }];
    
    [_roomTitleLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_themeImageView.mas_right).with.offset(4);
        make.top.equalTo(_themeImageView);
        make.height.mas_equalTo(RoomTitleLabelHeight);
        make.right.equalTo(_noticeButton.mas_left).with.offset(-4);
    }];
    
    [_signalImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_roomTitleLabe);
        make.size.mas_equalTo(CGSizeMake(SignalImageWidth, SignalImageWidth));
        make.top.equalTo(_roomTitleLabe.mas_bottom).with.offset(6);
    }];
    
    [_signalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_signalImageView.mas_right).with.offset(3);
        make.height.mas_equalTo(SignalLabelHeight);
        make.centerY.equalTo(_signalImageView);
    }];
    
    [_onlineCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_signalLabel.mas_right).with.offset(4);
        make.height.equalTo(_signalLabel);
        make.centerY.equalTo(_signalLabel);
    }];
    
    [_noticeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(NoticeButtonWidth, NoticeButtonWidth));
        make.right.equalTo(_micHandleButton.mas_left).with.offset(-20);
    }];
    
    [_micHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(MicHandleButtonWidth, MicHandleButtonWidth));
        make.right.equalTo(_setButton.mas_left).with.offset(-20);
    }];
    
    [_redTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(_micHandleButton);
        make.size.mas_equalTo(RedTipLabelWidth);
    }];
    
    [_setButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(SetButtonWidth, SetButtonWidth));
        make.right.equalTo(self).with.offset(-12);
    }];
}

- (void)updateDelay:(NSInteger)delay {
    NSString *image;
    UIColor *color;
    if (delay > 600) {
        image = @"room_signal_bad";
        color = RCMicColor(HEXCOLOR(0xd0021b, 1.0), HEXCOLOR(0xd0021b, 1.0));
    } else if (delay > 100) {
        image = @"room_signal_normal";
        color = RCMicColor(HEXCOLOR(0xffec00, 1.0), HEXCOLOR(0xffec00, 1.0));
    } else {
        image = @"room_signal_good";
        color = RCMicColor(HEXCOLOR(0x7ed321, 1.0), HEXCOLOR(0x7ed321, 1.0));
    }
    self.signalImageView.hidden = NO;
    self.signalImageView.image = [UIImage imageNamed:image];
    self.signalLabel.text = [NSString stringWithFormat:@"%ldms",(long)delay];
    self.signalLabel.textColor = color;
}

- (void)updateOnlineCount:(NSInteger)count {
    self.onlineCountLabel.text = [NSString stringWithFormat:@"%@ %ld",RCMicLocalizedNamed(@"room_participant_onlineCount"),(long)count];
}

- (void)showTipLabel:(BOOL)show {
    self.redTipLabel.hidden = !show;
}

#pragma mark - Actions
- (void)backAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(roomNavigationView:didSelectItemWithTag:)]) {
        [self.delegate roomNavigationView:self didSelectItemWithTag:RCMicRoomNavigationViewBackButton];
    }
}

- (void)setAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(roomNavigationView:didSelectItemWithTag:)]) {
        [self.delegate roomNavigationView:self didSelectItemWithTag:RCMicRoomNavigationViewSetButton];
    }
}

- (void)noticeAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(roomNavigationView:didSelectItemWithTag:)]) {
        [self.delegate roomNavigationView:self didSelectItemWithTag:RCMicRoomNavigationViewNoticeButton];
    }
}

- (void)micHandleAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(roomNavigationView:didSelectItemWithTag:)]) {
        [self.delegate roomNavigationView:self didSelectItemWithTag:RCMicRoomNavigationViewMicHandleButton];
    }
}


@end
