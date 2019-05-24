//
//  LoginHelper.h
//  SealClass
//
//  Created by 张改红 on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClassroomService.h"
#import <RongIMLib/RongIMLib.h>
#import "RTCService.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, LogoutChatRoomType) {
    LogoutChatRoomTypeLeave = 0,
    LogoutChatRoomTypeDetory,
    LogoutChatRoomTypeHasDetory,
};
@protocol LoginHelperDelegate <NSObject>
@optional
- (void)roomDidLogin;
- (void)roomDidOccurError:(NSString *)describe;
- (void)roomDidCreateOrJoin;
@end

//该类内部已经处理了各个模块中加入和离开的接口，加入房间、离开房间请调用该类中的方法
@interface LoginHelper : NSObject
+ (instancetype)sharedInstance;

@property (nonatomic, weak) id<LoginHelperDelegate> delegate;

- (void)login;

- (void)create:(NSString *)roomName type:(int)type;

- (void)join:(NSString *)roomId;

- (void)logout:(LogoutChatRoomType)type
       success:(void (^)(void))success
         error:(void (^)(NSInteger code))error;
@end

NS_ASSUME_NONNULL_END
