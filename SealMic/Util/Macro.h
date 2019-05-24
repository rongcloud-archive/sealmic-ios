//
//  Macro.h
//  SealMeeting
//
//  Created by LiFei on 2019/2/27.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

#define UIScreenWidth       [UIScreen mainScreen].bounds.size.width
#define UIScreenHeight      [UIScreen mainScreen].bounds.size.height

#define IMClient [RCIMClient sharedRCIMClient]

#define dispatch_main_async_safe(block)        \
if ([NSThread isMainThread]) {                 \
block();                                       \
} else {                                       \
dispatch_async(dispatch_get_main_queue(), block);\
}

#define SealMicLog(s, ...)    \
NSLog(@"[SealMicLog] desc: %@", [NSString stringWithFormat:(s), ##__VA_ARGS__]);

#define MicLocalizedNamed(s) NSLocalizedStringFromTable(s, @"SealMic", nil)
#endif /* Macro_h */
