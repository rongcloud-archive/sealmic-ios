//
//  RCMicCachedUserInfo.m
//  SealMic
//
//  Created by lichenfeng on 2020/5/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicCachedUserInfo.h"
#define UserInfoKey @"userInfo"
#define TokenKey @"token"
#define Authorization @"authorization"
@implementation RCMicCachedUserInfo
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userInfo forKey:UserInfoKey];
    [coder encodeObject:self.token forKey:TokenKey];
    [coder encodeObject:self.authorization forKey:Authorization];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.userInfo = [coder decodeObjectOfClass:[RCMicUserInfo class] forKey:UserInfoKey];
        self.token = [coder decodeObjectOfClass:[NSString class] forKey:TokenKey];
        self.authorization = [coder decodeObjectOfClass:[NSString class] forKey:Authorization];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"userInfo:%@, token:%@, authorization:%@", self.userInfo, self.token, self.authorization];
}
@end
