//
//  RCMicRoomToolBar.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/4.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicRoomToolBar.h"
#import "RCMicMacro.h"

#define ContentPaddingHorizontal 12
#define ButtonWidth 36
#define ButtonMargin 16
@interface RCMicRoomToolBar()
@property (nonatomic, strong) UIButton *messageButton;// 发消息按钮
@property (nonatomic, strong) UIButton *microphoneButton;// 麦克风按钮
@property (nonatomic, strong) UIButton *speakerButton;// 扬声器按钮
@property (nonatomic, strong) UIButton *metaphoneButton;// 变音按钮
@property (nonatomic, strong) UIButton *musicButton;//伴音按钮
@property (nonatomic, strong) UIButton *giftButton;//送礼按钮
@end
@implementation RCMicRoomToolBar
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
        [self addConstraints];
    }
    return self;
}

- (void)initSubviews {
    _messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _microphoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _speakerButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _metaphoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _musicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _giftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSArray *buttonArray = @[_messageButton, _microphoneButton, _speakerButton, /*_metaphoneButton,*/ _musicButton, _giftButton];
    NSArray *tagArray = @[@(RCMicRoomToolBarMessageButton), @(RCMicRoomToolBarMicrophoneButton), @(RCMicRoomToolBarSpeakerButton), /*@(RCMicRoomToolBarMetaPhoneButton),*/ @(RCMicRoomToolBarMusicButton), @(RCMicRoomToolBarGiftButton)];
    NSArray *imageArray = @[@"room_message", @"room_microphone_open", @"room_speaker_open", /*@"room_metaphone", */@"room_music", @"room_gift"];
    for (int i = 0; i < buttonArray.count; i ++) {
        UIButton *button = buttonArray[i];
        [button setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        button.tag = [tagArray[i] intValue];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

- (void)addConstraints {
    [_messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(ContentPaddingHorizontal);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(ButtonWidth, ButtonWidth));
    }];
    
    [_microphoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_messageButton);
        make.centerY.equalTo(self);
        make.right.equalTo(_speakerButton.mas_left).with.offset(-ButtonMargin);
    }];
    
    [_speakerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_messageButton);
        make.centerY.equalTo(self);
//        make.right.equalTo(_metaphoneButton.mas_left).with.offset(-ButtonMargin);
        make.right.equalTo(_musicButton.mas_left).with.offset(-ButtonMargin);
    }];
    
//    [_metaphoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.equalTo(_messageButton);
//        make.centerY.equalTo(self);
//        make.right.equalTo(_musicButton.mas_left).with.offset(-ButtonMargin);
//    }];
    
    [_musicButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_messageButton);
        make.centerY.equalTo(self);
        make.right.equalTo(_giftButton.mas_left).with.offset(-ButtonMargin);
    }];
    
    [_giftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_messageButton);
        make.centerY.equalTo(self);
        make.right.equalTo(self).with.offset(-ContentPaddingHorizontal);
    }];
}

- (void)buttonAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(roomToolBar:didSelectItemWithTag:)]) {
        [self.delegate roomToolBar:self didSelectItemWithTag:sender.tag];
    }
}

#pragma mark - Public method
- (void)updateWithRoleType:(RCMicRoleType)role {
    BOOL hidden = role == RCMicRoleType_Audience ? YES : NO;
    self.microphoneButton.hidden = hidden;
    self.metaphoneButton.hidden = hidden;
    self.musicButton.hidden = hidden;
    [self updateConstraints:role];
}

#pragma mark - Private method
- (void)updateConstraints:(RCMicRoleType)role {
    if (role == RCMicRoleType_Audience) {
        [_speakerButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(_messageButton);
            make.centerY.equalTo(self);
            make.right.equalTo(_giftButton.mas_left).with.offset(-ButtonMargin);
        }];
    } else {
        [_speakerButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(_messageButton);
            make.centerY.equalTo(self);
//            make.right.equalTo(_metaphoneButton.mas_left).with.offset(-ButtonMargin);
            make.right.equalTo(_musicButton.mas_left).with.offset(-ButtonMargin);
        }];
    }
    [self layoutIfNeeded];
}

#pragma mark - Getters & Setters
- (void)setSpeakerState:(RCMicSpeakerState)speakerState {
    _speakerState = speakerState;
    NSString *imageString;
    switch (speakerState) {
        case RCMicSpeakerStateClose:
            imageString = @"room_speaker_close";
            break;
        default:
            imageString = @"room_speaker_open";
            break;
    }
    [self.speakerButton setImage:[UIImage imageNamed:imageString] forState:UIControlStateNormal];
}

- (void)setMicroPhoneState:(RCMicMicrophoneState)microPhoneState {
    _microPhoneState = microPhoneState;
    NSString *imageString = microPhoneState == RCMicMicrophoneStateNormal ? @"room_microphone_open" : @"room_microphone_close";
    [self.microphoneButton setImage:[UIImage imageNamed:imageString] forState:UIControlStateNormal];
}
@end
