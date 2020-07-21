//
//  RCMicTextMessageCell.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicTextMessageCell.h"
#define MessageLabelMarginLeft 12
#define MessageLabelMarginTop 8
#define MessageLabelFont 12

@interface RCMicTextMessageCell()
@property (nonatomic, strong) UILabel *messageLabel;

@end
@implementation RCMicTextMessageCell

- (void)initSubviews {
    [super initSubviews];
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _messageLabel.font = RCMicFont(MessageLabelFont, nil);
    _messageLabel.textColor = RCMicColor(HEXCOLOR(0xffffff, 1.0), HEXCOLOR(0xffffff, 1.0));
    _messageLabel.numberOfLines = 0;
    _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.messageBackgroundView addSubview:_messageLabel];
}

- (void)addConstraints {
    [super addConstraints];
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.messageBackgroundView).with.offset(MessageLabelMarginLeft);
        make.right.lessThanOrEqualTo(self.messageBackgroundView.mas_right).with.offset(-MessageLabelMarginLeft);
        make.top.equalTo(self.messageBackgroundView).with.offset(MessageLabelMarginTop);
    }];
}

- (void)updateWithViewModel:(RCMicMessageViewModel *)viewModel {
    [super updateWithViewModel:viewModel];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[RCMicTextMessageCell finalStringWithViewModel:viewModel] attributes:@{NSFontAttributeName:RCMicFont(MessageLabelFont, nil), NSForegroundColorAttributeName:RCMicColor(HEXCOLOR(0xfefefe, 1.0), HEXCOLOR(0xfefefe, 1.0))}];
    [string addAttributes:@{NSForegroundColorAttributeName:RCMicColor([UIColor clearColor], [UIColor clearColor]), NSFontAttributeName:RCMicFont(MessageLabelFont, nil)} range:NSMakeRange(0, self.nameLabel.text.length)];
    self.messageLabel.attributedText = string;
}

#pragma mark - Private method
+ (NSString *)finalStringWithViewModel:(RCMicMessageViewModel *)viewModel {
    NSString *text = ((RCTextMessage *)viewModel.message.content).content;
    return [NSString stringWithFormat:@"%@：%@",viewModel.senderInfo.name,text];
}

#pragma mark - RCMicMessageCellHeightProvider
+ (CGFloat)contentHeightWithViewModel:(RCMicMessageViewModel *)viewModel {
    CGFloat maxWidth = MessageCellContentMaxWidth - MessageLabelMarginLeft * 2;
    CGRect textRect = [[self finalStringWithViewModel:viewModel] boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:RCMicFont(MessageLabelFont, nil)} context:nil];
    return textRect.size.height + MessageLabelMarginTop * 2 + MessageBaseCellTopExtra;
}
@end
