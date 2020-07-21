//
//  RCMicBottomDialogScrollPageViewController.h
//  SealMic
//
//  Created by rongyun on 2020/6/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMicRoomViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 选项列表 枚举
 */
typedef NS_ENUM(NSInteger, RCMicPageViewListState) {
    RCMicOnLineList = 0,//在线列表
    RCMicRankList = 1,//排麦列表
    RCMicBannedList = 2,//禁言列表
};

@interface RCMicBottomDialogScrollPageViewController : UIViewController
/// 列表类型
@property (nonatomic) RCMicPageViewListState listType;
//房间id
@property (nonatomic,strong)NSString *roomId;

@property (nonatomic, strong) RCMicRoomViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
