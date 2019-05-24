//
//  RCEHTTPResult.m
//  SealMeeting
//
//  Created by LiFei on 2019/2/25.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "HTTPResult.h"

@implementation HTTPResult

- (NSString *)description {
    return [NSString stringWithFormat:@"success: %d, httpCode: %ld, errorCode: %ld, message: %@, detail: %@, content: %@",
            self.success, (long)self.httpCode, (long)self.errorCode, self.message, self.detail, self.content];
}

@end
