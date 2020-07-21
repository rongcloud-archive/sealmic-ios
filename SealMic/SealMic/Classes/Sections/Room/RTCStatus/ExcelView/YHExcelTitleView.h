//
//  YHExcelTitleView.h
//
//  Created by Yahui on 16/3/4.
//  Copyright © 2016年 Yahui. All rights reserved.
//  

#import <UIKit/UIKit.h>

@class YHExcelTitleView;

@protocol YHExcelTitleViewDataSource <NSObject>
//必须
@required
//列数
- (NSInteger)excelTitleViewItemCount:(YHExcelTitleView *)titleView;
//标题文字
- (NSString *)excelTitleView:(YHExcelTitleView *)titleView titleNameAtIndex:(NSInteger)index;

//可选
@optional
//列宽，默认按照列数等分
- (CGFloat)excelTitleView:(YHExcelTitleView *)titleView widthForItemAtIndex:(NSInteger)index;
//标题字体
- (UIFont *)excelTitleView:(YHExcelTitleView *)titleView titleFontAtIndex:(NSInteger)index;
//标题颜色 
- (UIColor *)excelTitleView:(YHExcelTitleView *)titleView titleColorAtIndex:(NSInteger)index;
//对齐方式
- (NSTextAlignment)excelTitleView:(YHExcelTitleView *)titleView titleAlignmentAtIndex:(NSInteger)index;

@end

@interface YHExcelTitleView : UIScrollView

@property (weak,nonatomic)id<YHExcelTitleViewDataSource> dataSource;
@property (strong,nonatomic)UIFont *titleFont;//default [UIFont systemFontOfSize:13]
@property (strong,nonatomic)UIColor *titleColor;//default #333333
@property (assign,nonatomic)NSTextAlignment titleAlignment;//default NSTextAlignmentCenter

- (void)reload;

@end
