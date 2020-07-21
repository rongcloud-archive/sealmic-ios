//
//  RCMicCreateRoomViewModel.m
//  SealMic
//
//  Created by rongyun on 2020/7/5.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicCreateRoomViewModel.h"
#import "RCMicActiveWheel.h"
#import "RCMicUtil.h"
#import "RCMicMacro.h"

@implementation RCMicCreateRoomViewModel

- (void)createRoomWithRoomName:(NSString *)roomName success:(void (^)(RCMicRoomInfo * _Nonnull))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    //谓词验证只支持字母，数组，汉字。
    NSString *regex =@"[a-zA-Z0-9\u4e00-\u9fa5]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    //验证长度和支持规则
    if ([pred evaluateWithObject:roomName] && [self getToInt:roomName] <= 20){
        [[RCMicAppService sharedService] createRoomWithName:roomName themeImage:[RCMicUtil randomRoomTheme] success:^(RCMicRoomInfo * _Nonnull roomInfo) {
            successBlock ? successBlock(roomInfo) : nil;
        } error:^(RCMicHTTPCode errorCode) {
            errorBlock ? errorBlock(errorCode) : nil;
        }];
    } else {
        errorBlock ? errorBlock(RCMicHTTPCodeErrRoomNameInvalid) : nil;
    }
}

//得到中英文混合字符串长度
- (NSInteger)getToInt:(NSString*)strtemp
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [strtemp dataUsingEncoding:enc];
    return [da length];
}

@end
