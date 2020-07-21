//
//  RCMicVersionInfo.h
//  SealMic
//
//  Created by lichenfeng on 2020/7/3.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 新版本相关信息
@interface RCMicVersionInfo : NSObject
@property (nonatomic, copy) NSString *downloadUrl;//下载地址
@property (nonatomic, copy) NSString *version;//版本号
@property (nonatomic, copy) NSString *versionCode;//版本标识（时间戳）
@property (nonatomic, copy) NSString *releaseNote;//版本说明
@property (nonatomic, assign) BOOL forceUpgrade;//是否是强制升级
@end

NS_ASSUME_NONNULL_END
