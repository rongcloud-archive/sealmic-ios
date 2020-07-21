//
//  RCMicCachedUserInfo.h
//  SealMic
//
//  Created by lichenfeng on 2020/5/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCMicUserInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCMicCachedUserInfo : NSObject<NSSecureCoding>
@property (nonatomic, strong) RCMicUserInfo *userInfo;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *authorization;
@end

NS_ASSUME_NONNULL_END
