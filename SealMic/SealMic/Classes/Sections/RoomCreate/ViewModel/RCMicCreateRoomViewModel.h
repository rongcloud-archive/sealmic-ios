//
//  RCMicCreateRoomViewModel.h
//  SealMic
//
//  Created by rongyun on 2020/7/5.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCMicAppService.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMicCreateRoomViewModel : NSObject

/// 创建房间
/// @param roomName 房间名字
/// @param successBlock 成功回调
/// @param errorBlock 失败回调，携带错误码
- (void)createRoomWithRoomName:(NSString *)roomName
                       success:(void(^)(RCMicRoomInfo *roomInfo))successBlock
                         error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

@end

NS_ASSUME_NONNULL_END
