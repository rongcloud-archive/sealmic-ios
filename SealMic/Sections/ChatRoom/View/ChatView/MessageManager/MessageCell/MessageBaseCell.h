//
//  MessageBaseCell.h
//  SealMeeting
//
//  Created by 张改红 on 2019/3/6.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "MessageModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface MessageBaseCell : UITableViewCell

@property(nonatomic, strong) MessageModel *model;

@property(nonatomic, strong) UIView *baseContainerView;

/**
 设置数据模型
 
 @param model 数据模型
 */
- (void)setDataModel:(MessageModel *)model;

/**
 加载子视图
 */
- (void)loadSubView;
@end

NS_ASSUME_NONNULL_END
