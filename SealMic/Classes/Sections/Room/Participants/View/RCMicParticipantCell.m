//
//  RCMicParticipantCell.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicParticipantCell.h"
#import "RCMicMacro.h"
@interface RCMicParticipantCell()
@property (nonatomic, strong) RCMicParticipantItem *participantItem;
@end
@implementation RCMicParticipantCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
        [self addContraints];
    }
    return self;
}

- (void)initSubviews {
    _participantItem = [[RCMicParticipantItem alloc] initWithFrame:CGRectZero isHost:NO];
    [self.contentView addSubview:_participantItem];
}

- (void)addContraints {
    [_participantItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)updateWithViewModel:(RCMicParticipantViewModel *)viewModel {
    [self.participantItem updateWithViewModel:viewModel];
}

- (void)performAnimation {
    [self.participantItem performAnimation];
}

@end
