//
//  RCMicRoomViewModel.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/8.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicRoomViewModel.h"
#import "RCMicMacro.h"
#import "RCMicChatLocalDataInfoModel.h"
#import "RCMicChatDataInfoModel.h"

///进入聊天室时需要拉取的最新消息的数量
#define ChatroomMessageCount -1

/// 麦位更新相关类型
typedef NS_ENUM(NSInteger, ParticipantChangeType) {
    ParticipantChangeTypeInit = 0,//初始类型（刚加入房间时拉取 KV）
    ParticipantChangeTypeUp,//正常上麦
    ParticipantChangeTypeDown,//正常下麦
    ParticipantChangeTypeAudinceTakeOver,//观众接管主持麦位
    ParticipantChangeTypeParticipantTakeOver,//主播接管主持麦位
    ParticipantChangeTypeTransfer,//主持麦位转让
    ParticipantChangeTypeStateUpdate,//麦位状态变更(锁定、闭麦等)
};

@interface RCMicRoomViewModel()<RCMicMessageHandleDelegate, RCMicRTCActivityMonitorDelegate, RCRTCRoomEventDelegate, RCChatRoomKVStatusChangeDelegate>
@property (nonatomic, assign) BOOL isSpeaking;//当前用户是否正在发言
@property (nonatomic, strong) RCRTCRoom *room;//当前加入的房间
@property (nonatomic, strong) RCMicParticipantInfo *currentParticipantInfo;//记录当前用户所在的麦位情况，如果当前为观众则此字段为 nil
@property (nonatomic, copy) NSString *liveUrl;//成功订阅过的直播间合流地址，不为空表明成功订阅过直播间合流
@property (nonatomic, strong) NSTimer *onlineCountTimer;
@end
@implementation RCMicRoomViewModel
- (instancetype)initWithRoomInfo:(id)roomInfo role:(RCMicRoleType)role {
    self = [super init];
    if (self) {
        _roomInfo = roomInfo;
        _role = role;
        _useSpeaker = YES;
        _useMicrophone = YES;
        _onlineCountTimer = [[NSTimer alloc] initWithFireDate:[NSDate distantPast] interval:5 target:self selector:@selector(onlineCountTimerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_onlineCountTimer forMode:NSRunLoopCommonModes];
        [[RCMicIMService sharedService] addMessageHandleDelegate:self];
        [[RCMicIMService sharedService] addKVStatusChangedDelegate:self];
        [[RCMicRTCService sharedService] addRTCActivityMonitorDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageRecalled:) name:RCMicRecallMessageNotification object:nil];
    }
    return self;
}

- (void)descory {
    //房间销毁时如果是主播则需要清理麦位相关状态
    if (self.role != RCMicRoleType_Audience) {
        self.isSpeaking = NO;
        [self setSpeakingState:NO];
        [self giveUpParticipant:^{
        } error:^(RCMicHTTPCode errorCode) {
        }];
    }
    [self.onlineCountTimer invalidate];
    self.onlineCountTimer = nil;
}

- (void)dealloc {
    RCMicLog(@"room viewModel dealloc!");
}

#pragma mark - Public method
- (void)joinMicRoom:(void (^)(void))successBlock imError:(void (^)(void))imErrorBlock rtcError:(void (^)(void))rtcErrorBlock {
    __weak typeof(self) weakSelf = self;
    RCRTCLiveRoleType roleType = self.role == RCMicRoleType_Audience ? RCRTCLiveRoleTypeAudience : RCRTCLiveRoleTypeBroadcaster;
    [[RCMicIMService sharedService] joinChatRoom:self.roomInfo.roomId messageCount:ChatroomMessageCount success:^{
        [[RCMicRTCService sharedService] joinRoom:weakSelf.roomInfo.roomId roleType:roleType success:^(RCRTCRoom * _Nonnull room) {
            weakSelf.room = room;
            weakSelf.room.delegate = weakSelf;
            successBlock ? successBlock() : nil;
        } error:^(RCRTCCode code) {
            rtcErrorBlock ? rtcErrorBlock() : nil;
        }];
    } error:^(RCErrorCode status) {
        imErrorBlock ? imErrorBlock() : nil;
    }];
}

- (void)quitMicRoom:(void (^)(void))successBlock error:(void (^)(void))errorBlock {
    NSString *roomId = self.roomInfo.roomId;
    [[RCMicIMService sharedService] quitChatRoom:roomId success:^{
        [[RCMicRTCService sharedService] leaveRoom:roomId success:^{
            successBlock ? successBlock() : nil;
        } error:^(RCRTCCode code) {
            errorBlock ? errorBlock() : nil;
        }];
    } error:^(RCErrorCode status) {
        errorBlock ? errorBlock() : nil;
    }];
}

- (void)publishOrSubscribeAudioStream:(void(^)(void))successBlock error:(void(^)(void))errorBlock {
    [self publishOrSubscribeAudioStreamWithRoleType:self.role success:successBlock error:errorBlock];
}

- (void)syncParticipantWaitingState:(void (^)(void))successBlock error:(void (^)(void))errorBlock {
    __weak typeof(self) weakSelf = self;
    [[RCMicIMService sharedService] getParticipantWaitingState:self.roomInfo.roomId success:^(BOOL waiting) {
        RCMicMainThread(^{
            weakSelf.waitingStateChanged ? weakSelf.waitingStateChanged(waiting) : nil;
        })
        successBlock ? successBlock() : nil;
    } error:^(RCErrorCode errorCode) {
        if (errorCode != RC_KEY_NOT_EXIST) {
            errorBlock ? errorBlock() : nil;
        } else {
            //聊天室状态值不存在时认为成功，因为房间中没人申请过排麦时相关 Key 是可能不存在的
            successBlock ? successBlock() : nil;
        }
    }];
}

- (void)onlineCountTimerAction {
    [self syncOnlineCount:^{
    } error:^{
    }];
}

- (void)syncOnlineCount:(void (^)(void))successBlock error:(void (^)(void))errorBlock {
    __weak typeof(self) weakSelf = self;
    [[RCMicIMService sharedService] getChatRoomUserCount:self.roomInfo.roomId success:^(NSInteger count) {
        successBlock ? successBlock() : nil;
        RCMicMainThread(^{
            weakSelf.onlineCountChanged ? weakSelf.onlineCountChanged(count) : nil;
        })
    } error:^(RCErrorCode errorCode) {
        errorBlock ? errorBlock() : nil;
    }];
}

- (void)sendTextMessage:(NSString *)text error:(void (^)(RCErrorCode errorCode))errorBlock
{
    __weak typeof(self) weakSelf = self;
    RCTextMessage *textMessage = [RCTextMessage messageWithContent:text];
    [[RCMicIMService sharedService] sendMessage:ConversationType_CHATROOM targetId:self.roomInfo.roomId content:textMessage pushContent:[textMessage conversationDigest] pushData:nil success:^(RCMessage *message) {
        [weakSelf insertMessage:message];
    } error:^(RCErrorCode errorCode, RCMessage *message) {
        errorBlock ? errorBlock(errorCode) : nil;
    }];
    
}

- (void)sendGiftMessage:(NSString *)content giftInfo:(RCMicGiftInfo *)giftInfo success:(void (^)(RCMessage *))successBlock error:(void (^)(RCErrorCode errorCode, RCMessage *message))errorBlock{
    __weak typeof(self) weakSelf = self;
    RCMicGiftMessage *giftMessage = [RCMicGiftMessage messageWithContent:content tag:giftInfo.tag];
    [[RCMicIMService sharedService] sendMessage:ConversationType_CHATROOM targetId:self.roomInfo.roomId content:giftMessage pushContent:nil pushData:nil success:^(RCMessage *message) {
        [weakSelf insertMessage:message];
        successBlock ? successBlock(message) : nil;
    } error:^(RCErrorCode errorCode, RCMessage *message) {
        errorBlock ? errorBlock(errorCode, message) : nil;
    }];
    
}

- (void)sendBroadcastGiftMessage:(RCMicGiftInfo *)gift {
    RCMicBroadcastGiftMessage *giftMessage = [RCMicBroadcastGiftMessage messageWithRoomName:self.roomInfo.roomName tag:gift.tag];
    giftMessage.senderUserInfo = (RCUserInfo *)[RCMicAppService sharedService].currentUser.userInfo;
    NSString *content = [[NSString alloc] initWithData:[giftMessage encode] encoding:NSUTF8StringEncoding];
    [[RCMicAppService sharedService] sendBroadcastMessage:nil objectName:[RCMicBroadcastGiftMessage getObjectName] content:content success:^{
    } error:^(RCMicHTTPCode errorCode) {
    }];
}

- (void)recallMessageWithMessageViewModel:(RCMicMessageViewModel *)messageViewModel error:(void (^)(RCErrorCode))errorBlock {
    __weak typeof(self) weakSelf = self;
    [[RCMicIMService sharedService] recallMessage:messageViewModel.message success:^{
        [weakSelf deleteMessage:messageViewModel.message];
    } error:^(RCErrorCode errorCode) {
        errorBlock ? errorBlock(errorCode) : nil;
    }];
}

- (NSArray *)currentParticipantUserIds {
    NSMutableArray *userIds = [[NSMutableArray alloc] init];
    [self.participantDataSource enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, RCMicParticipantViewModel * _Nonnull obj, BOOL * _Nonnull stop) {
        //如果这个麦位有人的话 把当前该麦位的userId存到数组里
        if (obj.participantInfo.userId.length > 0){
            [userIds addObject:obj.participantInfo.userId];
        };
    }];
    return userIds;
}

- (void)loadAllParticipantViewModel:(void (^)(void))successBlock error:(void (^)(RCErrorCode))errorBlock {
    __weak typeof(self) weakSelf = self;
    [[RCMicIMService sharedService] getAllParticipantInfo:self.roomInfo.roomId success:^(NSDictionary<NSString *, RCMicParticipantInfo *> *particitantDict) {
        for (NSString *key in particitantDict.allKeys) {
            RCMicParticipantViewModel *viewModel = weakSelf.participantDataSource[key];
            viewModel.participantInfo = particitantDict[key];
            [weakSelf roleChangeIfNeeded:particitantDict[key] kvNotificationMessage:nil];
        }
        successBlock ? successBlock() : nil;
    } error:^(RCErrorCode errorCode) {
        errorBlock ? errorBlock(errorCode) : nil;
    }];
}

- (NSInteger)transformEntryKeyToPosition:(NSString *)key {
    NSInteger position = -1;
    NSArray *array = [key componentsSeparatedByString:@"_"];
    if (array.count >= 3) {
        position = [array[2] intValue];
    }
    return position;
}

- (void)giveUpParticipant:(void(^)(void))successBlock
                    error:(void(^)(RCMicHTTPCode errorCode))errorBlock{
    [[RCMicAppService sharedService] giveUpParticipant:self.roomInfo.roomId success:^{
        successBlock ? successBlock() : nil;
    } error:^(RCMicHTTPCode errorCode) {
        errorBlock ? errorBlock(errorCode) : nil;
    }];
}

- (void)transferHost:(NSString *)userId success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    [[RCMicAppService sharedService] transferHost:self.roomInfo.roomId toUser:userId success:^{
        successBlock ? successBlock() : nil;
    } error:^(RCMicHTTPCode errorCode) {
        errorBlock ? errorBlock(errorCode) : nil;
    }];
}

- (void)agreeHostTakeOver:(BOOL)agree userId:(NSString *)userId error:(void (^)(RCMicHTTPCode))errorBlock {
    [[RCMicAppService sharedService] dealWithHostTakeOver:self.roomInfo.roomId accept:agree userId:userId success:^{
    } error:^(RCMicHTTPCode errorCode) {
        errorBlock ? errorBlock(errorCode) : nil;
    }];
}

- (void)inviteParticipant:(NSString *)userId error:(void (^)(RCMicHTTPCode))errorBlock {
    [[RCMicAppService sharedService] inviteParticipant:self.roomInfo.roomId userId:userId success:^{
    } error:^(RCMicHTTPCode errorCode) {
        errorBlock ? errorBlock(errorCode) : nil;
    }];
}

- (void)enableSendMessage:(BOOL)enable user:(NSString *)userId error:(void (^)(RCMicHTTPCode))errorBlock {
    NSString *idString =  (userId == nil) ? @"" : userId;
    [[RCMicAppService sharedService] setUserStateInRoom:self.roomInfo.roomId userIds:@[idString] canSendMessage:enable success:^{
    } error:^(RCMicHTTPCode errorCode) {
        errorBlock ? errorBlock(errorCode) : nil;
    }];
}

- (void)changeParticipantState:(RCMicParticipantState)state position:(NSInteger)position success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    if (position == -1) {
        position = self.currentParticipantInfo.position;
    }
    [[RCMicAppService sharedService]setParticipantState:self.roomInfo.roomId state:state position:position success:^{
        successBlock ? successBlock() : nil;
    } error:^(RCMicHTTPCode errorCode) {
        errorBlock ? errorBlock(errorCode) : nil;
    }];
}

- (void)kickUserOut:(NSString *)userId success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    NSArray *userArray = userId.length > 0 ? @[userId] : nil;
    [[RCMicAppService sharedService] kickUserOut:self.roomInfo.roomId userIds:userArray success:^{
        successBlock ? successBlock() : nil;
    } error:^(RCMicHTTPCode errorCode) {
        errorBlock ? errorBlock(errorCode) : nil;
    }];
}

- (void)applyParticipant:(void(^)(RCMicHTTPCode errorCode))errorBlock{
    [[RCMicAppService sharedService] applyParticipant:self.roomInfo.roomId success:^{
    } error:^(RCMicHTTPCode errorCode) {
        errorBlock ? errorBlock(errorCode) : nil;
    }];
}

- (void)kickParticipantOut:(NSString *)userId error:(void (^)(RCMicHTTPCode))errorBlock {
    [[RCMicAppService sharedService] kickParticipantOut:self.roomInfo.roomId userId:userId success:^{
    } error:^(RCMicHTTPCode errorCode) {
        errorBlock ? errorBlock(errorCode) : nil;
    }];
}

- (void)takeOverHost:(void (^)(BOOL))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    NSString *hostKey = [NSString stringWithFormat:@"%@0",RCMicParticipantEntryKey];
    RCMicParticipantViewModel *viewModel = self.participantDataSource[hostKey];
    BOOL showWheel = viewModel.participantInfo.userId.length > 0 ? YES : NO;
    [[RCMicAppService sharedService] takeOverHost:self.roomInfo.roomId success:^{
        successBlock ? successBlock(showWheel) : nil;
    } error:^(RCMicHTTPCode errorCode) {
        errorBlock ? errorBlock(errorCode) : nil;
    }];
}

- (void)acceptHostTransfer:(BOOL)accept error:(void (^)(RCMicHTTPCode))errorBlock {
    [[RCMicAppService sharedService] dealWithHostTransfer:self.roomInfo.roomId accept:accept success:^{
    } error:^(RCMicHTTPCode errorCode) {
        errorBlock ? errorBlock(errorCode) : nil;
    }];
}

#pragma mark - Private method
#pragma mark - 消息相关
/// 收到需要展示的普通消息
- (void)receivedNormalMessage:(RCMessage *)message {
    [self insertMessage:message];
    //礼物消息
    if ([message.content isMemberOfClass:[RCMicGiftMessage class]]) {
        RCMicGiftMessage *giftMessage = (RCMicGiftMessage *)message.content;
        RCMicMainThread(^{
            self.receivedGiftMessage ? self.receivedGiftMessage(giftMessage) : nil;
        })
    }
}

/// 收到状态同步相关消息
- (void)receivedCommandMessage:(RCMessage *)message {
    NSString *currentUserId = [RCMicAppService sharedService].currentUser.userInfo.userId;
    
    if ([message.content isMemberOfClass:[RCChatroomKVNotificationMessage class]]) {
        //聊天室 KV 同步消息
        [self updateParticipantViewModelWithMessage:(RCChatroomKVNotificationMessage *)message.content];
    } else if ([message.content isMemberOfClass:[RCMicTransferHostMessage class]]) {
        //主持人转让消息
        RCMicTransferHostMessage *transferMessage = (RCMicTransferHostMessage *)message.content;
        if ([transferMessage.targetUserId isEqualToString:currentUserId]) {
            if (self.role == RCMicRoleType_Host && transferMessage.type != RCMicTransferHostMessageTypeRequest) {
                //主持人收到对方响应的消息时
                RCMicMainThread(^{
                    BOOL result = transferMessage.type == RCMicTransferHostMessageTypeResponseAccept ? YES : NO;
                    self.hostTransferResponse ? self.hostTransferResponse(transferMessage.operatorName, transferMessage.operatorId, result) : nil;
                })
            } else if (self.role == RCMicRoleType_Participant && transferMessage.type == RCMicTransferHostMessageTypeRequest) {
                //参会者收到自己被邀请接管主持人的消息时
                RCMicMainThread(^{
                    self.hostTransferRequest ? self.hostTransferRequest(transferMessage.operatorName, transferMessage.operatorId) : nil;
                })
            }
        }
    } else if ([message.content isMemberOfClass:[RCMicTakeOverHostMessage class]]) {
        //接管主持人消息
        RCMicTakeOverHostMessage *takeOverMessage = (RCMicTakeOverHostMessage *)message.content;
        if ([takeOverMessage.targetUserId isEqualToString:currentUserId]) {
            if (self.role == RCMicRoleType_Host && takeOverMessage.type == RCMicTakeOverHostMessageTypeRequest) {
                //主持人收到请求接管的消息时
                RCMicMainThread(^{
                    self.takeOverHostRequest ? self.takeOverHostRequest(takeOverMessage.operatorName, takeOverMessage.operatorId) : nil;
                })
            } else if (self.role != RCMicRoleType_Host && takeOverMessage.type != RCMicTakeOverHostMessageTypeRequest) {
                //参会者收到主持人的响应时
                RCMicMainThread(^{
                    BOOL result = takeOverMessage.type == RCMicTakeOverHostMessageTypeResponseAccept ? YES : NO;
                    self.takeOverHostResponse ? self.takeOverHostResponse(takeOverMessage.operatorName, takeOverMessage.operatorId, result) : nil;
                })
            }
        }
    } else if ([message.content isMemberOfClass:[RCMicBroadcastGiftMessage class]]) {
        //广播礼物消息
        RCMicBroadcastGiftMessage *broadcastMessage = (RCMicBroadcastGiftMessage *)message.content;
        RCMicMainThread(^{
            self.receivedBroadcastMessage ? self.receivedBroadcastMessage(broadcastMessage) : nil;
        })
    }
}

- (void)insertMessage:(RCMessage *)message {
    RCMicMainThread(^{
        RCMicMessageViewModel *viewModel = [[RCMicMessageViewModel alloc] initWithMessage:message];
        [self.messageDataSource addObject:viewModel];
        NSArray *indexs = @[@(self.messageDataSource.count - 1)];
        self.messageChanged ? self.messageChanged(RCMicMessageChangedTypeAdd, indexs) : nil;
    })
}

- (void)deleteMessage:(RCMessage *)message {
    RCMicMainThread(^{
        NSInteger index = 0;
        BOOL hasFind = NO;
        for (int i = 0; i < self.messageDataSource.count; i ++) {
            long messageId = self.messageDataSource[i].message.messageId;
            if (messageId == message.messageId) {
                index = i;
                hasFind = YES;
                break;
            }
        }
        if (hasFind) {
            [self.messageDataSource removeObjectAtIndex:index];
            NSArray *indexs = @[@(index)];
            self.messageChanged ? self.messageChanged(RCMicMessageChangedTypeDelete, indexs) : nil;
        }
    })
}

#pragma mark - 麦位角色转换及更新相关
- (void)updateParticipantViewModelWithMessage:(RCChatroomKVNotificationMessage *)kvMessage {
    NSString *key = kvMessage.key;
    NSData *data = [kvMessage.value dataUsingEncoding:NSUTF8StringEncoding];
    
    if ([key hasPrefix:RCMicParticipantEntryKey]) {//麦位变更
        if (kvMessage.type == RCChatroomKVNotificationTypeSet) {
            NSDictionary *dict = [RCMicUtil dictionaryWithData:data];
            
            //更新数据源中的麦位信息
            RCMicParticipantViewModel *viewModel = self.participantDataSource[key];
            RCMicParticipantInfo *info = viewModel.participantInfo;
            info.isHost = [self isHost:key];
            info.userId = dict[RCMicParticipantUserIdKey];
            info.state = (RCMicParticipantState)[dict[RCMicParticipantStateKey] integerValue];
            //根据麦位信息的改变处理相关角色的转换，只需处理和自己相关的角色转化逻辑，麦位上其它用户的上麦下麦需要做的订阅流操作在 RongRTCRoomDelegate 操作
            [self roleChangeIfNeeded:info kvNotificationMessage:kvMessage];
            RCMicMainThread(^{
                self.participantChanged ? self.participantChanged(@[key]) : nil;
            })
        }
    } else if ([key hasPrefix:RCMicParticipantSpeakingEntryKey]) {//发言状态变更
        NSDictionary *dict = [RCMicUtil dictionaryWithData:data];
        NSString *participantKey = [NSString stringWithFormat:@"%@%ld",RCMicParticipantEntryKey,[dict[RCMicParticipantSpeakingPositionKey] longValue]];
        BOOL speaking = NO;
        if (kvMessage.type == RCChatroomKVNotificationTypeSet) {
            speaking = [dict[RCMicParticipantSpeakingKey] intValue] == 1 ? YES : NO;
        } else if (kvMessage.type == RCChatroomKVNotificationTypeRemove) {
            speaking = NO;
        }
        [self updateSpeakingState:participantKey speaking:speaking];
    } else if ([key hasPrefix:RCMicParticipantWaitingKey]) {//排麦人数变更
        if (kvMessage.type == RCChatroomKVNotificationTypeSet) {
            BOOL waiting = [kvMessage.value integerValue] == 1 ? YES : NO;
            RCMicMainThread(^{
                self.waitingStateChanged ? self.waitingStateChanged(waiting) : nil;
            })
        }
    }
}

- (BOOL)isHost:(NSString *)key {
    if ([key isEqualToString:[RCMicParticipantEntryKey stringByAppendingString:@"0"]]) {
        return YES;
    }
    return NO;
}

- (void)roleChangeIfNeeded:(RCMicParticipantInfo *)newInfo kvNotificationMessage:(RCChatroomKVNotificationMessage *)kvMessage {
    NSString *currentUserId = [RCMicAppService sharedService].currentUser.userInfo.userId;
    ParticipantChangeType changeType = ParticipantChangeTypeInit;
    if (kvMessage) {
        NSString *dataString = kvMessage.extra ? kvMessage.extra : @"";
        changeType = (ParticipantChangeType)[[RCMicUtil dictionaryWithData:[dataString dataUsingEncoding:NSUTF8StringEncoding]][@"changeType"] integerValue];
    }
    //发生变化后麦位上的用户是自己时（表明此次变化后自己可能需要上麦或者根据麦位更新状态）
    if ([newInfo.userId isEqualToString:currentUserId]) {
        //如果之前自己是观众身份，则需要变为参会者
        if (self.role == RCMicRoleType_Audience) {
            [self changeAudienceToParticipant:newInfo];
        }
        //如果之前自己没有在麦位或者之前自己所在麦位的状态和新的不符，则需要更新麦位状态
        if (!self.currentParticipantInfo || self.currentParticipantInfo.state != newInfo.state) {
            BOOL enable = newInfo.state == RCMicParticipantStateNormal ? YES : NO;
            RCMicMainThread(^{
                self.microPhoneStateChanged ? self.microPhoneStateChanged(enable) : nil;
            })
        }
        //将本地保存的麦位信息更新到最新
        [self refreshCurrentParticipantInfo:newInfo];
    } else {
        BOOL changeToOtherPosition = changeType == ParticipantChangeTypeParticipantTakeOver || changeType == ParticipantChangeTypeTransfer || changeType == ParticipantChangeTypeStateUpdate;
        //发生变更的麦位是自己之前所持有的且变化后麦位上的人不是自己且此次变化类型不是双方在麦位互换身份（为了避免用户和主持人切换身份时频繁进行上下麦操作，麦位上互换身份时不做 RTC 层的上下麦处理），则需要进行下麦操作
        if (!changeToOtherPosition && self.currentParticipantInfo && self.currentParticipantInfo.position == newInfo.position) {
            [self changeParticipantToAudience];
            //将本地保存的麦位信息更新到最新
            [self refreshCurrentParticipantInfo:nil];
        }
    }
}

/**
 * 刷新当前用户的麦位及角色信息
 *
 * @param info 最新的麦位信息
 */
- (void)refreshCurrentParticipantInfo:(RCMicParticipantInfo *)info {
    //在角色改变前将所在麦位的发言状态设置为 NO
    self.isSpeaking = NO;
    [self setSpeakingState:NO];
    if (info) {
        self.role = info.position == 0 ? RCMicRoleType_Host : RCMicRoleType_Participant;
        //保存变更后自己的麦位信息，这里注意要 copy 后使用，否则后续麦位的变更会影响记录的数据
        self.currentParticipantInfo = [info copy];
    } else {
        self.role = RCMicRoleType_Audience;
        self.currentParticipantInfo = nil;
    }
}

- (void)changeAudienceToParticipant:(RCMicParticipantInfo *)participantInfo {
    __weak typeof(self) weakSelf = self;

    //观众先离开房间
    [[RCMicRTCService sharedService] leaveRoom:self.roomInfo.roomId success:^{
        //再以主播身份重新加入 RTC 房间，这里 roleType 传 RCMicRoleType_Participant 或者 RCMicRoleType_Host 效果是一样的，因为 RTC 层只有观众和主播的区分
        [[RCMicRTCService sharedService] joinRoom:weakSelf.roomInfo.roomId roleType:RCRTCLiveRoleTypeBroadcaster success:^(RCRTCRoom * _Nonnull room) {
            weakSelf.room = room;
            weakSelf.room.delegate = self;
            //注意：由于此 demo 中用户发言状态通过聊天室 KV 设置时会有消息产生，所以当房间内长时间没有用户手动发送消息时聊天室也不会被销毁
            //但是如果实际项目中没有使用 KV 相关功能频繁发送消息，就需要在加入成功后开启个定时器，每隔几分钟向房间内发送一条保活消息，防止房间内用户只通过音视频沟通但是 IM 聊天室由于长时间没有消息产生被服务销毁
            //订阅房间中的音频流
            NSMutableArray *streamArray = [NSMutableArray array];
            for (RCRTCRemoteUser *user in room.remoteUsers) {
                for (RCRTCInputStream *stream in user.remoteStreams) {
                    [streamArray addObject:stream];
                }
            }
            if (streamArray.count > 0) {
                [[RCMicRTCService sharedService] subscribeAudioStreams:weakSelf.room streams:streamArray success:^{
                } error:^(RCRTCCode code) {
                    //加入 RTC 房间后订阅已存在音频流失败，根据应用实际需求决定如何提示用户即可
                    [weakSelf showErrorTip:RCMicLocalizedNamed(@"room_subscribeStream_failed")];
                }];
            }
            
            //发送自己的音频流
            [weakSelf publishOrSubscribeAudioStreamWithRoleType:RCMicRoleType_Participant success:^{
            } error:^{
                //加入 RTC 房间后发布自己的音频流失败，根据应用实际需求决定如何提示用户即可
                [weakSelf showErrorTip:RCMicLocalizedNamed(@"room_publishStream_failed")];
            }];
        } error:^(RCRTCCode code) {
            [weakSelf showErrorTip:RCMicLocalizedNamed(@"room_joinRTC_failed")];
        }];
    } error:^(RCRTCCode code) {
        [weakSelf showErrorTip:RCMicLocalizedNamed(@"room_leaveRTC_failed")];
    }];
}

- (void)changeParticipantToAudience {
    __weak typeof(self) weakSelf = self;
    //主播先退出 RTC 房间
    [[RCMicRTCService sharedService] leaveRoom:self.roomInfo.roomId success:^{
        //然后以观众身份重新加入 RTC 房间
        [[RCMicRTCService sharedService] joinRoom:weakSelf.roomInfo.roomId roleType:RCRTCLiveRoleTypeAudience success:^(RCRTCRoom * _Nonnull room) {
            weakSelf.room = room;
            room.delegate = weakSelf;
            //订阅房间中的音频合流
            [weakSelf publishOrSubscribeAudioStreamWithRoleType:RCMicRoleType_Audience success:^{
            } error:^{
                //订阅音频合流失败，根据应用实际需求决定如何提示用户即可
                [weakSelf showErrorTip:RCMicLocalizedNamed(@"room_subscribeStream_failed")];
            }];
        } error:^(RCRTCCode code) {
            [weakSelf showErrorTip:RCMicLocalizedNamed(@"room_joinRTC_failed")];
        }];
    } error:^(RCRTCCode code) {
        [weakSelf showErrorTip:RCMicLocalizedNamed(@"room_leaveRTC_failed")];
    }];
}

- (void)reSubscribeAudioStream:(NSArray<RCRTCInputStream*> *)streams {
    __weak typeof(self) weakSelf = self;
    
    if (self.role == RCMicRoleType_Audience) {
        [[RCMicRTCService sharedService] subscribeAudioStreams:self.room streams:streams success:^{
        } error:^(RCRTCCode code) {
            [weakSelf showErrorTip:RCMicLocalizedNamed(@"room_subscribeStream_failed")];
        }];
    }
}

- (void)publishOrSubscribeAudioStreamWithRoleType:(RCMicRoleType)roleType success:(void (^)(void))successBlock error:(void (^)(void))errorBlock {
    __weak typeof(self) weakSelf = self;
    //主播：直接发布自己的音频流
    if (roleType == RCMicRoleType_Host || roleType == RCMicRoleType_Participant) {
        [[RCMicRTCService sharedService] publishAudioStream:self.room success:^(RCRTCLiveInfo * _Nonnull liveInfo) {
            successBlock ? successBlock() : nil;
            RCMicMainThread(^{
                //主播发布自己的流成功后才认为成功上麦
                weakSelf.didHoldOrGiveUpMic ? weakSelf.didHoldOrGiveUpMic(YES) : nil;
            })
        } error:^(RCRTCCode code) {
            errorBlock ? errorBlock() : nil;
        }];
    } else if (roleType == RCMicRoleType_Audience) {
        //观众：从当前房间中获取 live 合流并订阅
        NSArray *liveStreams = [self.room getLiveStreams];
        if (liveStreams.count) {
            [[RCMicRTCService sharedService] subscribeAudioStreams:self.room streams:liveStreams success:^{
                successBlock ? successBlock() : nil;
            } error:^(RCRTCCode code) {
                errorBlock ? errorBlock() : nil;
            }];
        }
        //观众无论是否成功订阅直播合流都认为成功下麦
        weakSelf.didHoldOrGiveUpMic ? weakSelf.didHoldOrGiveUpMic(NO) : nil;
    }
}

#pragma mark - 发言状态相关
- (void)speakingStateChanged {
    [self setSpeakingState:self.isSpeaking];
}

/**
 * 设置是否正在讲话的 KV
 */
- (void)setSpeakingState:(BOOL)speaking {
    if (self.currentParticipantInfo) {
        [[RCMicIMService sharedService] setSpeakingState:self.roomInfo.roomId position:self.currentParticipantInfo.position isSpeaking:speaking success:^{
        } error:^(RCErrorCode errorCode) {
            //            [self showErrorTip:RCMicLocalizedNamed(@"room_setSpeakingState_failed")];
        }];
        //设置 KV 的同时需要主动改变自己所在麦位的发言状态，因为 KV 改变的通知发送方是不会收到的
        NSString *key = [NSString stringWithFormat:@"%@%ld",RCMicParticipantEntryKey,(long)self.currentParticipantInfo.position];
        [self updateSpeakingState:key speaking:speaking];
    }
}

/**
 * 更新麦位上正在发言的状态
 *
 * @param key 该麦位在数据源中对应的 key
 * @param speaking 是否正在讲话
 */
- (void)updateSpeakingState:(NSString *)key speaking:(BOOL)speaking {
    RCMicMainThread(^{
        RCMicParticipantViewModel *viewModel = self.participantDataSource[key];
        viewModel.participantInfo.speaking = speaking;
        self.participantChanged ? self.participantChanged(@[key]) : nil;
    })
}

#pragma mark - 直播延迟相关
- (void)updateDebugInfo:(RCRTCStatusForm *)form {
    NSMutableArray *bitrateArray = [NSMutableArray new];
    NSMutableArray *localDIArray = [NSMutableArray array];
    [localDIArray addObject:@[RCMicLocalizedNamed(@"chat_data_excel_tunnelname"),RCMicLocalizedNamed(@"chat_data_excel_kbps"),RCMicLocalizedNamed(@"chat_data_excel_delay")]];
    
    RCMicChatLocalDataInfoModel *sendModel = [[RCMicChatLocalDataInfoModel alloc] init];
    sendModel.channelName = RCMicLocalizedNamed(@"chat_data_excel_send");
    sendModel.codeRate =  [NSString stringWithFormat:@"%0.2fkbps",form.totalSendBitRate];
    sendModel.delay = [NSString stringWithFormat:@"%@",@(form.rtt)];
    [localDIArray addObject:sendModel];
    
    RCMicChatLocalDataInfoModel *recvModel = [[RCMicChatLocalDataInfoModel alloc] init];
    recvModel.channelName = RCMicLocalizedNamed(@"chat_data_excel_receive");
    recvModel.codeRate =  [NSString stringWithFormat:@"%0.2fkbps",form.totalRecvBitRate];
    recvModel.delay = @"--";
    [localDIArray addObject:recvModel];
    
    [bitrateArray addObject:localDIArray];
    
    NSMutableArray *remoteDIArray = [NSMutableArray array];
    [remoteDIArray addObject:@[RCMicLocalizedNamed(@"chat_data_excel_userid"),RCMicLocalizedNamed(@"chat_data_excel_tunnelname"),RCMicLocalizedNamed(@"chat_data_excel_Codec"),RCMicLocalizedNamed(@"chat_data_excel_kbps"),RCMicLocalizedNamed(@"chat_data_excel_lossrate")]];
    
    for (RCRTCStreamStat* stat in form.sendStats) {
        RCMicChatDataInfoModel *tmpMemberModel = [[RCMicChatDataInfoModel alloc] init];
        tmpMemberModel.userName = RCMicLocalizedNamed(@"chat_data_excel_local");
        if ([stat.mediaType isEqualToString:RongRTCMediaTypeAudio]) {
            tmpMemberModel.tunnelName = RCMicLocalizedNamed(@"chat_data_excel_audio_send");
            tmpMemberModel.codec = stat.codecName;
            tmpMemberModel.codeRate = [NSString stringWithFormat:@"%.02f",stat.bitRate];
            tmpMemberModel.lossRate = [NSString stringWithFormat:@"%.02f",stat.packetLoss*100];
            [remoteDIArray addObject:tmpMemberModel];
            break;
        }
    }
    
    for (RCRTCStreamStat* stat in form.recvStats) {
        RCMicChatDataInfoModel *tmpMemberModel = [[RCMicChatDataInfoModel alloc] init];
        tmpMemberModel.userName = [RCRTCStatusForm fetchUserIdFromTrackId:stat.trackId];
        if ([stat.mediaType isEqualToString:RongRTCMediaTypeAudio]) {
            tmpMemberModel.tunnelName = RCMicLocalizedNamed(@"chat_data_excel_audio_receive");
            tmpMemberModel.codec = stat.codecName.length > 0 ? stat.codecName : @"--";
            tmpMemberModel.codeRate = [NSString stringWithFormat:@"%.02f",stat.bitRate];
            tmpMemberModel.lossRate = [NSString stringWithFormat:@"%.02f",stat.packetLoss*100];
            [remoteDIArray addObject:tmpMemberModel];
        }
    }
    
    [bitrateArray addObject:remoteDIArray];
    RCMicMainThread(^{
        self.debugInfoChanged ? self.debugInfoChanged([bitrateArray copy]) : nil;
    })
}

- (void)showErrorTip:(NSString *)tip {
    RCMicMainThread(^{
        self.showTipWithErrorInfo ? self.showTipWithErrorInfo(tip) : nil;
    })
}

#pragma mark - Notification selectors
- (void)onMessageRecalled:(NSNotification *)notification {
    RCMessage *message = notification.userInfo[@"message"];
    [self deleteMessage:message];
}

#pragma mark - RCMicMessageHandleDelegate
- (BOOL)handleMessage:(nonnull RCMessage *)message {
    if (message.conversationType == ConversationType_CHATROOM && [message.targetId isEqualToString:self.roomInfo.roomId]) {
        RCMessagePersistent flag = [[message.content class] persistentFlag];
        if (flag == MessagePersistent_ISCOUNTED) {
            [self receivedNormalMessage:message];
        } else if (flag == MessagePersistent_NONE) {
            [self receivedCommandMessage:message];
        }
        return YES;
    }
    return NO;
}

#pragma mark - RCMicRTCActivityMonitorDelegate
- (void)didReportStatForm:(RCRTCStatusForm *)form {
    //当前用户在麦位上时更新所在麦位发言状态
    if (self.currentParticipantInfo) {
        //遍历所有发送的音视频流的状态，如果是音频流，音量 > 1 则需要设置当前所处麦位的发言状态
        for (RCRTCStreamStat *status in form.sendStats) {
            if ([status.mediaType isEqualToString:RongRTCMediaTypeAudio]) {
                BOOL speaking = NO;
                if (status.audioLevel > 0) {
                    speaking = YES;
                } else {
                    speaking = NO;
                }
                if (self.isSpeaking != speaking) {
                    self.isSpeaking = speaking;
                    [self speakingStateChanged];
                }
                break;
            }
        }
    }
    //更新直播延迟信息
    RCMicMainThread(^{
        self.delayInfoChanged ? self.delayInfoChanged(form.rtt) : nil;
    })
    if (self.debugDisplay) {
        [self updateDebugInfo:form];
    }
}

#pragma mark - RCRTCRoomEventDelegate
- (void)didPublishStreams:(NSArray <RCRTCInputStream *>*)streams {
    __weak typeof(self) weakSelf = self;
    [[RCMicRTCService sharedService] subscribeAudioStreams:self.room streams:streams success:^{
    } error:^(RCRTCCode code) {
        //收到有人发布的音频流后订阅失败，根据实际需求提示用户
        [weakSelf showErrorTip:RCMicLocalizedNamed(@"room_subscribeStream_failed")];
    }];
}

//RTC 房间直播合流变更时观众需要重新订阅
- (void)didPublishLiveStreams:(NSArray<RCRTCInputStream *> *)streams {
    [self reSubscribeAudioStream:streams];
}

#pragma mark - RCChatRoomKVStatusChangeDelegate
- (void)chatRoomKVDidSync:(NSString *)roomId {
    if ([roomId isEqualToString:self.roomInfo.roomId]) {
        RCMicMainThread(^{
            self.kvSyncCompleted ? self.kvSyncCompleted() : nil;
        })
    }
}

#pragma mark - Getters & Setters

- (NSMutableArray<RCMicMessageViewModel *> *)messageDataSource {
    if (!_messageDataSource) {
        _messageDataSource = [NSMutableArray array];
    }
    return _messageDataSource;
}

- (NSMutableDictionary<NSString *, RCMicParticipantViewModel *> *)participantDataSource {
    if (!_participantDataSource) {
        _participantDataSource = [NSMutableDictionary dictionary];
        for (int i = 0; i < 9; i ++) {
            NSString *key = [NSString stringWithFormat:@"%@%d",RCMicParticipantEntryKey,i];
            RCMicParticipantInfo *info = [[RCMicParticipantInfo alloc] init];
            info.isHost = i == 0 ? YES : NO;
            info.state = RCMicParticipantStateNormal;
            info.position = i;
            info.speaking = NO;
            RCMicParticipantViewModel *viewModel = [[RCMicParticipantViewModel alloc] initWithParticipantInfo:info];
            [_participantDataSource setValue:viewModel forKey:key];
        }
    }
    return _participantDataSource;
}

- (void)setUseMicrophone:(BOOL)useMicrophone {
    _useMicrophone = useMicrophone;
    [[RCMicRTCService sharedService] microphoneEnable:useMicrophone];
}

- (void)setUseSpeaker:(BOOL)useSpeaker {
    _useSpeaker = useSpeaker;
    [[RCMicRTCService sharedService] useSpeaker:useSpeaker];
}
@end
