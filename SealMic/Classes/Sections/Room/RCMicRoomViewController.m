//
//  RCMicRoomViewController.m
//  SealMic
//
//  Created by lichenfeng on 2020/5/26.
//  Copyright © 2020 rongcloud. All rights reserved.
//
#import "GiftAnimationViewController.h"
#import "RCMicRoomViewController.h"
#import "RCMicRoomNavigationView.h"
#import "RCMicBroadcastView.h"
#import "RCMicUtil.h"
#import "RCMicMacro.h"
#import "RCMicParticipantsArea.h"
#import "RCMicChatView.h"
#import "RCMicInputBar.h"
#import "RCMicRoomToolBar.h"
#import "RCMicBlinkExcelView.h"
#import "RCMicBottomDialogViewController.h"
#import "RCMicBottomDialogScrollPageViewController.h"
#import "RCMicBottomDialogHorizontalViewController.h"
#import "RCMicNoticeAlertController.h"
#import "RCMicActiveWheel.h"
#import "RCMicEnumDialogDefine.h"
#import "RCMicAlertViewController.h"

#define InputBarHeight 50
#define ToolBarHeight 50
#define ResponseWaiting 15

@interface RCMicRoomViewController ()<RCMicRoomNavigationViewDelegate, RCMicRoomToolBarDelegate, RCMicParticipantsAreaDelegate, RCMicInputBarControlDelegate, RCMicChatViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) RCMicRoomViewModel *viewModel;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) RCMicRoomNavigationView *customNavigationView;//导航栏
@property (nonatomic, strong) RCMicRoomToolBar *customToolBar;//底部工具栏
@property (nonatomic, strong) RCMicParticipantsArea *participantsArea;//麦位区域
@property (nonatomic, strong) RCMicChatView *chatView;//聊天区域
@property (nonatomic, strong) RCMicInputBar *inputBar;//输入框
@property (nonatomic, strong) RCMicBlinkExcelView *blinkExcelView;//debug 模式展示数据展示区域
@property (nonatomic, strong) RCMicBottomDialogViewController *dialogViewController;//弹框样式
@property (nonatomic, strong) NSIndexPath *currentBgSoundIndexPath;//当前房间伴音选择项纪录
@property (nonatomic, strong) NSTimer *wheelDismissTimer;//控制主持人转让相关操作页面弹出的转轮
@property (nonatomic, assign) BOOL joinRoomSuccess;//是否已成功加入房间
@property (nonatomic, assign) BOOL kvSyncSuccess;//是否已完成 IM 聊天室 KV 信息同步
@end

@implementation RCMicRoomViewController

#pragma mark - Life cycle
- (instancetype)initWithRoomInfo:(id)roomInfo Role:(RCMicRoleType)role {
    self = [super init];
    if (self) {
        _joinRoomSuccess = NO;
        _kvSyncSuccess = NO;
        [self initViewModelWithRoomInfo:roomInfo role:role];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubviews];
    [self addConstraints];
    [self joinMicRoom];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveKickOutNofitication:) name:RCMicKickedOutNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //离开页面停止房间里的混音
    [[RCMicRTCService sharedService] stopMixingMusic];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //退出相关房间
    [_viewModel quitMicRoom:^{
        RCMicLog(@"quit mic room success!");
    } error:^{
        RCMicLog(@"quit mic room error!");
        //这里根据应用实际情况确定是否需要重试
    }];
}

- (void)dealloc {
    //释放资源
    [_viewModel descory];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private method
- (void)initViewModelWithRoomInfo:(RCMicRoomInfo *)roomInfo role:(RCMicRoleType)role {
    __weak typeof(self) weakSelf = self;
    _viewModel = [[RCMicRoomViewModel alloc] initWithRoomInfo:roomInfo role:role];
    //聊天室 KV 信息同步完成
    [_viewModel setKvSyncCompleted:^{
        weakSelf.kvSyncSuccess = YES;
        [weakSelf checkRoomStatus];
    }];
    //消息区域更新
    [_viewModel setMessageChanged:^(RCMicMessageChangedType type, NSArray * _Nonnull indexs) {
        [weakSelf.chatView updateTableViewWithType:type indexs:indexs];
    }];
    //麦位区域更新
    [_viewModel setParticipantChanged:^(NSArray<NSString *> * _Nonnull keys) {
        [weakSelf.participantsArea updateCollectionViewWithKeys:keys];
    }];
    //当前用户发布或订阅了直播间合流（发布表明在麦位，订阅表明不在麦位）
    [_viewModel setPublishOrSubscribeStream:^(BOOL isPublish) {
       //这里实际角色可能是主持人，但是主持人和参会者底部 toolbar 展示的内容一致，所以除了观众都可以认为是参会者
        RCMicRoleType role = isPublish ? RCMicRoleType_Participant : RCMicRoleType_Audience;
        [weakSelf.customToolBar updateWithRoleType:role];
        //每次角色转换需要重新设置扬声器状态
        RCMicSpeakerState state = weakSelf.viewModel.useSpeaker ? RCMicSpeakerStateOpen : RCMicSpeakerStateClose;
        [weakSelf setSpeakerState:state];
    }];
    //直播间延迟更新
    [_viewModel setDelayInfoChanged:^(NSInteger delay) {
        [weakSelf.customNavigationView updateDelay:delay];
    }];
    //debug 模块统计信息更新
    [_viewModel setDebugInfoChanged:^(NSArray * _Nonnull array) {
        weakSelf.blinkExcelView.array = array;
    }];
    //直播间在线人数更新
    [_viewModel setOnlineCountChanged:^(NSInteger onlineCount) {
        [weakSelf.customNavigationView updateOnlineCount:onlineCount];
    }];
    //有人排麦状态更新
    [_viewModel setWaitingStateChanged:^(BOOL waiting) {
        [weakSelf.customNavigationView showTipLabel:waiting];
    }];
    //收到礼物消息
    [_viewModel setReceivedGiftMessage:^(RCMicGiftMessage *giftMessage) {
        [weakSelf presentGiftBigAnimationViewController:giftMessage.content gaveName:giftMessage.senderUserInfo.name tag:giftMessage.tag];
    }];
    //收到跨房间礼物广播消息
    [_viewModel setReceivedBroadcastMessage:^(RCMicBroadcastGiftMessage * _Nonnull broadcastMessage) {
        [weakSelf showBroadcastView:broadcastMessage];
    }];
    //麦克风状态改变
    [_viewModel setMicroPhoneStateChanged:^(BOOL enable) {
        RCMicMicrophoneState state = enable ? RCMicMicrophoneStateNormal : RCMicMicrophoneStateSilent;
        [weakSelf setMicrophoneState:state];
    }];
    //收到请求接管主持人的消息
    [_viewModel setTakeOverHostRequest:^(NSString * _Nonnull name, NSString * _Nonnull userId) {
        [weakSelf showAlertWithOperator:name identifier:userId isHostTransfer:NO];
    }];
    //收到主持人转让的消息
    [_viewModel setHostTransferRequest:^(NSString * _Nonnull name, NSString * _Nonnull userId) {
        [weakSelf showAlertWithOperator:name identifier:userId isHostTransfer:YES];
    }];
    //收到主持人的响应
    [_viewModel setTakeOverHostResponse:^(NSString * _Nonnull name, NSString * _Nonnull userId, BOOL result) {
        [weakSelf stopActiveWheelWithResponse:result isTimeout:NO];
    }];
    //收到被转让者的响应
    [_viewModel setHostTransferResponse:^(NSString * _Nonnull name, NSString * _Nonnull userId, BOOL result) {
        [weakSelf stopActiveWheelWithResponse:result isTimeout:NO];
    }];
    //麦位转换过程中相关错误回调
    [_viewModel setShowTipWithErrorInfo:^(NSString * _Nonnull description) {
        [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:description];
    }];
}

- (void)addSubviews {
    [self.view addGestureRecognizer:self.tapGesture];
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.customNavigationView];
    [self.view addSubview:self.participantsArea];
    [self.view addSubview:self.chatView];
    [self.view addSubview:self.customToolBar];
    [self.view addSubview:self.inputBar];
    [self.view addSubview:self.blinkExcelView];
}

- (void)addConstraints {
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.customNavigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        CGFloat margin = [RCMicUtil statusBarHeight];
        make.top.equalTo(self.view).with.offset(margin);
        make.height.mas_equalTo(44);
    }];
    
    [self.participantsArea mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view);
        make.top.equalTo(self.customNavigationView.mas_bottom);
        make.height.mas_equalTo(339);
    }];
    
    [self.chatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.participantsArea.mas_bottom);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.customToolBar.mas_top);
    }];
    
    [self.customToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(ToolBarHeight);
        CGFloat bottomMargin = [RCMicUtil bottomSafeAreaHeight];
        make.bottom.equalTo(self.view).with.offset(-bottomMargin);
    }];
}

- (void)joinMicRoom {
    __weak typeof(self) weakSelf = self;
    //加入房间
    [self.viewModel joinMicRoom:^{
        [weakSelf.viewModel sendTextMessage:RCMicLocalizedNamed(@"room_join") error:^(RCErrorCode errorCode) {
        }];
        //加入房间后需要等待 viewmodel 中的 KvSyncCompleted 回调才能开始从 聊天室 KV 中拉取麦位信息
        weakSelf.joinRoomSuccess = YES;
        [weakSelf checkRoomStatus];
    } imError:^{
        RCMicMainThread(^{
            [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"room_joinIM_failed")];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        })
    } rtcError:^{
        RCMicMainThread(^{
            [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"room_joinRTC_failed")];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        })
    }];
}

- (void)checkRoomStatus {
    //加入房间完成并且 KV 同步完成后才能开始加载初始房间数据
    if (self.joinRoomSuccess && self.kvSyncSuccess) {
        [self loadDataAndPublishAudioStream];
    }
}

- (void)loadDataAndPublishAudioStream {
    __weak typeof(self) weakSelf = self;
    //加载麦位数据
    [self.viewModel loadAllParticipantViewModel:^{
        RCMicMainThread(^{
            [weakSelf.participantsArea reloadData];
        })
    } error:^(RCErrorCode errorCode) {
        RCMicMainThread(^{
            [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"room_getParticipantInfo_failed")];
            //进入房间获取麦位初始信息失败后退出聊天室
            [weakSelf backAction];
        })
    }];
    
    //发布或订阅音频流，失败后根据应用实际需求处理 UI 即可
    [self.viewModel publishOrSubscribeAudioStream:^{
    } error:^{
        RCMicMainThread(^{
            [RCMicActiveWheel showPromptHUDAddedTo:weakSelf.view text:RCMicLocalizedNamed(@"room_publishOrSubscribeStream_failed")];
        })
    }];
    
    //同步下当前房间人数
    [self.viewModel syncOnlineCount:^{
    } error:^{
    }];
    
    //同步下当前是否有人排麦的信息
    [self.viewModel syncParticipantWaitingState:^{
    } error:^{
    }];
}

- (void)shouldShowInputBar:(BOOL)show {
    //如果没有被禁言按正常流程操作
    if (show) {
        self.inputBar.hidden = NO;
        [self.inputBar becomeFirstResponderIfNeed];
    } else {
        self.inputBar.hidden = YES;
        [self.inputBar resignFirstResponderIfNeed];
    }
}

/**
 * 弹出提示框（参会者收到主持人转让申请或者主持人收到接管申请时弹出）
 *
 * @param name 发起操作者的名字
 * @param userId 发起操作者的 Id
 * @param isHostTransfer 是否是主持人转让的申请
 */
- (void)showAlertWithOperator:(NSString *)name identifier:(NSString *)userId isHostTransfer:(BOOL)isHostTransfer {
    if (isHostTransfer) {
        NSString *title = [NSString stringWithFormat:@"%@ %@",name,RCMicLocalizedNamed(@"room_alert_transferHost")];
        RCMicAlertViewController *alertVC = [[RCMicAlertViewController alloc] init];
        alertVC.alertMessageLabel.text = title;
        alertVC.agreeBtnAction = ^{
            [self.viewModel acceptHostTransfer:YES error:^(RCMicHTTPCode errorCode) {
                [RCMicUtil showTipWithErrorCode:errorCode];
            }];
        };
        alertVC.refuseBtnAction = ^{
            [self.viewModel acceptHostTransfer:NO error:^(RCMicHTTPCode errorCode) {
                [RCMicUtil showTipWithErrorCode:errorCode];
            }];
        };
        [self configAndPresentController:alertVC];
    }else {
        NSString *title = [NSString stringWithFormat:@"%@ %@",name,RCMicLocalizedNamed(@"room_alert_takeover")];
        RCMicAlertViewController *alertVC = [[RCMicAlertViewController alloc] init];
        alertVC.alertMessageLabel.text = title;
        alertVC.agreeBtnAction = ^{
            [self.viewModel agreeHostTakeOver:YES userId:userId error:^(RCMicHTTPCode errorCode) {
                [RCMicUtil showTipWithErrorCode:errorCode];
            }];
        };
        alertVC.refuseBtnAction = ^{
            [self.viewModel agreeHostTakeOver:NO userId:userId error:^(RCMicHTTPCode errorCode) {
                [RCMicUtil showTipWithErrorCode:errorCode];
            }];
        };
        [self configAndPresentController:alertVC];
    }
}

- (void)setSpeakerState:(RCMicSpeakerState)state {
    BOOL enable = state == RCMicSpeakerStateOpen ? YES : NO;
    [self.viewModel setUseSpeaker:enable];
    self.customToolBar.speakerState = state;
}

- (void)setMicrophoneState:(RCMicMicrophoneState)state {
    BOOL enable = state == RCMicMicrophoneStateNormal ? YES : NO;
    [self.viewModel setUseMicrophone:enable];
    self.customToolBar.microPhoneState = state;
}

- (void)activeWheelTimerAction {
    [self stopActiveWheelWithResponse:NO isTimeout:YES];
}

/**
 * 结束主持人转让及接管相关转轮
 *
 * @param accept 对方是否同意
 * @param timeout 是否是定时器触发的结束
 */
- (void)stopActiveWheelWithResponse:(BOOL)accept isTimeout:(BOOL)timeout {
    [RCMicActiveWheel hideHUDForView:RCMicKeyWindow animated:YES];
    if (timeout) {
        [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"room_tip_noresponse")];
    } else {
        if (!accept) {
            [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"room_tip_refuse")];
        }
    }
    [self.wheelDismissTimer invalidate];
    self.wheelDismissTimer = nil;
}

- (void)showBroadcastView:(RCMicBroadcastGiftMessage *)message {
    RCMicBroadcastView *view = [[RCMicBroadcastView alloc] initWithFrame:CGRectMake(RCMicScreenWidth, CGRectGetMaxY(self.customNavigationView.frame), [RCMicBroadcastView contentWidthWithMessage:message], 24)];
    [view updateContentWithMessage:message];
    [self.view addSubview:view];
    [UIView animateWithDuration:7 animations:^{
        CGRect finalRect = view.frame;
        finalRect.origin.x = -view.frame.size.width;
        view.frame = finalRect;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

- (void)configAndPresentController:(UIViewController *)controller {
    controller.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Actions
- (void)tapAction {
    [self shouldShowInputBar:NO];
}

- (void)backAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/*
 messageViewModel 如果消息viewModel不为空 说明是点击聊天室的回调
 */
- (void)dialogBlockAction:(DIALOGOPERATIONTYPE)type participantViewModel:(RCMicParticipantViewModel *)participantViewModel messageViewModel:(RCMicMessageViewModel *)messageViewModel {
    __weak typeof(self) weakSelf = self;
    RCUserInfo *userInfo = messageViewModel ? messageViewModel.senderInfo : participantViewModel.userInfo;
    
    switch (type) {
        case DIALOGOPERATIONTYPE_GiveGift:{
            [weakSelf presentGiftDialogViewController:true userInfo:userInfo];
            break;
        }
        case DIALOGOPERATIONTYPE_SendMessage:{
            [weakSelf shouldShowInputBar:YES];
            [weakSelf.inputBar setText:[NSString stringWithFormat:@"@%@ ",userInfo.name]];
            break;
        }
        case DIALOGOPERATIONTYPE_ApplyParticipant:{
            [weakSelf.viewModel applyParticipant:^(RCMicHTTPCode errorCode) {
                [RCMicUtil showTipWithErrorCode:errorCode];
            }];
            break;
        }
        case DIALOGOPERATIONTYPE_TakeOverHost:{
            [weakSelf.viewModel takeOverHost:^(BOOL showWheel) {
                if (showWheel) {
                    //发出请求后显示转轮，指定时间后对方未响应则此次操作失败，提示未响应
                    RCMicMainThread(^{
                        [RCMicActiveWheel showHUDAddedTo:RCMicKeyWindow];
                        weakSelf.wheelDismissTimer = [NSTimer scheduledTimerWithTimeInterval:ResponseWaiting target:weakSelf selector:@selector(activeWheelTimerAction) userInfo:nil repeats:NO];
                    })
                }
            } error:^(RCMicHTTPCode errorCode) {
                [RCMicUtil showTipWithErrorCode:errorCode];
            }];
            break;
        }
        case DIALOGOPERATIONTYPE_KickParticipantOut:{
            //判断当前是否是主持人，然后根据当前角色来调用 自己主动下麦 或 将参会者下麦 接口
            if (weakSelf.viewModel.role == RCMicRoleType_Host){
                [weakSelf.viewModel kickParticipantOut:userInfo.userId error:^(RCMicHTTPCode errorCode) {
                    [RCMicUtil showTipWithErrorCode:errorCode];
                }];
            }else {
                [weakSelf.viewModel giveUpParticipant:^{
                } error:^(RCMicHTTPCode errorCode) {
                    [RCMicUtil showTipWithErrorCode:errorCode];
                }];
            }
            break;
        }
        case DIALOGOPERATIONTYPE_ParticipantOpen:{
            [weakSelf.viewModel changeParticipantState:RCMicParticipantStateNormal position:participantViewModel.participantInfo.position success:^{
            } error:^(RCMicHTTPCode errorCode) {
                [RCMicUtil showTipWithErrorCode:errorCode];
            } ];
            break;
        }
        case DIALOGOPERATIONTYPE_ParticipantClose:{
            [weakSelf.viewModel changeParticipantState:RCMicParticipantStateSilent position:participantViewModel.participantInfo.position success:^{
            } error:^(RCMicHTTPCode errorCode) {
                [RCMicUtil showTipWithErrorCode:errorCode];
            }];
            break;
        }
        case DIALOGOPERATIONTYPE_TransferHost:{
            [weakSelf.viewModel transferHost:userInfo.userId success:^{
                //发出请求后显示转轮，指定时间后对方未响应则此次操作失败，提示未响应
                RCMicMainThread(^{
                    [RCMicActiveWheel showHUDAddedTo:RCMicKeyWindow];
                    weakSelf.wheelDismissTimer = [NSTimer scheduledTimerWithTimeInterval:ResponseWaiting target:weakSelf selector:@selector(activeWheelTimerAction) userInfo:nil repeats:NO];
                })
            } error:^(RCMicHTTPCode errorCode) {
                [RCMicUtil showTipWithErrorCode:errorCode];
            }];
            break;
        }
        case DIALOGOPERATIONTYPE_KickUserOut:{
            [weakSelf.viewModel kickUserOut:userInfo.userId success:^{
            } error:^(RCMicHTTPCode errorCode) {
                [RCMicUtil showTipWithErrorCode:errorCode];
            }];
        }
            break;
        case DIALOGOPERATIONTYPE_SetParticipantLock:{
            [weakSelf.viewModel changeParticipantState:RCMicParticipantStateClosed position:participantViewModel.participantInfo.position success:^{
            } error:^(RCMicHTTPCode errorCode) {
                [RCMicUtil showTipWithErrorCode:errorCode];
            }];
        }
            break;
        case DIALOGOPERATIONTYPE_SetParticipantUnLock:{
            [weakSelf.viewModel changeParticipantState:RCMicParticipantStateNormal position:participantViewModel.participantInfo.position success:^{
            } error:^(RCMicHTTPCode errorCode) {
                [RCMicUtil showTipWithErrorCode:errorCode];
            }];
        }
            break;
        case DIALOGOPERATIONTYPE_InvitationConnectMic:{
            [weakSelf presentScrollPageViewController:RCMicOnLineList];
        }
            break;
            //下面是点击聊天室才触发的回调 需要 messageViewModel
        case DIALOGOPERATIONTYPE_InvitationParticipant:{
            [weakSelf.viewModel inviteParticipant:messageViewModel.message.senderUserId error:^(RCMicHTTPCode errorCode) {
                [RCMicUtil showTipWithErrorCode:errorCode];
            } ];
            break;
        }
        case DIALOGOPERATIONTYPE_SetUserBanned:{
            [weakSelf.viewModel enableSendMessage:NO user:messageViewModel.message.senderUserId error:^(RCMicHTTPCode errorCode) {
                [RCMicUtil showTipWithErrorCode:errorCode];
            }];
            break;
        }
        case DIALOGOPERATIONTYPE_DeleteMessage:{
            [weakSelf.viewModel recallMessageWithMessageViewModel:messageViewModel error:^(RCErrorCode errorCode) {
                RCMicMainThread(^{
                    [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"room_recall_failed")];
                })
            }];
        }
            
        default:
            break;
    };
}

- (void)speakerAction {
    RCMicSpeakerState state = self.customToolBar.speakerState == RCMicSpeakerStateOpen ? RCMicSpeakerStateClose : RCMicSpeakerStateOpen;
    [self setSpeakerState:state];
}

- (void)microphoneAction {
    RCMicMicrophoneState microphoneState = self.customToolBar.microPhoneState == RCMicMicrophoneStateNormal ? RCMicMicrophoneStateSilent : RCMicMicrophoneStateNormal;
    RCMicParticipantState participantState = microphoneState == RCMicMicrophoneStateNormal ? RCMicParticipantStateNormal : RCMicParticipantStateSilent;
    
    [self.viewModel changeParticipantState:participantState position:-1 success:^{
        RCMicMainThread(^{
            [self setMicrophoneState:microphoneState];
        })
    } error:^(RCMicHTTPCode errorCode) {
        [RCMicUtil showTipWithErrorCode:errorCode];
    }];
}

/// 礼物 按钮点击进来 是给全部用户送礼物
- (void)giftAction {
    [self presentGiftDialogViewController:false userInfo:nil];
}

/// 伴音
- (void)musicAction {
    [self presentBgMusicViewController:RCMicLocalizedNamed(@"along_sound")];
}

/// 变声(这期不做具体效果，只是展示)
- (void)metaPhoneAction {
    [self presentBgMusicViewController:RCMicLocalizedNamed(@"change_sound")];
}

/// 设置
- (void)setAction {
    [self.dialogViewController clickSetButtonDialogStyle];
    __weak typeof(self) weakSelf = self;
    self.dialogViewController.changeReceiverBlock = ^(BOOL isReceiver) {
        RCMicSpeakerState state = isReceiver ? RCMicSpeakerStateClose : RCMicSpeakerStateOpen;
        [weakSelf setSpeakerState:state];
    };
    self.dialogViewController.debugBlock = ^(BOOL open) {
        weakSelf.blinkExcelView.hidden = !open;
        weakSelf.viewModel.debugDisplay = open;
    };
    [self.navigationController presentViewController:self.dialogViewController animated:true completion:nil];
}

/// 公告
- (void)noticeAction {
    RCMicNoticeAlertController *noticeViewController = [[RCMicNoticeAlertController alloc] init];
    [self configAndPresentController:noticeViewController];
}

/// 排麦
- (void)handleAction {
    [self presentScrollPageViewController:RCMicRankList];
}

- (void)presentBgMusicViewController:(NSString *)title {
    RCMicBottomDialogHorizontalViewController *dialogTestViewController = [[RCMicBottomDialogHorizontalViewController alloc] init];
    dialogTestViewController.isGiftStyle = false;
    dialogTestViewController.isHead = false;
    dialogTestViewController.dialogTitle = title;
    dialogTestViewController.viewModel = self.viewModel;
    if ([title isEqualToString:RCMicLocalizedNamed(@"along_sound")]){
        dialogTestViewController.currentBgSoundIndexPath = self.currentBgSoundIndexPath;
        dialogTestViewController.seletedItemBlock = ^(NSIndexPath * _Nonnull indexPath) {
            self.currentBgSoundIndexPath = indexPath;
        };
    }
    [self configAndPresentController:dialogTestViewController];
}

- (void)presentScrollPageViewController:(RCMicPageViewListState)listType {
    RCMicBottomDialogScrollPageViewController *dialogTestViewController = [[RCMicBottomDialogScrollPageViewController alloc] init];
    dialogTestViewController.listType = listType;
    dialogTestViewController.roomId = self.viewModel.roomInfo.roomId;
    dialogTestViewController.viewModel = self.viewModel;
    [self configAndPresentController:dialogTestViewController];
}

- (void)presentGiftDialogViewController:(BOOL)isHead userInfo:(RCUserInfo *)userInfo{
    __weak typeof(self) weakSelf = self;
    RCMicBottomDialogHorizontalViewController *dialogTestViewController = [[RCMicBottomDialogHorizontalViewController alloc] init];
    dialogTestViewController.isGiftStyle = true;
    dialogTestViewController.isHead = isHead;
    dialogTestViewController.dialogTitle = RCMicLocalizedNamed(@"gift");
    dialogTestViewController.userInfo = userInfo;
    dialogTestViewController.seletedGiftItemBlock = ^(RCMicGiftInfo *giftInfo) {
        //礼物消息格式 xxx 给 xxx 送了 xx
        NSString *giftContentString = @"";
        if (userInfo){
            giftContentString = [NSString stringWithFormat:@" 给 %@ 送了%@",userInfo.name,giftInfo.name];
        }else {
            giftContentString = [NSString stringWithFormat:@" 给 所有人 送了%@",giftInfo.name];
        }
        //先发聊天室消息，发送成功后去做动画展示和类型判断，失败的话根据是被禁言还是别的原因 弹出相应提示。
        [weakSelf.viewModel sendGiftMessage:giftContentString giftInfo:giftInfo success:^(RCMessage * _Nonnull message) {
            [weakSelf presentGiftBigAnimationViewController:giftContentString gaveName:[RCMicAppService sharedService].currentUser.userInfo.name tag:giftInfo.tag];
            if (giftInfo.type == RCMicGiftTypeSportsCar) {
                [weakSelf.viewModel sendBroadcastGiftMessage:giftInfo];
            }
        } error:^(RCErrorCode errorCode, RCMessage * _Nonnull message) {
            if (errorCode == FORBIDDEN_IN_CHATROOM) {
                RCMicMainThread(^{
                    [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"room_banned_alert")];
                });
            }
        }];
        
    };
    [self configAndPresentController:dialogTestViewController];
}

- (void)presentGiftBigAnimationViewController:(NSString *)content gaveName:(NSString *)gaveName tag:(NSString *)tag{
    RCMicMainThread(^{
        GiftAnimationViewController *dialogTestViewController = [[GiftAnimationViewController alloc] init];
        dialogTestViewController.content = content;
        dialogTestViewController.gaveName = gaveName;
        dialogTestViewController.tag = tag;
        [self configAndPresentController:dialogTestViewController];
    });
}

#pragma mark - Notification selectors
- (void)receiveKickOutNofitication:(NSNotification *)notification {
    NSString *roomId = notification.userInfo[@"roomId"];
    if ([roomId isEqualToString:self.viewModel.roomInfo.roomId]) {
        RCMicMainThread(^{
            [self backAction];
            [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"room_kickout")];
        })
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UICollectionView class]] || [touch.view isKindOfClass:[UICollectionReusableView class]] || [touch.view isKindOfClass:[UITableView class]]) {
        return YES;
    }
    return NO;
}

#pragma mark - RCMicRoomNavigationViewDelegate
- (void)roomNavigationView:(RCMicRoomNavigationView *)navigationView didSelectItemWithTag:(RCMicRoomNavigationViewTag)tag {
    
    switch (tag) {
        case RCMicRoomNavigationViewBackButton:
            [self backAction];
            break;
        case RCMicRoomNavigationViewSetButton:
            [self setAction];
            break;
        case RCMicRoomNavigationViewMicHandleButton:
            [self handleAction];
            break;
        case RCMicRoomNavigationViewNoticeButton:
            [self noticeAction];
            break;
            
        default:
            break;
    }
}

#pragma mark - RCMicParticipantsAreaDelegate
- (void)participantsArea:(RCMicParticipantsArea *)participantsArea didSelectItemWithViewModel:(RCMicParticipantViewModel *)participantViewModel {
    
    //当前点击麦位区域弹框样式
    __weak typeof(self) weakSelf = self;
    //当前点击麦位有人
    if (participantViewModel.participantInfo.userId.length > 0) {
        //如果有用户信息先去获取下用户信息
        [participantViewModel getUserInfo:^(RCMicUserInfo * _Nullable userInfo) {
            [weakSelf.dialogViewController clickParticipantsAreaDialogStyle:participantViewModel userInfo:userInfo];
            RCMicMainThread(^{
                [weakSelf.navigationController presentViewController:weakSelf.dialogViewController animated:true completion:nil];
            });
        }];
    } else {
        //如果当前是  参会者 点其他空麦位 不弹对话框 点主持人麦位除外
        if (self.viewModel.role != RCMicRoleType_Participant || participantViewModel.participantInfo.isHost){
            [self.dialogViewController clickParticipantsAreaDialogStyle:participantViewModel userInfo:nil];
            RCMicMainThread(^{
                [self.navigationController presentViewController:weakSelf.dialogViewController animated:true completion:nil];
            });
        }
    }
}

#pragma mark - RCMicRoomToolBarDelegate
- (void)roomToolBar:(RCMicRoomToolBar *)toolBar didSelectItemWithTag:(RCMicRoomToolBarViewTag)tag {
    switch (tag) {
        case RCMicRoomToolBarMessageButton:
            [self shouldShowInputBar:YES];
            break;
        case RCMicRoomToolBarMusicButton:
            [self musicAction];
            break;
        case RCMicRoomToolBarMetaPhoneButton:
            [self metaPhoneAction];
            break;
        case RCMicRoomToolBarGiftButton:
            [self giftAction];
            break;
        case RCMicRoomToolBarSpeakerButton:
            [self speakerAction];
            break;
        case RCMicRoomToolBarMicrophoneButton:
            [self microphoneAction];
            break;
        default:
            break;
    }
}

#pragma mark - RCMicChatViewDelegate
- (void)chatView:(RCMicChatView *)chatView didTapMessageCell:(RCMicMessageBaseCell *)cell withViewModel:(RCMicMessageViewModel *)messageViewModel {
    //如果主持人点击聊天室消息 可以对观众进行操作
    if (self.viewModel.role == RCMicRoleType_Host){
        [self.dialogViewController clickChatViewDialogStyle:messageViewModel];
        [self.navigationController presentViewController:self.dialogViewController animated:true completion:nil];
    }
    
}

#pragma mark - RCMicInputBarControlDelegate
- (void)inputBar:(RCMicInputBar *)inputBar didTouchsendButton:(NSString *)text {
    [inputBar clearInputView];
    [self shouldShowInputBar:NO];
    [self.viewModel sendTextMessage:text error:^(RCErrorCode errorCode) {
        if (errorCode == FORBIDDEN_IN_CHATROOM) {
            RCMicMainThread(^{
                [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"room_banned_alert")];
            });
        }
    }];
}

#pragma mark - Getters & Setters
- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        _tapGesture.delegate = self;
    }
    return _tapGesture;
}

- (UIImageView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _backgroundView.image = [UIImage imageNamed:@"room_background"];
    }
    return _backgroundView;
}

- (RCMicRoomNavigationView *)customNavigationView {
    if (!_customNavigationView) {
        _customNavigationView = [[RCMicRoomNavigationView alloc] initWithFrame:CGRectZero viewModel:self.viewModel];
        _customNavigationView.delegate = self;
    }
    return _customNavigationView;
}

- (RCMicRoomToolBar *)customToolBar {
    if (!_customToolBar) {
        _customToolBar = [[RCMicRoomToolBar alloc] initWithFrame:CGRectZero];
        _customToolBar.delegate = self;
        [_customToolBar updateWithRoleType:self.viewModel.role];
    }
    return _customToolBar;
}

- (RCMicParticipantsArea *)participantsArea {
    if (!_participantsArea) {
        _participantsArea = [[RCMicParticipantsArea alloc] initWithFrame:CGRectZero viewModel:self.viewModel];
        _participantsArea.delegate = self;
    }
    return _participantsArea;
}

- (RCMicChatView *)chatView {
    if (!_chatView) {
        _chatView = [[RCMicChatView alloc] initWithFrame:CGRectZero viewModel:self.viewModel];
        _chatView.delegate = self;
    }
    return _chatView;
}

- (RCMicInputBar *)inputBar {
    if (!_inputBar) {
        CGFloat height = [RCMicUtil bottomSafeAreaHeight] + InputBarHeight;
        CGFloat originY = RCMicScreenHeight - height;
        _inputBar = [[RCMicInputBar alloc] initWithFrame:CGRectMake(0, originY, RCMicScreenWidth, height)];
        _inputBar.delegate = self;
        _inputBar.hidden = YES;
    }
    return _inputBar;
}

- (RCMicBlinkExcelView *)blinkExcelView {
    if (!_blinkExcelView) {
        _blinkExcelView = [[RCMicBlinkExcelView alloc] initWithFrame:CGRectMake(0, 0, RCMicScreenWidth, RCMicScreenHeight) viewModel:self.viewModel];
        _blinkExcelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
        _blinkExcelView.hidden = YES;
    }
    return _blinkExcelView;
}

- (RCMicBottomDialogViewController *)dialogViewController {
    if (!_dialogViewController) {
        _dialogViewController = [[RCMicBottomDialogViewController alloc] init];
        _dialogViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        //设置弹框展现时过渡的动画样式
        _dialogViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //默认把房间的viewModel传进去
        _dialogViewController.viewModel = self.viewModel;
        
        //弹框回调
        __weak typeof(self) weakSelf = self;
        //点击麦位弹框选择操作项回调
        _dialogViewController.clickParticipantSelectedCellBlock = ^(DIALOGOPERATIONTYPE type, RCMicParticipantViewModel * _Nonnull participantViewModel) {
            [weakSelf dialogBlockAction:type participantViewModel:participantViewModel messageViewModel:nil];
        };
        //点击聊天室弹框选择操作项回调
        _dialogViewController.clickChatViewSelectedCellBlock = ^(DIALOGOPERATIONTYPE type, RCMicMessageViewModel * _Nonnull messageViewModel) {
            [weakSelf dialogBlockAction:type participantViewModel:nil messageViewModel:messageViewModel];
        };
        
    }
    return _dialogViewController;
}

@end
