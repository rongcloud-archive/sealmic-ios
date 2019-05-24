//
//  UserInfo.h
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserInfo : NSObject
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, assign) long long joinDate;
@property (nonatomic, assign) int  avatarResourceId;
+ (instancetype)userInfoFromJson:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
