//
//  RCMicRoomListViewModel.m
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicRoomListViewModel.h"
#import "RCMicAppService.h"
#import "RCMicMacro.h"
#define RoomListFetchCount 50

@implementation RCMicRoomListViewModel

- (void)refreshRoomListWithOperation:(RCMicRoomListRefreshType)operationType success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    NSString * latestRoomId;
    if (operationType == RCMicRoomListRefreshTypeDropDown) {
    } else {
        latestRoomId = [self.roomSource lastObject].roomId;
    }
    [[RCMicAppService sharedService] getRoomListWithLimit:RoomListFetchCount latestRoom:latestRoomId success:^(NSArray<RCMicRoomInfo *> * _Nonnull roomList) {
        RCMicMainThread(^{
            if (operationType == RCMicRoomListRefreshTypeDropDown) {
                [self.roomSource removeAllObjects];
            }
            for (RCMicRoomInfo *roomInfo in roomList) {
                [self.roomSource addObject:roomInfo];
            }
            self.roomListChanged ? self.roomListChanged(RCMicRoomListChangedTypeReloadAll, nil) : nil;
            successBlock ? successBlock() : nil;
        })
    } error:^(RCMicHTTPCode errorCode) {
       errorBlock ? errorBlock(errorCode) : nil;
    }];
}

- (void)joinRoomWithIndexPath:(NSIndexPath *)indexPath success:(void (^)(void))successBlock error:(void (^)(RCMicHTTPCode))errorBlock {
    RCMicRoomInfo *roomInfo = self.roomSource[indexPath.row];
    [[RCMicAppService sharedService] getRoomInfo:roomInfo.roomId success:^(RCMicRoomInfo * _Nonnull roomInfo) {
        RCMicMainThread(^{
            [self.roomSource replaceObjectAtIndex:indexPath.row withObject:roomInfo];
            self.roomListChanged ? self.roomListChanged(RCMicRoomListChangedTypeRefresh, indexPath) : nil;
            if (roomInfo.freeJoinRoom) {
                successBlock ? successBlock() : nil;
            } else {
                errorBlock ? errorBlock(RCMicHTTPCodeErrRoomLocked) : nil;
            }
        })
    } error:^(RCMicHTTPCode errorCode) {
        RCMicMainThread(^{
            if (errorCode == RCMicHTTPCodeErrRoomNotExist) {
                [self.roomSource removeObjectAtIndex:indexPath.row];
                self.roomListChanged ? self.roomListChanged(RCMicRoomListChangedTypeDelete, indexPath) : nil;
            }
            errorBlock ? errorBlock(errorCode) : nil;
        })
    }];
}

#pragma mark - Getters & Setters
- (NSMutableArray *)roomSource {
    if (!_roomSource) {
        _roomSource = [NSMutableArray array];
    }
    return _roomSource;
}
@end
