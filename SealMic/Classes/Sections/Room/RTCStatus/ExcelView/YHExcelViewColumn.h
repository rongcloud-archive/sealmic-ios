//
//  YHExcelViewColumn.h
//
//  Created by Yahui on 16/3/4.
//  Copyright © 2016年 Yahui. All rights reserved.
//  column

#import <UIKit/UIKit.h>

@interface YHExcelViewColumn : UIView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
@property (nonatomic, readonly, strong) UILabel *textLabel;
@property (nonatomic, readonly, strong) UIView *contentView;
@property (nonatomic, readonly, copy) NSString *reuseIdentifier;
@property (nonatomic, assign)NSInteger index;
@property (nonatomic, assign) NSInteger section;

@end
