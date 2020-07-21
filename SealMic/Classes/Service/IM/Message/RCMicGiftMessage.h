//
//  RCMicGiftMessage.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/18.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

/// 礼物消息，实际开发时需要根据需求定制，这里只是一个简单示例
@interface RCMicGiftMessage : RCMessageContent

@property (nonatomic, copy) NSString *content;//在聊天窗口显示的内容

@property (nonatomic, copy) NSString *tag;//礼物的 tag

/**
 * 初始化方法
 *
 * @param content 礼物消息显示的提示文本
 */
+ (instancetype)messageWithContent:(NSString *)content tag:(NSString *)tag;
@end

NS_ASSUME_NONNULL_END
