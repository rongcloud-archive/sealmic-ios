//
//  BlinkExcelView.m
//  RongCloud
//
//  Created by Vicky on 2018/2/7.
//  Copyright © 2018年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "RCMicBlinkExcelView.h"
#import "YHExcel.h"
#import "UIView+YHCategory.h"
#import "RCMicChatLocalDataInfoModel.h"
#import "RCMicChatDataInfoModel.h"
#import "RCMicMacro.h"

#define ColumnCount_0 ((NSArray *)self.titleArray[0]).count > 0 ? ((NSArray *)self.titleArray[0]).count : 0
#define ColumnCount_1 ((NSArray *)self.dataArray[0]).count > 0 ? ((NSArray *)self.dataArray[0]).count : 0
@interface RCMicBlinkExcelView ()<YHExcelTitleViewDataSource,YHExcelViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) RCMicRoomViewModel *viewModel;
@property (strong, nonatomic) YHExcelTitleView *titleView;//表头
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSArray *colWidthArray;

@end

@implementation RCMicBlinkExcelView

- (instancetype)initWithFrame:(CGRect)frame viewModel:(id)viewModel {
    if (self == [super initWithFrame:frame]) {
        _viewModel = viewModel;
        [self configUI:frame];
    }
    return self;
}

- (void)setArray:(NSArray<NSArray *> *)array {
    _array = array;
    if (array.count > 1) {
        self.titleArray = [array[0] copy];
        self.dataArray = [array[1] copy];
        [self.excelView.tableView reloadData];
    }
}

- (void)configUI:(CGRect)framesize {
    self.excelView = [[YHExcelView alloc] initWithFrame:CGRectMake(15, 0, framesize.size.width-30.0, framesize.size.height)];
    [self addSubview:self.excelView];
     self.excelView.showBorder = YES;
    self.excelView.borderWidth = 1;
//    self.excelView.backgroundColor = [UIColor blackColor];
//        self.excelView.borderColor = [UIColor blueColor];
    self.titleArray = @[];
    self.dataArray = @[];

    //    self.colWidthArray = @[@(35.0),@(35.0),@(35.0),@(35.0),@(35.0),@(35.0),@(35.0)];
    
    //    self.excelView.tableViewFrame = CGRectMake(0, 0, 750, self.excelView.yh_height);//设置可横向滚动
    //    self.titleView.contentSize = CGSizeMake(0, 0);
    //    self.titleArray = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九"];
    //    self.colWidthArray = @[@(35.0),@(35.0),@(35.0),@(35.0),@(35.0),@(35.0),@(35.0),@(35.0),@(40.0)];
    //    self.titleView.dataSource = self;
    self.excelView.dataSource = self;
    self.excelView.tableView.delegate = self;
 
//    self.excelView.backgroundColor = [UIColor clearColor];
//    self.excelView.tableView.backgroundColor = [UIColor clearColor];
    //    self.excelView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    self.excelView.tableView.separatorColor = [UIColor clearColor];
    self.excelView.tableView.layer.borderWidth=1.0;
    self.excelView.tableView.layer.borderColor=[[UIColor clearColor]CGColor];
    self.excelView.tableView.showsVerticalScrollIndicator = NO;
    //表头 与 表内容 同时滚动
    [self.titleView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld  context:nil];
    [self.excelView.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    self.excelView.tableView.showsHorizontalScrollIndicator = NO;
    [self.excelView.tableView reloadData];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tapGesture];
}

- (void)tapAction {
    self.hidden = YES;
    self.viewModel.debugDisplay = NO;
}

#pragma mark - YHExcelTitleViewDataSource
- (NSInteger)excelTitleViewItemCount:(YHExcelTitleView *)titleView {
    return self.titleArray.count;
}

- (NSString *)excelTitleView:(YHExcelTitleView *)titleView titleNameAtIndex:(NSInteger)index {
    return self.titleArray[index];
}

- (CGFloat)excelTitleView:(YHExcelTitleView *)titleView widthForItemAtIndex:(NSInteger)index
{
    //    return [self.colWidthArray[index] doubleValue] * ([UIScreen mainScreen].bounds.size.width/320);
    if (index == 0) {
        return  3;
    }else
        return  (self.excelView.frame.size.width/7);
}

#pragma mark - YHExcelViewDataSource
- (NSInteger)excelView:(YHExcelView *)excelView columnCountAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return ColumnCount_0;
    }
    return ColumnCount_1;
}
- (NSInteger)excelView:(YHExcelView *)excelView columnCountAtIndexPath:(NSIndexPath *)indexPath atSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    return 5;
}

- (CGFloat)excelView:(YHExcelView *)excelView widthForColumnAtIndex:(YHExcelViewIndexPath *)indexPath atSection:(NSInteger)section {
    if (section == 0) {
        NSInteger columnCount = ColumnCount_0 > 0 ? ColumnCount_0 : 1;
        return self.excelView.frame.size.width/columnCount;
    }
    NSInteger columnCount = ColumnCount_1 > 0 ? ColumnCount_1 : 1;
    return  (self.excelView.frame.size.width/columnCount);
}

- (YHExcelViewColumn *)excelView:(YHExcelView *)excelView columnForRowAtIndexPath:(YHExcelViewIndexPath *)indexPath {
    YHExcelViewColumn *col = [excelView dequeueReusableColumnWithIdentifier:@"col"];
    if (col == nil) {
        col = [[YHExcelViewColumn alloc] initWithReuseIdentifier:@"col"];
        col.textLabel.font = [UIFont systemFontOfSize:10];
    }
    if (indexPath.row == 0 && [self.titleArray count]) {
        NSArray *titles = self.titleArray[0];
        if (indexPath.section == 1 && [self.dataArray count]) {
            titles = self.dataArray[0];
        }
        if ([titles count]) {
            col.textLabel.text = titles[indexPath.col];
        }
        col.backgroundColor = [UIColor clearColor];
        col.section = indexPath.section;
        return col;
    }
    if (indexPath.section == 0 && indexPath.row != 0 && [self.titleArray count]) {
        
        RCMicChatLocalDataInfoModel *localModel = (RCMicChatLocalDataInfoModel *)self.titleArray[indexPath.row];
        switch (indexPath.col) {
            case 0:
                col.textLabel.text = localModel.channelName;
                break;
            case 1:
                col.textLabel.text = localModel.codeRate;
                break;
            case 2:
                col.textLabel.text = localModel.delay;
                break;
            default:
                break;
        }
        
    }else if (indexPath.row != 0 && [self.dataArray count]){
        RCMicChatDataInfoModel *info = (RCMicChatDataInfoModel *)self.dataArray[indexPath.row];
        switch (indexPath.col) {
            case 0:
                col.textLabel.text = info.userName;
                break;
            case 1:
                col.textLabel.text = info.tunnelName;
                break;
            case 2:
                col.textLabel.text = info.codec;
                break;
            case 3:
                col.textLabel.text = info.codeRate;
                break;
            case 4:
                col.textLabel.text = info.lossRate;
                break;
            default:
                break;
        }
    }
    col.backgroundColor = [UIColor clearColor];
    col.section = indexPath.section;
    return col;
}

- (NSInteger)numberOfSectionsInExcelView:(YHExcelView *)excelView {
    return self.array.count;
}

- (NSInteger)excelView:(YHExcelView *)excelView numberOfRowsInSection:(NSInteger)section {
    if (self.array.count > section) {
        return self.array[section].count;
    }
    return self.array.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [UIView new];
    //    headerView.backgroundColor = [UIColor brownColor];
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, tableView.frame.size.width, 44.0)];
    [headerView addSubview:titleLable];
    titleLable.textColor = [UIColor whiteColor];
    if (section == 0) {
        titleLable.text = RCMicLocalizedNamed(@"network_detection");
        
    }else{
        titleLable.text = RCMicLocalizedNamed(@"participants");
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 64;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    if (scrollView == self.excelView.tableView)
    //    {
    //        CGFloat sectionHeaderHeight = 64;
    //        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
    //            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    //        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
    //            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    //        }
    //    }
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    CGPoint old = [change[@"old"] CGPointValue];
    CGPoint new = [change[@"new"] CGPointValue];
    if (old.x == new.x) {
        return;
    }
    //    if (object == self.titleView) {
    //        self.excelView.scrollView.contentOffset = CGPointMake(new.x, 0);
    //    }else if(object == self.excelView.scrollView){
    //        self.titleView.contentOffset = CGPointMake(new.x, 0);
    //    }
}

- (void)dealloc {
    [self.titleView removeObserver:self forKeyPath:@"contentOffset"];
    [self.excelView.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

@end
