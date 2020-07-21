//
//  RCMicParticipantItem.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/1.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicParticipantItem.h"
#import "RCMicMacro.h"
#import <SDWebImage/SDWebImage.h>
#define PortraitViewWidth (_isHost ? 79 : 56)
#define AnimationViewWidth (_isHost ? 79 : 56)
//#define AnimationViewWidth (_isHost ? 99 : 76)做动画时最大的尺寸
#define BottomContentHeight (_isHost ? 20 : 17)
#define CenterMarkWidth (_isHost ? 30 : 24)

#define StateViewWidth (_isHost ? 18 : 18)
#define PositionTagViewWidth (_isHost ? 12 : 12)
@interface RCMicParticipantItem()
@property (nonatomic, strong) UILabel *nameLabel;//底部名称
@property (nonatomic, strong) UIView *animationView;//背景动效
@property (nonatomic, strong) CALayer *animationLayer;//动效所在的 layer
@property (nonatomic, strong) UIImageView *stateView;//禁言状态
@property (nonatomic, strong) UIImageView *portraitView;//头像
@property (nonatomic, strong) UIImageView *centerMarkView;//麦位状态标识
@property (nonatomic, strong) UIButton *positionTagButton;//麦位序号
@property (nonatomic, strong) UIImageView *bottomContentView;//底部区域
@property (nonatomic, assign) BOOL isHost;
@property (nonatomic, strong) NSTimer *animationTimer;

@end
@implementation RCMicParticipantItem

- (instancetype)initWithFrame:(CGRect)frame isHost:(BOOL)isHost {
    self = [super initWithFrame:frame];
    if (self) {
        _isHost = isHost;
        _animationTimer = [[NSTimer alloc] initWithFireDate:[NSDate distantFuture] interval:1.6 target:self selector:@selector(performAnimation) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
        [self initSubviews];
        [self addConstraints];
    }
    return self;
}

- (void)initSubviews {
    //说话时动效视图
    _animationView = [[UIView alloc] initWithFrame:CGRectZero];
    _animationView.layer.cornerRadius = AnimationViewWidth/2;
    [self addSubview:_animationView];
    
    _animationLayer = [CALayer layer];
    _animationLayer.frame = self.animationView.bounds;
    [_animationView.layer addSublayer:_animationLayer];
    
    //头像
    _portraitView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _portraitView.layer.cornerRadius = PortraitViewWidth/2;
    _portraitView.layer.masksToBounds = YES;
    _portraitView.layer.borderWidth = 1;
    _portraitView.userInteractionEnabled = YES;
    [self addSubview:_portraitView];
    
    //麦位状态标记
    _centerMarkView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_portraitView addSubview:_centerMarkView];
    
    //禁言视图
    _stateView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _stateView.image = [UIImage imageNamed:@"participant_forbidden"];
    _stateView.hidden = YES;
    [self addSubview:_stateView];
    
    //底部内容承载视图
    _bottomContentView = [[UIImageView alloc] initWithFrame:CGRectZero];
    UIImage *bottomImage = _isHost ? nil : [UIImage imageNamed:@"participant_bottom_container"];
    _bottomContentView.image = bottomImage;
    _bottomContentView.layer.cornerRadius = 9;
    _bottomContentView.layer.masksToBounds = YES;
    [self addSubview:_bottomContentView];
    
    //麦位标识
    _positionTagButton = [[UIButton alloc] initWithFrame:CGRectZero];
    if (!_isHost) {
        _positionTagButton.layer.cornerRadius = PositionTagViewWidth/2;
    }
    [_positionTagButton setTitleColor:RCMicColor(HEXCOLOR(0xffffff, 1.0), HEXCOLOR(0xffffff, 1.0)) forState:UIControlStateNormal];
    _positionTagButton.titleLabel.font = RCMicFont(9, nil);
    [_bottomContentView addSubview:_positionTagButton];
    
    //名称
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.textColor = RCMicColor(HEXCOLOR(0xFFFFFF, 1.0), HEXCOLOR(0xFFFFFF, 1.0));
    UIFont *nameFont = _isHost ? RCMicFont(14, nil) : RCMicFont(10, nil);
    _nameLabel.font = nameFont;
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [_nameLabel sizeToFit];
    [_bottomContentView addSubview:_nameLabel];
}

- (void)addConstraints {
    [_portraitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(PortraitViewWidth, PortraitViewWidth));
    }];
    
    [_centerMarkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_portraitView);
        make.size.mas_equalTo(CGSizeMake(CenterMarkWidth, CenterMarkWidth));
    }];
    
    [_animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_portraitView);
        make.centerY.equalTo(_portraitView);
        make.size.mas_equalTo(CGSizeMake(AnimationViewWidth, AnimationViewWidth));
    }];
    
    [_stateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_portraitView);
        make.right.equalTo(_portraitView);
        make.size.mas_equalTo(CGSizeMake(StateViewWidth, StateViewWidth));
    }];
    
    [_bottomContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(_portraitView.mas_bottom).with.offset(10);
        make.height.mas_equalTo(BottomContentHeight);
        make.width.lessThanOrEqualTo(self);
    }];
    
    [_positionTagButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bottomContentView).with.offset(5);
        make.centerY.equalTo(_bottomContentView);
        make.size.mas_equalTo(CGSizeMake(PositionTagViewWidth, PositionTagViewWidth));
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_positionTagButton.mas_right).with.offset(3);
        make.right.equalTo(_bottomContentView).with.offset(-5);
        make.top.equalTo(_bottomContentView);
        make.height.mas_equalTo(BottomContentHeight);
    }];
}

- (void)updateWithViewModel:(RCMicParticipantViewModel *)viewModel {
    //麦位上已经没人时不允许播放动画，可能会出现异常原因导致某个麦位上没人了发言状态仍为 YES
    if (viewModel.participantInfo.userId.length == 0) {
        [self suspendAnimation:[NSNumber numberWithBool:YES]];
    }
    
    self.isHost = viewModel.participantInfo.position == 0 ? YES : NO;
    RCMicParticipantState state = viewModel.participantInfo.state;
    if (state == RCMicParticipantStateNormal || state == RCMicParticipantStateSilent) {
        if (viewModel.participantInfo.userId.length > 0) {
            self.centerMarkView.hidden = YES;
            UIImage *positionImage = self.isHost ? [UIImage imageNamed:@"participant_host_blue"] : [UIImage imageNamed:@"participant_button_bg_blue"];
            [self.positionTagButton setBackgroundImage:positionImage forState:UIControlStateNormal];
            [viewModel getUserInfo:^(RCMicUserInfo * _Nullable userInfo) {
                RCMicMainThread(^{
                    [self.portraitView sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"room_portrait_temp"]];
                    if (self.isHost) {
                        self.portraitView.layer.borderColor = RCMicColor(HEXCOLOR(0x50e3c2, 1.0), HEXCOLOR(0x50e3c2, 1.0)).CGColor;
                    } else {
                        self.portraitView.layer.borderColor = RCMicColor([UIColor clearColor], [UIColor clearColor]).CGColor;
                    }
                    self.nameLabel.text = userInfo.name;
                })
            }];
            //只有麦位上有人时才能开启动画
            if (viewModel.participantInfo.speaking) {
                [self suspendAnimation:[NSNumber numberWithBool:NO]];
            } else {
                //说话时间太短动画可能消失的太快，可根据应用需求适当延迟消失时间
                [self performSelector:@selector(suspendAnimation:) withObject:[NSNumber numberWithBool:YES] afterDelay:1];
            }
        } else {
            self.portraitView.image = [UIImage imageNamed:@"participant_portrait_default"];
            self.portraitView.layer.borderColor = RCMicColor([UIColor clearColor], [UIColor clearColor]).CGColor;
            self.centerMarkView.hidden = NO;
            self.centerMarkView.image = [UIImage imageNamed:@"participant_empty"];
            UIImage *positionImage = self.isHost ? [UIImage imageNamed:@"participant_host_blue"] : [UIImage imageNamed:@"participant_button_bg_gray"];
            [self.positionTagButton setBackgroundImage:positionImage forState:UIControlStateNormal];
            NSString *nameText = self.isHost ? RCMicLocalizedNamed(@"room_participant_host_placeholder") : RCMicLocalizedNamed(@"room_participant_placeholder");
            self.nameLabel.text = nameText;
        }
        self.stateView.hidden = state == RCMicParticipantStateSilent ? NO : YES;
        NSString *positionTitle = self.isHost ? RCMicLocalizedNamed(@"room_participant_host") : [NSString stringWithFormat:@"%ld",(long)viewModel.participantInfo.position];
        [self.positionTagButton setTitle:positionTitle forState:UIControlStateNormal];
    } else if (state == RCMicParticipantStateClosed) {
        self.portraitView.image = [UIImage imageNamed:@"participant_portrait_default"];
        self.portraitView.layer.borderColor = RCMicColor([UIColor clearColor], [UIColor clearColor]).CGColor;
        self.centerMarkView.hidden = NO;
        self.centerMarkView.image = [UIImage imageNamed:@"participant_closed"];
        UIImage *positionImage = self.isHost ? [UIImage imageNamed:@"participant_host_blue"] : [UIImage imageNamed:@"participant_button_bg_gray"];
        [self.positionTagButton setBackgroundImage:positionImage forState:UIControlStateNormal];
        NSString *positionTitle = self.isHost ? RCMicLocalizedNamed(@"room_participant_host") : [NSString stringWithFormat:@"%ld",(long)viewModel.participantInfo.position];
        [self.positionTagButton setTitle:positionTitle forState:UIControlStateNormal];
        NSString *nameText = self.isHost ? RCMicLocalizedNamed(@"room_participant_host_placeholder") : RCMicLocalizedNamed(@"room_participant_placeholder");
        self.nameLabel.text = nameText;
    }
}

- (void)suspendAnimation:(id)suspend {
    if ([suspend boolValue]) {
        self.animationLayer.sublayers = nil;
        [self.animationTimer setFireDate:[NSDate distantFuture]];
        if (!self.isHost) {
            self.portraitView.layer.borderColor = RCMicColor([UIColor clearColor], [UIColor clearColor]).CGColor;
        }
    } else {
        [self.animationTimer setFireDate:[NSDate distantPast]];
        self.portraitView.layer.borderColor = RCMicColor(HEXCOLOR(0x50e3c2, 1.0), HEXCOLOR(0x50e3c2, 1.0)).CGColor;
    }
}

- (void)performAnimation {
    self.animationLayer.sublayers = nil;
    CGFloat animationDuration = 1.6;
    NSInteger layerCount = 2;
    for (int i = 0; i < layerCount; ++ i) {
        CAKeyframeAnimation *boundsAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        boundsAnimation.values = @[@1, @1.13, @1.25, @1.36, @1.47, @1.48, @1.485, @1.49, @1.495, @1.498, @1.5];
        boundsAnimation.keyTimes = @[@0, @0.1, @0.2, @0.3, @0.4, @0.5, @0.6, @0.7, @0.8, @0.9, @1];

        // 透明度变化
        CAKeyframeAnimation * opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.values   = @[@1, @0.5, @0.3, @0.25, @0.20, @0.17, @0.14, @0.11, @0.1, @0.05, @0.0];
        opacityAnimation.keyTimes = @[@0, @0.1, @0.2, @0.3, @0.4, @0.5, @0.6, @0.7, @0.8, @0.9, @1];
        
        CAAnimationGroup * groupAnimation = [CAAnimationGroup animation];
        groupAnimation.animations = @[boundsAnimation, opacityAnimation];
        groupAnimation.fillMode = kCAFillModeForwards;
        groupAnimation.beginTime = CACurrentMediaTime() + (double)i * 0.4;
        groupAnimation.duration = animationDuration;
        groupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        
        CALayer * layer = [CALayer layer];
        layer.backgroundColor = RCMicColor(HEXCOLOR(0x50e3c2, 1.0), HEXCOLOR(0x50e3c2, 1.0)).CGColor;
        layer.frame = self.animationView.bounds;
        layer.cornerRadius = AnimationViewWidth/2;
        [layer addAnimation:groupAnimation forKey:@"layer"];
        [self.animationLayer addSublayer:layer];
    }
}

///从界面移除时释放 timer
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self.animationTimer invalidate];
        self.animationTimer = nil;
    }
}
@end
