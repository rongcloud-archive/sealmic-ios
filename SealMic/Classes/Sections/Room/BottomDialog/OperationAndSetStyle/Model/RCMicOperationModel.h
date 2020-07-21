//
//  RCMicOperationModel.h
//  SealMic
//
//  Created by rongyun on 2020/7/16.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCMicEnumDialogDefine.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCMicOperationModel : NSObject

@property (nonatomic, strong) NSString *title;//选项对应的显示文字
@property (nonatomic, assign) DIALOGOPERATIONTYPE type;//选项操作类型
@property (nonatomic, assign) DIALOGOPERATIONSETTYPE setType;//设置选项操作类型

/// 根据操作列表 type 初始化
- (instancetype)initWithType:(DIALOGOPERATIONTYPE)type;
/// 根据设置列表 type 初始化
- (instancetype)initWithSetType:(DIALOGOPERATIONSETTYPE)type;

@end

NS_ASSUME_NONNULL_END
