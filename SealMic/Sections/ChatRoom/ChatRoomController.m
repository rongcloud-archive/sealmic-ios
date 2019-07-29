//
//  ChatRoomController.m
//  SealMic
//
//  Created by 张改红 on 2019/5/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ChatRoomController.h"
#import "MicSeatView.h"
#import "HeaderView.h"
#import "ChatAreaView.h"
#import "ClassroomService.h"
#import "RoomInfo.h"
#import "NaviView.h"
#import "SettingView.h"
#import "ChangeBgViewController.h"
#import "MemberListView.h"
#import "IMService.h"
#import "LoginHelper.h"
#define HeaderViewHeight 120
#define MicSeatViewHeight 200
#define ChatAreaViewHeight 300
#define HeaderViewHeight 120
#define MicSeatViewTotalHeight 240
@interface ChatRoomController()<SettingViewDelegate, NaviViewDelegate, MicSeatViewDelegate, ClassroomDelegate, MemberListViewDelegate, RongRTCRoomDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) NaviView *naviView;
@property (nonatomic, strong) UIImageView *backgroudView;
@property (nonatomic, strong) MicSeatView *seatView;
@property (nonatomic, strong) HeaderView *headerView;
@property (nonatomic, strong) ChatAreaView *chatAreaView;
@property (nonatomic, strong) SettingView *settingView;
@property (nonatomic, strong) MemberListView *memberListView;
@end
@implementation ChatRoomController
#pragma mark - life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view = self.backgroudView;
    [[RTCService sharedService] useSpeaker:YES];
    [[RTCService sharedService] setMicrophoneDisable:YES];
    [[RTCService sharedService] setRTCRoomDelegate:self];
    [ClassroomService sharedService].classroomDelegate = self;
    [self addSubviews];
    [self setNaviItem];
    [self addObserver];
    [self addGesture];
    [[IMService sharedService] receiveFakeCurrentUserJoinMessage];
    [self.chatAreaView.extensionView reloadExtensionView];
    [self pulishCurrentUserAudioStream];
    [self subscribeRoomCreatorStream];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ClassroomDelegate
- (void)classroomService:(ClassroomService *)service userDidJoin:(NSString *)userId{
    [self.naviView reloadTitle];
    [self.memberListView reloadMemberList];
}

- (void)classroomService:(ClassroomService *)service userDidLeave:(NSString *)userId{
    [self.naviView reloadTitle];
    [self.memberListView reloadMemberList];
}

- (void)classroomService:(ClassroomService *)service userDidKicked:(NSString *)userId{
    [self.naviView reloadTitle];
    [self back];
}

- (void)classroomService:(ClassroomService *)service userDidSpeak:(NSString *)userId{
    if([userId isEqualToString:[ClassroomService sharedService].currentUser.userId]) {
        if(![ClassroomService sharedService].currentUserCanAnime) {
            return;
        }
    }
    if ([userId isEqualToString:[ClassroomService sharedService].currentRoom.creatorId]) {
        [self.headerView startAnimation];
    }else{
        MicPositionInfo *info = [[ClassroomService sharedService].currentRoom getMicPositionInfo:userId];
        if (info && info.userId.length > 0) {
            [self.seatView startAnimationInIndex:info.position];
        }
    }
}

//mic
- (void)classroomService:(ClassroomService *)service micDidChange:(NSString *)userId behavior:(MicBehaviorType)type from:(int)fPosition to:(int)tPostion{
    [self.seatView reloadSeatView];
    [self.chatAreaView.extensionView reloadExtensionView];
}

- (void)classroomService:(ClassroomService *)service micDidControl:(NSString *)userId behavior:(MicBehaviorType)type position:(int)p{
    [self.seatView reloadSeatView];
    [self.chatAreaView.extensionView reloadExtensionView];
    [self.memberListView reloadMemberList];
    if (type == MicBehaviorTypeKickOffMic && [userId isEqualToString:[ClassroomService sharedService].currentUser.userId]) {
        [self back];
    }else{
        [self updateCurrentSubscribeOrPulishStream:userId behavior:type];
    }
}

//bg
- (void)classroomService:(ClassroomService *)service backgroundDidChange:(int)bgId{
    self.backgroudView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bg_%d",bgId]];
}

//error
- (void)classroomService:(ClassroomService *)service errorDidOccur:(ErrorCode)code{
    
}

- (void)classroomDidDesory{
    [self.view showHUDMessage:MicLocalizedNamed(@"RoomDesory")];
    [[LoginHelper sharedInstance] logout:LogoutChatRoomTypeHasDetory success:^{
        
    } error:^(NSInteger code) {
        
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - RongRTCRoomDelegate
- (void)didPublishStreams:(NSArray <RongRTCAVInputStream *>*)streams {
    for (RongRTCAVInputStream *stream in streams) {
        MicPositionInfo *info = [[ClassroomService sharedService].currentRoom getMicPositionInfo:stream.userId];
        if ([stream.userId isEqualToString:info.userId] && (info.state & MicStateHold) && ![stream.userId isEqualToString:[ClassroomService sharedService].currentUser.userId]) {
            NSLog(@"didPublishStreams userId:%@",stream.userId);
            [[RTCService sharedService] subscribeRemoteUserAudioStream:stream.userId];
        }
    }
}

- (void)didConnectToStream:(RongRTCAVInputStream *)stream {
    NSLog(@"didConnectToStream userId:%@ streamID:%@",stream.userId,stream.userId);
}

- (void)didReportFirstKeyframe:(RongRTCAVInputStream *)stream {
    NSLog(@"didReportFirstKeyframe userId:%@ streamID:%@",stream.userId,stream.userId);
}

#pragma mark - NaviViewDelegate
- (void)back{
    [[LoginHelper sharedInstance] logout:[self isRoomCreator] ? LogoutChatRoomTypeDetory : LogoutChatRoomTypeLeave success:^{
        
    } error:^(NSInteger code) {
        
    }];
    dispatch_main_async_safe(^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark - MemberListViewDelegate
- (void)didClickJoinMic:(NSString *)targetId index:(int)index{
     [self controlMic:targetId index:index type:MicBehaviorTypePickupMic];
}

#pragma mark - MicSeatViewDelegate
- (void)didSelectPostion:(MicPositionInfo *)info{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    BOOL isPresentAlert = YES;
    NSArray<NSNumber *> *behaviorList = [[ClassroomService sharedService] getMicBehaviorList:info.position];
    for (NSNumber *number in behaviorList) {
        MicBehaviorType type = [number integerValue];
        if (type == MicBehaviorTypePickupMic) {
            [alertController addAction:[UIAlertAction actionWithTitle:MicLocalizedNamed(@"JoinMic") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self roomOwnerInviteUserJoinMic:info];
            }]];
        }else if (type == MicBehaviorTypeLockMic){
            [alertController addAction:[UIAlertAction actionWithTitle:MicLocalizedNamed(@"LockMic") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self controlMic:info.userId index:info.position type:type];
            }]];
        }else if (type == MicBehaviorTypeUnlockMic){
            [alertController addAction:[UIAlertAction actionWithTitle:MicLocalizedNamed(@"UnlocMic") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self controlMic:info.userId index:info.position type:type];
            }]];
        }else if (type == MicBehaviorTypeForbidMic){
            [alertController addAction:[UIAlertAction actionWithTitle:MicLocalizedNamed(@"MuteMic") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self controlMic:info.userId index:info.position type:type];
            }]];
        }else if (type == MicBehaviorTypeUnForbidMic){
            [alertController addAction:[UIAlertAction actionWithTitle:MicLocalizedNamed(@"UnmuteMic") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self controlMic:info.userId index:info.position type:type];
            }]];
        }else if (type == MicBehaviorTypeKickOffMic){
            [alertController addAction:[UIAlertAction actionWithTitle:MicLocalizedNamed(@"KickMic") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self controlMic:info.userId index:info.position type:type];
            }]];
        }else if (type == MicBehaviorTypeJumpOnMic){
            isPresentAlert = NO;
            [self joinMic:info];
        }else if (type == MicBehaviorTypeJumpDownMic){
            [alertController addAction:[UIAlertAction actionWithTitle:MicLocalizedNamed(@"LeaveMic") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([self isRoomCreator]) {
                    [self controlMic:info.userId index:info.position type:type];
                }else{
                    [self leaveMic:info];
                }
            }]];
        }else if (type == MicBehaviorTypeJumpToMic){
            isPresentAlert = NO;
            MicPositionInfo *currentUserPositionInfo = [[ClassroomService sharedService].currentRoom getMicPositionInfo:[ClassroomService sharedService].currentUser.userId];
            if (currentUserPositionInfo) {
                [self changeMic:currentUserPositionInfo.position toIndex:info.position];
            }
        }else{
            isPresentAlert = NO;
        }
    }
    if (isPresentAlert && behaviorList.count > 0) {
        [alertController addAction:[UIAlertAction actionWithTitle:MicLocalizedNamed(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint tp = [touch locationInView:self.seatView];
    if (CGRectContainsPoint(self.seatView.bounds, tp)) {
        return NO;
    }
    return YES;
}

#pragma mark - SettingViewDelegate
- (void)settingViewChangeBackground {
    [self.settingView hiden];
    ChangeBgViewController *changeBgVC = [[ChangeBgViewController alloc] init];
    [self.navigationController pushViewController:changeBgVC animated:YES];
}

- (void)settingViewQuitChatRoom {
    [self.settingView hiden];
    [self back];
}


#pragma mark - help
- (void)addSubviews{
    [self.view addSubview:self.headerView];
    [self.seatView showInView:self.view];
    [self.view addSubview:self.chatAreaView];
}

- (void)setNaviItem{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.naviView.backButton];
    if ([[ClassroomService sharedService].currentUser.userId isEqualToString:[ClassroomService sharedService].currentRoom.creatorId]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting"] style:(UIBarButtonItemStylePlain) target:self action:@selector(didClickSetting)];
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    }
}

- (void)pulishCurrentUserAudioStream{
    if ([self isRoomCreator]) {
        [[RTCService sharedService] pulishCurrentUserAudioStream];
    }else{
        MicPositionInfo *info = [[ClassroomService sharedService].currentRoom getMicPositionInfo:[ClassroomService sharedService].currentUser.userId];
        if (info) {
            [[RTCService sharedService] pulishCurrentUserAudioStream];
        }
    }
}

- (void)subscribeRoomCreatorStream{
    if (![self isRoomCreator]) {
        NSLog(@"subscribeRoomCreatorStream");
        [[RTCService sharedService] subscribeRemoteUserAudioStream:[ClassroomService sharedService].currentRoom.creatorId];
    }
}

- (void)updateCurrentSubscribeOrPulishStream:(NSString *)userId behavior:(MicBehaviorType)type{
    if (userId.length > 0 && (type == MicBehaviorTypeJumpOnMic || type == MicBehaviorTypePickupMic || type == MicBehaviorTypeJumpToMic)) {
        if ([userId isEqualToString:[ClassroomService sharedService].currentUser.userId]) {
            [self pulishCurrentUserAudioStream];
        }else{
            NSLog(@"updateCurrentSubscribeOrPulishStream %@",userId);
            [[RTCService sharedService] subscribeRemoteUserAudioStream:userId];
        }
    }else if(userId.length > 0 && (type == MicBehaviorTypeLockMic || type == MicBehaviorTypeKickOffMic || type == MicBehaviorTypeJumpDownMic)){
        if ([userId isEqualToString:[ClassroomService sharedService].currentUser.userId]) {
            [[RTCService sharedService] unpublishCurrentUserAudioStream];
        }else{
            [[RTCService sharedService] unsubscribeRemoteUserAudioStream:userId];
        }
    }
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRoomBg:) name:@"changeRoomBg" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(back) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChange:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

- (void)addGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)didTapView {
    [self.chatAreaView.inputBarControl resignResponder];
}

- (void)didClickSetting{
    [self.settingView showSettingViewInView:[UIApplication sharedApplication].keyWindow];
}

- (void)changeRoomBg:(NSNotification *)notification {
    NSString *bgId = (NSString *)notification.object;
    self.backgroudView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bg_%@", bgId]];
}

- (void)statusBarChange:(NSNotification *)notification {
    CGRect statusRect = [[notification.userInfo objectForKey:UIApplicationStatusBarFrameUserInfoKey] CGRectValue];
    CGRect statusFrame = [self.view convertRect:statusRect fromView:[[UIApplication sharedApplication] keyWindow]];
    CGFloat statusHeight = statusFrame.size.height - 20;

    CGFloat seatViewY = CGRectGetMaxY(self.seatView.frame);
    CGFloat chatViewHeight = UIScreenHeight - (CGRectGetMaxY(self.seatView.frame)) - [self getIphoneXFitSpace];
    if (statusHeight == 0) {
        [UIView animateWithDuration:0.25 animations:^{
            self.chatAreaView.frame = CGRectMake(0, seatViewY, UIScreenWidth, chatViewHeight);
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.chatAreaView.frame = CGRectMake(0, seatViewY - statusHeight, UIScreenWidth, chatViewHeight);
            
        }];
    }
}

- (BOOL)isRoomCreator{
    if ([[ClassroomService sharedService].currentRoom.creatorId isEqualToString:[ClassroomService sharedService].currentUser.userId]) {
        return YES;
    }
    return NO;
}

- (void)roomOwnerInviteUserJoinMic:(MicPositionInfo *)info{
    [self.memberListView showInView:[UIApplication sharedApplication].keyWindow position:info.position];
}

- (void)controlMic:(NSString *)userId index:(int)index type:(MicBehaviorType)type {
    [[ClassroomService sharedService] controlMic:[ClassroomService sharedService].currentRoom.roomId targetId:userId behavior:type position:index success:^{
        [self updateCurrentSubscribeOrPulishStream:userId behavior:type];
        [self reloadRoomInfo];
        if (type == MicBehaviorTypePickupMic) {
            [self.memberListView hidden];
        }
    } error:^(ErrorCode code) {
        SealMicLog(@"controlMic failure,type = %ld, code = %ld",(long)type,(long)code);
    }];
}

- (void)reloadRoomInfo{
    [[ClassroomService sharedService] getRoomInfo:[ClassroomService sharedService].currentRoom.roomId success:^(RoomInfo * _Nonnull room) {
        [self.naviView reloadTitle];
        [self.memberListView reloadMemberList];
        [self.seatView reloadSeatView];
        [self.chatAreaView.extensionView reloadExtensionView];
    } error:^(ErrorCode code) {
        dispatch_main_async_safe(^{
//            [self.view showHUDMessage:MicLocalizedNamed(@"GetRoomInfoFailure")];
        });
        SealMicLog(@"reloadRoomInfo,code = %ld",(long)code);
    }];
}


- (void)joinMic:(MicPositionInfo *)info{
    self.seatView.userInteractionEnabled = NO;
    [[ClassroomService sharedService] joinMic:[ClassroomService sharedService].currentRoom.roomId position:info.position success:^{
        self.seatView.userInteractionEnabled = YES;
        [self updateCurrentSubscribeOrPulishStream:[ClassroomService sharedService].currentUser.userId behavior:MicBehaviorTypeJumpOnMic];
        [self reloadRoomInfo];
    } error:^(ErrorCode code) {
        self.seatView.userInteractionEnabled = YES;
        dispatch_main_async_safe(^{
//            [self.view showHUDMessage:MicLocalizedNamed(@"JoinMicFailure")];
        });
        SealMicLog(@"抢麦失败");
    }];
}

- (void)changeMic:(int)fromIndex toIndex:(int)toIndex{
    self.seatView.userInteractionEnabled = NO;
    [[ClassroomService sharedService] changeMic:[ClassroomService sharedService].currentRoom.roomId from:fromIndex to:toIndex success:^{
        self.seatView.userInteractionEnabled = YES;
        [self reloadRoomInfo];
    }error:^(ErrorCode code) {
        self.seatView.userInteractionEnabled = YES;
        dispatch_main_async_safe(^{
//            [self.view showHUDMessage:MicLocalizedNamed(@"ChangeMicFailure")];
        });
        SealMicLog(@"跳麦失败");
    }];
}

- (void)leaveMic:(MicPositionInfo *)info{
    [[ClassroomService sharedService] leaveMic:[ClassroomService sharedService].currentRoom.roomId position:info.position success:^{
        [self updateCurrentSubscribeOrPulishStream:[ClassroomService sharedService].currentUser.userId behavior:MicBehaviorTypeJumpDownMic];
        [self reloadRoomInfo];
    } error:^(ErrorCode code) {
        dispatch_main_async_safe(^{
//            [self.view showHUDMessage:MicLocalizedNamed(@"LeaveMicFailure")];
        });
        SealMicLog(@"下麦失败");
    }];
}

- (CGFloat)getNaviHeight{
    CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
    //获取导航栏的rect
    CGRect navRect = self.navigationController.navigationBar.frame;
    return statusRect.size.height+navRect.size.height;
}

- (CGFloat)getIphoneXFitSpace{
    static CGFloat space;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0, *)) {
            UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
            UIEdgeInsets safeAreaInsets = mainWindow.safeAreaInsets;
            if (safeAreaInsets.bottom != 0){
                space = 34;
            }
        }});
    return space;
}
#pragma mark - getter or setter
- (NaviView *)naviView{
    if (!_naviView) {
        _naviView = [[NaviView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth/3, 64)];
        _naviView.delegate = self;
    }
    return _naviView;
}

- (UIImageView *)backgroudView{
    if (!_backgroudView) {
        _backgroudView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _backgroudView.backgroundColor = [UIColor blackColor];
        _backgroudView.userInteractionEnabled = YES;
        int bgId = [ClassroomService sharedService].currentRoom.bgId;
        _backgroudView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bg_%d", bgId]];
    }
    return _backgroudView;
}

- (MicSeatView *)seatView{
    if (!_seatView) {
        _seatView = [[MicSeatView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(self.headerView.frame), UIScreenWidth, MicSeatViewTotalHeight)];
        _seatView.delegate = self;
    }
    return _seatView;
}

- (HeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[HeaderView alloc] initWithFrame:CGRectMake(0,[self getNaviHeight]+10, UIScreenWidth, HeaderViewHeight)];
        _headerView.userInteractionEnabled = YES;
    }
    return _headerView;
}

- (ChatAreaView *)chatAreaView {
    if(!_chatAreaView) {
        CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height - 20;
        _chatAreaView = [[ChatAreaView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.seatView.frame) - statusBarHeight,UIScreenWidth ,UIScreenHeight - (CGRectGetMaxY(self.seatView.frame)) - [self getIphoneXFitSpace]) conversationType:ConversationType_CHATROOM targetId:[ClassroomService sharedService].currentRoom.roomId];
    }
    return _chatAreaView;
}

- (SettingView *)settingView {
    if (!_settingView) {
        _settingView = [[SettingView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight)];
        _settingView.settingDelegate = self;
    }
    return _settingView;
}

- (MemberListView *)memberListView{
    if (!_memberListView) {
        CGFloat naviHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        _memberListView = [[MemberListView alloc] initWithFrame:CGRectMake(0,naviHeight, UIScreenWidth, UIScreenHeight-naviHeight)];
        _memberListView.delegate = self;
    }
    return _memberListView;
}
@end
