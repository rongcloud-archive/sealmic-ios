//
//  NaviView.m
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "NaviView.h"
#import "ClassroomService.h"
#define InfoTextFont 12
@interface NaviView()
@property (nonatomic, strong) UILabel *infoLabel;
@end
@implementation NaviView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setInfo];
        [self addSubview:self.backButton];
        [self.backButton addSubview:self.infoLabel];
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self).offset(15);
            make.width.offset(30);
            make.height.offset(20);
        }];
        [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.backButton);
            make.left.equalTo(self.backButton.mas_right).offset(-8);
            make.width.offset([self getInfoWidth]);
            make.height.offset(33);
        }];
    }
    return self;
}

- (void)reloadTitle{
    [self setInfo];
    [self.infoLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.offset([self getInfoWidth]);
    }];
}

#pragma mark - target action
- (void)didClickBackButton{
    if (self.delegate && [self.delegate respondsToSelector:@selector(back)]) {
        [self.delegate back];
    }
}

#pragma mark - help
- (void)setInfo{
    NSString *content = [NSString stringWithFormat:@" %@(%d%@) ",[ClassroomService sharedService].currentRoom.subject,[ClassroomService sharedService].currentRoom.memberCount,MicLocalizedNamed(@"person")];
    self.infoLabel.text = content;
}

- (CGFloat)getInfoWidth{
    CGRect rect = [self.infoLabel.text boundingRectWithSize:CGSizeMake(400, 33)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:InfoTextFont]}
                                              context:nil];
    return ceilf(rect.size.width)+10;
}

#pragma mark - Getters and setters
- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton addTarget:self action:@selector(didClickBackButton) forControlEvents:(UIControlEventTouchUpInside)];
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:(UIControlStateNormal)];
        _backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    }
    return _backButton;
}

- (UILabel *)infoLabel{
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.backgroundColor = [HEXCOLOR(0xffffff) colorWithAlphaComponent:0.16];
        _infoLabel.layer.cornerRadius = 15;
        _infoLabel.layer.masksToBounds = YES;
        _infoLabel.layer.borderColor = HEXCOLOR(0x5c77fa).CGColor;
        _infoLabel.layer.borderWidth = 0.5;
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.font = [UIFont systemFontOfSize:InfoTextFont];
    }
    return _infoLabel;
}
@end
