//
//  RCMicKickOutMessage.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/22.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

/// 用户被踢出房间的通知（端上只负责接收）
@interface RCMicKickOutMessage : RCMessageContent
@property (nonatomic, assign) NSInteger type;//目前只有踢出房间一种类型
@property (nonatomic, copy) NSString *operatorId;//操作者 Id
@property (nonatomic, copy) NSString *operatorName;//操作者名字
@property (nonatomic, copy) NSString *roomId;//房间号
@end

NS_ASSUME_NONNULL_END
