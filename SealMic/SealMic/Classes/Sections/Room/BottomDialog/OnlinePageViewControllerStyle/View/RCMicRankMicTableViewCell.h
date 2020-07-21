//
//  RCMicRankMicTableViewCell.h
//  SealMic
//
//  Created by rongyun on 2020/6/3.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMicUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMicRankMicTableViewCell : UITableViewCell
/// 头像
@property (nonatomic, strong) UIImageView *headImageView;
/// 名称
@property (nonatomic, strong) UILabel *titleLabel;
/// 上麦 操作按钮
@property (nonatomic, strong) UIButton *openBtn;
/// 拒绝 操作按钮
@property (nonatomic, strong) UIButton *refusedBtn;
/// 底部分割线
@property (nonatomic, strong) UIView *lineView;

- (void)setDataModel:(RCMicUserInfo *)model;
@end

NS_ASSUME_NONNULL_END
