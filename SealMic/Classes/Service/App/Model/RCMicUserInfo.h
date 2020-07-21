//
//  RCMicUserInfo.h
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RCIMClient.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RCMicUserType) {
    RCMicUserTypeVisitor = 0,
    RCMicUserTypeNormal,
};

@interface RCMicUserInfo : RCUserInfo<NSSecureCoding>
@property (nonatomic, assign) RCMicUserType type;
@end

NS_ASSUME_NONNULL_END
