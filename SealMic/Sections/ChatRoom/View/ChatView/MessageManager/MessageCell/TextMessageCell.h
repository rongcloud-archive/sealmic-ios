//
//  TextMessageCell.h
//  SealMeeting
//
//  Created by 张改红 on 2019/3/6.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "MessageCell.h"

NS_ASSUME_NONNULL_BEGIN
#define Text_Message_Font_Size 12
@interface TextMessageCell : MessageCell
@property (nonatomic, strong) UILabel *contentLabel;
@end

NS_ASSUME_NONNULL_END
