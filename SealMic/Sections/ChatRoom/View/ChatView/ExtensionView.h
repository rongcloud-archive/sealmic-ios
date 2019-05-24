//
//  ExtensionView.h
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExtensionView : UIView
@property (nonatomic, strong) UIButton *micButton;
@property (nonatomic, strong) UIButton *voiceButton;
- (void)reloadExtensionView;
@end

NS_ASSUME_NONNULL_END
