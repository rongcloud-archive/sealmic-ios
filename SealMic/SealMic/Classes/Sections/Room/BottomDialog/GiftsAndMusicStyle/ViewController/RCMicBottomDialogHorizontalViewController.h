//
//  RCMicBottomDialogHorizontalViewController.h
//  SealMic
//
//  Created by rongyun on 2020/6/1.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMicUserInfo.h"
#import "RCMicGiftInfo.h"
#import "RCMicRoomViewModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^clickSelectItemAtIndexPath)(NSIndexPath *indexPath);
typedef void(^clickSelectGiftItemAtIndexPath)(RCMicGiftInfo *giftInfo);

@interface RCMicBottomDialogHorizontalViewController : UIViewController
///是否是有头像的视图
@property (nonatomic)BOOL isHead;
///是否是礼物样式
@property (nonatomic)BOOL isGiftStyle;
///弹框标题
@property (nonatomic,strong)NSString *dialogTitle;
/// 选择伴音/变音选项回调
@property(nonatomic, strong) clickSelectItemAtIndexPath seletedItemBlock;
/// 选择礼物选项回调
@property(nonatomic, strong) clickSelectGiftItemAtIndexPath seletedGiftItemBlock;
///当前伴音选择项
@property (nonatomic, strong) NSIndexPath *currentBgSoundIndexPath;
///用户信息
@property (nonatomic, strong) RCUserInfo *userInfo;
/// 房间 viewModel 数据
@property (nonatomic, strong) RCMicRoomViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
