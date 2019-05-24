//
//  MicSeatView.h
//  SealMic
//
//  Created by 张改红 on 2019/5/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MicPositionInfo.h"
#import "SeatItemCell.h"
NS_ASSUME_NONNULL_BEGIN
@protocol MicSeatViewDelegate <NSObject>
- (void)didSelectPostion:(MicPositionInfo*)postion;
@end
@interface MicSeatView : UIView
@property (nonatomic, weak) id<MicSeatViewDelegate> delegate;
- (void)showInView:(UIView *)view;
- (void)hidden;
- (void)reloadSeatView;
- (void)startAnimationInIndex:(int)index;
@end


NS_ASSUME_NONNULL_END
