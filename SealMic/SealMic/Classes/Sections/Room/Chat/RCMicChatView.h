//
//  RCMicChatView.h
//  SealMic
//
//  Created by lichenfeng on 2020/5/29.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMicRoomViewModel.h"
#import "RCMicTextMessageCell.h"
#import "RCMicGiftMessageCell.h"

NS_ASSUME_NONNULL_BEGIN
@protocol RCMicChatViewDelegate;
/// 聊天视图
@interface RCMicChatView : UIView

@property (nonatomic, weak) id<RCMicChatViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame viewModel:(RCMicRoomViewModel *)viewModel;
/**
 * 批量更新聊天区域 tableView 指定索引的 cell
 * @param type 更新的类型（增加还是删减）
 * @param indexs 需要更新的索引数组
 */
- (void)updateTableViewWithType:(RCMicMessageChangedType)type indexs:(NSArray *)indexs;

/**
 * 滚动到最后
 */
- (void)scrollToBottom;
@end

@protocol RCMicChatViewDelegate <NSObject>

@optional
/**
 * 点击某个 cell 的回调
 * @param chatView 视图本身
 * @param cell 所点击的 cell
 * @param messageViewModel 所点击 cell 对应的 viewModel
 */
- (void)chatView:(RCMicChatView *)chatView didTapMessageCell:(RCMicMessageBaseCell *)cell withViewModel:(RCMicMessageViewModel *)messageViewModel;

/**
 * 长按某个 cell 的回调
 * @param chatView 视图本身
 * @param cell 长按的 cell
 * @param messageViewModel 长按的 cell 对应的 viewModel
 */
- (void)chatView:(RCMicChatView *)chatView didLongPressMessageCell:(RCMicMessageBaseCell *)cell withViewModel:(RCMicMessageViewModel *)messageViewModel;

@end
NS_ASSUME_NONNULL_END
