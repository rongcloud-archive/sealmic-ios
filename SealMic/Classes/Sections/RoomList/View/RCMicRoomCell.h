//
//  RCMicRoomCell.h
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMicRoomInfo.h"
NS_ASSUME_NONNULL_BEGIN

/// 房间列表页普通 cell
@interface RCMicRoomCell : UICollectionViewCell

- (void)setDataModel:(RCMicRoomInfo *)model;
@end

NS_ASSUME_NONNULL_END
