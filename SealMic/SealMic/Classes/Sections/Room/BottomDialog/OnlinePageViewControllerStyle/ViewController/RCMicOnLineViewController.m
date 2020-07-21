//
//  RCMicOnLineViewController.m
//  SealMic
//
//  Created by rongyun on 2020/6/3.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicOnLineViewController.h"
#import "RCMicOnLineTableViewCell.h"
#import "RCMicMacro.h"
#import "RCMicAppService.h"
#import "RCMicActiveWheel.h"

#define MicOnLineTableViewCell @"RCMicOnLineTableViewCell"
//（连麦、禁言、踢）操作按钮基础tag标示数值
#define ConnectBtnTag 2000
#define BannedBtnTag 4000
#define KickBtnTag 6000

@interface RCMicOnLineViewController ()<UITableViewDataSource,UITableViewDelegate>
/// 选项卡操作列表
@property (nonatomic, strong) UITableView *operationTableView;
/// 在线用户列表数组
@property (nonatomic, strong) NSArray *onlineArray;
/// 禁言用户列表数组
@property (nonatomic, strong) NSArray *bannedArray;
/// 处理过的在线用户列表数组（除去禁言和麦位用户）
@property (nonatomic, strong) NSMutableArray *resultsArray;
/// 需要过滤的ID（禁言和麦位用户的ID）
@property (nonatomic, strong) NSMutableArray *filterIds;
@end

@implementation RCMicOnLineViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
    
    //选项卡列表
    [self.view addSubview:self.operationTableView];
    [self addConstraints];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupDataSource];
}

#pragma mark - Private method
- (void)addConstraints {
    [self.operationTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(400);
    }];
}

- (void)setupDataSource {
    self.onlineArray = [[NSArray alloc] init];
    self.bannedArray = [[NSArray alloc] init];
    self.resultsArray = [[NSMutableArray alloc] init];
    self.filterIds = [[NSMutableArray alloc] init];
    [self.filterIds removeAllObjects];
    //删除自己
    [self.filterIds addObjectsFromArray:@[[RCMicAppService sharedService].currentUser.userInfo.userId]];
    //删除麦位上用户
    [self.filterIds addObjectsFromArray:self.viewModel.currentParticipantUserIds];
    [self requestUserList];
}

// 获取禁言列表用于筛选在线列表
- (void)requestGetBannedList {
    __weak typeof(self) weakSelf = self;
    //禁言列表
    [[RCMicAppService sharedService] getBannedUserList:self.viewModel.roomInfo.roomId success:^(NSArray<RCMicUserInfo *> * _Nonnull userList) {
//        RCMicLog(@"禁言列表userList:%@",userList);
        weakSelf.bannedArray = userList;
        //添加禁言列表的id
        for (int i=0; i<weakSelf.bannedArray.count; i++) {
            RCMicUserInfo *userInfo = weakSelf.bannedArray[i];
            [weakSelf.filterIds addObject:userInfo.userId];
        }
        //禁言列表筛选id添加完以后 进行筛选在线列表数据
        [weakSelf screeningUser];
    } error:^(RCMicHTTPCode errorCode) {
//        RCMicLog(@"禁言列表errorCode:%ld",(long)errorCode);
    }];
}

//在线列表
- (void)requestUserList {
    [self.resultsArray removeAllObjects];
    __weak typeof(self) weakSelf = self;
    [[RCMicAppService sharedService] getRoomUserList:self.viewModel.roomInfo.roomId success:^(NSArray<RCMicUserInfo *> * _Nonnull userList) {
//        RCMicLog(@"在线列表userList:%@",userList);
        weakSelf.onlineArray = userList;
        //把在线用户列表数组放到一个可变数组里
        [weakSelf.resultsArray addObjectsFromArray:userList];
        //获取完在线列表以后 进行禁言列表的获取和数据的筛选。如果请求过多可以使用gcd的组
        [weakSelf requestGetBannedList];
    } error:^(RCMicHTTPCode errorCode) {
//        RCMicLog(@"在线列表errorCode:%ld",(long)errorCode);
    }];
}

/// 筛选用户（除去禁言和麦位用户）
- (void)screeningUser {
    __weak typeof(self) weakSelf = self;
    for (int i=0; i<self.onlineArray.count; i++) {
        //获取每个在线用户列表的用户id
        RCMicUserInfo *userInfo = self.onlineArray[i];
        for (int j=0; j<self.filterIds.count;j++){
            //拿在线列表的用户id 和要进行筛选的用户id做对比
            NSString *idString = self.filterIds[j];
            if ([userInfo.userId isEqualToString:idString]){
                //如果有发现 禁言列表的用户和麦位上的用户 就从在线列表显示里移出去
                [self.resultsArray removeObject:userInfo];
            }
        }
    }
    //筛选完进行数据刷新显示
    RCMicMainThread(^{
        [weakSelf.operationTableView reloadData];
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCMicOnLineTableViewCell *cell = (RCMicOnLineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:MicOnLineTableViewCell];
    if (cell == nil){
        cell = [[RCMicOnLineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MicOnLineTableViewCell];
    }
    cell.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
    //取消点击选中cell改变背景颜色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    RCMicUserInfo *userInfo = self.resultsArray[indexPath.row];
    [cell setDataModel:userInfo];
    
    if (self.viewModel.role != RCMicRoleType_Host){
        cell.connectBtn.alpha = 0;
        cell.bannedBtn.alpha = 0;
        cell.kickBtn.alpha = 0;
    }else {
        cell.connectBtn.alpha = 1;
        cell.bannedBtn.alpha = 1;
        cell.kickBtn.alpha = 1;
        //添加点击事件
        cell.connectBtn.tag = ConnectBtnTag + indexPath.row;
        [cell.connectBtn addTarget:self action:@selector(connectAction:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.bannedBtn.tag = BannedBtnTag + indexPath.row;
        [cell.bannedBtn addTarget:self action:@selector(bannedAction:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.kickBtn.tag = KickBtnTag + indexPath.row;
        [cell.kickBtn addTarget:self action:@selector(kickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (void)connectAction:(UIButton *)btn {
    __weak typeof(self) weakSelf = self;

    RCMicUserInfo *userInfo = self.resultsArray[btn.tag - ConnectBtnTag];
    
    [[RCMicAppService sharedService] inviteParticipant:weakSelf.viewModel.roomInfo.roomId userId:userInfo.userId success:^{
//        RCMicLog(@"连麦成功!");
        //        [self requestUserList];
        RCMicMainThread(^{
            [weakSelf dismissViewControllerAnimated:true completion:nil];
        });
    } error:^(RCMicHTTPCode errorCode) {
        RCMicMainThread(^{
            [RCMicUtil showTipWithErrorCode:errorCode];
        });
    }];
}

- (void)bannedAction:(UIButton *)btn {
    __weak typeof(self) weakSelf = self;

    RCMicUserInfo *userInfo = self.resultsArray[btn.tag - BannedBtnTag];
    [[RCMicAppService sharedService] setUserStateInRoom:weakSelf.viewModel.roomInfo.roomId userIds:@[userInfo.userId] canSendMessage:0 success:^{
        RCMicLog(@"禁言成功!");
        [weakSelf setupDataSource];
    } error:^(RCMicHTTPCode errorCode) {
        RCMicLog(@"禁言失败%ld!",(long)errorCode);
        RCMicMainThread(^{
            [RCMicUtil showTipWithErrorCode:errorCode];
        });
    }];
    
}

- (void)kickAction:(UIButton *)btn {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag - KickBtnTag inSection:0];
    RCMicUserInfo *userInfo = self.resultsArray[btn.tag - KickBtnTag];
    [self.viewModel kickUserOut:userInfo.userId success:^{
        RCMicMainThread(^{
            [self.resultsArray removeObjectAtIndex:indexPath.row];
            [self.operationTableView reloadData];
        })
    } error:^(RCMicHTTPCode errorCode) {
       RCMicMainThread(^{
           [RCMicUtil showTipWithErrorCode:errorCode];
        });
    }];
}

#pragma mark - Getters & Setters
- (UITableView *)operationTableView {
    if (!_operationTableView) {
        _operationTableView = [[UITableView alloc] init];
        _operationTableView.dataSource = self;
        _operationTableView.delegate = self;
        //        _operationTableView.backgroundColor = [UIColor clearColor];
        _operationTableView.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
        _operationTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_operationTableView registerClass:[RCMicOnLineTableViewCell class] forCellReuseIdentifier:MicOnLineTableViewCell];
    }
    return _operationTableView;
}

@end
