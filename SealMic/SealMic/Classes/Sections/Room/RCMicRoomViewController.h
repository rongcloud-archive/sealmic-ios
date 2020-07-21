//
//  RCMicRoomViewController.h
//  SealMic
//
//  Created by lichenfeng on 2020/5/26.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMicRoomViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMicRoomViewController : UIViewController

- (instancetype)initWithRoomInfo:(RCMicRoomInfo *)roomInfo Role:(RCMicRoleType)role;
@end

NS_ASSUME_NONNULL_END
