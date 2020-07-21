//
//  RCMicOperationAudioCollectionCell.h
//  SealMic
//
//  Created by rongyun on 2020/6/1.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCMicOperationAudioCollectionCell : UICollectionViewCell

/// 选项卡名称
@property (nonatomic, strong) UIButton *operationTitleButton;
- (void)setDataDictionary:(NSDictionary *)dictionary;
@end

NS_ASSUME_NONNULL_END
