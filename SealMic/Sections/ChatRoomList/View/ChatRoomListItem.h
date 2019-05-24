//
//  ChatRoomListItem.h
//  SealMic
//
//  Created by 孙浩 on 2019/5/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomInfo.h"

#define WidthScale (UIScreenWidth / 375)
#define ItemWidth (160 * WidthScale)
#define ItemHeight (182 * WidthScale)

NS_ASSUME_NONNULL_BEGIN

@interface ChatRoomListItem : UICollectionViewCell

- (void)setRoomInfo:(RoomInfo *)roomInfo;

@end

NS_ASSUME_NONNULL_END
