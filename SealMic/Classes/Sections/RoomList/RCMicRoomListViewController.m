//
//  RCMicRoomListViewController.m
//  SealMic
//
//  Created by lichenfeng on 2020/5/21.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicRoomListViewController.h"
#import <MJRefresh/MJRefresh.h>
#import "RCMicRoomListViewModel.h"
#import "RCMicRoomCell.h"
#import "RCMicRoomCreateCell.h"
#import "RCMicActiveWheel.h"
#import "RCMicLoginViewController.h"
#import "RCMicRoomViewController.h"
#import "RCMicCreateRoomViewController.h"
#import <SDWebImage/SDWebImage.h>
#import "RCMicAppService.h"

#define MicRoomListCell @"MicRoomListCell"
#define MicRoomListCreateCell @"MicRoomListCreateCell"
#define ItemPadding 12
#define ItemMarginLeftRight 21.5
@interface RCMicRoomListViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *roomListView;
@property (nonatomic, strong) RCMicRoomListViewModel *viewModel;
@property (nonatomic, strong) UIView *customNavigationBar;
@property (nonatomic, strong) UILabel *titleLabel;//标题
@property (nonatomic, strong) UIImageView *portraitView;//头像
@property (nonatomic, strong) UIButton *loginButton;//登录按钮
@end

@implementation RCMicRoomListViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RCMicColor([UIColor whiteColor], [UIColor whiteColor]);
    [self.customNavigationBar addSubview:self.titleLabel];
    [self.customNavigationBar addSubview:self.loginButton];
    [self.customNavigationBar addSubview:self.portraitView];
    [self.view addSubview:self.customNavigationBar];
    [self.view addSubview:self.roomListView];
    [self addConstraints];
    [self addNotificationObserver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showPortraitWhenUserLogin];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private method
- (void)addConstraints {
    [self.customNavigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat margin = [RCMicUtil statusBarHeight];
        make.top.equalTo(self.view).with.offset(margin);
        make.height.mas_equalTo(44);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.customNavigationBar);
        make.width.mas_equalTo(80);
        make.height.equalTo(self.customNavigationBar);
    }];
    
    [self.portraitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.customNavigationBar);
        make.right.equalTo(self.customNavigationBar).with.offset(-16);
        make.width.mas_equalTo(32);
        make.height.mas_equalTo(32);
    }];

    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.customNavigationBar);
        make.right.equalTo(self.customNavigationBar).with.offset(-16);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(32);
    }];
    
    [self.roomListView mas_makeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets padding = UIEdgeInsetsMake([RCMicUtil topSafeAreaHeight], 0, 0, 0);
        make.edges.equalTo(self.view).with.insets(padding);
    }];
}

- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserLogin) name:RCMicLoginSuccessNotification object:nil];
}

- (void)showPortraitWhenUserLogin {
    RCMicCachedUserInfo *cachedInfo = [RCMicAppService sharedService].currentUser;
    if (cachedInfo.userInfo.type == RCMicUserTypeNormal) {
        self.loginButton.hidden = YES;
        self.portraitView.hidden = NO;
        [self.portraitView sd_setImageWithURL:[NSURL URLWithString:cachedInfo.userInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"room_portrait_temp"]];
    } else {
        self.loginButton.hidden = NO;
        self.portraitView.hidden = YES;
    }
}

- (void)refreshRoomList:(BOOL)isDropDown {
    RCMicRoomListRefreshType refreshType = isDropDown ? RCMicRoomListRefreshTypeDropDown : RCMicRoomListRefreshTypePull;
    MJRefreshComponent *component = isDropDown ? self.roomListView.mj_header : self.roomListView.mj_footer;
    [self.viewModel refreshRoomListWithOperation:refreshType success:^{
        RCMicMainThread(^{
            [component endRefreshing];
        })
    } error:^(RCMicHTTPCode errorCode) {
       RCMicMainThread(^{
           [component endRefreshing];
           [RCMicUtil showTipWithErrorCode:errorCode];
        })
    }];
}

- (void)updateRoomListWithType:(RCMicRoomListChangedType)type index:(NSIndexPath *)indexPath {
    if (type == RCMicRoomListChangedTypeReloadAll) {
        [self.roomListView reloadData];
    } else if (type == RCMicRoomListChangedTypeRefresh) {
        [self.roomListView reloadItemsAtIndexPaths:@[indexPath]];
    } else if (type == RCMicRoomListChangedTypeDelete) {
        [self.roomListView deleteItemsAtIndexPaths:@[indexPath]];
    }
}

#pragma mark - Actions
- (void)loginAction {
    RCMicLoginViewController *loginVC = [[RCMicLoginViewController alloc] init];
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (void)refreshAction {
    [self refreshRoomList:YES];
}

- (void)loadMoreAction {
    [self refreshRoomList:NO];
}

#pragma mark - Notification selector
- (void)onUserLogin {
    RCMicMainThread(^{
        [self.roomListView.mj_header beginRefreshing];
    });
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //最后添加一个固定的创建房间的 cell
    return self.viewModel.roomSource.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    //最后一个是固定的
    if (indexPath.row == self.viewModel.roomSource.count) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:MicRoomListCreateCell forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:MicRoomListCell forIndexPath:indexPath];
        [(RCMicRoomCell *)cell setDataModel:self.viewModel.roomSource[indexPath.row]];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.viewModel.roomSource.count) {
        //查询是否登录过
        RCMicCachedUserInfo *userInfo = [RCMicAppService sharedService].currentUser;
        if (userInfo.userInfo.type == RCMicUserTypeNormal) {
            RCMicCreateRoomViewController *createRoomVC = [[RCMicCreateRoomViewController alloc] init];
            [self.navigationController pushViewController:createRoomVC animated:true];
        } else {
            [self loginAction];
        }
    } else {
        [RCMicActiveWheel showHUDAddedTo:RCMicKeyWindow];
        [self.viewModel joinRoomWithIndexPath:indexPath success:^{
            RCMicMainThread(^{
                [RCMicActiveWheel hideHUDForView:RCMicKeyWindow animated:YES];
                RCMicRoomInfo *roomInfo = self.viewModel.roomSource[indexPath.row];
                RCMicRoomViewController *roomVC = [[RCMicRoomViewController alloc] initWithRoomInfo:roomInfo Role:RCMicRoleType_Audience];
                [self.navigationController pushViewController:roomVC animated:YES];
            })
        } error:^(RCMicHTTPCode errorCode) {
            RCMicMainThread(^{
                [RCMicActiveWheel hideHUDForView:RCMicKeyWindow animated:YES];
                [RCMicUtil showTipWithErrorCode:errorCode];
            })
        }];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat size = (RCMicScreenWidth - ItemMarginLeftRight * 2 - ItemPadding)/2;
    return CGSizeMake(size, size);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(40, ItemMarginLeftRight, 40, ItemMarginLeftRight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return ItemPadding;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return ItemPadding;
}

#pragma mark - Getters & Setters
- (RCMicRoomListViewModel *)viewModel {
    if (!_viewModel) {
        __weak typeof(self) weakSelf = self;
        _viewModel = [[RCMicRoomListViewModel alloc] init];
        [_viewModel setRoomListChanged:^(RCMicRoomListChangedType type, NSIndexPath * _Nullable index) {
            [weakSelf updateRoomListWithType:type index:index];
        }];
    }
    return _viewModel;
}

- (UIView *)customNavigationBar {
    if (!_customNavigationBar) {
        _customNavigationBar = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _customNavigationBar;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = RCMicLocalizedNamed(@"roomList_title");
        _titleLabel.font = RCMicFont(19, @"PingFangSC-Medium");
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = RCMicColor(HEXCOLOR(0x000000, 1.0), HEXCOLOR(0x000000, 1.0));
    }
    return _titleLabel;
}

- (UIImageView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _portraitView;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_loginButton setTitle:RCMicLocalizedNamed(@"roomList_login") forState:UIControlStateNormal];
        _loginButton.titleLabel.font = RCMicFont(15, nil);
        [_loginButton setTitleColor:RCMicColor([UIColor blackColor], [UIColor blackColor]) forState:UIControlStateNormal];
        [_loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (UICollectionView *)roomListView {
    if (!_roomListView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _roomListView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _roomListView.backgroundColor = RCMicColor([UIColor whiteColor], [UIColor whiteColor]);
        [_roomListView registerClass:[RCMicRoomCell class] forCellWithReuseIdentifier:MicRoomListCell];
        [_roomListView registerClass:[RCMicRoomCreateCell class] forCellWithReuseIdentifier:MicRoomListCreateCell];
        if (@available(iOS 11.0, *)) {
            _roomListView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _roomListView.dataSource = self;
        _roomListView.delegate = self;
        _roomListView.mj_header = [self refreshHeader];
        _roomListView.mj_footer = [self refreshFooter];
        [_roomListView.mj_header beginRefreshing];
    }
    return _roomListView;
}

- (MJRefreshHeader *)refreshHeader {
    MJRefreshNormalHeader *normalHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshAction)];
    //头部显示当前版本信息
    NSString *version = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [normalHeader setLastUpdatedTimeText:^NSString * _Nonnull(NSDate * _Nullable lastUpdatedTime) {
        return [NSString stringWithFormat:@"%@：v%@", RCMicLocalizedNamed(@"roomList_current_version"), version];
    }];
    return normalHeader;
}

- (MJRefreshFooter *)refreshFooter {
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreAction)];
    return footer;
}
@end
