//
//  RCMicIMService.m
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicIMService.h"
#import "RCMicMacro.h"
#import "RCMicAppService.h"

NSString *const RCMicRecallMessageNotification = @"RCMicRecallMessageNotification";

static RCMicIMService *imService = nil;

@interface RCMicIMService()<RCConnectionStatusChangeDelegate, RCIMClientReceiveMessageDelegate, RCChatRoomKVStatusChangeDelegate>
@property (nonatomic, strong) NSHashTable *messageHandleTable;
@property (nonatomic, strong) NSHashTable *connectionStatusHandleTable;
@property (nonatomic, strong) NSHashTable *kvStatusChangedTable;
@end

@implementation RCMicIMService

+ (instancetype)sharedService {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imService = [[RCMicIMService alloc] init];
        [imService initRCIM];
    });
    return imService;
}

- (void)initRCIM {
    //私有云导航配置
    if (Navi_URL.length > 0) {
        [[RCIMClient sharedRCIMClient] setServerInfo:Navi_URL fileServer:nil];
    }
    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Verbose];
    [[RCIMClient sharedRCIMClient] initWithAppKey:APPKey];
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:self object:nil];
    [[RCIMClient sharedRCIMClient] setRCChatRoomKVStatusChangeDelegate:self];
    //注册自定义消息
    [[RCIMClient sharedRCIMClient] registerMessageType:[RCMicGiftMessage class]];
    [[RCIMClient sharedRCIMClient] registerMessageType:[RCMicTransferHostMessage class]];
    [[RCIMClient sharedRCIMClient] registerMessageType:[RCMicTakeOverHostMessage class]];
    [[RCIMClient sharedRCIMClient] registerMessageType:[RCMicKickOutMessage class]];
    [[RCIMClient sharedRCIMClient] registerMessageType:[RCMicBroadcastGiftMessage class]];
}

- (void)connectWithToken:(NSString *)token {
    [[RCIMClient sharedRCIMClient] connectWithToken:token dbOpened:^(RCDBErrorCode code) {
    } success:^(NSString *userId) {
    } error:^(RCConnectErrorCode errorCode) {
        RCMicLog(@"connect im complete with error, code:%ld",(long)errorCode);
    }];
}

- (void)disconnect {
    [[RCIMClient sharedRCIMClient] disconnect:NO];
}
#pragma mark - Public method
- (void)addIMConnectionStatusChangeDelegate:(id<RCMicIMConnectionStatusChangeDelegate>)delegate {
    [self.connectionStatusHandleTable addObject:delegate];
}

- (void)addMessageHandleDelegate:(id<RCMicMessageHandleDelegate>)delegate {
    [self.messageHandleTable addObject:delegate];
}

- (void)addKVStatusChangedDelegate:(id<RCChatRoomKVStatusChangeDelegate>)delegate {
    [self.kvStatusChangedTable addObject:delegate];
}

- (NSArray<RCMessage *> *)loadLatestMessageWithRoomId:(NSString *)roomId messageCount:(NSUInteger)count {
    if (roomId.length == 0) {
        RCMicLog(@"load latest message error, roomId is null");
    }
    return [[RCIMClient sharedRCIMClient] getLatestMessages:ConversationType_CHATROOM targetId:roomId count:(int)count];
}

- (void)sendMessage:(RCConversationType)conversationType targetId:(NSString *)targetId content:(RCMessageContent *)content pushContent:(NSString *)pushContent pushData:(NSString *)pushData success:(void (^)(RCMessage *))successBlock error:(void (^)(RCErrorCode, RCMessage *))errorBlock {
    if (targetId.length == 0) {
        RCMicLog(@"send message error, targetId is null");
    }
    
    content.senderUserInfo = (RCUserInfo *)[RCMicAppService sharedService].currentUser.userInfo;
    [[RCIMClient sharedRCIMClient] sendMessage:conversationType targetId:targetId content:content pushContent:pushContent pushData:pushData success:^(long messageId) {
        RCMessage *message = [[RCIMClient sharedRCIMClient] getMessage:messageId];
        successBlock ? successBlock(message) : nil;
    } error:^(RCErrorCode nErrorCode, long messageId) {
        RCMicLog(@"send message complete with error, code:%ld", (long)nErrorCode);
        RCMessage *message = [[RCIMClient sharedRCIMClient] getMessage:messageId];
        errorBlock ? errorBlock(nErrorCode, message) : nil;
    }];
}

- (void)recallMessage:(RCMessage *)message success:(void (^)(void))successBlock error:(void (^)(RCErrorCode))errorBlock {
    [[RCIMClient sharedRCIMClient] recallMessage:message success:^(long messageId) {
        successBlock ? successBlock() : nil;
    } error:^(RCErrorCode errorcode) {
        RCMicLog(@"recall message complete with error, code:%ld, message:%@",(long)errorcode, message);
        errorBlock ? errorBlock(errorcode) : nil;
    }];
}

- (BOOL)deleteMessages:(NSArray<NSNumber *> *)messageIds {
    return [[RCIMClient sharedRCIMClient] deleteMessages:messageIds];
}

- (void)joinChatRoom:(NSString *)roomId messageCount:(NSInteger)messageCount success:(void (^)(void))successBlock error:(void (^)(RCErrorCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"join im chatroom error, targetId is null");
    }
    [[RCIMClient sharedRCIMClient] joinChatRoom:roomId messageCount:(int)messageCount success:^{
        successBlock ? successBlock() : nil;
    } error:^(RCErrorCode status) {
        RCMicLog(@"join chat room error, code:%ld, roomId:%@",(long)status, roomId);
        errorBlock ? errorBlock(status) : nil;
    }];
}

- (void)quitChatRoom:(NSString *)roomId success:(void (^)(void))successBlock error:(void (^)(RCErrorCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"quit chatroom error, roomId is null");
    }
    [[RCIMClient sharedRCIMClient] quitChatRoom:roomId success:^{
        successBlock ? successBlock() : nil;
    } error:^(RCErrorCode status) {
        RCMicLog(@"quit chatroom complete with error, code:%ld, roomId:%@",(long)status, roomId);
        errorBlock ? errorBlock(status) : nil;
    }];
}

- (void)getChatRoomUserCount:(NSString *)roomId success:(void (^)(NSInteger))successBlock error:(void (^)(RCErrorCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"get chatroom user count error, roomId is null");
    }
    [[RCIMClient sharedRCIMClient] getChatRoomInfo:roomId count:0 order:RC_ChatRoom_Member_Asc success:^(RCChatRoomInfo *chatRoomInfo) {
        successBlock ? successBlock(chatRoomInfo.totalMemberCount) : nil;
    } error:^(RCErrorCode status) {
        RCMicLog(@"get chatroom user count complete with error, code:%ld, roomId:%@",(long)status, roomId);
        errorBlock ? errorBlock(status) : nil;
    }];
}

- (void)getRoomLiveUrl:(NSString *)roomId success:(void (^)(NSString *))successBlock error:(void (^)(RCErrorCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"get room live url error, roomId is null");
    }
    [[RCIMClient sharedRCIMClient] getChatRoomEntry:roomId key:RCMicRoomLiveUrlKey success:^(NSDictionary *entry) {
        successBlock ? successBlock(entry[RCMicRoomLiveUrlKey]) : nil;
    } error:^(RCErrorCode nErrorCode) {
        RCMicLog(@"get room live url complete with error, code:%ld, roomId:%@, key:%@", (long)nErrorCode, roomId, RCMicRoomLiveUrlKey);
        errorBlock ? errorBlock(nErrorCode) : nil;
    }];
}

- (void)setRoomLiveUrl:(NSString *)roomId url:(NSString *)liveUrl success:(void (^)(void))successBlock error:(void (^)(RCErrorCode))errorBlock {
    if (roomId.length == 0 || liveUrl.length == 0) {
        RCMicLog(@"set room live url error, roomId is null");
    }
    [[RCIMClient sharedRCIMClient] forceSetChatRoomEntry:roomId key:RCMicRoomLiveUrlKey value:liveUrl sendNotification:YES autoDelete:NO notificationExtra:nil success:^{
        successBlock ? successBlock() : nil;
    } error:^(RCErrorCode nErrorCode) {
        RCMicLog(@"set room live url complete with error, code:%ld, roomId:%@, liveUrl:%@",(long)nErrorCode, roomId, liveUrl);
        errorBlock ? errorBlock(nErrorCode) : nil;
    }];
}

- (void)getAllParticipantInfo:(NSString *)roomId success:(void (^)(NSDictionary<NSString *, RCMicParticipantInfo *> *))successBlock error:(void (^)(RCErrorCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"get all participant info error, roomId is null");
    }
    [[RCIMClient sharedRCIMClient] getAllChatRoomEntries:roomId success:^(NSDictionary *entry) {
        successBlock ? successBlock([self generateParticipantInfoWithDitc:entry]) : nil;
    } error:^(RCErrorCode nErrorCode) {
        RCMicLog(@"get all participant info complete with error, code:%ld, roomId:%@",(long)nErrorCode, roomId);
        errorBlock ? errorBlock(nErrorCode) : nil;
    }];
}

- (void)setSpeakingState:(NSString *)roomId position:(NSInteger)position isSpeaking:(BOOL)isSpeaking success:(void (^)(void))successBlock error:(void (^)(RCErrorCode))errorBlock {
    if (roomId.length == 0 || position < 0 || position > RCMicParticipantCount) {
        RCMicLog(@"set speaking state error, param illegal, roomId:%@, position:%ld, isSpeaking:%@", roomId, (long)position, isSpeaking ? @"YES" : @"NO");
    }
    NSNumber *speaking = isSpeaking ? @(1) : @(0);
    NSDictionary *jsonDict = @{RCMicParticipantSpeakingKey:speaking, RCMicParticipantSpeakingPositionKey:@(position)};
    NSString *key = [NSString stringWithFormat:@"%@%ld",RCMicParticipantSpeakingEntryKey,(long)position];
    NSString *value = [[NSString alloc] initWithData:[RCMicUtil dataWithDictionary:jsonDict] encoding:NSUTF8StringEncoding];
    [[RCIMClient sharedRCIMClient] forceSetChatRoomEntry:roomId key:key value:value sendNotification:YES autoDelete:YES notificationExtra:nil success:^{
        successBlock ? successBlock() : nil;
    } error:^(RCErrorCode nErrorCode) {
        RCMicLog(@"set speaking state complete with error, code:%ld, roomId:%@, key:%@, value:%@",(long)nErrorCode, roomId, key, value);
        errorBlock ? errorBlock(nErrorCode) : nil;
    }];
}

- (void)getParticipantWaitingState:(NSString *)roomId success:(void (^)(BOOL))successBlock error:(void (^)(RCErrorCode))errorBlock {
    if (roomId.length == 0) {
        RCMicLog(@"get participant waiting state error, roomId is null");
    }
    [[RCIMClient sharedRCIMClient] getChatRoomEntry:roomId key:RCMicParticipantWaitingKey success:^(NSDictionary *entry) {
        BOOL waiting = [entry[RCMicParticipantWaitingKey] integerValue] == 1 ? YES : NO;
        successBlock ? successBlock(waiting) : nil;
    } error:^(RCErrorCode nErrorCode) {
        RCMicLog(@"get participant waiting state complete with error, code:%ld, roomId:%@, key:%@",(long)nErrorCode, roomId, RCMicParticipantWaitingKey);
        errorBlock ? errorBlock(nErrorCode) : nil;
    }];
}

#pragma mark - Private method
- (NSDictionary<NSString *, RCMicParticipantInfo *> *)generateParticipantInfoWithDitc:(NSDictionary *)dict {
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    //先处理麦位基本信息，然后更新麦位是否正在发言信息
    for (NSString *key in dict.allKeys) {
        if ([key hasPrefix:RCMicParticipantEntryKey]) {
            NSData *data = [dict[key] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *participantDict = [RCMicUtil dictionaryWithData:data];
            NSInteger position = [participantDict[RCMicParticipantPositionKey] integerValue];

            RCMicParticipantInfo *participantInfo = [[RCMicParticipantInfo alloc] init];
            participantInfo.position = position;
            participantInfo.isHost = position == 0 ? YES : NO;
            participantInfo.userId = participantDict[RCMicParticipantUserIdKey];
            participantInfo.state = (RCMicParticipantState)[participantDict[RCMicParticipantStateKey] integerValue];
            [resultDict setValue:participantInfo forKey:key];
        }
    }
    for (NSString *key in dict.allKeys) {
        if ([key hasPrefix:RCMicParticipantSpeakingEntryKey]) {
            NSData *data = [dict[key] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *speakingDict = [RCMicUtil dictionaryWithData:data];
            
            RCMicParticipantInfo *info = resultDict[key];
            info.speaking = [speakingDict[RCMicParticipantSpeakingKey] intValue] == 1 ? YES : NO;
        }
    }
    return [resultDict copy];
}

#pragma mark - RCConnectionStatusChangeDelegate
- (void)onConnectionStatusChanged:(RCConnectionStatus)status {
    for (id<RCMicIMConnectionStatusChangeDelegate>delegate in self.connectionStatusHandleTable) {
        if ([delegate respondsToSelector:@selector(onConnectionStatusChanged:)]) {
            [delegate onConnectionStatusChanged:status];
        }
    }
}

#pragma mark - RCIMClientReceiveMessageDelegate
- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object {
    for (id<RCMicMessageHandleDelegate>delegate in self.messageHandleTable) {
        if ([delegate respondsToSelector:@selector(handleMessage:)] && [delegate handleMessage:message]) {
            break;
        }
    }
}

- (void)onMessageRecalled:(long)messageId {
    RCMessage *message = [[RCIMClient sharedRCIMClient] getMessage:messageId];
    [[NSNotificationCenter defaultCenter] postNotificationName:RCMicRecallMessageNotification object:nil userInfo:@{@"message":message}];
}

#pragma mark - RCChatRoomKVStatusChangeDelegate
- (void)chatRoomKVDidSync:(NSString *)roomId {
    for (id<RCChatRoomKVStatusChangeDelegate>delegate in self.kvStatusChangedTable) {
        if ([delegate respondsToSelector:@selector(chatRoomKVDidSync:)]) {
            [delegate chatRoomKVDidSync:roomId];
        }
    }
}

- (void)chatRoomKVDidUpdate:(NSString *)roomId entry:(NSDictionary<NSString *,NSString *> *)entry {
    for (id<RCChatRoomKVStatusChangeDelegate>delegate in self.kvStatusChangedTable) {
        if ([delegate respondsToSelector:@selector(chatRoomKVDidUpdate:entry:)]) {
            [delegate chatRoomKVDidUpdate:roomId entry:entry];
        }
    }
}

- (void)chatRoomKVDidRemove:(NSString *)roomId entry:(NSDictionary<NSString *,NSString *> *)entry {
    for (id<RCChatRoomKVStatusChangeDelegate>delegate in self.kvStatusChangedTable) {
        if ([delegate respondsToSelector:@selector(chatRoomKVDidRemove:entry:)]) {
            [delegate chatRoomKVDidRemove:roomId entry:entry];
        }
    }
}

#pragma mark - Getters & Setters
- (NSHashTable *)connectionStatusHandleTable {
    if (!_connectionStatusHandleTable) {
        _connectionStatusHandleTable = [NSHashTable weakObjectsHashTable];
    }
    return _connectionStatusHandleTable;
}

- (NSHashTable *)messageHandleTable {
    if (!_messageHandleTable) {
        _messageHandleTable = [NSHashTable weakObjectsHashTable];
    }
    return _messageHandleTable;
}

- (NSHashTable *)kvStatusChangedTable {
    if (!_kvStatusChangedTable) {
        _kvStatusChangedTable = [NSHashTable weakObjectsHashTable];
    }
    return _kvStatusChangedTable;
}
@end
