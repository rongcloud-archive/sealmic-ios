//
//  RCMicLoginViewModel.h
//  SealMic
//
//  Created by rongyun on 2020/7/5.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCMicAppService.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMicLoginViewModel : NSObject

/// 登录
/// @param phoneNumber 手机号
/// @param verifyCode 验证码
/// @param successBlock 成功回调
- (void)loginWithPhoneNumber:(NSString *)phoneNumber verifyCode:(NSString *)verifyCode
                     success:(void(^)(void))successBlock;

/// 发送验证码
/// @param phoneNumber 获取验证码的手机号
- (void)sendVerificationCodeWithPhoneNumber:(NSString *)phoneNumber;

@end

NS_ASSUME_NONNULL_END
