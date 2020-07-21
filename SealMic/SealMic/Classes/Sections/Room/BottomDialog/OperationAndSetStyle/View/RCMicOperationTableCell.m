//
//  RCMicOperationTableCell.m
//  SealMic
//
//  Created by rongyun on 2020/5/29.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicOperationTableCell.h"
#import "RCMicMacro.h"
#import "RCMicEnumDialogDefine.h"

@implementation RCMicOperationTableCell

#pragma mark - Life cycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
        //取消点击选中cell改变背景颜色
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self initSubviews];
        [self addConstraints];
    }
    return self;
}

#pragma mark - Private method
- (void)initSubviews {
    _operationBtn = [[UIButton alloc] init];
    //默认值
    [_operationBtn setBackgroundImage:[UIImage imageNamed:@"select_box_bg"] forState:UIControlStateNormal];
    [_operationBtn.titleLabel setFont:RCMicFont(14, nil)];
    //使用cell触发事件
    _operationBtn.userInteractionEnabled = false;
    [self addSubview:_operationBtn];
}

- (void)addConstraints {
    [_operationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(23);
        make.right.mas_equalTo(-23);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(44);
    }];
}

@end
