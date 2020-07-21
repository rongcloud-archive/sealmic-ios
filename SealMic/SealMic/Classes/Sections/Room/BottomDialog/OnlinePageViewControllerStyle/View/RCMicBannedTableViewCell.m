//
//  RCMicOnLineTableViewCell.m
//  SealMic
//
//  Created by rongyun on 2020/6/3.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicBannedTableViewCell.h"
#import "RCMicMacro.h"
#import <SDWebImage/SDWebImage.h>

@implementation RCMicBannedTableViewCell

#pragma mark - Life cycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubviews];
        [self addConstraints];
    }
    return self;
}

- (void)setDataModel:(RCMicUserInfo *)model {
    self.titleLabel.text = model.name;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.portraitUri] placeholderImage:[UIImage imageNamed:@"room_portrait_temp"]];
}

#pragma mark - Private method
- (void)initSubviews {
    _headImageView = [[UIImageView alloc] init];
    _headImageView.image = [UIImage imageNamed:@"room_portrait_temp"];
    _headImageView.clipsToBounds = true;
    _headImageView.layer.cornerRadius = 48/2;
    [self addSubview:_headImageView];
    
    _titleLabel = [[UILabel alloc] init];
    //默认值
//    _titleLabel.textColor = UIColor.whiteColor;
    _titleLabel.textColor = RCMicColor([UIColor whiteColor], [UIColor whiteColor]);
    _titleLabel.font = RCMicFont(17, @"PingFangSC-Medium");
    [self addSubview:_titleLabel];
    
    _unbindBtn = [[UIButton alloc] init];
    [_unbindBtn setTitle:RCMicLocalizedNamed(@"dialog_unlock") forState:UIControlStateNormal];
    [_unbindBtn.titleLabel setFont:RCMicFont(14, @"PingFangSC-Regular")];
    [_unbindBtn setBackgroundImage:[UIImage imageNamed:@"online_btn_bg"] forState:UIControlStateNormal];
    [self addSubview:_unbindBtn];
    
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = RCMicColor(HEXCOLOR(0xFFFFFF, 1.0), HEXCOLOR(0xFFFFFF, 1.0));
    _lineView.alpha = 0.1;
    [self addSubview:_lineView];
}

- (void)addConstraints {
    
    [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(23);
        make.width.height.mas_equalTo(48);
        make.centerY.equalTo(self);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headImageView.mas_right).offset(12);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(100);
        make.centerY.equalTo(self);
    }];
    
    [_unbindBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-23);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(50);
        make.centerY.equalTo(self);
    }];

    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.left.equalTo(_titleLabel.mas_left);
        make.right.equalTo(self);
        make.bottom.equalTo(self.mas_bottom);
    }];
}

@end
