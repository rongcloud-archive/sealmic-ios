//
//  RCMicBottomDialogStyle1Controller.h
//  SealMic
//
//  Created by rongyun on 2020/5/29.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicRoomViewModel.h"
#import <UIKit/UIKit.h>
#import "RCMicEnumDialogDefine.h"

NS_ASSUME_NONNULL_BEGIN
/// isReceiver 听筒模式开关状态
typedef void(^changeReceiverSwitch)(BOOL isReceiver);
/// type 选择弹框中的哪一个选项， participantViewModel 麦位视图 model
typedef void(^clickParticipantSelectCellAtIndexPath)(DIALOGOPERATIONTYPE type,RCMicParticipantViewModel *participantViewModel);
/// type 选择弹框中的哪一个选项， messageViewModel 聊天区域的消息 model
typedef void(^clickChatViewSelectCellAtIndexPath)(DIALOGOPERATIONTYPE type,RCMicMessageViewModel *messageViewModel);
/// isOpen debug模式是否打开
typedef void(^debugSwitch)(BOOL isOpen);

/// 底部弹出对话框视图控制器
@interface RCMicBottomDialogViewController : UIViewController
/// 用户点击设置按钮弹框的样式
- (void)clickSetButtonDialogStyle;
/// 用户点击麦位区域弹框样式
- (void)clickParticipantsAreaDialogStyle:(RCMicParticipantViewModel *)participantViewModel userInfo:(RCMicUserInfo *_Nullable)userInfo;
/// 用户点击聊天区域弹框样式
- (void)clickChatViewDialogStyle:(RCMicMessageViewModel *)messageViewModel;
/// 房间 viewModel 数据
@property (nonatomic, strong) RCMicRoomViewModel *viewModel;
/// 点击麦位弹出的操作项 block
@property (nonatomic, strong) clickParticipantSelectCellAtIndexPath clickParticipantSelectedCellBlock;
/// 点击聊天室弹出的操作项 block
@property (nonatomic, strong) clickChatViewSelectCellAtIndexPath clickChatViewSelectedCellBlock;
/// 听筒模式开关回调
@property (nonatomic, strong) changeReceiverSwitch changeReceiverBlock;
/// debug 模式开关回调
@property (nonatomic, strong) debugSwitch debugBlock;

@end

NS_ASSUME_NONNULL_END
