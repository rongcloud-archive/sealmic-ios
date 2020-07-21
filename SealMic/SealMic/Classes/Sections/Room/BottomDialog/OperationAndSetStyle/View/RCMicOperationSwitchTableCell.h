//
//  RCMicOperationSwitchTableCell.h
//  SealMic
//
//  Created by rongyun on 2020/6/1.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^clickOperationSwitchBtn)(UIButton *mySwitchBtn,NSString *key);

@interface RCMicOperationSwitchTableCell : UITableViewCell
/// 选项框背景图片
@property (nonatomic, strong) UIImageView *bgImageView;
/// 选项卡名字
@property (nonatomic, strong) UILabel *operationTitleLabel;

@property (nonatomic, strong) UIButton *operationSwitchBtn;

@property(nonatomic, strong) clickOperationSwitchBtn changeSwitchBtnBlock;

@end

NS_ASSUME_NONNULL_END
