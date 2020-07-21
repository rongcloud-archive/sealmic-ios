//
//  RCMicRoomCell.m
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicRoomCell.h"
#import <SDWebImage/SDWebImage.h>
#import "RCMicMacro.h"
@interface RCMicRoomCell()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *translucentView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *lockView;
@property (nonatomic, strong) UIImageView *hotView;
@property (nonatomic, strong) UILabel *countLabel;
@end
@implementation RCMicRoomCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
        [self addConstraints];
    }
    return self;
}

- (void)initSubviews {
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _backgroundImageView.layer.cornerRadius = 12;
    _backgroundImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:_backgroundImageView];
    
    _translucentView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"roomlist_translucent"]];
    _translucentView.layer.cornerRadius = 12;
    _translucentView.layer.masksToBounds = YES;
    [self.contentView addSubview:_translucentView];

    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.font = RCMicFont(15, @"PingFangSC-Medium");
    _nameLabel.textColor = RCMicColor(HEXCOLOR(0xffffff, 1.0), HEXCOLOR(0xffffff, 1.0));
    [self.contentView addSubview:_nameLabel];
    
    _lockView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"roomlist_lock"]];
    [self.contentView addSubview:_lockView];
    
    _hotView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"roomlist_hot"]];
    [self.contentView addSubview:_hotView];
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _countLabel.text = @"369";
    _countLabel.font = RCMicFont(11, nil);
    _countLabel.textColor = RCMicColor(HEXCOLOR(0xd7d5d0, 1.0), HEXCOLOR(0xd7d5d0, 1.0));
    [self.contentView addSubview:_countLabel];
}

- (void)addConstraints {
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [_translucentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_backgroundImageView);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(15);
        make.height.mas_equalTo(20);
        make.left.equalTo(self.contentView).with.offset(20);
        CGFloat maxWidth = self.contentView.frame.size.width - 40;
        make.width.mas_lessThanOrEqualTo(maxWidth);
    }];
    
    [_lockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameLabel.mas_right).with.offset(4);
        make.top.equalTo(_nameLabel);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    [_hotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameLabel);
        make.top.equalTo(_nameLabel.mas_bottom).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(9, 11));
    }];
    
    [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_hotView.mas_right).with.offset(2);
        make.top.equalTo(_hotView);
        make.height.equalTo(_hotView);
    }];
}

- (void)setDataModel:(RCMicRoomInfo *)model {
    [self.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:model.themeImageURL] placeholderImage:[UIImage imageNamed:@"roomlist_theme_temp"]];
    self.nameLabel.text = model.roomName;
    self.lockView.hidden = model.freeJoinRoom;
}
@end
