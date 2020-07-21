//
//  RCMicOperationGiftCollectionCell.h
//  SealMic
//
//  Created by rongyun on 2020/6/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMicGiftInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCMicOperationGiftCollectionCell : UICollectionViewCell

/// 礼物图片
@property (nonatomic, strong) UIImageView *giftImageView;

/// 礼物名字
@property (nonatomic, strong) UILabel *giftTitleLabel;

/// 礼物选中后显示的bg视图
@property (nonatomic, strong) UIImageView *seletedBgImageView;

- (void)setDataGiftInfoModel:(RCMicGiftInfo *)giftInfo;

@end

NS_ASSUME_NONNULL_END
