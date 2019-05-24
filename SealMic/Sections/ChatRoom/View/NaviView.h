//
//  NaviView.h
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NaviViewDelegate <NSObject>
- (void)back;
@end
NS_ASSUME_NONNULL_BEGIN

@interface NaviView : UIButton
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, weak) id<NaviViewDelegate> delegate;
- (void)reloadTitle;
@end

NS_ASSUME_NONNULL_END
