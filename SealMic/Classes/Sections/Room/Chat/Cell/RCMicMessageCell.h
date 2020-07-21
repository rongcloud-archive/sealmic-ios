//
//  RCMicMessageCell.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicMessageBaseCell.h"
#import "RCMicMacro.h"

NS_ASSUME_NONNULL_BEGIN

/// cell 内视图布局时所占屏幕的最大宽度
#define MessageCellContentMaxWidth (RCMicScreenWidth * 0.7)
/// 展示用户所发消息 cell 的基础类，其上包含用户消息的统一布局
@interface RCMicMessageCell : RCMicMessageBaseCell
@property (nonatomic, strong) UIView *messageBackgroundView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

NS_ASSUME_NONNULL_END
