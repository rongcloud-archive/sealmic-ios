//
//  MemberCell.m
//  SealMic
//
//  Created by 张改红 on 2019/5/10.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "MemberCell.h"
@interface MemberCell()
@property (nonatomic, strong) UIImageView *headerImage;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *joinMicButton;
@end
@implementation MemberCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.headerImage];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.joinMicButton];
        [self.headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
            [self.headerImage mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(15);
                make.centerY.equalTo(self).offset(0);
                make.height.width.offset(46);
            }];
            
            [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self).offset(0);
                make.left.equalTo(self.headerImage.mas_right).offset(8);
                make.height.offset(16);
                make.right.equalTo(self.joinMicButton.mas_right).offset(-10);
            }];
            [self.joinMicButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self).offset(0);
                make.right.equalTo(self).offset(-15);
                make.height.offset(26);
                make.width.offset(75);
            }];
        }];
    }
    return self;
}

-(void)setUser:(UserInfo *)info{
    self.headerImage.image = [RandomUtil randomPortraitFor:info.userId];
    self.nameLabel.text = [RandomUtil randomNameFor:info.userId];
}

- (void)didClickJoinMicButton{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickJoinMicButton:)]) {
        [self.delegate didClickJoinMicButton:self];
    }
}

#pragma mark - getter & setter
- (UIImageView *)headerImage{
    if (!_headerImage) {
        _headerImage = [[UIImageView alloc] init];
        _headerImage.layer.masksToBounds = YES;
        _headerImage.layer.cornerRadius = 23;
    }
    return _headerImage;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = HEXCOLOR(0x666666);
    }
    return _nameLabel;
}

- (UIButton *)joinMicButton{
    if (!_joinMicButton) {
        _joinMicButton = [[UIButton alloc] init];
        _joinMicButton.backgroundColor = HEXCOLOR(0x5b6ffa);
        [_joinMicButton setTitle:MicLocalizedNamed(@"upMic") forState:(UIControlStateNormal)];
        [_joinMicButton addTarget:self action:@selector(didClickJoinMicButton) forControlEvents:(UIControlEventTouchUpInside)];
        _joinMicButton.layer.masksToBounds = YES;
        _joinMicButton.layer.cornerRadius = 2;
        _joinMicButton.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _joinMicButton;
}
@end
