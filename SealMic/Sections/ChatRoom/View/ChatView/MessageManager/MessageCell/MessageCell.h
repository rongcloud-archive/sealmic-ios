//
//  MessageCell.h
//  SealMeeting
//
//  Created by 张改红 on 2019/3/6.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "MessageBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageCell : MessageBaseCell
@property(nonatomic, strong) UIView *messageContentView;
- (void)updateSentStatus;
@end

NS_ASSUME_NONNULL_END
