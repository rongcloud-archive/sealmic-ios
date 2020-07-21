//
//  YHExcelViewColumn.m
//
//  Created by Yahui on 16/3/4.
//  Copyright © 2016年 Yahui. All rights reserved.
//  column

#import "YHExcelViewColumn.h"
#import "UIView+YHCategory.h"

@interface YHExcelViewColumn()

@end

@implementation YHExcelViewColumn

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithReuseIdentifier:@"default"];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:CGRectZero]) {
        _reuseIdentifier = [reuseIdentifier copy];
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    _textLabel = [UILabel new];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_textLabel];
    _contentView = [UIView new];
//    if (self.section == 0) {
//        _contentView.frame = CGRectMake(-1, -1, self.bounds.size.width+2, self.bounds.size.height+2);
//    }else
        _contentView.frame = CGRectMake(-0.75, -0.75, self.bounds.size.width+1.5, self.bounds.size.height+1.5);
    
    
    
    _contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:_contentView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _textLabel.frame = self.bounds;
    _textLabel.backgroundColor = [UIColor clearColor];
//    if (self.section == 0) {
//        _contentView.frame = CGRectMake(-1, -1, self.bounds.size.width+2, self.bounds.size.height+2);
//    }else
        _contentView.frame = CGRectMake(-0.75, -0.75, self.bounds.size.width+1.5, self.bounds.size.height+1.5);
}

@end
