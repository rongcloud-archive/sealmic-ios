//
//  ErrorCode.h
//  SealMeeting
//
//  Created by Sin on 2019/3/13.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#ifndef ErrorCode_h
#define ErrorCode_h

typedef NS_ENUM(NSInteger, ErrorCode) {
    ErrorCodeOther = 255,
    ErrorCodeSuccess = 0,
    ErrorCodeParameterError = 1,
    ErrorCodeInvalidAuth = 2,
    ErrorCodeAccessDenied = 3,
    ErrorCodeBadRequest = 4,
    ErrorCodeIMTokenError = 10,
    ErrorCodeCreateRoomError = 11,
    ErrorCodeSignallingError = 12,
    ErrorCodeDestroyRoomError = 14,
    ErrorCodeRoomNotExist = 20,
    ErrorCodeUserNotExistInRoom = 21,
    ErrorCodeLeaveRoomError = 22,
    ErrorCodeSpeakerNotExistInRoom = 23,
    ErrorCodeMicPositionError = 24,
    ErrorCodeMicPositionLocked = 25,
    ErrorCodeRoomOverMaxCount = 26,
    ErrorCodeMemberOverMaxCount = 27,
    ErrorCodeHTTPFailure = 99
};

#endif /* ErrorCode_h */
