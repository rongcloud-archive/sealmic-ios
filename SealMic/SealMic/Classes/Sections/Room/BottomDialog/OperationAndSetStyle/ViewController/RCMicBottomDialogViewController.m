//
//  RCMicBottomDialogStyle1Controller.m
//  SealMic
//
//  Created by rongyun on 2020/5/29.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicBottomDialogViewController.h"
#import "RCMicMacro.h"
#import "RCMicOperationTableCell.h"
#import "RCMicOperationSwitchTableCell.h"
#import "RCMicActiveWheel.h"
#import <SDWebImage/SDWebImage.h>
#import "RCMicBottomDialogScrollPageViewController.h"
#import "RCMicOperationModel.h"

#define MicOperationTableViewCell @"MicOperationTableViewCell"
#define MicOperationSwitchTableViewCell @"MicOperationSwitchTableViewCell"
#define MicOperationTableViewCellHeight 64.0
//列表距离有头像视图的顶部间距 注意减去cell的间距 这里每个spacing减去了10间距
#define TableViewDistanceHeadTopSpacing 136.5
//列表距离没有头像视图的顶部间距
#define TableViewDistanceTopSpacing 50.5
//列表距离底部的间距
#define TableViewDistanceBottomSpacing 10

@interface RCMicBottomDialogViewController ()<UITableViewDelegate,UITableViewDataSource>
/// 当前麦位信息
@property (nonatomic, strong) RCMicParticipantViewModel *currentParticipantViewModel;
/// 当前点击消息 Model
@property (nonatomic, strong) RCMicMessageViewModel *currentMessageViewModel;
/// 是否是有头像的视图
@property (nonatomic)BOOL isHead;
/// 是否有开关选择
@property (nonatomic)BOOL isSwitch;
/// 弹框背景图片视图
@property (nonatomic, strong) UIImageView *bgImageView;
/// 头像
@property (nonatomic, strong) UIImageView *headImageView;
/// 标题
@property (nonatomic, strong) UILabel *titleLabel;
/// 副标题
@property (nonatomic, strong) UILabel *subtitleLabel;
/// 选项卡操作列表
@property (nonatomic, strong) UITableView *operationTableView;
/// 选项卡选项配置
@property (nonatomic, strong) NSMutableArray *operationMutableArray;
/// 点击消失弹框按钮
@property (nonatomic, strong) UIButton *dismissBtn;

@end

@implementation RCMicBottomDialogViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置类似遮罩的视图背景颜色
    self.view.backgroundColor = [UIColor colorWithRed:3/255.0f green:6/255.0f blue:47/255.0f alpha:0.5];
    //添加视图
    [self addSubviews];
    //配置布局约束
    [self addConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //每次进页面检测下显示样式
    [self setupStyle];
}

#pragma mark - 配置弹框UI展示不同样式

- (void)setupStyle{
    //样式： 是否显示有头像的样式
    self.headImageView.alpha = self.isHead;
    self.subtitleLabel.alpha = self.isHead;
    CGFloat iphoneXHeight = [RCMicUtil bottomSafeAreaHeight];
    if (self.isHead){
        if (self.operationMutableArray.count <2){
            self.bgImageView.image = [UIImage imageNamed:@"alert_bottom_head_short_bg"];
        }
        else if (self.operationMutableArray.count > 5){
            self.bgImageView.image = [UIImage imageNamed:@"alert_bottom_head_long_bg"];
        }
        else {
            self.bgImageView.image = [UIImage imageNamed:@"alert_bottom_head_bg"];
        }
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgImageView.mas_top).offset(80);
        }];
        //更新tableview的y坐标位置
        [self.operationTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgImageView).offset(TableViewDistanceHeadTopSpacing);
        }];
        ////选相框背景的高度更新，计算公式 根据当前 tableview的高度 + 间距
        CGFloat bgImageViewHeight = self.operationMutableArray.count * MicOperationTableViewCellHeight + TableViewDistanceHeadTopSpacing + TableViewDistanceBottomSpacing + iphoneXHeight;
        [self.bgImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(bgImageViewHeight);
            //底部超出12圆角位置，只显示左上右上圆角
            make.bottom.mas_equalTo(0);
        }];
        self.bgImageView.layer.cornerRadius = 0;
    }else {
        self.bgImageView.image = [UIImage imageNamed:@"alert_bottom_bg"];
        self.bgImageView.layer.cornerRadius = 12;
        //更新标题的y坐标位置
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgImageView.mas_top).offset(20);
        }];
        //更新tableview的y坐标位置
        [self.operationTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgImageView).offset(TableViewDistanceTopSpacing);
        }];
        ////选相框背景的高度更新，计算公式 根据当前 tableview的高度 + 间距
        CGFloat bgImageViewHeight = self.operationMutableArray.count * MicOperationTableViewCellHeight + TableViewDistanceTopSpacing + TableViewDistanceBottomSpacing + iphoneXHeight;
        [self.bgImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(bgImageViewHeight + 12);
            //底部超出12圆角位置，只显示左上右上圆角
            make.bottom.mas_equalTo(12);
        }];
    }
    //更新点击消失弹框按钮覆盖区域
    [self.dismissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.bottom.equalTo(self.bgImageView.mas_top);
    }];
}

#pragma mark - 点击展示弹框事件

#pragma mark 点击设置按钮弹框样式
- (void)clickSetButtonDialogStyle {
    /// 是否显示头像
    self.isHead = false;
    /// 设置标题
    self.titleLabel.text = RCMicLocalizedNamed(@"seting");
    /// 是否是有开关的样式
    self.isSwitch = true;
    /// 注册开关样式的cell
    [self.operationTableView registerClass:[RCMicOperationSwitchTableCell class] forCellReuseIdentifier:MicOperationSwitchTableViewCell];
    /// 移除旧的数据源
    [self.operationMutableArray removeAllObjects];
    /// 判断当前状态是否是主持人
    if (self.viewModel.role == RCMicRoleType_Host){
        //主持人的设置操作权限选项
        [self setupOperation];
        //请求获取最新的房间设置状态
        [self requestRoomInfo];
    }else {
        //非主持人设置配置选项
        self.operationMutableArray = [[NSMutableArray alloc] initWithObjects:
                                      @(DIALOGOPERATIONSETTYPE_Receiver),
                                      @(DIALOGOPERATIONSETTYPE_TurnDebug),
                                      nil];
    }
    //刷新
    [self.operationTableView reloadData];
}

#pragma mark 点击麦位区域 弹框样式
- (void)clickParticipantsAreaDialogStyle:(RCMicParticipantViewModel *)participantViewModel userInfo:(RCMicUserInfo *)userInfo {
    RCMicMainThread((^{
        //判断当前麦位对象是否为空
        if (participantViewModel){
            //根据传进来的userInfo判断当前点击麦位是否有人
            if(userInfo){
                //有用户头像显示有头像的视图样式
                self.isHead = true;
                //当前麦位用户名字
                self.titleLabel.text = [NSString stringWithFormat:@"%@",userInfo.name];
                //当前麦位用户头像
                [self.headImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"login_portrait_default"]];
                //移除旧的选项数据源 根据条件进行重新配置
                [self.operationMutableArray removeAllObjects];
                //点击自己的 弹框样式（判断是否点击的是自己）
                if ([participantViewModel.participantInfo.userId isEqualToString:[RCMicAppService sharedService].currentUser.userInfo.userId]){
                    self.operationMutableArray = [[NSMutableArray alloc] initWithObjects:
                                                  @(DIALOGOPERATIONTYPE_KickParticipantOut), nil];
                }
                
                //参会者点击主持人 弹框样式
                else if (participantViewModel.participantInfo.isHost && self.viewModel.role == RCMicRoleType_Participant){
                    self.operationMutableArray = [[NSMutableArray alloc] initWithObjects:
                                                  @(DIALOGOPERATIONTYPE_GiveGift),
                                                  @(DIALOGOPERATIONTYPE_SendMessage),
                                                  @(DIALOGOPERATIONTYPE_TakeOverHost),
                                                  nil];
                    
                }
                else {
                    //判断当前角色 根据角色来显示对应用户的操作选项
                    switch (self.viewModel.role) {
                        case RCMicRoleType_Audience:
                            //普通听众点击麦位上的用户
                            self.operationMutableArray = [[NSMutableArray alloc] initWithObjects:
                                                          @(DIALOGOPERATIONTYPE_GiveGift),
                                                          @(DIALOGOPERATIONTYPE_SendMessage),
                                                          @(DIALOGOPERATIONTYPE_ApplyParticipant),nil];
                            break;
                        case RCMicRoleType_Host:{
                            //主持人点击麦位上的用户
                            self.operationMutableArray = [[NSMutableArray alloc] initWithObjects:
                                                          @(DIALOGOPERATIONTYPE_ParticipantClose),
                                                          @(DIALOGOPERATIONTYPE_KickParticipantOut),
                                                          @(DIALOGOPERATIONTYPE_TransferHost),
                                                          @(DIALOGOPERATIONTYPE_SendMessage),
                                                          @(DIALOGOPERATIONTYPE_GiveGift),
                                                          @(DIALOGOPERATIONTYPE_KickUserOut),
                                                          nil];
                            
                            //如果当前麦位是闭麦状态可以更改状态
                            if (participantViewModel.participantInfo.state == RCMicParticipantStateSilent){
                                //把当前闭麦选项 替换成 开麦选项
                                [self.operationMutableArray replaceObjectAtIndex:0 withObject:@(DIALOGOPERATIONTYPE_ParticipantOpen)];
                            };
                            
                        }
                            break;
                        case RCMicRoleType_Participant:
                            //主播点击麦位上其他的用户
                            self.operationMutableArray = [[NSMutableArray alloc] initWithObjects:
                                                          @(DIALOGOPERATIONTYPE_GiveGift),
                                                          @(DIALOGOPERATIONTYPE_SendMessage),nil];
                            break;
                        default:
                            break;
                    }
                }
                //设置副标题为当前麦位的位置信息
                if (participantViewModel.participantInfo.position == 0){
                    self.subtitleLabel.text = RCMicLocalizedNamed(@"host");
                }else {
                    self.subtitleLabel.text = [NSString stringWithFormat:@"%ld号麦",(long)participantViewModel.participantInfo.position];
                }
            }else {
                //当前麦位没有人
                self.isHead = false;
                //移除旧的选项数据源 根据条件进行重新配置
                [self.operationMutableArray removeAllObjects];
                //如果当前点击的是 主持人麦位 没有用户 直接显示接管主持人
                if (participantViewModel.participantInfo.isHost){
                    self.titleLabel.text = [NSString stringWithFormat:RCMicLocalizedNamed(@"host_mike")];
                    self.operationMutableArray = [[NSMutableArray alloc] initWithObjects:
                                                  @(DIALOGOPERATIONTYPE_TakeOverHost), nil];
                }
                else {
                    //如果当前操作用户是主持人的话
                    if (self.viewModel.role == RCMicRoleType_Host){
                        self.titleLabel.text = [NSString stringWithFormat:@"%@-%ld%@",RCMicLocalizedNamed(@"dialog_location_mic_management"),(long)participantViewModel.participantInfo.position,RCMicLocalizedNamed(@"dialog_location_mic")];
                        self.operationMutableArray = [[NSMutableArray alloc] initWithObjects:
                                                      @(DIALOGOPERATIONTYPE_InvitationConnectMic),
                                                      nil];
                        //如果当前麦位被加锁显示解锁
                        if (participantViewModel.participantInfo.state == RCMicParticipantStateClosed){
                            [self.operationMutableArray addObject:@(DIALOGOPERATIONTYPE_SetParticipantUnLock)];
                        }else {
                            //没有加锁的话，主持人点空麦位显示选项
                            [self.operationMutableArray addObject:@(DIALOGOPERATIONTYPE_SetParticipantLock)];
                        }
                    }else {
                        self.operationMutableArray = [[NSMutableArray alloc] initWithObjects:
                                                      @(DIALOGOPERATIONTYPE_ApplyParticipant),
                                                      nil];
                        //不是主持人角色 点击空麦位显示选项
                        if (participantViewModel.participantInfo.position == 0){
                            self.titleLabel.text = RCMicLocalizedNamed(@"host_mike");
                        }else {
                            self.titleLabel.text = [NSString stringWithFormat:@"%ld%@",(long)participantViewModel.participantInfo.position,RCMicLocalizedNamed(@"dialog_location_mic")];
                        }
                        
                        if (participantViewModel.participantInfo.state == RCMicParticipantStateClosed){
                            self.titleLabel.text = [NSString stringWithFormat:@"%ld%@",(long)participantViewModel.participantInfo.position,RCMicLocalizedNamed(@"dialog_location_mic_lock")];
                        }
                    }
                }
                
            }
        }
        [self setupCurrentModel:participantViewModel messageViewModel:nil];
        //不是开关视图
        self.isSwitch = false;
        //刷新选项卡列表
        [self.operationTableView reloadData];
        
        
    }));
    
}

#pragma mark 点击聊天区域弹框
- (void)clickChatViewDialogStyle:(RCMicMessageViewModel *)messageViewModel {
    [self setupCurrentModel:nil messageViewModel:messageViewModel];
    //当前显示用户头像
    self.isHead = true;
    //点击文字聊天区域
    [self.operationMutableArray removeAllObjects];
    //如果主持人点击的是自己的消息 只有删除此条消息操作
    if (messageViewModel && [messageViewModel.senderInfo.userId isEqualToString:[RCMicAppService sharedService].currentUser.userInfo.userId]){
        
        self.operationMutableArray = [[NSMutableArray alloc] initWithObjects:
                                      @(DIALOGOPERATIONTYPE_DeleteMessage),
                                      nil];
        self.subtitleLabel.text = RCMicLocalizedNamed(@"host");
    }else {
        
        self.operationMutableArray = [[NSMutableArray alloc] initWithObjects:
                                      @(DIALOGOPERATIONTYPE_InvitationParticipant),
                                      @(DIALOGOPERATIONTYPE_SendMessage),
                                      @(DIALOGOPERATIONTYPE_SetUserBanned),
                                      @(DIALOGOPERATIONTYPE_KickUserOut),
                                      @(DIALOGOPERATIONTYPE_DeleteMessage),
                                      nil];
        
        //默认显示观众
        self.subtitleLabel.text = RCMicLocalizedNamed(@"audience");
        //如果这个用户在麦位上就不显示副标题
        for (int i =0; i<self.viewModel.currentParticipantUserIds.count; i ++) {
            NSString *idString = self.viewModel.currentParticipantUserIds[i];
            if ([idString isEqualToString:messageViewModel.senderInfo.userId]){
                self.subtitleLabel.text = @"";
            }else {
                self.subtitleLabel.text = RCMicLocalizedNamed(@"audience");
            }
        }
    }
    if (messageViewModel.senderInfo){
        //当前点击的聊天区域用户数据信息不为空的话 显示其名字和头像
        self.titleLabel.text = [NSString stringWithFormat:@"%@",messageViewModel.senderInfo.name];
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:messageViewModel.senderInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"participant_portrait_default"]];
    }
    //不是开关视图
    self.isSwitch = false;
    //刷新选项卡列表
    [self.operationTableView reloadData];
}

- (void)setupOperation {
    //主持人显示的设置选项
    self.operationMutableArray = [[NSMutableArray alloc] initWithObjects:
                                  @(DIALOGOPERATIONSETTYPE_AllowJoin),
                                  @(DIALOGOPERATIONSETTYPE_AllowFreeToTheMic),
                                  @(DIALOGOPERATIONSETTYPE_Receiver),
                                  @(DIALOGOPERATIONSETTYPE_TurnDebug),
                                  nil];
    
    RCMicMainThread(^{
        [self.operationTableView reloadData];
    });
}

#pragma mark - Private method

- (void)setupCurrentModel:(RCMicParticipantViewModel *)participantViewModel messageViewModel:(RCMicMessageViewModel *)messageViewModel {
    //把当前 Model 信息赋值，方便其他地方使用
    self.currentMessageViewModel = messageViewModel;
    self.currentParticipantViewModel = participantViewModel;
}

- (void)addSubviews {
    //弹框背景图片视图
    [self.view addSubview:self.bgImageView];
    //点击消失弹框
    [self.view addSubview:self.dismissBtn];
    //头像
    [self.view addSubview:self.headImageView];
    //title标题
    [self.view addSubview:self.titleLabel];
    //副标题
    [self.view addSubview:self.subtitleLabel];
    //选项卡列表
    [self.view addSubview:self.operationTableView];
}

- (void)addConstraints {
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        //默认高度
        make.height.mas_equalTo(420);
    }];
    
    [self.dismissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.bottom.equalTo(self.bgImageView.mas_top);
    }];
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgImageView);
        make.top.equalTo(self.bgImageView).offset(9);
        make.width.height.mas_equalTo(56);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgImageView);
        make.top.equalTo(self.headImageView.mas_bottom).offset(15);
        make.height.mas_equalTo(24);
    }];
    
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgImageView);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
        make.height.mas_equalTo(18.5);
    }];
    
    [self.operationTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        //默认使用没有头像的间距
        make.top.equalTo(self.bgImageView).offset(TableViewDistanceTopSpacing);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.bgImageView).offset(-TableViewDistanceBottomSpacing);
    }];
}


#pragma mark - 网络请求
/// 请求获取最新的房间设置状态
- (void)requestRoomInfo {
    __weak typeof(self) weakSelf = self;
    // 获取房间设置
    [[RCMicAppService sharedService] getRoomInfo:self.viewModel.roomInfo.roomId success:^(RCMicRoomInfo * _Nonnull roomInfo) {
        //是否允许自由加入房间
        weakSelf.viewModel.roomInfo.freeJoinRoom = roomInfo.freeJoinRoom;
        weakSelf.viewModel.roomInfo.freeJoinMic = roomInfo.freeJoinMic;
        //更新最新设置状态
        [weakSelf setupOperation];
    } error:^(RCMicHTTPCode errorCode) {
        RCMicMainThread(^{
            [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"failed_to_get_room_information")];
        });
    }];
}

///请求房间设置
- (void)requestSetRoom{
    __weak typeof(self) weakSelf = self;
    // 房间设置
    [[RCMicAppService sharedService]setRoomAttribute:self.viewModel.roomInfo.roomId freeJoinRoom:weakSelf.viewModel.roomInfo.freeJoinRoom freeJoinMic:weakSelf.viewModel.roomInfo.freeJoinMic success:^{
        [weakSelf requestRoomInfo];
    } error:^(RCMicHTTPCode errorCode) {
        RCMicMainThread(^{
            [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"setup_failed")];
        });
        [weakSelf requestRoomInfo];
    }];
}

#pragma mark - Action
- (void)dismissAction {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.operationMutableArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MicOperationTableViewCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.isSwitch){
        DIALOGOPERATIONTYPE type = [self.operationMutableArray[indexPath.row] intValue];
        //先判断是否点击的是邀请连麦
        if (type == DIALOGOPERATIONTYPE_InvitationConnectMic) {
            //如果当前麦位被锁定，邀请连麦点击无操作
            if (self.currentParticipantViewModel.participantInfo.state == RCMicParticipantStateClosed){
                return;
            }
        }
        [self dismissViewControllerAnimated:false completion:nil];
        
        //选择麦位弹框操作选项调用回调
        if (self.clickParticipantSelectedCellBlock && self.currentParticipantViewModel){
            self.clickParticipantSelectedCellBlock(type, self.currentParticipantViewModel);
        }
        //选择聊天室弹框操作选项调用回调
        if (self.clickChatViewSelectedCellBlock  && self.currentMessageViewModel){
            self.clickChatViewSelectedCellBlock(type, self.currentMessageViewModel);
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSwitch){
        RCMicOperationSwitchTableCell *switchCell = (RCMicOperationSwitchTableCell *)[tableView dequeueReusableCellWithIdentifier:MicOperationSwitchTableViewCell];
        if (switchCell == nil){
            switchCell = [[RCMicOperationSwitchTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MicOperationSwitchTableViewCell];
        }
        __weak typeof(self) weakSelf = self;
        switchCell.changeSwitchBtnBlock = ^(UIButton * _Nonnull mySwitchBtn, NSString * _Nonnull key) {
            if ([key isEqualToString:RCMicLocalizedNamed(@"allow_the_audience_to_join")]){
                weakSelf.viewModel.roomInfo.freeJoinRoom = mySwitchBtn.selected;
                [weakSelf requestSetRoom];
            }
            if ([key isEqualToString:RCMicLocalizedNamed(@"allow_the_audience_free_access_to_the_mic")]){
                weakSelf.viewModel.roomInfo.freeJoinMic = mySwitchBtn.selected;
                [weakSelf requestSetRoom];
            }
            if ([key isEqualToString:RCMicLocalizedNamed(@"use_the_receiver")]){
                if (weakSelf.changeReceiverBlock){
                    weakSelf.viewModel.useSpeaker = !mySwitchBtn.selected;
                    weakSelf.changeReceiverBlock(mySwitchBtn.selected);
                }
            }
            if ([key isEqualToString:RCMicLocalizedNamed(@"turn_on_debug_mode")]){
                if (weakSelf.debugBlock) {
                    weakSelf.debugBlock(mySwitchBtn.selected);
                }
            }
        };
        
        DIALOGOPERATIONSETTYPE type = [self.operationMutableArray[indexPath.row] intValue];
        //通过操作类型获取当前显示的对应 中英文标题
        RCMicOperationModel *model = [[RCMicOperationModel alloc] initWithSetType:type];
        //设置选项卡标题
        switchCell.operationTitleLabel.text = model.title;
        switch (type) {
            case DIALOGOPERATIONSETTYPE_Receiver:
                switchCell.operationSwitchBtn.selected = !self.viewModel.useSpeaker;
                break;
            case DIALOGOPERATIONSETTYPE_TurnDebug:
                switchCell.operationSwitchBtn.selected = self.viewModel.debugDisplay;
                break;
            case DIALOGOPERATIONSETTYPE_AllowJoin:
                switchCell.operationSwitchBtn.selected = self.viewModel.roomInfo.freeJoinRoom;
                break;
            case DIALOGOPERATIONSETTYPE_AllowFreeToTheMic:
                switchCell.operationSwitchBtn.selected = self.viewModel.roomInfo.freeJoinMic;
                break;
                
            default:
                break;
        }
        
        return switchCell;
    }else {
        RCMicOperationTableCell *cell = (RCMicOperationTableCell *)[tableView dequeueReusableCellWithIdentifier:MicOperationTableViewCell];
        if (cell == nil){
            cell = [[RCMicOperationTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MicOperationTableViewCell];
        }
        //获取当前要显示的操作类型
        DIALOGOPERATIONTYPE type = [self.operationMutableArray[indexPath.row] intValue];
        //通过操作类型获取当前显示的对应 中英文标题
        RCMicOperationModel *model = [[RCMicOperationModel alloc] initWithType:type];
        //设置选项卡标题
        [cell.operationBtn setTitle:model.title forState:UIControlStateNormal];
        
        //默认选项颜色
        [cell.operationBtn setTitleColor:RCMicColor([UIColor whiteColor], [UIColor whiteColor]) forState:UIControlStateNormal];
        //设置默认为亮色背景和可以选中
        [cell.operationBtn setBackgroundImage:[UIImage imageNamed:@"select_box_bg"] forState:UIControlStateNormal];
        cell.operationBtn.alpha = 1;
        
        //移出房间和删除消息如果是最后一个选项就改变选项字体颜色为绿色
        if ((self.operationMutableArray.count - 1) == indexPath.row){
            if (type == DIALOGOPERATIONTYPE_KickUserOut || type == DIALOGOPERATIONTYPE_DeleteMessage ) {
                [cell.operationBtn setTitleColor:RCMicColor(HEXCOLOR(0x2DF3C1, 1.0), HEXCOLOR(0x2DF3C1, 1.0)) forState:UIControlStateNormal];
            }
        }
        
        //判断当前展示的是否是麦位视图的弹框
        if (self.currentParticipantViewModel){
            //如果当前麦位被加锁显示邀请连麦为灰色 不可点击样式
            if (self.currentParticipantViewModel.participantInfo.state == RCMicParticipantStateClosed){
                if (type == DIALOGOPERATIONTYPE_InvitationConnectMic) {
                    [cell.operationBtn setBackgroundImage:[UIImage imageNamed:@"select_box_drak_bg"] forState:UIControlStateNormal];
                    cell.operationBtn.alpha = 0.6;
                }
            }
        }
        
        return cell;
    }
}

#pragma mark - Getters & Setters
- (UIImageView *)bgImageView {
    if(!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        //默认值
        _bgImageView.image = [UIImage imageNamed:@"alert_bottom_head_bg"];
        _bgImageView.userInteractionEnabled = true;
        _bgImageView.clipsToBounds = true;
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

- (UIImageView *)headImageView {
    if(!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        //默认值
        _headImageView.image = [UIImage imageNamed:@"room_portrait_temp"];
        _headImageView.clipsToBounds = true;
        _headImageView.layer.cornerRadius = 56/2;
    }
    return _headImageView;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        //默认值
        _titleLabel.text = @"";
        _titleLabel.textColor = RCMicColor([UIColor whiteColor], [UIColor whiteColor]);
        //默认值
        _titleLabel.font = RCMicFont(17.5, @"PingFangSC-Medium");
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if(!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        //默认值
        _subtitleLabel.text = @"";
        _subtitleLabel.textColor = RCMicColor(HEXCOLOR(0xDFDFDF, 1.0), HEXCOLOR(0xDFDFDF, 1.0));
        _subtitleLabel.font = RCMicFont(14, @"PingFangSC-Regular");
    }
    return _subtitleLabel;
}

- (UITableView *)operationTableView {
    if (!_operationTableView) {
        _operationTableView = [[UITableView alloc] init];
        _operationTableView.dataSource = self;
        _operationTableView.delegate = self;
        _operationTableView.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
        _operationTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //默认不能滑动根据数量计算高度显示，根据情况调整
        _operationTableView.scrollEnabled = false;
        [_operationTableView registerClass:[RCMicOperationTableCell class] forCellReuseIdentifier:MicOperationTableViewCell];
    }
    return _operationTableView;
}

@end
