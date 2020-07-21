//
//  RCMicRoomInfo.h
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCMicRoomInfo : NSObject
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, copy) NSString *themeImageURL;
@property (nonatomic, copy) NSString *creatorId;
@property (nonatomic, assign) BOOL freeJoinRoom;//是否允许自由加入房间
@property (nonatomic, assign) BOOL freeJoinMic;//是否允许自由上麦
@property (nonatomic, assign) long long createDt;
@end

NS_ASSUME_NONNULL_END
