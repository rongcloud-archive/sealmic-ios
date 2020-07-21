//
//  RCMicParticipantsArea.h
//  SealMic
//
//  Created by lichenfeng on 2020/6/1.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMicRoomViewModel.h"
#import "RCMicParticipantCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RCMicParticipantsAreaDelegate;
@interface RCMicParticipantsArea : UIView

@property (nonatomic, weak) id<RCMicParticipantsAreaDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame viewModel:(RCMicRoomViewModel *)viewModel;

- (void)reloadData;
- (void)updateCollectionViewWithKeys:(NSArray *)keys;
@end

@protocol RCMicParticipantsAreaDelegate <NSObject>
@optional
/**
 * 点击某个参会者（麦位）的回调
 * @param participantsArea 视图本身
 * @param participantViewModel 麦位上对应的 viewModel
 */
- (void)participantsArea:(RCMicParticipantsArea *)participantsArea didSelectItemWithViewModel:(RCMicParticipantViewModel *)participantViewModel;
@end
NS_ASSUME_NONNULL_END
