//
//  MessageCell.m
//  SealMeeting
//
//  Created by 张改红 on 2019/3/6.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "MessageCell.h"
#import "Masonry.h"
#import "ClassroomService.h"
#import "UserInfo.h"
@interface MessageCell()
@property (nonatomic, strong) UIImageView *bubbleBackgroundView;
@property (nonatomic, strong) UIImageView *headerImage;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *sendStatusContentView;
@property (nonatomic, strong) UIActivityIndicatorView *sendIndicatorView;
@property (nonatomic, strong) UIButton *sendFailView;
@end
@implementation MessageCell
#pragma mark - Super Api
- (void)loadSubView{
    [super loadSubView];
    [self.baseContainerView addSubview:self.headerImage];
    [self.baseContainerView addSubview:self.nameLabel];
    [self.baseContainerView addSubview:self.messageContentView];
    [self.baseContainerView addSubview:self.sendStatusContentView];
    [self.messageContentView addSubview:self.bubbleBackgroundView];
}

- (void)setDataModel:(MessageModel *)model {
    [super setDataModel:model];
    [self setOrUpdateLayout];
    [self setDataInView];
    [self updateSentStatus];
}

#pragma mark - Api
- (void)updateSentStatus {
    switch (self.model.message.sentStatus) {
        case SentStatus_SENDING:
            [self showSendIndicatorView:YES];
            break;
        case SentStatus_FAILED:
            [self showSendIndicatorView:NO];
            [self showSendFailView];
            break;
        case SentStatus_SENT:
            [self showSendIndicatorView:NO];
            [self hidenSendFailView];
            break;
        default:
            break;
    }
    NSLog(@"rcim updateSentStatus %@",@(self.model.message.sentStatus));
}

#pragma mark - Helper
- (void)setDataInView{
    self.nameLabel.text = [RandomUtil randomNameFor:self.model.message.senderUserId];
    self.headerImage.image = [RandomUtil randomPortraitFor:self.model.message.senderUserId];
}

- (void)showSendIndicatorView:(BOOL)show{
    [self.sendIndicatorView removeFromSuperview];
    [self.sendIndicatorView stopAnimating];
    if (show) {
        [self.sendStatusContentView addSubview:self.sendIndicatorView];
        [self.sendIndicatorView startAnimating];
    }
}

- (void)showSendFailView{
    [self.sendStatusContentView addSubview:self.sendFailView];
}

- (void)hidenSendFailView{
   [self.sendFailView removeFromSuperview];
}

- (void)setOrUpdateLayout{
    
    [self.bubbleBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.messageContentView);
    }];
    
    [self.headerImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.baseContainerView).offset(5);
        make.left.equalTo(self.baseContainerView).offset(15);
        make.height.width.offset(20);
    }];
    
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerImage.mas_top).offset(0);
        make.left.equalTo(self.headerImage.mas_right).offset(5);
        make.height.offset(14);
        make.width.offset(200);
    }];
    
    [self.messageContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(4);
        make.bottom.equalTo(self.baseContainerView.mas_bottom).offset(-5);
        make.left.equalTo(self.headerImage.mas_right).offset(5);
        make.width.offset(self.model.contentSize.width);
    }];
    
    [self.sendStatusContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.messageContentView);
        make.left.equalTo(self.messageContentView.mas_right).offset(10);
        make.width.height.offset(25);
    }];
}

#pragma mark - Getters & setters
- (UIView *)messageContentView{
    if (!_messageContentView) {
        _messageContentView = [[UIView alloc] init];
    }
    return _messageContentView;
}

- (UIImageView *)bubbleBackgroundView {
    if (!_bubbleBackgroundView) {
        _bubbleBackgroundView = [[UIImageView alloc] init];
        _bubbleBackgroundView.userInteractionEnabled = YES;
        UIImage *image = [UIImage imageNamed:@"messageBg"];
        self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.4, image.size.height * 0.4, image.size.width * 0.8)];
    }
    return _bubbleBackgroundView;
}

- (UIImageView *)headerImage{
    if (!_headerImage) {
        _headerImage = [[UIImageView alloc] init];
        _headerImage.layer.masksToBounds = YES;
        _headerImage.layer.cornerRadius = 10;
    }
    return _headerImage;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:10];
        _nameLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
    }
    return _nameLabel;
}

- (UIView *)sendStatusContentView{
    if (!_sendStatusContentView) {
        _sendStatusContentView = [[UIView alloc] init];
    }
    return _sendStatusContentView;
}

- (UIActivityIndicatorView *)sendIndicatorView{
    if (!_sendIndicatorView) {
        _sendIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _sendIndicatorView.frame = CGRectMake(0, 0, 25, 25);
    }
    return _sendIndicatorView;
}

- (UIButton *)sendFailView{
    if (!_sendFailView) {
        _sendFailView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [_sendFailView setImage:[UIImage imageNamed:@"sendMsg_failed_tip"] forState:UIControlStateNormal];
    }
    return _sendFailView;
}
@end
