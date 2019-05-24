//
//  CreateRoomView.h
//  SealMic
//
//  Created by 孙浩 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CreateRoomViewDelegate <NSObject>

- (void)createRoom:(NSString *)roomName type:(int)roomType;

@end

@interface CreateRoomView : UIView

@property (nonatomic, weak) id<CreateRoomViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
