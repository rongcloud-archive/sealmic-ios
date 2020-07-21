//
//  RCMicHTTPUtility.h
//  SealMic
//
//  Created by LiFei on 2019/2/25.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCMicHTTPResult.h"

typedef NS_ENUM(NSUInteger, RCMicHTTPMethod) {
    RCMicHTTPMethodGet = 1,
    RCMicHTTPMethodHead = 2,
    RCMicHTTPMethodPost = 3,
    RCMicHTTPMethodPut = 4,
    RCMicHTTPMethodDelete = 5
};

@interface RCMicHTTPUtility : NSObject

+ (void)requestWithHTTPMethod:(RCMicHTTPMethod)method
                    URLString:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                     response:(void (^)(RCMicHTTPResult *result))responseBlock;

+ (void)setAuthHeader:(NSString *)authorization;

+ (NSString *)demoServer;
@end
