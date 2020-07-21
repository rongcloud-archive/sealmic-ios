//
//  RCMicUserInfo.m
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicUserInfo.h"
#define UserId @"userId"
#define Username @"userName"
#define Portrait @"portrait"
#define Type @"type"

@implementation RCMicUserInfo

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:Username]) {
        self.name = value;
    } else if ([key isEqualToString:Portrait]) {
        self.portraitUri = value;
    }
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:UserId];
    [coder encodeObject:self.name forKey:Username];
    [coder encodeObject:self.portraitUri forKey:Portrait];
    [coder encodeInteger:self.type forKey:Type];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.userId = [coder decodeObjectOfClass:[NSString class] forKey:UserId];
        self.name = [coder decodeObjectOfClass:[NSString class] forKey:Username];
        self.portraitUri = [coder decodeObjectOfClass:[NSString class] forKey:Portrait];
        self.type = [coder decodeIntegerForKey:Type];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"userId:%@, name:%@, portrait:%@, type:%ld",self.userId, self.name, self.portraitUri, (long)self.type];
}
@end
