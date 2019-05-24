//
//  RoleUpdateMessageCell.m
//  SealMeeting
//
//  Created by 张改红 on 2019/3/13.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "TipMessageCell.h"
#import "MessageHelper.h"
#import "ClassroomService.h"
#import "RoomMemberChangedMessage.h"

@interface TipMessageCell ()
@property(nonatomic, strong) UIImageView *headerImage;
@property (nonatomic, strong) UILabel *infoLabel;
@end

@implementation TipMessageCell
#pragma mark - Super Api
-(void)loadSubView {
    [super loadSubView];
    [self.baseContainerView addSubview:self.headerImage];
    [self.baseContainerView addSubview:self.infoLabel];
}

- (void)setModel:(MessageModel *)model {
    [super setModel:model];
    [self setDataInView];
    [self setOrUpdateLayout];
}

#pragma mark - helper
- (void)setDataInView {
    RoomMemberChangedMessage *message = (RoomMemberChangedMessage *)self.model.message.content;
    self.headerImage.image = [RandomUtil randomPortraitFor:message.userId];
    self.infoLabel.text = [[MessageHelper sharedInstance] formatMessage:self.model.message.content];
}

- (void)setOrUpdateLayout {
    [self.headerImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.baseContainerView).offset(5);
        make.left.equalTo(self.baseContainerView).offset(15);
        make.height.width.offset(20);
    }];
    
    [self.infoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerImage.mas_right).offset(5);
        make.centerY.equalTo(self.baseContainerView);
        make.width.offset(self.model.contentSize.width);
        make.height.offset(self.model.contentSize.height);
    }];
}

#pragma mark - Getters and setters
- (UIImageView *)headerImage {
    if (!_headerImage) {
        _headerImage = [[UIImageView alloc] init];
        _headerImage.layer.masksToBounds = YES;
        _headerImage.layer.cornerRadius = 10;
    }
    return _headerImage;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:InfoTextFont];
        _infoLabel.textColor = [UIColor colorWithHexString:@"5E85FA" alpha:1];
        _infoLabel.numberOfLines = 0;
        _infoLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _infoLabel;
}
@end
