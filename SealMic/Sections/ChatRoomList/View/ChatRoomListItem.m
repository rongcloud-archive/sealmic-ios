//
//  ChatRoomListItem.m
//  SealMic
//
//  Created by 孙浩 on 2019/5/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ChatRoomListItem.h"
#import "Masonry.h"
#import "RandomUtil.h"

@interface ChatRoomListItem ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *portraitImgView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *numberLabel;

@end

@implementation ChatRoomListItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.portraitImgView];
    [self.bgView addSubview:self.nameLabel];
    [self.portraitImgView addSubview:self.numberLabel];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.portraitImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.bgView);
        make.height.width.offset(ItemWidth);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.portraitImgView.mas_bottom).offset(2);
        make.left.right.equalTo(self.bgView);
        make.bottom.equalTo(self.bgView);
    }];
    
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(17);
        make.width.mas_greaterThanOrEqualTo(45);
        make.right.equalTo(self.portraitImgView).offset(-5);
        make.bottom.equalTo(self.portraitImgView).offset(-8);
    }];
}

- (void)setRoomInfo:(RoomInfo *)roomInfo {
    self.portraitImgView.image = [RandomUtil randomRoomCover:roomInfo.roomId];
    self.nameLabel.text = roomInfo.subject;
    self.numberLabel.text = [NSString stringWithFormat: MicLocalizedNamed(@"memberCount"), (long)roomInfo.memberCount];
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
    }
    return _bgView;
}

- (UIImageView *)portraitImgView {
    if (!_portraitImgView) {
        _portraitImgView = [[UIImageView alloc] init];
    }
    return _portraitImgView;
}

- (UILabel *)nameLabel {
    if(!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:14];
        _nameLabel.numberOfLines = 1;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textColor = [UIColor colorWithHexString:@"8F8F8F" alpha:1];
    }
    return _nameLabel;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.font = [UIFont systemFontOfSize:9];
        _numberLabel.layer.cornerRadius = 8;
        _numberLabel.layer.masksToBounds = YES;
        _numberLabel.numberOfLines = 1;
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.textColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
        _numberLabel.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.4];

    }
    return _numberLabel;
}

@end
