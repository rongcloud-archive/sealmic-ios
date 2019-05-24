//
//  IMService.m
//  SealMeeting
//
//  Created by LiFei on 2019/3/15.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "IMService.h"
#import "ClassroomService.h"
#import "RoomMemberChangedMessage.h"

@implementation IMService

+ (instancetype)sharedService {
    static IMService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[IMService alloc] init];
        [[ClassroomService sharedService] registerCommandMessages];
    });
    return service;
}

- (void)joinIMChatRoom:(NSString *)roomId success:(void(^)(void))successBlock error:(void(^)(int errCode))errorBlock {
    [IMClient joinChatRoom:roomId messageCount:-1 success:^{
        dispatch_main_async_safe(^{
            if(successBlock) {
                successBlock();
            }
        })
    } error:^(RCErrorCode status) {
        dispatch_main_async_safe(^{
            if(errorBlock) {
                errorBlock(status);
            }
        })
    }];
}

- (void)quitIMChatRoom:(NSString *)roomId success:(void (^)(void))successBlock error:(void (^)(RCErrorCode))errorBlock{
    SealMicLog(@"leave IM room start");
    [IMClient quitChatRoom:roomId success:^{
        SealMicLog(@"leave IM room success");
        dispatch_main_async_safe(^{
            if(successBlock) {
                successBlock();
            }
        })
    } error:^(RCErrorCode status) {
        SealMicLog(@"leave IM room error:%ld",status);
        dispatch_main_async_safe(^{
            if(errorBlock) {
                errorBlock(status);
            }
        })
    }];
}

- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object {
    if (![[ClassroomService sharedService] isHoldMessage:message]) {
        if ([self.receiveMessageDelegate respondsToSelector:@selector(onReceiveMessage:left:object:)]) {
            [self.receiveMessageDelegate onReceiveMessage:message left:nLeft object:object];
        }
    }
}

- (void)receiveFakeCurrentUserJoinMessage {
    if([self.receiveMessageDelegate respondsToSelector:@selector(onReceiveMessage: left: object:)]) {
        RCMessage *msg = [self _generateMemberChangeMessage:MemberChangeActionJoin];
        [self.receiveMessageDelegate onReceiveMessage:msg left:0 object:nil];
    }
}

- (RCMessage *)_generateMemberChangeMessage:(MemberChangeAction)action {
    RCMessage *msg = [RCMessage new];
    NSString *curUserId = [ClassroomService sharedService].currentUser.userId;
    msg.senderUserId = curUserId;
    RoomMemberChangedMessage *content = [RoomMemberChangedMessage new];
    content.userId = curUserId;
    content.action = action;
    content.targetPosition = -1;
    msg.content = content;
    msg.objectName = [[content class] getObjectName];
    return msg;
}
@end
