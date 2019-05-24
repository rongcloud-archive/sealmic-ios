//
//  MicPositionInfo.h
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MicPositionInfo : NSObject
//当前麦位上的人员 id
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, assign) MicState state;
@property (nonatomic, assign) int position;
+ (instancetype)micPositionInfoFromJson:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
