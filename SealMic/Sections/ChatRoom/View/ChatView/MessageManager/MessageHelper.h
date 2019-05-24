//
//  MessageHelper.h
//  SealMeeting
//
//  Created by 张改红 on 2019/3/6.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
NS_ASSUME_NONNULL_BEGIN
@protocol MessageHelperDelegate <NSObject>

@optional

- (void)willSendMessage:(RCMessage *)message;

- (void)onSendMessage:(RCMessage *)message didCompleteWithError:(nullable NSError *)error;

@end

@interface MessageHelper : NSObject

@property (nonatomic, weak) id<MessageHelperDelegate> delegate;

+ (instancetype)sharedInstance;

- (RCMessage *)sendMessage:(RCMessageContent *)content
               pushContent:(nullable NSString *)pushContent
                  pushData:(nullable NSString *)pushData
                toTargetId:(NSString *)targetId
          conversationType:(RCConversationType)conversationType;

- (void)setMaximumContentWidth:(CGFloat)width;

- (CGSize)getMessageContentSize:(RCMessageContent *)content;

- (NSString *)convertChatMessageTime:(long long)secs;

- (NSArray <NSString *> *)getAllSupportMessage;

- (NSString *)formatMessage:(RCMessageContent *)content;
@end

NS_ASSUME_NONNULL_END
