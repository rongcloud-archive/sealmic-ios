//
//  RCMicHTTPResult.m
//  SealMic
//
//  Created by LiFei on 2019/2/25.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCMicHTTPResult.h"

@implementation RCMicHTTPResult

- (NSString *)description {
    return [NSString stringWithFormat:@"success: %d, httpCode: %ld, errorCode: %ld, message: %@, content: %@",
            self.success, (long)self.httpCode, (long)self.errorCode, self.message, self.content];
}

@end
