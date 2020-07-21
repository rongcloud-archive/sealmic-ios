//
//  RCMicGiftMessageCell.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/18.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicGiftMessageCell.h"
#import "RCMicMacro.h"

#define ContentMaxWidth (RCMicScreenWidth * 0.7)
#define MessageLabelFont 12
@interface RCMicGiftMessageCell()
@property (nonatomic, strong) UILabel *messageLabel;
@end
@implementation RCMicGiftMessageCell

- (void)initSubviews {
    [super initSubviews];
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _messageLabel.font = RCMicFont(MessageLabelFont, nil);
    _messageLabel.textColor = RCMicColor(HEXCOLOR(0xf8e71c, 1.0), HEXCOLOR(0xf8e71c, 1.0));
    _messageLabel.numberOfLines = 0;
    [self.contentView addSubview:_messageLabel];
}

- (void)addConstraints {
    [super addConstraints];
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(12);
        make.top.equalTo(self.contentView).with.offset(MessageBaseCellTopExtra);
        make.width.mas_lessThanOrEqualTo(ContentMaxWidth);
    }];
}

- (void)updateWithViewModel:(RCMicMessageViewModel *)viewModel {
    [super updateWithViewModel:viewModel];
    self.messageLabel.text = [RCMicGiftMessageCell finalStringWithViewModel:viewModel];
}

#pragma mark - Private method
+ (NSString *)finalStringWithViewModel:(RCMicMessageViewModel *)viewModel {
    RCMicGiftMessage *giftMessage = (RCMicGiftMessage *)viewModel.message.content;
    return [NSString stringWithFormat:@"%@%@",giftMessage.senderUserInfo.name,giftMessage.content];
}

#pragma mark - RCMicMessageCellHeightProvider
+ (CGFloat)contentHeightWithViewModel:(RCMicMessageViewModel *)viewModel {
    CGRect textRect = [[RCMicGiftMessageCell finalStringWithViewModel:viewModel] boundingRectWithSize:CGSizeMake(ContentMaxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:RCMicFont(MessageLabelFont, nil)} context:nil];
    return textRect.size.height + MessageBaseCellTopExtra;
}
@end
