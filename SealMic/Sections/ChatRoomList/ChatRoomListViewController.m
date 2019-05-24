//
//  ChatRoomListViewController.m
//  SealMic
//
//  Created by 孙浩 on 2019/5/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ChatRoomListViewController.h"
#import "ChatRoomListItem.h"
#import "ChatRoomController.h"
#import "MJRefresh.h"
#import "ClassroomService.h"
#import "CreateRoomView.h"
#import "LoginHelper.h"

#define CreateRoomBtnWidth 107.5
#define CreateRoomBtnHeight 113.5
#define ChatRoomListItemID @"ChatRoomListItemID"

@interface ChatRoomListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, CreateRoomViewDelegate>
@property (nonatomic, strong) UIImageView *emptyView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *createBtn;
@property (nonatomic, strong) CreateRoomView *createRoomView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation ChatRoomListViewController

#pragma mark - life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 导航设置
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = MicLocalizedNamed(@"ChatRoomListTitle");
    [self addSubviews];
    [self.hud showAnimated:YES];
}

#pragma mark - private method
- (void)addSubviews {
    [self.view addSubview:self.collectionView];
    [self.collectionView addSubview:self.emptyView];
    [self.view addSubview:self.createBtn];
    
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.collectionView);
        make.centerY.equalTo(self.collectionView).offset(-32);
        make.width.offset(84);
        make.height.offset(94);
    }];
    
    [self.createBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.offset(CreateRoomBtnWidth);
        make.height.offset(CreateRoomBtnHeight);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-12);
        } else {
            make.bottom.equalTo(self.view.mas_bottom).offset(-12);
        }
    }];
    [self.view addSubview:self.hud];
}

- (void)loadHistoryData {
    [[ClassroomService sharedService] getRoomList:^(NSArray<RoomInfo *> * _Nonnull roomList) {
        self.dataArray = [roomList copy];
        NSLog(@"loadHistoryData success: %@", self.dataArray);
        dispatch_main_async_safe(^{
            if (self.dataArray.count == 0) {
                self.emptyView.hidden = NO;
            } else {
                self.emptyView.hidden = YES;
            }
            [self.collectionView.mj_header endRefreshing];
            [self.collectionView reloadData];
        });
    } error:^(ErrorCode code) {
        NSLog(@"loadHistoryData failure: %ld", (long)code);
        dispatch_main_async_safe(^{
            [self.view showHUDMessage:MicLocalizedNamed(@"LoadHistroyDatFailure")];
        });
        [self.collectionView.mj_header endRefreshing];
    }];
}

#pragma mark - Target Action
- (void)createChatRoom {
    self.createRoomView = [[CreateRoomView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight)];
    self.createRoomView.delegate = self;
    [self.view addSubview:self.createRoomView];
}

#pragma mark - LoginHelperDelegate
- (void)roomDidLogin{
    [self.hud hideAnimated:YES];
    [self loadHistoryData];
}

- (void)roomDidCreateOrJoin{
    [self.hud hideAnimated:YES];
    [self pushChatRoomVC];
}

- (void)roomDidOccurError:(NSString *)describe {
    [self.view showHUDMessage:describe];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RoomInfo *roomInfo = self.dataArray[indexPath.item];
    [self.hud showAnimated:YES];
    [[LoginHelper sharedInstance] join:roomInfo.roomId];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatRoomListItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ChatRoomListItemID forIndexPath:indexPath];
    if (!cell) {
        cell = [[ChatRoomListItem alloc] init];
    }
    RoomInfo *roomInfo = self.dataArray[indexPath.item];
    [cell setRoomInfo:roomInfo];
    return cell;
}

#pragma mark - CreateRoomViewDelegate
- (void)createRoom:(NSString *)roomName type:(int)roomType {
    [self.createRoomView removeFromSuperview];
    [self.hud showAnimated:YES];
    [[LoginHelper sharedInstance] create:roomName type:roomType];
}

- (void)pushChatRoomVC{
    ChatRoomController *chatRoomVC = [[ChatRoomController alloc] init];
    [self.navigationController pushViewController:chatRoomVC animated:YES];
}

#pragma mark - getter or setter
- (UIImageView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIImageView alloc] init];
        _emptyView.image = [UIImage imageNamed:@"chatlist_empty"];
    }
    return _emptyView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(ItemWidth, ItemHeight);
        flowLayout.minimumLineSpacing = 8.0;
        flowLayout.minimumInteritemSpacing = 10.0;
        CGFloat space = (UIScreenWidth - ItemWidth * 2) / 3;
        flowLayout.sectionInset = UIEdgeInsetsMake(16.0, space, 16.0, space);
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor colorWithHexString:@"F5F5F5" alpha:1];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = YES;
        [_collectionView registerClass:[ChatRoomListItem class] forCellWithReuseIdentifier:ChatRoomListItemID];
        
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadHistoryData)];
        header.automaticallyChangeAlpha = YES;
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        header.arrowView.hidden = YES;
        _collectionView.mj_header = header;
    }
    return _collectionView;
}

- (UIButton *)createBtn {
    if (!_createBtn) {
        _createBtn = [[UIButton alloc] init];
        [_createBtn setBackgroundImage:[UIImage imageNamed:@"chatlist_create_normal"] forState:UIControlStateNormal];
        [_createBtn setBackgroundImage:[UIImage imageNamed:@"chatlist_create_select"] forState:UIControlStateSelected];
        [_createBtn addTarget:self action:@selector(createChatRoom) forControlEvents:UIControlEventTouchUpInside];
    }
    return _createBtn;
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.label.text = MicLocalizedNamed(@"PleaseWait");
    }
    return _hud;
}

@end
