//
//  RCMicBottomDialogScrollPageViewController.m
//  SealMic
//
//  Created by rongyun on 2020/6/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicBottomDialogScrollPageViewController.h"
#import "SGPageTitleView.h"
#import "SGPageTitleViewConfigure.h"
#import "SGPageContentScrollView.h"
#import "RCMicOnLineViewController.h"
#import "RCMicRankMicViewController.h"
#import "RCMicBannedViewController.h"
#import "RCMicMacro.h"
#import "RCMicAppService.h"

@interface RCMicBottomDialogScrollPageViewController ()<SGPageContentScrollViewDelegate,SGPageTitleViewDelegate>
{
    CGFloat PersonalCenterVCPageTitleViewHeight;
    CGFloat PersonalCenterVCNavHeight;
    CGFloat PersonalCenterVCTopViewHeight;
}
/// 弹框背景图片视图
@property (nonatomic, strong) UIImageView *bgImageView;
/// 选择标签菜单视图
@property (nonatomic, strong) SGPageTitleView *pageTitleView;
/// 选择标签内容视图
@property (nonatomic, strong) SGPageContentScrollView *pageContentView;
/// 选择标签标题
@property (nonatomic, copy) NSArray<NSString *> *titles;
/// 点击消失弹框按钮
@property (nonatomic, strong) UIButton *dismissBtn;

@end

@implementation RCMicBottomDialogScrollPageViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置类似遮罩的视图背景颜色
    self.view.backgroundColor = [UIColor colorWithRed:3/255.0f green:6/255.0f blue:47/255.0f alpha:0.5];
    //弹框背景图片视图
    [self.view addSubview:self.bgImageView];
    //点击消失弹框
    [self.view addSubview:self.dismissBtn];
    //配置选择控制器标题 （如果某个角色不需要显示某个列表 可以在这里进行配置）
    self.titles = [NSMutableArray arrayWithArray:@[RCMicLocalizedNamed(@"dialog_online_list"),
                                                   RCMicLocalizedNamed(@"dialog_ranking_mic_list"),
                                                   RCMicLocalizedNamed(@"dialog_Banned_list")]];
    //添加选择控制器标签标题
    [self.view addSubview:self.pageTitleView];
    //添加选择控制器滚动内容
    [self.view addSubview:self.pageContentView];
    //添加布局约束
    [self addConstraints];
    //根据需求显示对应的默认列表
    [self.pageTitleView setSelectedIndex:self.listType];
}

#pragma mark - Action
- (void)dismissAction {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Private method
- (void)addConstraints {
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        //底部超出12圆角位置，只显示左上右上圆角
        make.bottom.mas_equalTo(12);
        make.height.mas_equalTo(459 + 12);
    }];
    
    [self.dismissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.bottom.equalTo(self.bgImageView.mas_top);
    }];
    
    [self.pageTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgImageView).offset(19);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(30);
    }];
    
    [self.pageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pageTitleView).offset(51);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(600);
    }];
    
}

#pragma mark - - - SGPageTitleViewDelegate - SGPageContentViewDelegate
- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex {
    [self.pageContentView setPageContentScrollViewCurrentIndex:selectedIndex];
}

- (void)pageContentScrollView:(SGPageContentScrollView *)pageContentScrollView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex {
    [self.pageTitleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
}

#pragma mark - Getters & Setters
- (UIImageView *)bgImageView {
    if(!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        //默认值
        _bgImageView.image = [UIImage imageNamed:@"alert_bottom_bg"];
        _bgImageView.layer.cornerRadius = 12;
        _bgImageView.clipsToBounds = true;
        //        _bgImageView.backgroundColor = [UIColor cyanColor];
    }
    return _bgImageView;
}

- (UIButton *)dismissBtn {
    if (!_dismissBtn) {
        _dismissBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_dismissBtn addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissBtn;
}

- (SGPageTitleView *)pageTitleView {
    if (!_pageTitleView) {
        SGPageTitleViewConfigure *configure = [SGPageTitleViewConfigure pageTitleViewConfigure];
        configure.indicatorAdditionalWidth = 3;
        configure.indicatorFixedWidth = 3;
        configure.indicatorDynamicWidth = 3;
        //        configure.bottomSeparatorColor = [UIColor clearColor];
        configure.bottomSeparatorColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
        //        configure.titleColor = [UIColor lightGrayColor];
        configure.titleColor = RCMicColor([UIColor lightGrayColor], [UIColor lightGrayColor]);
        configure.titleSelectedColor = RCMicColor(HEXCOLOR(0x2DF3C1, 1.0), HEXCOLOR(0x2DF3C1, 1.0));
        configure.titleFont = RCMicFont(17, nil);
        configure.indicatorColor = RCMicColor(HEXCOLOR(0x2DF3C1, 1.0), HEXCOLOR(0x2DF3C1, 1.0));
        //        configure.titleSelectedColor = [UIColor colorWithRed:45/255.0f green:243/255.0f blue:193/255.0f alpha:1];
        //        configure.indicatorColor = [UIColor colorWithRed:45/255.0f green:243/255.0f blue:193/255.0f alpha:1];
        /// pageTitleView
        _pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(8, 0, self.view.frame.size.width, 50) delegate:self titleNames:self.titles configure:configure];
        //        _pageTitleView.backgroundColor = [UIColor clearColor];
        _pageTitleView.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
        _pageTitleView.layer.mask = nil;
        
    }
    return _pageTitleView;
}

- (SGPageContentScrollView *)pageContentView {
    if (!_pageContentView) {
        RCMicOnLineViewController *onLineVC = [[RCMicOnLineViewController alloc] init];
        onLineVC.viewModel = self.viewModel;
        
        RCMicRankMicViewController *rankMicVC = [[RCMicRankMicViewController alloc] init];
        rankMicVC.viewModel = self.viewModel;
        
        RCMicBannedViewController *bannedVC = [[RCMicBannedViewController alloc] init];
        bannedVC.viewModel = self.viewModel;
        NSArray *childArr = @[onLineVC, rankMicVC,bannedVC];
        _pageContentView = [[SGPageContentScrollView alloc] initWithFrame:CGRectZero parentVC:self childVCs:childArr];
        _pageContentView.delegatePageContentScrollView = self;
        //        _pageContentView.backgroundColor = [UIColor clearColor];
        _pageContentView.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
        
    }
    return _pageContentView;
}

@end
