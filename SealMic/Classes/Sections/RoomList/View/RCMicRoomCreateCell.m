//
//  RCMicRoomCreateCell.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/11.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicRoomCreateCell.h"
#import "RCMicMacro.h"
#define CenterViewWidth 41

@interface RCMicRoomCreateCell()
@property (nonatomic, strong) UIImageView *centerView;
@property (nonatomic, strong) UILabel *tipLabel;
@end

@implementation RCMicRoomCreateCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    self.contentView.backgroundColor = RCMicColor(HEXCOLOR(0xf4f5f7, 1.0), HEXCOLOR(0xf4f5f7, 1.0));
    self.contentView.layer.cornerRadius = 12;
    self.contentView.layer.masksToBounds = YES;
    
    _centerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"roomlist_create"]];
    _centerView.layer.cornerRadius = CenterViewWidth/2;
    _centerView.layer.masksToBounds = YES;
    [self.contentView addSubview:_centerView];
    
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _tipLabel.text = RCMicLocalizedNamed(@"roomList_create");
    _tipLabel.font = RCMicFont(14, @"PingFangSC-Medium");
    _tipLabel.textColor = RCMicColor(HEXCOLOR(0x000000, 1.0), HEXCOLOR(0x000000, 1.0));
    [self.contentView addSubview:_tipLabel];
    
    [_centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat marginY = 0.06 * self.frame.size.height;
        make.centerX.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView).with.offset(-marginY);
        make.size.mas_equalTo(CGSizeMake(CenterViewWidth, CenterViewWidth));
    }];
    
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_centerView.mas_bottom).with.offset(10);
        make.height.mas_equalTo(20);
        make.centerX.equalTo(self.contentView);
    }];
}
@end
