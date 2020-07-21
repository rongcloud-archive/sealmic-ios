//
//  YHExcelView.m
//
//  Created by Yahui on 16/3/4.
//  Copyright © 2016年 Yahui. All rights reserved.
//  

#import "YHExcelView.h"
#import "UIView+YHCategory.h"

@interface YHExcelViewCell : UITableViewCell

- (void)setupViewWithexcelView:(YHExcelView *)excelView indexPath:(NSIndexPath *)indexPath  colViewPool:(NSMutableArray *) colViewPool;

@end

@interface YHExcelViewCell()
@property (nonatomic,weak)YHExcelView *excelView;
@property (nonatomic,weak)NSIndexPath *indexPath;
@end

@implementation YHExcelViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup {
}

- (void)setupViewWithexcelView:(YHExcelView *)excelView indexPath:(NSIndexPath *)indexPath colViewPool:(NSMutableArray *)colViewPool{
    if (self.excelView == nil ) {
        self.excelView = excelView;
    }
    _indexPath = indexPath;
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[YHExcelViewColumn class]]) {
            [colViewPool addObject:obj];
            [obj removeFromSuperview];
        }
    }];
    NSInteger columnCount = [excelView.dataSource excelView:excelView columnCountAtIndexPath:indexPath atSection:indexPath.section];
    for (NSInteger i = 0 ; i < columnCount ; i ++) {
        YHExcelViewColumn *column = [excelView.dataSource excelView:excelView columnForRowAtIndexPath:[YHExcelViewIndexPath indexPathForCol:i atIndexPath:indexPath]];
        column.index = i ;
        column.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
        column.contentView.layer.borderWidth = 0.5;
        [self.contentView addSubview:column];
    }
    
    [self setNeedsLayout];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    NSInteger columnCount = [self.excelView.dataSource excelView:self.excelView columnCountAtIndexPath:self.indexPath];
    NSMutableArray *colViewArray = [NSMutableArray array];
    for (YHExcelViewColumn *colView in self.contentView.subviews) {
        if ([colView isKindOfClass:[YHExcelViewColumn class]]) {
            if (colView.index < columnCount) {
                colView.hidden = NO;
                [colViewArray addObject:colView];
            }else {
                colView.hidden = YES;
            }
            
        }
    }
    NSArray *sortColArray = [colViewArray sortedArrayUsingComparator:^NSComparisonResult(YHExcelViewColumn   *obj1, YHExcelViewColumn  *obj2) {
        return [[NSNumber numberWithInteger:obj1.index] compare:[NSNumber numberWithInteger:obj2.index]];
    }];
    
    BOOL isCustomColWidth = NO ;
    if (self.excelView && [self.excelView.dataSource respondsToSelector:@selector(excelView:widthForColumnAtIndex:atSection:)]){
        isCustomColWidth = YES;
    }
    
    if (self.excelView.showBorder) {
        
    }
    
    CGFloat borderW = self.excelView.borderWidth ;
    if (!self.excelView.showBorder) {
        borderW = 0;
    }
    
    YHExcelViewColumn *tmpColView = nil ;
    for (YHExcelViewColumn *col in sortColArray) {
        col.yh_y = borderW;
        col.yh_height = self.yh_height - borderW;
        if (!isCustomColWidth) {
            col.yh_width = (self.yh_width / columnCount) - borderW - (borderW / columnCount);
        }else{
            col.yh_width = [self.excelView.dataSource excelView:self.excelView widthForColumnAtIndex:[YHExcelViewIndexPath indexPathForCol:col.index atIndexPath:self.indexPath ] atSection:col.section] - borderW - (borderW / columnCount);
        }
        if (tmpColView == nil) {
            col.yh_x = borderW;
        }else {
            col.yh_x = CGRectGetMaxX(tmpColView.frame) + borderW;
        }
        tmpColView = col;
        
    };
    
    
}

@end

@interface YHExcelView()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)NSMutableArray *colViewPool;
@property (nonatomic,strong)UIView *bottomBorder;
@end

@implementation YHExcelView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    _showBorder = YES;
//    _borderColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
    _borderColor = [UIColor whiteColor];
    _borderWidth = 1.0;
    _bottomBorder = [UIView new];
}

- (void)setShowBorder:(BOOL)showBorder {
    _showBorder = showBorder;
    _bottomBorder.hidden = !showBorder;
    [self reload];
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    [self reload];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth ;
    [self reload];
}

- (void)setTableViewFrame:(CGRect)tableViewFrame {
    _tableViewFrame = tableViewFrame;
    [self reload];
}

- (void)setDataSource:(id<YHExcelViewDataSource>)dataSource {
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollView];
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.scrollView addSubview:_tableView];
//    [self.tableView addSubview:_bottomBorder];
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0.01f)];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0.01f)];
    self.tableView.sectionHeaderHeight = 0;
    _dataSource = dataSource;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[YHExcelViewCell class] forCellReuseIdentifier:@"YHExcelViewCell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
}

#pragma mark - UITableViewDataSource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource excelView:self numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YHExcelViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YHExcelViewCell"];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];

    if (self.showBorder) {
//        cell..contentView.backgroundColor = self.borderColor;
//        cell.contentView.layer.borderColor = [UIColor redColor].CGColor;
//        cell.contentView.layer.borderWidth = 0.5;
    }else{
        cell.contentView.backgroundColor = nil;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;


    //取消点击效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setupViewWithexcelView:self indexPath:indexPath colViewPool:self.colViewPool];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInExcelView:)]) {
        return [self.dataSource numberOfSectionsInExcelView:self];
    }else {
        return 1;
    }
}

#pragma mark - public
- (YHExcelViewColumn *)dequeueReusableColumnWithIdentifier:(NSString *)identifier {
    YHExcelViewColumn *colView = nil;
    for (YHExcelViewColumn *tmpView in self.colViewPool) {
        if ([tmpView.reuseIdentifier isEqualToString:identifier]) {
            colView = tmpView;
            break;
        }
    }
    if (colView != nil) {
        [self.colViewPool removeObject:colView];
    }
    return colView;
}
- (void)reload {
    if (self.tableView != nil) {
        [self.tableView reloadData];
        [self setNeedsLayout];
    }
}

#pragma mark - layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = self.bounds;
    if (_tableViewFrame.size.width == 0) {
        _tableView.frame = self.bounds;
    }else{
        _tableView.frame = _tableViewFrame;
    }
    _scrollView.contentSize = CGSizeMake(self.tableView.yh_width, self.yh_height);
    _bottomBorder.yh_x = 0 ;
    _bottomBorder.yh_y =  self.tableView.contentSize.height ;
    _bottomBorder.yh_width = self.tableView.yh_width;
    _bottomBorder.yh_height = _borderWidth ;
    _bottomBorder.backgroundColor = _borderColor;
    [self.tableView bringSubviewToFront:_bottomBorder];
}

#pragma mark - getter 
- (NSMutableArray *)colViewPool {
    if (_colViewPool == nil) {
        _colViewPool = [NSMutableArray array];
    }
    return _colViewPool;
}

@end
