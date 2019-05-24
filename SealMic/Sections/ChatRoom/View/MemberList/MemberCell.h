//
//  MemberCell.h
//  SealMic
//
//  Created by 张改红 on 2019/5/10.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
NS_ASSUME_NONNULL_BEGIN
@class MemberCell;
@protocol MemberCellDelegate <NSObject>
- (void)didClickJoinMicButton:(MemberCell *)cell;
@end
#define MemberCellIdentifier @"MemberCellIdentifier"
@interface MemberCell : UITableViewCell
@property (nonatomic, weak) id<MemberCellDelegate> delegate;
- (void)setUser:(UserInfo *)info;
@end

NS_ASSUME_NONNULL_END
