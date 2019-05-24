//
//  RCEHTTPResult.h
//  SealMeeting
//
//  Created by LiFei on 2019/2/25.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ErrorCode.h"

@interface HTTPResult : NSObject

@property(nonatomic, assign) BOOL success;
@property(nonatomic, assign) NSInteger httpCode;
@property(nonatomic, assign) ErrorCode errorCode;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic, copy)   NSString *detail;
@property(nonatomic, strong) id content;

@end
