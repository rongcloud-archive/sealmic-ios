//
//  GiftAnimationViewController.h
//  SealMic
//
//  Created by rongyun on 2020/6/10.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface GiftAnimationViewController : UIViewController
/// 礼物动画标题内容
@property (nonatomic, strong) NSString *content;
/// 礼物图片
@property (nonatomic, strong) UIImage *image;
/// 赠送礼物方名称
@property (nonatomic, strong) NSString *gaveName;
/// 赠送礼物方tags
@property (nonatomic, strong) NSString *tag;

@end

NS_ASSUME_NONNULL_END
