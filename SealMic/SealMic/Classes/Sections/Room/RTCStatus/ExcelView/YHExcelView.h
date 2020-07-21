//
//  YHExcelView.h
//
//  Created by Yahui on 16/3/4.
//  Copyright © 2016年 Yahui. All rights reserved.
//  

#import <UIKit/UIKit.h>
#import "YHExcelViewIndexPath.h"
#import "YHExcelViewColumn.h"

@class YHExcelView;
@protocol YHExcelViewDataSource <NSObject>

@required
//行数
- (NSInteger)excelView:(YHExcelView *)excelView numberOfRowsInSection:(NSInteger)section;
//某行的列数量
- (NSInteger)excelView:(YHExcelView *)excelView columnCountAtIndexPath:(NSIndexPath *)indexPath;
//colView
- (YHExcelViewColumn *)excelView:(YHExcelView *)excelView columnForRowAtIndexPath:(YHExcelViewIndexPath *)indexPath;

- (NSInteger)excelView:(YHExcelView *)excelView columnCountAtIndexPath:(NSIndexPath *)indexPath atSection:(NSInteger)section;

@optional
//组数
- (NSInteger)numberOfSectionsInExcelView:(YHExcelView *)excelView;
//列宽，默认按照列数等分
- (CGFloat)excelView:(YHExcelView *)excelView widthForColumnAtIndex:(YHExcelViewIndexPath *)indexPath atSection:(NSInteger)section;

@end

@interface YHExcelView : UIView

@property (nonatomic, weak) id <YHExcelViewDataSource> dataSource;
//不要设置tableView的dataSource，YHExcelViewDataSource继承自UITableViewDataSource
@property (nonatomic, readonly, strong) UIScrollView *scrollView;
@property (nonatomic, readonly, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL showBorder;//default YES
@property (nonatomic, strong) UIColor *borderColor;//default #eeeeee
@property (nonatomic, assign) CGFloat borderWidth;//default 1.0
@property (nonatomic, assign) CGRect tableViewFrame;//如果需要横向滚动，则需要设置

- (YHExcelViewColumn *)dequeueReusableColumnWithIdentifier:(NSString *)identifier;
- (void)reload;

@end
