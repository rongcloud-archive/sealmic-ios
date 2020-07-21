//
//  ChatDataInfoModel.h
//  RongCloud
//
//  Created by Vicky on 2018/2/8.
//  Copyright © 2018年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCMicChatDataInfoModel : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *tunnelName;
@property (nonatomic, strong) NSString *codec;
@property (nonatomic, strong) NSString *frame;
@property (nonatomic, strong) NSString *frameRate;
@property (nonatomic, strong) NSString *codeRate;
@property (nonatomic, strong) NSString *lossRate;


@end
