//
//  RCMicParticipantCell.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMicParticipantItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMicParticipantCell : UICollectionViewCell
- (void)updateWithViewModel:(RCMicParticipantViewModel *)viewModel;
- (void)performAnimation;
@end

NS_ASSUME_NONNULL_END
