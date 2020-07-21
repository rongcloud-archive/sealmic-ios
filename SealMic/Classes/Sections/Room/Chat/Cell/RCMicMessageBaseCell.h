//
//  RCMicMessageBaseCell.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMicMessageViewModel.h"
NS_ASSUME_NONNULL_BEGIN

/// 所有消息 cell 顶部留白
#define MessageBaseCellTopExtra 10

@protocol RCMicMessageCellDelegate;
@protocol RCMicMessageCellHeightProvider <NSObject>
/**
 * 根据 viewModel 返回 cell 自身展示所需的高度
 * @param viewModel 展示的 viewModel
 * @return 所需高度
 */
+ (CGFloat)contentHeightWithViewModel:(RCMicMessageViewModel *)viewModel;
@end

/// 所有消息 cell 的基础类，内置所有 cell 需要的统一布局及手势等，子类需要实现 RCMicMessageCellHeightProvider 中的方法
@interface RCMicMessageBaseCell : UITableViewCell<RCMicMessageCellHeightProvider>

@property (nonatomic, strong) RCMicMessageViewModel *viewModel;
@property (nonatomic, weak) id<RCMicMessageCellDelegate> delegate;

/// 添加自定义视图，子类注意调用 super
- (void)initSubviews;

/// 添加约束，子类注意调用 super
- (void)addConstraints;

/**
 * 更新视图 ，子类注意调用 super
 * @param viewModel 模型数据
 */
- (void)updateWithViewModel:(RCMicMessageViewModel *)viewModel;
@end

@protocol RCMicMessageCellDelegate <NSObject>

/**
 * 点击消息 cell 的回调
 * @param cell 点击的 cell
 * @param viewModel cell 对应的 viewModel
 */
- (void)messageCell:(RCMicMessageBaseCell *)cell didTapCellWithViewModel:(RCMicMessageViewModel *)viewModel;

/**
 * 长按 cell 的回调
 * @param cell 长按的 cell
 * @param viewModel cell 对应的 viewModel
 */
- (void)messageCell:(RCMicMessageBaseCell *)cell didLongPressCellWithViewModel:(RCMicMessageViewModel *)viewModel;
@end
NS_ASSUME_NONNULL_END
