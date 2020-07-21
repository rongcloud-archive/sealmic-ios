//
//  RCMicOperationGiftCollectionCell.m
//  SealMic
//
//  Created by rongyun on 2020/6/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicOperationGiftCollectionCell.h"
#import "RCMicMacro.h"

@implementation RCMicOperationGiftCollectionCell

#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
//        self.backgroundColor = [UIColor cyanColor];
    }
    return self;
}

#pragma mark - Private method
- (void)initSubviews {
    
    _seletedBgImageView = [[UIImageView alloc] init];
    _seletedBgImageView.image = [UIImage imageNamed:@"gift_seleted_bg"];
    //默认隐藏 选中后显示
    _seletedBgImageView.alpha = 0;
    [self addSubview:_seletedBgImageView];
    [_seletedBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    _giftImageView = [[UIImageView alloc] init];
    [self addSubview:_giftImageView];
//    _giftImageView.image = [UIImage imageNamed:@"gift_smail"];
    _giftImageView.contentMode = UIViewContentModeScaleAspectFit;
//    _giftImageView.backgroundColor = [UIColor cyanColor];
    [_giftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(80);
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-13);
    }];
    
    _giftTitleLabel = [[UILabel alloc] init];
    [self addSubview:_giftTitleLabel];
    _giftTitleLabel.text = @"";
    _giftTitleLabel.textAlignment = NSTextAlignmentCenter;
    _giftTitleLabel.textColor = RCMicColor(HEXCOLOR(0xDFDFDF, 1.0), HEXCOLOR(0xDFDFDF, 1.0));
    _giftTitleLabel.font = RCMicFont(12, @"PingFangSC-Medium");
    [_giftTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_giftImageView.mas_bottom).offset(0);
        make.centerX.equalTo(_giftImageView);
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(20);
    }];
    
}

- (void)setDataGiftInfoModel:(RCMicGiftInfo *)giftInfo {
    if (giftInfo){
        self.giftTitleLabel.text = giftInfo.name;
        self.giftImageView.image = giftInfo.image;
    }
}

@end
