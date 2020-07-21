//
//  RCMicOperationModel.m
//  SealMic
//
//  Created by rongyun on 2020/7/16.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicOperationModel.h"
#import "RCMicMacro.h"

@implementation RCMicOperationModel

- (instancetype)initWithType:(DIALOGOPERATIONTYPE)type {
    self = [super init];
    if (self) {
        _type = type;
        _title = [self dialogOperationStringWithType:type];
    }
    return self;
}

- (instancetype)initWithSetType:(DIALOGOPERATIONSETTYPE)type {
    self = [super init];
    if (self) {
        _setType = type;
        _title = [self dialogSetOperationStringWithType:type];
    }
    return self;
}

///// 将对应枚举值转换为字符串
///// @param type 弹框操作枚举项类型
- (NSString *)dialogOperationStringWithType:(DIALOGOPERATIONTYPE)type {
    switch (type) {
            
        case DIALOGOPERATIONTYPE_GiveGift:
            return RCMicLocalizedNamed(@"dialog_giving_gift");
            break;
        case DIALOGOPERATIONTYPE_SendMessage:
            return RCMicLocalizedNamed(@"dialog_send_message");
            break;
        case DIALOGOPERATIONTYPE_ApplyParticipant:
            return RCMicLocalizedNamed(@"dialog_ranking_mic");
            break;
        case DIALOGOPERATIONTYPE_TakeOverHost:
            return RCMicLocalizedNamed(@"dialog_takeOver_Host");
            break;
        case DIALOGOPERATIONTYPE_KickParticipantOut:
            return RCMicLocalizedNamed(@"dialog_exit_mic");
            break;
        case DIALOGOPERATIONTYPE_ParticipantOpen:
            return RCMicLocalizedNamed(@"dialog_open_mic");
            break;
        case DIALOGOPERATIONTYPE_ParticipantClose:
            return RCMicLocalizedNamed(@"dialog_close_mic");
            break;
        case DIALOGOPERATIONTYPE_TransferHost:
            return RCMicLocalizedNamed(@"dialog_transferHost");
            break;
        case DIALOGOPERATIONTYPE_KickUserOut:
            return RCMicLocalizedNamed(@"dialog_kick_user_out");
            break;
        case DIALOGOPERATIONTYPE_SetParticipantLock:
            return RCMicLocalizedNamed(@"dialog_participant_lock");
            break;
        case DIALOGOPERATIONTYPE_SetParticipantUnLock:
            return RCMicLocalizedNamed(@"dialog_participant_unlock");
            break;
        case DIALOGOPERATIONTYPE_InvitationParticipant:
            return RCMicLocalizedNamed(@"dialog_invitation_participant");
            break;
        case DIALOGOPERATIONTYPE_InvitationConnectMic:
            return RCMicLocalizedNamed(@"dialog_invitation_connect_participant");
            break;
        case DIALOGOPERATIONTYPE_SetUserBanned:
            return RCMicLocalizedNamed(@"dialog_invitation_user_banned");
            break;
        case DIALOGOPERATIONTYPE_DeleteMessage:
            return RCMicLocalizedNamed(@"dialog_invitation_delete_message");
            break;
        default:
            return @"无操作";
            break;
    }
}

///// 将对应枚举值转换为字符串
///// @param type 弹框设置列表操作枚举项类型
- (NSString *)dialogSetOperationStringWithType:(DIALOGOPERATIONSETTYPE)type {
    switch (type) {
            
        case DIALOGOPERATIONSETTYPE_Receiver:
            return RCMicLocalizedNamed(@"use_the_receiver");
            break;
        case DIALOGOPERATIONSETTYPE_TurnDebug:
            return RCMicLocalizedNamed(@"turn_on_debug_mode");
            break;
        case DIALOGOPERATIONSETTYPE_AllowJoin:
            return RCMicLocalizedNamed(@"allow_the_audience_to_join");
            break;
        case DIALOGOPERATIONSETTYPE_AllowFreeToTheMic:
            return RCMicLocalizedNamed(@"allow_the_audience_free_access_to_the_mic");
            break;
        default:
            return @"无操作";
            break;
    }
}

@end
