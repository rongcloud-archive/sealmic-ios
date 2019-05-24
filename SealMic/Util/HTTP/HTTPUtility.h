//
//  HTTPUtility.h
//  SealMeeting
//
//  Created by LiFei on 2019/2/25.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "HTTPResult.h"

typedef NS_ENUM(NSUInteger, HTTPMethod) {
    HTTPMethodGet = 1,
    HTTPMethodHead = 2,
    HTTPMethodPost = 3,
    HTTPMethodPut = 4,
    HTTPMethodDelete = 5
};

@interface HTTPUtility : NSObject

+ (void)requestWithHTTPMethod:(HTTPMethod)method
                    URLString:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                     response:(void (^)(HTTPResult *result))responseBlock;

+ (void)setAuthHeader:(NSString *)authorization;

@end
