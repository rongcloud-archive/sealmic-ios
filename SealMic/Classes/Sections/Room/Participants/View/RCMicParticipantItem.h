//
//  RCMicParticipantItem.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/1.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMicParticipantViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMicParticipantItem : UIView
- (instancetype)initWithFrame:(CGRect)frame isHost:(BOOL)isHost;

- (void)updateWithViewModel:(RCMicParticipantViewModel *)viewModel;

- (void)performAnimation;
@end

NS_ASSUME_NONNULL_END
