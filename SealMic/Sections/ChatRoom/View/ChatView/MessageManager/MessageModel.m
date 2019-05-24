//
//  MessageModel.m
//  SealMeeting
//
//  Created by 张改红 on 2019/3/5.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "MessageModel.h"
#import "MessageHelper.h"
@interface MessageModel ()
@property(nonatomic, strong) RCMessage *message;
@end

@implementation MessageModel
- (instancetype)initWithMessage:(RCMessage *)message{
    if (self = [super init]) {
        self.message = message;
        self.contentSize = [[MessageHelper sharedInstance] getMessageContentSize:message.content];
    }
    return self;
}
@end
