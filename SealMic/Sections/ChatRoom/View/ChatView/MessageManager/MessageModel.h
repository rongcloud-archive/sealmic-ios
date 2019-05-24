//
//  MessageModel.h
//  SealMeeting
//
//  Created by 张改红 on 2019/3/5.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface MessageModel : NSObject
@property (nonatomic, strong, readonly) RCMessage *message;
@property (nonatomic, assign) CGSize contentSize;
- (instancetype)initWithMessage:(RCMessage *)message;
@end

NS_ASSUME_NONNULL_END
