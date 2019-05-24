//
//  IMService.h
//  SealMeeting
//
//  Created by LiFei on 2019/3/15.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IMReceiveMessageDelegate <NSObject>

- (void)onReceiveMessage:(RCMessage *)message left:(int)nLeft object:(id)object;

@end

@interface IMService : NSObject <RCIMClientReceiveMessageDelegate>

@property (nonatomic, weak) id<IMReceiveMessageDelegate> receiveMessageDelegate;

+ (instancetype)sharedService;

- (void)joinIMChatRoom:(NSString *)roomId success:(void(^)(void))successBlock error:(void(^)(int errCode))errorBlock;
- (void)quitIMChatRoom:(NSString *)roomId
             success:(void (^)(void))successBlock
               error:(void (^)(RCErrorCode status))errorBlock;
- (void)receiveFakeCurrentUserJoinMessage;
@end


NS_ASSUME_NONNULL_END
