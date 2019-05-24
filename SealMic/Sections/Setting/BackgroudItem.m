//
//  BackgroudItem.m
//  SealMic
//
//  Created by 孙浩 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "BackgroudItem.h"

@interface BackgroudItem ()

@property (nonatomic, strong) UIImageView *checkBgView;
@property (nonatomic, strong) UIImageView *checkImgView;

@end

@implementation BackgroudItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    [self addSubview:self.checkBgView];
    [self.checkBgView addSubview:self.checkImgView];
    
    [self.checkBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.offset(25);
    }];
    
    [self.checkImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.checkBgView).offset(-5);
        make.width.offset(22);
        make.height.offset(15);
    }];
}

- (void)setIsChecked:(BOOL)isChecked {
    self.checkBgView.hidden = !isChecked;
    self.checkImgView.hidden = !isChecked;
}

- (UIImageView *)checkBgView {
    if (!_checkBgView) {
        _checkBgView = [[UIImageView alloc] init];
        _checkBgView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        _checkBgView.hidden = YES;
        _checkBgView.userInteractionEnabled = YES;
    }
    return _checkBgView;
}

- (UIImageView *)checkImgView {
    if (!_checkImgView) {
        _checkImgView = [[UIImageView alloc] init];
        _checkImgView.image = [UIImage imageNamed:@"setting_bg_check"];
        _checkImgView.hidden = YES;
        _checkImgView.userInteractionEnabled = YES;
    }
    return _checkImgView;
}

@end
