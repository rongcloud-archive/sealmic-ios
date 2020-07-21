//
//  RCMicHTTPResult.h
//  SealMic
//
//  Created by LiFei on 2019/2/25.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCMicEnumDefine.h"

@interface RCMicHTTPResult : NSObject

@property(nonatomic, assign) BOOL success;
@property(nonatomic, assign) NSInteger httpCode;
@property(nonatomic, assign) RCMicHTTPCode errorCode;
@property(nonatomic, copy)   NSString *message;
@property(nonatomic, strong) id content;

@end
