//
//  RCMicParticipantsArea.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/1.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicParticipantsArea.h"
#import "RCMicParticipantItem.h"
#import "RCMicMacro.h"

#define ParticipantCell @"ParticipantCell"
#define SectionHeaderView @"SectionHeaderView"
#define SectionHeaderHeight 143
#define ParticipantCellWidth 76
#define ParticipantCellHeight 93
#define SectionInsetLeft (RCMicScreenWidthEqualTo320 ? 4 : 13)

@interface RCMicParticipantsArea()<UICollectionViewDataSource, UISearchControllerDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) RCMicRoomViewModel *viewModel;
@property (nonatomic, strong) UICollectionView *participantsView;
@property (nonatomic, strong) RCMicParticipantItem *headerItem;
@end
@implementation RCMicParticipantsArea

- (instancetype)initWithFrame:(CGRect)frame viewModel:(RCMicRoomViewModel *)viewModel {
    self = [super initWithFrame:frame];
    if (self) {
        _viewModel = viewModel;
        [self initSubviews];
        [self addConstraints];
    }
    return self;
}

- (void)initSubviews {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _participantsView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _participantsView.backgroundColor = [UIColor clearColor];
    _participantsView.delegate = self;
    _participantsView.dataSource = self;
    [_participantsView registerClass:[RCMicParticipantCell class] forCellWithReuseIdentifier:ParticipantCell];
    [_participantsView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SectionHeaderView];
    [self addSubview:_participantsView];
}

- (void)addConstraints {
    [_participantsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark - Action
- (void)headerTapAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(participantsArea:didSelectItemWithViewModel:)]) {
        NSString *key = [RCMicParticipantEntryKey stringByAppendingFormat:@"%d",0];
        [self.delegate participantsArea:self didSelectItemWithViewModel:self.viewModel.participantDataSource[key]];
    }
}

#pragma mark - Public method
- (void)reloadData {
    [self.participantsView reloadData];
}

- (void)updateCollectionViewWithKeys:(NSArray *)keys {
    RCMicMainThread(^{
        for (NSString *key in keys) {
            NSInteger position = [self.viewModel transformEntryKeyToPosition:key];
            //头部单独更新，cell 中的批量更新
            if (position == 0) {
                [self.headerItem updateWithViewModel:self.viewModel.participantDataSource[key]];
            } else {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(position - 1) inSection:0];
                RCMicParticipantCell *cell = (RCMicParticipantCell *)[self.participantsView cellForItemAtIndexPath:indexPath];
                [cell updateWithViewModel:self.viewModel.participantDataSource[key]];
            }
        }
    })
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //减 1 因为第一个是主持人
    return self.viewModel.participantDataSource.allKeys.count - 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCMicParticipantCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ParticipantCell forIndexPath:indexPath];
    NSString *key = [RCMicParticipantEntryKey stringByAppendingFormat:@"%ld",(long)indexPath.row + 1];

    [cell updateWithViewModel:self.viewModel.participantDataSource[key]];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SectionHeaderView forIndexPath:indexPath];
    NSString *key = [RCMicParticipantEntryKey stringByAppendingFormat:@"%ld",(long)indexPath.section];
    [self.headerItem updateWithViewModel:self.viewModel.participantDataSource[key]];
    [headerView addSubview:self.headerItem];
    [self.headerItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerView.mas_centerX);
        make.top.equalTo(headerView).with.offset(7);
        make.size.mas_equalTo(CGSizeMake(89, 109));
    }];
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.delegate && [self.delegate respondsToSelector:@selector(participantsArea:didSelectItemWithViewModel:)]) {
        NSString *key = [RCMicParticipantEntryKey stringByAppendingFormat:@"%ld",(long)indexPath.row + 1];
        [self.delegate participantsArea:self didSelectItemWithViewModel:self.viewModel.participantDataSource[key]];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(ParticipantCellWidth, ParticipantCellHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, SectionInsetLeft, 0, SectionInsetLeft);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat space = (self.frame.size.width - (ParticipantCellWidth * 4) - (SectionInsetLeft * 2))/3;
    return floor(space);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.frame.size.width, SectionHeaderHeight);
}

#pragma mark - Getters & Setters
- (RCMicParticipantItem *)headerItem {
    if (!_headerItem) {
        _headerItem = [[RCMicParticipantItem alloc] initWithFrame:CGRectZero isHost:YES];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapAction)];
        [_headerItem addGestureRecognizer:tapGesture];
    }
    return _headerItem;
}
@end
