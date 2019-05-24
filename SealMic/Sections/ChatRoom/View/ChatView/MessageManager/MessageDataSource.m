//
//  MessageDataSource.m
//  SealMeeting
//
//  Created by 张改红 on 2019/3/5.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "MessageDataSource.h"
#import "MessageHelper.h"
#import "ClassroomService.h"
const NSUInteger numOfMessages = 20;
@interface MessageDataSource () <MessageHelperDelegate>
@property (nonatomic, strong) dispatch_queue_t storeQueue;
@property (nonatomic, strong) NSMutableArray <MessageModel *> *dataSource;
@property (nonatomic, assign) RCConversationType conversationType;
@property (nonatomic, assign) long long earliestMessageSendTime; /// 当前sotre中最早的发送时间
@property (nonatomic, strong) NSMutableDictionary <NSNumber *,NSNumber *> *sendingCache;
@property (nonatomic, copy) NSString *targetId;
@end

@implementation MessageDataSource
#pragma mark - Life cycle
- (instancetype)initWithTargetId:(NSString *)targetId
                conversationType:(RCConversationType)type {
    if (self = [super init]) {
        [IMService sharedService].receiveMessageDelegate = self;
        self.targetId = targetId;
        self.conversationType = type;
        [self fetchLatestMessages];
        [MessageHelper sharedInstance].delegate = self;
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Api
- (NSUInteger)count {
    return self.dataSource.count;
}

- (MessageModel *)objectAtIndex:(NSUInteger)index{
    MessageModel *model = self.dataSource[index];
    return model;
}

- (void)fetchHistoryMessages {
    NSAssert([[NSThread currentThread] isMainThread],
             @"%@ is not invoked by the main thread.",
             NSStringFromSelector(_cmd));
    NSMutableArray *totalArray = [[NSMutableArray alloc] initWithCapacity:20];
    NSLog(@"rcim getHistoryMessages"
          @"earliestMessageSendTime %@",
          @(self.earliestMessageSendTime));
    NSArray<RCMessage *> *localMessages= [IMClient getHistoryMessages:self.conversationType targetId:self.targetId objectNames:[[MessageHelper sharedInstance] getAllSupportMessage] sentTime:self.earliestMessageSendTime isForward:YES count:numOfMessages];
    localMessages = [localMessages.reverseObjectEnumerator allObjects];
    
    void (^insertHistoryMessageBlock)(NSArray<RCMessage *> *, BOOL) =
    ^(NSArray<RCMessage *> *messages,BOOL isRemaining) {
        NSLog(@"rcim insertHistorymesssages %@"
              @"count %@, isRemaining %@",
              messages,@(messages.count),@(isRemaining));
        dispatch_async(self.storeQueue, ^{
            __block NSArray *array = [self messageModels:messages];
            dispatch_main_async_safe(^{
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)];
                [self.dataSource insertObjects:array atIndexes:indexSet];
                [self.delegate didLoadHistory:array isRemaining:isRemaining];
            });
        });
    };
    if (localMessages.count < numOfMessages) {
        NSUInteger msgCount = numOfMessages - localMessages.count;
        if (localMessages.count > 0) {
            [totalArray addObjectsFromArray:localMessages];
        }
        void (^success)(NSArray *, BOOL) = ^(NSArray *messages, BOOL isRemaining) {
            NSArray<RCMessage *> *remoteMessage = [messages.reverseObjectEnumerator allObjects];
            [totalArray addObjectsFromArray:remoteMessage];
            insertHistoryMessageBlock([totalArray copy], isRemaining);
        };
        void (^error)(RCErrorCode) = ^(RCErrorCode status) {
            BOOL isRemain = status == MSG_ROAMING_SERVICE_UNAVAILABLE ? NO : YES;
            insertHistoryMessageBlock(totalArray, isRemain);
        };
        [IMClient getRemoteHistoryMessages:self.conversationType
                                  targetId:self.targetId
                                recordTime:self.earliestMessageSendTime
                                     count:(int)msgCount
                                   success:success
                                     error:error];
        return;
    }
    [totalArray addObjectsFromArray:localMessages];
    insertHistoryMessageBlock([totalArray copy], YES);
}

#pragma mark - IMReceiveMessageDelegate
- (void)onReceiveMessage:(RCMessage *)message left:(int)nLeft object:(id)object {
    NSArray *supportMessages = [[MessageHelper sharedInstance] getAllSupportMessage];
    if (![self isCurrentConversation:message] && ![self isPersistentMessage:message] && ![supportMessages containsObject:message.objectName]) {
        return;
    }
    dispatch_async(self.storeQueue, ^{
        MessageModel *model = [self messageModel:message];
        if (!model) {
            return;
        }
        dispatch_main_async_safe(^{
            [self.dataSource addObject:model];
            NSUInteger index = self.dataSource.count - 1;
            [self.delegate didInsert:model startIndex:index];
        });
    });
}

#pragma mark - MessageHelperDelegate
- (void)willSendMessage:(RCMessage *)message {
    if (![self isCurrentConversation:message]) {
        return;
    }
    dispatch_async(self.storeQueue, ^{
        message.sentStatus = SentStatus_SENDING;
        MessageModel *model = [self messageModel:message];
        if (!model) {
            return;
        }
        dispatch_main_async_safe(^{
            [self.dataSource addObject:model];
            NSUInteger index = self.dataSource.count - 1;
            self.sendingCache[@(message.messageId)] = @(index);
            [self.delegate didInsert:model startIndex:index];
            [self.delegate didSendStatusUpdate:model index:index];
        });
    });
}

- (void)onSendMessage:(RCMessage *)message didCompleteWithError:(nullable NSError *)error {
    if (![self isCurrentConversation:message]) {
        return;
    }
    dispatch_main_async_safe(^{
        NSNumber *indexNumber =  self.sendingCache[@(message.messageId)];
        if (indexNumber) {
            NSInteger index = [indexNumber integerValue];
            MessageModel *model = [self.dataSource objectAtIndex:index];
            model.message.sentStatus = SentStatus_SENT;
            // dispatch_async(dispatch_get_main_queue(), ^{
            //NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
            [self.delegate didSendStatusUpdate:model index:index];
            //});
            [self.sendingCache removeObjectForKey:@(message.messageId)];
        } else {
            NSUInteger count = self.dataSource.count;
            NSInteger index = NSNotFound;
            for (NSInteger i = count - 1; i >= 0; i--) {
                MessageModel *model = self.dataSource[i];
                if (model.message.messageId == message.messageId) {
                    index = i;
                    break;
                }
            }
            if (index != NSNotFound) {
                MessageModel *model = [self.dataSource objectAtIndex:index];
                model.message.sentStatus = SentStatus_SENT;
                [self.delegate didSendStatusUpdate:model index:index];
            } else {
                MessageModel *model = [self messageModel:message];
                if (!model) {
                    return;
                }
                [self.dataSource addObject:model];
                NSUInteger index = self.dataSource.count - 1;
                self.sendingCache[@(message.messageId)] = @(index);
                [self.delegate didInsert:model startIndex:index];
                [self.delegate didSendStatusUpdate:model index:index];
            }
        }
    });
}

#pragma mark - Helper
- (void)fetchLatestMessages {
    NSArray<RCMessage *> *messages= [IMClient getHistoryMessages:self.conversationType targetId:self.targetId objectNames:[[MessageHelper sharedInstance] getAllSupportMessage] sentTime:0 isForward:YES count:numOfMessages];
    messages = [messages.reverseObjectEnumerator allObjects];
    NSLog(@"rcim lastestMessage %@ count %@", messages, @(messages.count));
    dispatch_async(self.storeQueue, ^{
        NSArray *array = [self messageModels:messages];
        dispatch_main_async_safe(^{
            [self.dataSource addObjectsFromArray:array];
            [self.delegate forceReloadData];
            [self.delegate lastestMessageLoadCompleted];
        });
    });
    if (messages.count == 0) {
        [self fetchHistoryMessages];
    }
}

- (MessageModel *)messageModel:(RCMessage *)message {
    return [[MessageModel alloc] initWithMessage:message];
}

- (NSArray *)messageModels:(NSArray *)messages {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:messages.count];
    [messages enumerateObjectsUsingBlock:^(RCMessage *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        MessageModel *model = [self messageModel:obj];
        if (model) {
            [array addObject:model];
        }
    }];
    return [array copy];
}

- (BOOL)isCurrentConversation:(RCMessage *)message {
    return [message.targetId isEqualToString:self.targetId] &&
    message.conversationType == self.conversationType;
}

- (BOOL)isPersistentMessage:(RCMessage *)message{
    return ([[message.content class] persistentFlag] & MessagePersistent_ISPERSISTED);
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    NSAssert([[NSThread currentThread] isMainThread],
             @"%@ is not invoked by the main thread.",
             NSStringFromSelector(_cmd));
    NSAssert(index < self.dataSource.count,
             @"index %@ beyond bounds [0 .. %@]",
             @(index), @(self.dataSource.count));
    [self.dataSource removeObjectAtIndex:index];
    [self.delegate didRemoved:self.dataSource[index] atIndex:index];
}

#pragma mark - Getters & setters
- (NSMutableArray<MessageModel *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] initWithCapacity:2000];
    }
    return _dataSource;
}

- (NSMutableDictionary<NSNumber *, NSNumber *> *)sendingCache {
    if (!_sendingCache) {
        _sendingCache = [[NSMutableDictionary alloc] initWithCapacity:30];
    }
    return _sendingCache;
}

- (dispatch_queue_t)storeQueue {
    if (!_storeQueue) {
        _storeQueue = dispatch_queue_create("rcimkit.messagestorequeue", DISPATCH_QUEUE_SERIAL);
    }
    return _storeQueue;
}

- (long long)earliestMessageSendTime{
    long long time = 0;
    if (self.dataSource.count > 0) {
        MessageModel *model = [self objectAtIndex:0];
        time = model.message.sentTime;
    }
    return time;
}
@end
