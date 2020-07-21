//
//  RCMicPhoneVerificationView.h
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol VerificationInputDelegate <NSObject>
/// 监听登录按钮是否可以点击
/// @param isClick 登录状态按钮是否可以点击
- (void)notificationChangesLoginButtonStatus:(BOOL)isClick;
/// 发送验证码
/// @param phoneNumber 接收短信验证码的手机号
- (void)sendCode:(NSString *)phoneNumber;
/// 监听输入框里手机号
/// @param phoneNumber 当前输入框里的手机号
- (void)currentPhoneNumber:(NSString *)phoneNumber;
@end

@interface RCMicPhoneVerificationView : UIView
@property (nonatomic, strong) UITextField *phoneInputField;
@property (nonatomic, strong) UITextField *codeInputField;
@property (nonatomic, strong) UIButton *sendCodeButton;
@property(nonatomic,weak)id<VerificationInputDelegate> verificationDelegate;
@end

NS_ASSUME_NONNULL_END
