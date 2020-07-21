//
//  RCMicOnLineViewController.m
//  SealMic
//
//  Created by rongyun on 2020/6/3.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicRankMicViewController.h"
#import "RCMicRankMicTableViewCell.h"
#import "RCMicMacro.h"
#import "RCMicAppService.h"
#import "RCMicActiveWheel.h"

#define MicRankMicTableViewCell @"RCMicRankMicTableViewCell"

//（同意，拒绝）操作按钮基础tag标示数值
#define OpenBtnBaseTag     8000
#define RefusedBtnBaseTag  10000

@interface RCMicRankMicViewController ()<UITableViewDataSource,UITableViewDelegate>
/// 选项卡操作列表
@property (nonatomic, strong) UITableView *operationTableView;
@property (nonatomic, strong) NSArray *rankArray;
@end

@implementation RCMicRankMicViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.rankArray = [[NSArray alloc] init];
    
    //选项卡列表
    [self.view addSubview:self.operationTableView];
    self.view.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
    
    [self addConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestWaitingUserList];
}

#pragma mark - Private method
- (void)addConstraints {
    [self.operationTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(400);
    }];
}
//请求排麦列表
- (void)requestWaitingUserList {
    [[RCMicAppService sharedService] getMicWaitingUserList:self.viewModel.roomInfo.roomId success:^(NSArray<RCMicUserInfo *> * _Nonnull userList) {
//        RCMicLog(@"排麦列表userList:%@",userList);
        self.rankArray = userList;
        RCMicMainThread(^{
            [self.operationTableView reloadData];
        });
    } error:^(RCMicHTTPCode errorCode) {
        RCMicLog(@"排麦列表errorCode:%ld",(long)errorCode);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rankArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCMicRankMicTableViewCell *cell = (RCMicRankMicTableViewCell *)[tableView dequeueReusableCellWithIdentifier:MicRankMicTableViewCell];
    if (cell == nil){
        cell = [[RCMicRankMicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MicRankMicTableViewCell];
    }
    //    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
    //取消点击选中cell改变背景颜色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.viewModel.role != RCMicRoleType_Host){
        cell.openBtn.alpha = 0;
        cell.refusedBtn.alpha = 0;
    }else {
        cell.openBtn.alpha = 1;
        cell.refusedBtn.alpha = 1;
        //添加点击事件
        cell.openBtn.tag = OpenBtnBaseTag + indexPath.row;
        [cell.openBtn addTarget:self action:@selector(openAction:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.refusedBtn.tag = RefusedBtnBaseTag + indexPath.row;
        [cell.refusedBtn addTarget:self action:@selector(refusedAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    RCMicUserInfo *userInfo = self.rankArray[indexPath.row];
    [cell setDataModel:userInfo];
    return cell;
}

- (void)openAction:(UIButton *)btn {
    
    RCMicUserInfo *userInfo = self.rankArray[btn.tag - OpenBtnBaseTag];
    [[RCMicAppService sharedService] dealWithParticipantApply:self.viewModel.roomInfo.roomId userId:userInfo.userId accept:YES success:^{
//        RCMicLog(@"同意上麦请求成功");
        //        [self requestWaitingUserList];
        RCMicMainThread(^{
            [self dismissViewControllerAnimated:true completion:nil];
        });
    } error:^(RCMicHTTPCode errorCode) {
        RCMicLog(@"同意上麦请求失败:%ld",(long)errorCode);
        RCMicMainThread(^{
            [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"agree_connect_fail")];
        });
    }];
}

- (void)refusedAction:(UIButton *)btn {
    
    RCMicUserInfo *userInfo = self.rankArray[btn.tag - RefusedBtnBaseTag];
    [[RCMicAppService sharedService] dealWithParticipantApply:self.viewModel.roomInfo.roomId userId:userInfo.userId accept:NO success:^{
//        RCMicLog(@"拒绝上麦请求成功");
        //        [self requestWaitingUserList];
        RCMicMainThread(^{
            [self dismissViewControllerAnimated:true completion:nil];
        });
    } error:^(RCMicHTTPCode errorCode) {
        RCMicLog(@"拒绝上麦请求失败:%ld",(long)errorCode);
        RCMicMainThread(^{
            [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"refused_connect_fail")];
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
        [_operationTableView registerClass:[RCMicRankMicTableViewCell class] forCellReuseIdentifier:MicRankMicTableViewCell];
    }
    return _operationTableView;
}

@end
