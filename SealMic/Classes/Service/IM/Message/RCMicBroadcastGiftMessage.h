//
//  RCMicBroadcastGiftMessage.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/22.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCMicBroadcastGiftMessage : RCMessageContent
@property (nonatomic, copy) NSString *roomName;//礼物产生的房间名字
@property (nonatomic, copy) NSString *tag;//礼物的 tag

+ (instancetype)messageWithRoomName:(NSString *)name tag:(nonnull NSString *)tag;
@end

NS_ASSUME_NONNULL_END
