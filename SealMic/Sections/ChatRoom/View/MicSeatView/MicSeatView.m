//
//  MicSeatView.m
//  SealMic
//
//  Created by 张改红 on 2019/5/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "MicSeatView.h"
#import "ClassroomService.h"
#import "RTCService.h"

#define SeatCount 8
#define SeatItemWidth 65
#define OwnerActionSheetTag 100
#define OtherActionSheetTag 101
@interface MicSeatView()<UICollectionViewDelegate, UICollectionViewDataSource, UIActionSheetDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataSources;
@end
@implementation MicSeatView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        [self.collectionView registerClass:[SeatItemCell class] forCellWithReuseIdentifier:SeatItemCellIdentifier];
        self.dataSources = [ClassroomService sharedService].currentRoom.micPositions;
    }
    return self;
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
//每一分区的单元个数

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SeatItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SeatItemCellIdentifier forIndexPath:indexPath];
    MicPositionInfo *position = [[MicPositionInfo alloc] init];
    if (self.dataSources.count > indexPath.row) {
        position = self.dataSources[indexPath.row];
    }
    [cell setModel:position];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MicPositionInfo *position = [[MicPositionInfo alloc] init];
    if (self.dataSources.count > indexPath.row) {
        position = self.dataSources[indexPath.row];
    }
    position.position = (int)indexPath.row;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPostion:)]) {
        [self.delegate didSelectPostion:position];
    }
    
}

#pragma mark - public API
- (void)showInView:(UIView *)view{
    [view addSubview:self];
}

- (void)hidden{
    [self removeFromSuperview];
}

- (void)reloadSeatView{
    self.dataSources = [ClassroomService sharedService].currentRoom.micPositions;
    [self.collectionView reloadData];
}

- (void)startAnimationInIndex:(int)index{
    SeatItemCell *cell = (SeatItemCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if (cell) {
        [cell startHeaderAnimation];
    }
}

#pragma mark - getter or setter
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        CGFloat space = (UIScreenWidth - SeatItemWidth*4)/5;
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = space;
        layout.sectionInset = UIEdgeInsetsMake(30.0, space, 30.0, space);
        layout.itemSize = CGSizeMake(SeatItemWidth, SeatItemWidth+20);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width,self.frame.size.height) collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.scrollEnabled = NO;
        _collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    }
    return _collectionView;
}
@end
