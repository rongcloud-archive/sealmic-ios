//
//  RCMicMessageBaseCell.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicMessageBaseCell.h"
#import "RCMicMacro.h"
@interface RCMicMessageBaseCell()
@property (nonatomic, strong) UIImageView *messageBackgroundView;
@end
@implementation RCMicMessageBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubviews];
        [self addConstraints];
    }
    return self;
}

- (void)initSubviews {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentTapAction)];
    [self.contentView addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(contentLongPressAction:)];
    [self.contentView addGestureRecognizer:longPressGesture];
}

- (void)addConstraints {
}

- (void)updateWithViewModel:(RCMicMessageViewModel *)viewModel {
    self.viewModel = viewModel;
}

- (void)contentTapAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCell:didTapCellWithViewModel:)]) {
        [self.delegate messageCell:self didTapCellWithViewModel:self.viewModel];
    }
}

- (void)contentLongPressAction:(UILongPressGestureRecognizer *)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageCell:didLongPressCellWithViewModel:)]) {
            [self.delegate messageCell:self didLongPressCellWithViewModel:self.viewModel];
        }        
    }
}

#pragma mark - RCMicMessageCellHeightProvider
+ (CGFloat)contentHeightWithViewModel:(RCMicMessageViewModel *)viewModel {
    RCMicLog(@"RCMicMessageBaseCell 子类必须实现 contentHeightWithViewModel 方法 返回 cell 高度");
    return 0.0f;
}
@end
