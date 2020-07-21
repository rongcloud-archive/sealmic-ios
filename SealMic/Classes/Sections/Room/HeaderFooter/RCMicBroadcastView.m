//
//  RCMicBroadcastView.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/22.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicBroadcastView.h"
#import "RCMicMacro.h"
#import "RCMicGiftInfo.h"

#define ContentPadding 10
#define AccessoryWidth 14
#define TextFont 12
#define ContentMargin 5
@interface RCMicBroadcastView()
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *leftAccessory;
@property (nonatomic, strong) UILabel *middleLabel;
@end
@implementation RCMicBroadcastView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
        [self addConstraints];
    }
    return self;
}

- (void)initSubviews {
    _backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"room_broadcast_bg"]];
    [self addSubview:_backgroundView];
    
    _leftAccessory = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"room_broadcast_accessory"]];
    [self addSubview:_leftAccessory];
    
    _userNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _userNameLabel.font = RCMicFont(TextFont, nil);
    _userNameLabel.textColor = RCMicColor(HEXCOLOR(0xf8e71c, 1.0), HEXCOLOR(0xf8e71c, 1.0));
    [self addSubview:_userNameLabel];
    
    _middleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _middleLabel.text = RCMicLocalizedNamed(@"room_broadcast_at");
    _middleLabel.font = RCMicFont(TextFont, nil);
    _middleLabel.textColor = RCMicColor([UIColor whiteColor], [UIColor whiteColor]);
    [self addSubview:_middleLabel];
    
    _roomNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _roomNameLabel.font = RCMicFont(TextFont, nil);
    _roomNameLabel.textColor = RCMicColor(HEXCOLOR(0xf8e71c, 1.0), HEXCOLOR(0xf8e71c, 1.0));
    [self addSubview:_roomNameLabel];
    
    _giftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _giftLabel.font = RCMicFont(TextFont, nil);
    _giftLabel.textColor = RCMicColor([UIColor whiteColor], [UIColor whiteColor]);
    [self addSubview:_giftLabel];
}

- (void)addConstraints {
    [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_leftAccessory mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(ContentPadding);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(AccessoryWidth, AccessoryWidth));
    }];
    
    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftAccessory.mas_right).with.offset(ContentMargin);
        make.centerY.equalTo(self);
        make.right.equalTo(_middleLabel.mas_left).with.offset(-ContentMargin);
    }];
    
    [_middleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(_roomNameLabel.mas_left).with.offset(-ContentMargin);
    }];
    
    [_roomNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(_giftLabel.mas_left).with.offset(-ContentMargin);
    }];
    
    [_giftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).with.offset(-ContentPadding);
    }];
}

- (void)updateContentWithMessage:(RCMicBroadcastGiftMessage *)message {
    RCMicGiftInfo *gift = [[RCMicGiftInfo alloc] initWithTag:message.tag];
    self.userNameLabel.text = message.senderUserInfo.name;
    self.roomNameLabel.text = message.roomName;
    self.giftLabel.text = [NSString stringWithFormat:@"%@%@!!!",RCMicLocalizedNamed(@"room_broadcast_room"),gift.name];
}

+ (CGFloat)contentWidthWithMessage:(RCMicBroadcastGiftMessage *)message {
    RCMicGiftInfo *gift = [[RCMicGiftInfo alloc] initWithTag:message.tag];
    CGSize size = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    CGRect userNameRect = [message.senderUserInfo.name boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:RCMicFont(TextFont, nil)} context:nil];
    CGRect middleRect = [RCMicLocalizedNamed(@"room_broadcast_at") boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:RCMicFont(TextFont, nil)} context:nil];
    CGRect roomNameRect = [message.roomName boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:RCMicFont(TextFont, nil)} context:nil];
    NSString *giftString = [NSString stringWithFormat:@"%@%@!!!",RCMicLocalizedNamed(@"room_broadcast_room"),gift.name];
    CGRect giftLabelRect = [giftString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:RCMicFont(TextFont, nil)} context:nil];
    //比标准宽度额外加 2，防止精度问题导致文字显示不全
    return ContentPadding + AccessoryWidth + ContentMargin + userNameRect.size.width + ContentMargin + middleRect.size.width + ContentMargin + roomNameRect.size.width + ContentMargin + giftLabelRect.size.width + ContentPadding + 2;
}
@end
