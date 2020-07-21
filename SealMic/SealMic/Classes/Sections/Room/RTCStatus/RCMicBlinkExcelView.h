//
//  BlinkExcelView.h
//  RongCloud
//
//  Created by Vicky on 2018/2/7.
//  Copyright © 2018年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHExcelView.h"
#import "RCMicRoomViewModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface RCMicBlinkExcelView : UIView

@property (nonatomic, copy) NSArray<NSArray *> *array;
@property (strong, nonatomic) YHExcelView *excelView;//表内容

- (instancetype)initWithFrame:(CGRect)frame viewModel:(RCMicRoomViewModel *)viewModel;

@end
NS_ASSUME_NONNULL_END
