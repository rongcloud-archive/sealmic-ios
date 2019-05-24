//
//  MessageDataSource.h
//  SealMeeting
//
//  Created by 张改红 on 2019/3/5.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
#import "MessageModel.h"
#import "IMService.h"

@protocol MessageDataSourceDelegate;
NS_ASSUME_NONNULL_BEGIN

@interface MessageDataSource : NSObject <IMReceiveMessageDelegate>

@property(nonatomic, assign, readonly) NSUInteger count;

@property(nonatomic, weak) id<MessageDataSourceDelegate> delegate;

- (instancetype)initWithTargetId:(NSString *)targetId conversationType:(RCConversationType)type;

- (MessageModel *)objectAtIndex:(NSUInteger)index;

- (void)fetchHistoryMessages;

@end

@protocol MessageDataSourceDelegate <NSObject>

/**
 最新消息加载完成时调用
 */
- (void)lastestMessageLoadCompleted;

/**
 收到消息，或者发送消息时调用
 
 @param model model
 @param index 插入数据的起始索引
 */
- (void)didInsert:(MessageModel *)model startIndex:(NSInteger)index;

/**
 消息发送状态变更时调用
 
 @param model 消息模型
 @param index 索引
 */
- (void)didSendStatusUpdate:(MessageModel *)model index:(NSInteger)index;

/**
 历史消息载入完成是调用
 
 @param models 消息模型数组
 @param remain 是否还有历史消息
 */
- (void)didLoadHistory:(NSArray<MessageModel *> *)models isRemaining:(BOOL)remain;

/**
 移除 model
 
 @param model 消息模型数组
 @param index 索引
 */
- (void)didRemoved:(MessageModel *)model atIndex:(NSInteger)index;


/**
 UI 需要 reloadData 是调用
 */
- (void)forceReloadData;

@end
NS_ASSUME_NONNULL_END
