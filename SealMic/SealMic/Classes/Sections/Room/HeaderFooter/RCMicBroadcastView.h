//
//  RCMicBroadcastView.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/22.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMicBroadcastGiftMessage.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCMicBroadcastView : UIView
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *roomNameLabel;
@property (nonatomic, strong) UILabel *giftLabel;

- (void)updateContentWithMessage:(RCMicBroadcastGiftMessage *)message;
+ (CGFloat)contentWidthWithMessage:(RCMicBroadcastGiftMessage *)message;
@end

NS_ASSUME_NONNULL_END
