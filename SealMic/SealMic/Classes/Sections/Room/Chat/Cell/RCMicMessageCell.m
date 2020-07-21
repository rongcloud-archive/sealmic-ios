//
//  RCMicMessageCell.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicMessageCell.h"
#define MessageBackgroundMarginLeft 12
#define NameLabelMarginLeft 12
#define NameLabelMarginTop 8
#define NameLabelHeight 17

@implementation RCMicMessageCell

- (void)initSubviews {
    [super initSubviews];
    _messageBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    _messageBackgroundView.backgroundColor = RCMicColor(HEXCOLOR(0x000000, 0.3), HEXCOLOR(0x000000, 0.3));
    _messageBackgroundView.layer.cornerRadius = 6;
    [self.contentView addSubview:_messageBackgroundView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.textColor = RCMicColor(HEXCOLOR(0xcfcfcf, 1.0), HEXCOLOR(0xcfcfcf, 1.0));
    _nameLabel.font = RCMicFont(12, nil);
    [_messageBackgroundView addSubview:_nameLabel];
}

- (void)addConstraints {
    [super addConstraints];
    [_messageBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(MessageBackgroundMarginLeft);
        make.width.mas_lessThanOrEqualTo(MessageCellContentMaxWidth);
        make.top.equalTo(self.contentView).with.offset(MessageBaseCellTopExtra);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_messageBackgroundView).with.offset(NameLabelMarginLeft);
        make.left.lessThanOrEqualTo(_messageBackgroundView.mas_right).with.offset(NameLabelMarginLeft);
        make.top.equalTo(_messageBackgroundView).with.offset(NameLabelMarginTop);
        make.height.mas_equalTo(NameLabelHeight);
    }];
}

- (void)updateWithViewModel:(RCMicMessageViewModel *)viewModel {
    [super updateWithViewModel:viewModel];
    self.nameLabel.text = [NSString stringWithFormat:@"%@：",viewModel.senderInfo.name];
}

#pragma mark - RCMicMessageCellHeightProvider
+ (CGFloat)contentHeightWithViewModel:(RCMicMessageViewModel *)viewModel {
    RCMicLog(@"RCMicMessageCell 子类必须实现 contentHeightWithViewModel 方法 返回 cell 高度");
    return 0.0f;
}
@end
