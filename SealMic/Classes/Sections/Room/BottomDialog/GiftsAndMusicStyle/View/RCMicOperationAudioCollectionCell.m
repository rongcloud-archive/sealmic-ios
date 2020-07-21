//
//  RCMicOperationAudioCollectionCell.m
//  SealMic
//
//  Created by rongyun on 2020/6/1.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicOperationAudioCollectionCell.h"
#import "RCMicMacro.h"

@implementation RCMicOperationAudioCollectionCell

#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
//        self.backgroundColor = [UIColor cyanColor];
    }
    return self;
}

#pragma mark - Private method
- (void)initSubviews {
    
    _operationTitleButton = [[UIButton alloc] init];
    [self addSubview:_operationTitleButton];
    
    [_operationTitleButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(22);
//        make.right.mas_equalTo(-22);
        make.width.mas_equalTo(78.5);
        make.centerX.equalTo(self);
        make.top.bottom.equalTo(self);
    }];
//    _operationTitleButton.backgroundColor = [UIColor blueColor];
//    [_operationTitleButton setTitle:@"test" forState:UIControlStateNormal];
    _operationTitleButton.layer.borderWidth = 0.5;
    _operationTitleButton.layer.cornerRadius = 21.5;
    [_operationTitleButton setEnabled:false];
//    _operationTitleButton.layer.borderColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1].CGColor;
    _operationTitleButton.titleLabel.font = RCMicFont(14, @"PingFangSC-Regular");
    _operationTitleButton.layer.borderColor = RCMicColor(HEXCOLOR(0xDCDCC8, 1.0), HEXCOLOR(0xDCDCC8, 1.0)).CGColor;
    
}

- (void)setDataDictionary:(NSDictionary *)dictionary {
    if (dictionary){
        [self.operationTitleButton setTitle:dictionary[@"title"] forState:UIControlStateNormal];
    }
}

@end
