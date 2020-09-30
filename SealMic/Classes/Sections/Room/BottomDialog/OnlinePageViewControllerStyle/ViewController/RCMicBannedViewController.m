//
//  RCMicOnLineViewController.m
//  SealMic
//
//  Created by rongyun on 2020/6/3.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicBannedViewController.h"
#import "RCMicBannedTableViewCell.h"
#import "RCMicMacro.h"
#import "RCMicAppService.h"
#import "RCMicActiveWheel.h"

#define MicBannedTableViewCell @"RCMicBannedTableViewCell"
//（解禁言）操作按钮基础tag标示数值
#define UnbindBtnBaseTag 12000

@interface RCMicBannedViewController ()<UITableViewDataSource,UITableViewDelegate>
/// 选项卡操作列表
@property (nonatomic, strong) UITableView *operationTableView;
@property (nonatomic, strong) NSMutableArray *bannedArray;
@end

@implementation RCMicBannedViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //选项卡列表
    [self.view addSubview:self.operationTableView];
    self.view.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
    [self addConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.bannedArray = [[NSMutableArray alloc] init];
    [self requestGetBannedList];
}

#pragma mark - Private method
- (void)addConstraints {
    [self.operationTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(400);
    }];
}

- (void)requestGetBannedList {
    //禁言列表
    [[RCMicAppService sharedService] getBannedUserList:self.viewModel.roomInfo.roomId success:^(NSArray<RCMicUserInfo *> * _Nonnull userList) {
        RCMicMainThread(^{
            [self.bannedArray removeAllObjects];
            [self.bannedArray addObjectsFromArray:userList];
            [self.operationTableView reloadData];
        });
    } error:^(RCMicHTTPCode errorCode) {
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bannedArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCMicBannedTableViewCell *cell = (RCMicBannedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:MicBannedTableViewCell];
    if (cell == nil){
        cell = [[RCMicBannedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MicBannedTableViewCell];
    }
    //    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
    //取消点击选中cell改变背景颜色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.viewModel.role != RCMicRoleType_Host){
        cell.unbindBtn.alpha = 0;
    }else {
        cell.unbindBtn.alpha = 1;
        [cell.unbindBtn addTarget:self action:@selector(unbindAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.unbindBtn.tag = UnbindBtnBaseTag + indexPath.row;
    }
    RCMicUserInfo *userInfo = self.bannedArray[indexPath.row];
    [cell setDataModel:userInfo];
    return cell;
}

- (void)unbindAction:(UIButton *)btn {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag - UnbindBtnBaseTag inSection:0];
    RCMicUserInfo *userInfo = self.bannedArray[btn.tag - UnbindBtnBaseTag];
    [[RCMicAppService sharedService] setUserStateInRoom:self.viewModel.roomInfo.roomId userIds:@[userInfo.userId] canSendMessage:1 success:^{
//        [self requestGetBannedList];
        RCMicMainThread(^{
            [self.bannedArray removeObjectAtIndex:indexPath.row];
            [self.operationTableView reloadData];
        })
    } error:^(RCMicHTTPCode errorCode) {
        RCMicMainThread(^{
            [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"dialog_unban_failed")];
        });
    }];
}

#pragma mark - Getters & Setters
- (UITableView *)operationTableView {
    if (!_operationTableView) {
        _operationTableView = [[UITableView alloc] init];
        _operationTableView.dataSource = self;
        _operationTableView.delegate = self;
        _operationTableView.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
        _operationTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_operationTableView registerClass:[RCMicBannedTableViewCell class] forCellReuseIdentifier:MicBannedTableViewCell];
    }
    return _operationTableView;
}

@end
