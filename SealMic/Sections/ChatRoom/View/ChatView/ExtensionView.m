//
//  ExtensionView.m
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ExtensionView.h"
#import "MicPositionInfo.h"
#import "ClassroomService.h"
#import "RTCService.h"

@implementation ExtensionView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.micButton];
        [self addSubview:self.voiceButton];
        
        [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(8);
            make.right.equalTo(self).offset(-15);
            make.width.height.offset(32);
        }];
        [self.micButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.voiceButton.mas_top);
            make.right.equalTo(self.voiceButton.mas_left).offset(-6);
            make.width.height.offset(32);
        }];
    }
    return self;
}

- (void)reloadExtensionView {
    MicPositionInfo *info = [[ClassroomService sharedService].currentRoom getMicPositionInfo:[ClassroomService sharedService].currentUser.userId];
    BOOL isCreator = [[ClassroomService sharedService].currentRoom.creatorId isEqualToString:[ClassroomService sharedService].currentUser.userId];
    if (info && info.userId.length > 0) {
        if (info.state & MicStateForbidden) {
            self.micButton.enabled = NO;
            [[RTCService sharedService] setMicrophoneDisable:YES];
        }else{
            self.micButton.enabled = YES;
            [[RTCService sharedService] setMicrophoneDisable:self.micButton.selected];
        }
    } else if (isCreator) {
        self.micButton.enabled = YES;
        [[RTCService sharedService] setMicrophoneDisable:self.micButton.selected];
    } else {
        self.micButton.enabled = NO;
    }
    [[RTCService sharedService] setMuteAllVoice:self.voiceButton.selected];
}

#pragma mark - target action
- (void)didClickMicButton{
    self.micButton.selected = !self.micButton.selected;
    [[RTCService sharedService] setMicrophoneDisable:self.micButton.isSelected];
}

- (void)didClickVoiceButton{
    self.voiceButton.selected = !self.voiceButton.selected;
    [[RTCService sharedService] setMuteAllVoice:self.voiceButton.selected];
}
#pragma mark - getting & setting
- (UIButton *)micButton{
    if (!_micButton) {
        _micButton = [[UIButton alloc] init];
        [_micButton addTarget:self action:@selector(didClickMicButton) forControlEvents:(UIControlEventTouchUpInside)];
        [_micButton setImage:[UIImage imageNamed:@"mic"] forState:(UIControlStateNormal)];
        [_micButton setImage:[UIImage imageNamed:@"mic_mute"] forState:(UIControlStateSelected)];
    }
    return _micButton;
}

- (UIButton *)voiceButton{
    if (!_voiceButton) {
        _voiceButton = [[UIButton alloc] init];
        [_voiceButton addTarget:self action:@selector(didClickVoiceButton) forControlEvents:(UIControlEventTouchUpInside)];
        [_voiceButton setImage:[UIImage imageNamed:@"volume"] forState:(UIControlStateNormal)];
        [_voiceButton setImage:[UIImage imageNamed:@"volume_mute"] forState:(UIControlStateSelected)];
    }
    return _voiceButton;
}
@end
