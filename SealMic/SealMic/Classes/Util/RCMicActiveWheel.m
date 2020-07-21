//
//  RCMicActiveWheel.m
//  SealMic
//
//  Created by zhaobindong on 2017/6/8.
//  Copyright © 2017年 rongcloud. All rights reserved.
//

#import "RCMicActiveWheel.h"

@interface RCMicActiveWheel ()
@property(nonatomic) BOOL *ptimeoutFlag;
@end

@implementation RCMicActiveWheel

- (id)initWithView:(UIView *)view {
    self = [super initWithView:view];
    if (self) {
        self.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        self.tintColor = [UIColor blackColor];
        self.removeFromSuperViewOnHide = YES;
    }
    return self;
}

- (void)dealloc {
    self.processString = nil;
}

+ (RCMicActiveWheel *)showHUDAddedTo:(UIView *)view {
    RCMicActiveWheel *hud = [[RCMicActiveWheel alloc] initWithView:view];
    hud.contentColor = [UIColor whiteColor];
    [view addSubview:hud];
    [hud showAnimated:YES];
    return hud;
}

+ (void)showPromptHUDAddedTo:(UIView *)view text:(NSString *)text {
    RCMicActiveWheel *hud = [RCMicActiveWheel showHUDAddedTo:view];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabel.text = text;
    hud.detailsLabel.textColor = [UIColor whiteColor];

    [hud hideAnimated:YES afterDelay:2.0f];
}

+ (void)dismissForView:(UIView *)view {
    MBProgressHUD *hud = [super HUDForView:view];
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES];
}

+ (void)dismissViewDelay:(NSTimeInterval)interval forView:(UIView *)view warningText:(NSString *)text;
{
    RCMicActiveWheel *wheel = (RCMicActiveWheel *)[super HUDForView:view];
    ;
    [wheel performSelector:@selector(setWarningString:) withObject:text afterDelay:0];
    [RCMicActiveWheel performSelector:@selector(dismissForView:) withObject:view afterDelay:interval];
}

+ (void)dismissViewDelay:(NSTimeInterval)interval forView:(UIView *)view processText:(NSString *)text {
    RCMicActiveWheel *wheel = (RCMicActiveWheel *)[super HUDForView:view];
    ;
    wheel.processString = text;
    [RCMicActiveWheel performSelector:@selector(dismissForView:) withObject:view afterDelay:interval];
}

+ (void)dismissForView:(UIView *)view delay:(NSTimeInterval)interval {
    [RCMicActiveWheel performSelector:@selector(dismissForView:) withObject:view afterDelay:interval];
}

- (void)setProcessString:(NSString *)processString {
    // self.labelColor = [UIColor colorWithRed:219/255.0f green:78/255.0f blue:32/255.0f alpha:1];
    self.label.text = processString;
}

- (void)setWarningString:(NSString *)warningString {
    self.label.textColor = [UIColor redColor];
    self.label.text = warningString;
}


+ (void)hidePromptHUDDelay:(UIView *)view text:(NSString *)text {
    RCMicActiveWheel *wheel = (RCMicActiveWheel *)[super HUDForView:view];
    //  hud.square = YES;
    wheel.mode = MBProgressHUDModeText;
    wheel.label.text = nil;
    wheel.detailsLabel.text = text;
    wheel.detailsLabel.textColor = [UIColor whiteColor];
    [wheel hideAnimated:YES afterDelay:2.0f];
}

@end
