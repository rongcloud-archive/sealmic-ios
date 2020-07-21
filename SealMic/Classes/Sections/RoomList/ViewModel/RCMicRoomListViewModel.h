//
//  RCMicRoomListViewModel.h
//  SealMic
//
//  Created by lichenfeng on 2020/5/25.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCMicAppService.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RCMicRoomListRefreshType) {
    RCMicRoomListRefreshTypeDropDown = 0,//下拉刷新
    RCMicRoomListRefreshTypePull,//上拉加载
};

typedef NS_ENUM(NSInteger, RCMicRoomListChangedType) {
    RCMicRoomListChangedTypeRefresh = 0,//更新
    RCMicRoomListChangedTypeDelete,//删除
    RCMicRoomListChangedTypeReloadAll,//全量更新
};

@interface RCMicRoomListViewModel : NSObject

/// 房间列表数据源
@property (nonatomic, strong) NSMutableArray<RCMicRoomInfo *> *roomSource;

/// 房间数据源变更回调，携带变更的类型及索引（全量更新时索引不存在）
@property (nonatomic, copy) void(^roomListChanged)(RCMicRoomListChangedType type,  NSIndexPath * _Nullable indexPath);

/**
 * 刷新房间信息
 * @param operationType 操作类型，下拉刷新还是上拉加载更多
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)refreshRoomListWithOperation:(RCMicRoomListRefreshType)operationType
                             success:(void(^)(void))successBlock
                               error:(void(^)(RCMicHTTPCode errorCode))errorBlock;

/**
 * 加入房间
 * @param indexPath 对应房间的索引
 * @param successBlock 成功回调
 * @param errorBlock 失败回调，携带相关错误码
 */
- (void)joinRoomWithIndexPath:(NSIndexPath *)indexPath
                      success:(void(^)(void))successBlock
                        error:(void(^)(RCMicHTTPCode errorCode))errorBlock;
@end

NS_ASSUME_NONNULL_END
