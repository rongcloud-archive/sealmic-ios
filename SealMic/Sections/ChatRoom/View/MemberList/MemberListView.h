//
//  MemberListView.h
//  SealMic
//
//  Created by 张改红 on 2019/5/10.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MicPositionInfo;
NS_ASSUME_NONNULL_BEGIN
@protocol MemberListViewDelegate <NSObject>
- (void)didClickJoinMic:(NSString *)targetId index:(int)index;
@end
@interface MemberListView : UIView
@property (nonatomic, weak) id<MemberListViewDelegate> delegate;

- (void)showInView:(UIView *)view position:(int)position;
- (void)hidden;
- (void)reloadMemberList;
@end

NS_ASSUME_NONNULL_END
