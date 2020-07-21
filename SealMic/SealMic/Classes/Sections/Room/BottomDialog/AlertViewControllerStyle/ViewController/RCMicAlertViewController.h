//
//  RCMicAlertViewController.h
//  SealMic
//
//  Created by rongyun on 2020/6/29.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^agreeBlockAction)(void);
typedef void(^refuseBlockAction)(void);
/// 系统样式匹配UI的弹框控制器
@interface RCMicAlertViewController : UIViewController
/// 弹框同意按钮回调
@property (nonatomic,strong)agreeBlockAction agreeBtnAction;
/// 弹框拒绝按钮回调
@property (nonatomic,strong)refuseBlockAction refuseBtnAction;
/// 弹框提示内容Label
@property (nonatomic, strong) UILabel *alertMessageLabel;
@end
NS_ASSUME_NONNULL_END
