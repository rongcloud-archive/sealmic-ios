//
//  SeatItemCell.h
//  SealMic
//
//  Created by 张改红 on 2019/5/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MicPositionInfo.h"
#define SeatItemCellIdentifier @"SeatItemCellIdentifier"
NS_ASSUME_NONNULL_BEGIN

@interface SeatItemCell : UICollectionViewCell
- (void)setModel:(MicPositionInfo *)info;
- (void)startHeaderAnimation;
@end

NS_ASSUME_NONNULL_END
