//
//  RCMicMacro.h
//  SealMic
//
//  Created by lichenfeng on 2020/5/21.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#ifndef RCMicMacro_h
#define RCMicMacro_h

#import "RCMicUtil.h"
#import <Masonry/Masonry.h>

//环境配置
#define APPKey @""//此处填写您的 appkey（必填）
#define BASE_URL @""//此处填写您的 demo server 地址（必填）
#define BuglyKey @""//此处填写您应用的 buglyKey（选填）
#define Navi_URL @""//此处填写私有云导航地址，公有云用户不需要配置
//屏幕宽度等于逻辑分辨率 320 pt 认定为最小屏幕 iPhoneSE / 5 / 5c / 4 /3gs .....
#define RCMicScreenWidthEqualTo320 RCMicScreenWidth == 320
#define RCMicScreenWidth       [UIScreen mainScreen].bounds.size.width
#define RCMicScreenHeight      [UIScreen mainScreen].bounds.size.height
#define RCMicKeyWindow [UIApplication sharedApplication].keyWindow
#define HEXCOLOR(rgbValue, alphaValue)                                                                                             \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                                               \
                green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                                                  \
                 blue:((float)(rgbValue & 0xFF)) / 255.0                                                           \
                alpha:alphaValue]
#define RCMicColor(lightColor, darkColor) [RCMicUtil colorWithLight:lightColor dark:darkColor]
#define RCMicFont(size, fontName) [RCMicUtil fontWithSize:size name:fontName]

#define RCMicLog(s, ...) NSLog(@"[SealMicLog]: %@", [NSString stringWithFormat:(s), ##__VA_ARGS__]);

#define RCMicLocalizedNamed(s) NSLocalizedStringFromTable(s, @"SealMic", nil)

#define RCMicMainThread(block)        \
if ([NSThread isMainThread]) {                 \
block();                                       \
} else {                                       \
dispatch_async(dispatch_get_main_queue(), block);\
}

#define WeakObj(o) __weak typeof(o) o##Weak = o;

#endif /* RCMicMacro_h */
