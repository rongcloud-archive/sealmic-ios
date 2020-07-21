//
//  YBFIndexListTitleView.m
//
//  Created by Yahui on 16/3/4.
//  Copyright © 2016年 Yahui. All rights reserved.
//  

#import "YHExcelTitleView.h"
#import "UIView+YHCategory.h"


@interface YHExcelTitleView()
@property (nonatomic, assign)NSInteger itemCount;
@end

@implementation YHExcelTitleView

#pragma mark - init
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupSubView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubView];
    }
    return self;
}

#pragma mark - setter
- (void)setupSubView {
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.titleFont = [UIFont systemFontOfSize:13];
    self.titleColor = [UIColor grayColor];
    self.titleAlignment = NSTextAlignmentCenter;
}

- (void)setDataSource:(id<YHExcelTitleViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self reload];
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    if (self.dataSource != nil) {
        [self reload];
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    if (self.dataSource != nil) {
        [self reload];
    }
}

- (void)setTitleAlignment:(NSTextAlignment)titleAlignment {
    _titleAlignment = titleAlignment;
    if (self.dataSource != nil) {
        [self reload];
    }
}


#pragma mark - layoutSubview
- (void)reload {
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    if (_dataSource != nil) {
        _itemCount = [_dataSource excelTitleViewItemCount:self];
        for (NSInteger i = 0 ; i < _itemCount ; i++) {
            [self createItemWithIndex:i];
        }
    }else{
        NSLog(@"错误dataSource为空");
    }
    [self setNeedsLayout];
}

- (void)createItemWithIndex:(NSInteger)index {
    UILabel *label = [UILabel new];
    label.tag = index;
    NSString *title = [_dataSource excelTitleView:self titleNameAtIndex:index];
    label.text = title;
    if (_dataSource != nil  && [_dataSource respondsToSelector:@selector(excelTitleView:titleFontAtIndex:)]) {
        label.font = [_dataSource excelTitleView:self titleFontAtIndex:index];
    }else{
        label.font = self.titleFont;
    }
    if (_dataSource != nil  && [_dataSource respondsToSelector:@selector(excelTitleView:titleColorAtIndex:)]) {
        label.textColor = [_dataSource excelTitleView:self titleColorAtIndex:index];
    }else{
        label.textColor = self.titleColor;
    }
    if (_dataSource != nil  && [_dataSource respondsToSelector:@selector(excelTitleView:titleAlignmentAtIndex:)]) {
        label.textAlignment = [_dataSource excelTitleView:self titleAlignmentAtIndex:index];
    }else{
        label.textAlignment = self.titleAlignment;
    }
    [self addSubview:label];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    BOOL isCustomItemWidth = NO ;
    if (_dataSource != nil  && [_dataSource respondsToSelector:@selector(excelTitleView:widthForItemAtIndex:)]) {
        isCustomItemWidth = YES ;
    }
    CGFloat defaultWidth = self.yh_width / _itemCount;
    for (NSInteger i = 0 ; i < self.subviews.count ; i++) {
        UILabel *label = self.subviews[i];
        if (![label isKindOfClass:[UILabel class]]) {
            continue;
        }
        NSInteger index = label.tag;
        label.yh_height = self.yh_height;
        if (isCustomItemWidth){
            label.yh_width = [_dataSource excelTitleView:self widthForItemAtIndex:index];
            CGFloat x = 0;
            for (NSInteger j = 0 ; j < index; j ++) {
                x += [_dataSource excelTitleView:self widthForItemAtIndex:j];
            }
            label.yh_x = x;
        }else{
            label.yh_width = defaultWidth;
            label.yh_x = index * defaultWidth;
        }
    }
    
}



@end
