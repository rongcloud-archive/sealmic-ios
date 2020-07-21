//
//  RCMicOperationSwitchTableCell.m
//  SealMic
//
//  Created by rongyun on 2020/6/1.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicOperationSwitchTableCell.h"
#import "RCMicMacro.h"

@implementation RCMicOperationSwitchTableCell

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
    _bgImageView = [[UIImageView alloc] init];
    _bgImageView.image = [UIImage imageNamed:@"select_box_bg"];
    //如果有点击事件加在图片视图上面，需要开启
    _bgImageView.userInteractionEnabled = true;
    [self addSubview:_bgImageView];
    
    _operationTitleLabel = [[UILabel alloc] init];
    //    _operationTitleLabel.text = RCMicLocalizedNamed(@"turn_on_debug_mode");
    //    _operationTitleLabel.textColor = [UIColor whiteColor];
    _operationTitleLabel.font = RCMicFont(14, @"PingFangSC-Regular");
    _operationTitleLabel.textColor = RCMicColor([UIColor whiteColor], [UIColor whiteColor]);
    [_bgImageView addSubview:_operationTitleLabel];
    
    _operationSwitchBtn = [[UIButton alloc] init];
    //    _operationSwitchBtn.backgroundColor = [UIColor cyanColor];
    [_operationSwitchBtn setBackgroundImage:[UIImage imageNamed:@"switch_btn_open"] forState:UIControlStateSelected];
    [_operationSwitchBtn setBackgroundImage:[UIImage imageNamed:@"switch_btn_close"] forState:UIControlStateNormal];
    _operationSwitchBtn.contentMode = UIViewContentModeScaleAspectFill;
    [_operationSwitchBtn addTarget:self action:@selector(changeSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_bgImageView addSubview:_operationSwitchBtn];
}

- (void)changeSwitchBtn:(UIButton *)switchBtn {
    self.operationSwitchBtn.selected = !switchBtn.selected;
    if (self.changeSwitchBtnBlock){
        // key 根据情况改成字符
        self.changeSwitchBtnBlock(switchBtn, self.operationTitleLabel.text);
    }
}

- (void)addConstraints {
    [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(23);
        make.right.mas_equalTo(-23);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(44);
    }];
    
    [_operationTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(18);
        make.right.mas_equalTo(40);
        make.centerY.equalTo(_bgImageView);
        make.height.mas_equalTo(22);
    }];
    
    [_operationSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-12);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(26);
        make.width.mas_equalTo(41);
    }];
}

//- (void)setDataDictionary:(NSDictionary *)dictionary {
//    if (dictionary){
//        self.operationTitleLabel.text = dictionary[@"title"];
//        //bool取值的时候要转一下
//        NSNumber * boolNum = dictionary[@"isOpen"];
//        BOOL isOn = [boolNum boolValue];
//        self.operationSwitchBtn.selected = isOn;
//    }
//}

@end
