//
//  MessageBaseCell.m
//  SealMeeting
//
//  Created by 张改红 on 2019/3/6.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "MessageBaseCell.h"

@implementation MessageBaseCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self loadSubView];
    }
    return self;
}

- (void)loadSubView {
    [self.contentView addSubview:self.baseContainerView];
}

#pragma mark - Api
- (void)setDataModel:(MessageModel *)model{
    self.model = model;
    [self.baseContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(0);
        make.bottom.equalTo(self.contentView).offset(0);
        make.right.equalTo(self.contentView).offset(0);
        make.left.equalTo(self.contentView).offset(0);
    }];
}

#pragma mark - Getters & setters
- (UIView *)baseContainerView {
    if (!_baseContainerView) {
        _baseContainerView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    }
    return _baseContainerView;
}
@end
