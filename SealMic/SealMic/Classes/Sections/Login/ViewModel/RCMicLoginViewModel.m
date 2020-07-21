//
//  RCMicLoginViewModel.m
//  SealMic
//
//  Created by rongyun on 2020/7/5.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicLoginViewModel.h"
#import "RCMicActiveWheel.h"
#import "RCMicMacro.h"

@implementation RCMicLoginViewModel

- (void)sendVerificationCodeWithPhoneNumber:(NSString *)phoneNumber {
    // 获取短信验证码
    [[RCMicAppService sharedService] sendVerificationCode:phoneNumber success:^{
    } error:^(RCMicHTTPCode errorCode) {
        [RCMicUtil showTipWithErrorCode:errorCode];
    }];
}

- (void)loginWithPhoneNumber:(NSString *)phoneNumber verifyCode:(NSString *)verifyCode
                     success:(void(^)(void))successBlock{
    if ([self valiMobile:phoneNumber]){
        //注册登录
        NSString *uuid = [UIDevice currentDevice].identifierForVendor.UUIDString;
        NSString *name = [RCMicUtil randomName];
        NSString *portrait = [RCMicUtil randomPortrait];
        [[RCMicAppService sharedService] userLogin:name portrait:portrait deviceId:uuid phoneNumber:phoneNumber verifyCode:verifyCode success:^(RCMicCachedUserInfo * _Nonnull userInfo) {
            //将用户信息缓存
            [[RCMicAppService sharedService] configUserEnvironment:userInfo];
            successBlock ? successBlock() : nil;
        } error:^(RCMicHTTPCode errorCode) {
            [RCMicUtil showTipWithErrorCode:errorCode];
        }];
    }
}
- (BOOL)valiMobile:(NSString *)mobile{
    //    if (mobile.length < 11)
    //    {
    //        RCMicMainThread(^{
    //            [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:@"手机号长度只能是11位!"];
    //        });
    //    }else{
    /**
     * 移动号段正则表达式
     */
    NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
    /**
     * 联通号段正则表达式
     */
    NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(175)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
    /**
     * 电信号段正则表达式
     */
    NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
    BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
    BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
    NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
    BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
    
    if (isMatch1 || isMatch2 || isMatch3) {
        return true;
    }else{
        RCMicMainThread(^{
            [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"phone_failed")];
        });
    }
    
    //    }
    return false;
}
@end
