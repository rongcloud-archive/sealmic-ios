//
//  RCMicBottomDialogHorizontalViewController.m
//  SealMic
//
//  Created by rongyun on 2020/6/1.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicBottomDialogHorizontalViewController.h"
#import "RCMicOperationAudioCollectionCell.h"
#import "RCMicOperationGiftCollectionCell.h"
#import "RCMicMacro.h"
#import "GiftAnimationViewController.h"
#import "RCMicRTCService.h"
#import "RCMicActiveWheel.h"
#import <SDWebImage/SDWebImage.h>
#define RCMicOperationAudioCollectionCELL @"RCMicOperationAudioCollectionCELL"
#define RCMicOperationGiftCollectionCELL @"RCMicOperationGiftCollectionCELL"

@interface RCMicBottomDialogHorizontalViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
/// 弹框背景图片视图
@property (nonatomic, strong) UIImageView *bgImageView;
/// 头像
@property (nonatomic, strong) UIImageView *headImageView;
/// 标题
@property (nonatomic, strong) UILabel *titleLabel;
/// 副标题
@property (nonatomic, strong) UILabel *subtitleLabel;
/// 选项卡操作横向列表
@property (nonatomic, strong) UICollectionView *operationCollectionView;
/// 选项卡选项配置
@property (nonatomic, strong) NSMutableArray *operationMutableArray;
/// 赠送按钮
@property (nonatomic, strong) UIButton *giveGiftButton;
/// 点击消失弹框按钮
@property (nonatomic, strong) UIButton *dismissBtn;
//  当前礼物选择项
@property (nonatomic, strong) NSIndexPath *currentBgGiftIndexPath;
@end

@implementation RCMicBottomDialogHorizontalViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置类似遮罩的视图背景颜色
    self.view.backgroundColor = [UIColor colorWithRed:3/255.0f green:6/255.0f blue:47/255.0f alpha:0.5];
    //弹框背景图片视图
    [self.view addSubview:self.bgImageView];
    //点击消失弹框
    [self.view addSubview:self.dismissBtn];
    //头像
    [self.view addSubview:self.headImageView];
    //title标题
    [self.view addSubview:self.titleLabel];
    self.titleLabel.text = self.dialogTitle;
    //副标题
    [self.view addSubview:self.subtitleLabel];
    //选项卡列表
    [self.view addSubview:self.operationCollectionView];
    //赠送按钮
    [self.view addSubview:self.giveGiftButton];
    //配置选项数据源
    [self setupOperationDataSource];
    //配置布局约束
    [self addConstraints];
    //配置设置样式
    [self setupStyle];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Private method

- (void)setupOperationDataSource {
    //设置选项
    if(!self.isGiftStyle){
        self.giveGiftButton.alpha = 0;
        if ([self.dialogTitle isEqualToString:RCMicLocalizedNamed(@"change_sound")]){
            self.operationMutableArray = [[NSMutableArray alloc] initWithObjects:
                                          @{@"title":RCMicLocalizedNamed(@"original_sound"), @"soundName":@""},
                                          @{@"title":RCMicLocalizedNamed(@"female_voice"), @"soundName":@""},
                                          @{@"title":RCMicLocalizedNamed(@"male_voice"), @"soundName":@""},
                                          @{@"title":RCMicLocalizedNamed(@"neutral"), @"soundName":@""},
                                          @{@"title":RCMicLocalizedNamed(@"robot"), @"soundName":@""},
                                          @{@"title":RCMicLocalizedNamed(@"childlike_voice"), @"soundName":@""},nil];
            
        }else {
            self.operationMutableArray = [[NSMutableArray alloc] initWithObjects:
                                          @{@"title":RCMicLocalizedNamed(@"overdub_none"), @"soundName":@""},
                                          @{@"title":RCMicLocalizedNamed(@"overdub_railway_station"),@"soundName":@"metro_entrance"},
                                          //                                          @{@"title":RCMicLocalizedNamed(@"overdub_sound_card"), @"soundName":@""},
                                          //                                          @{@"title":RCMicLocalizedNamed(@"overdub_market"), @"soundName":@""},
                                          @{@"title":RCMicLocalizedNamed(@"overdub_nature"), @"soundName":@"rain_thunder1"},
                                          @{@"title":RCMicLocalizedNamed(@"overdub_airport"), @"soundName":@"airport_gate1"},nil];
        }
        //伴音选项默认为 无 选项
        if (!self.currentBgSoundIndexPath){
            self.currentBgSoundIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        }
    }else{
        //礼物
        self.operationMutableArray = [[NSMutableArray alloc] init];
        for (int i = 0 ;i < 8;i ++){
            RCMicGiftInfo *giftInfo = [[RCMicGiftInfo alloc] initWithType:i];
            [self.operationMutableArray addObject:giftInfo];
        }
    }
}

- (void)setupStyle {
    // 是否显示有头像的样式(根据显示业务做调整)
    if (self.isHead){
        self.titleLabel.text = self.userInfo.name;
        self.subtitleLabel.text = RCMicLocalizedNamed(@"m_a_view");
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"login_portrait_default"]];
        self.bgImageView.layer.cornerRadius = 0;
        if (self.isGiftStyle){
            [self.giveGiftButton mas_updateConstraints:^(MASConstraintMaker *make) {
                CGFloat iphoneXHeight = [RCMicUtil bottomSafeAreaHeight];
                make.bottom.equalTo(self.bgImageView.mas_bottom).offset(-15 - iphoneXHeight);
            }];
        }
    }else {
        self.bgImageView.image = [UIImage imageNamed:@"alert_bottom_bg"];
        self.bgImageView.layer.cornerRadius = 12;
        //隐藏头像图片视图
        self.headImageView.alpha = 0;
        //隐藏副标题
        self.subtitleLabel.alpha = 0;
        //更新标题的y坐标位置
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headImageView.mas_bottom).offset(-45);
        }];
        CGFloat iphoneXHeight = [RCMicUtil bottomSafeAreaHeight];
        if (self.isGiftStyle){
            //更新tableview的y坐标位置
            [self.operationCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.subtitleLabel).offset(15);
            }];
            [self.bgImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(382 + iphoneXHeight);
                //底部超出12圆角位置，只显示左上右上圆角
                make.bottom.mas_equalTo(12);
            }];
            [self.giveGiftButton mas_updateConstraints:^(MASConstraintMaker *make) {
                CGFloat iphoneXHeight = [RCMicUtil bottomSafeAreaHeight];
                make.bottom.equalTo(self.bgImageView.mas_bottom).offset(-30 - iphoneXHeight);
            }];
        }else {
            //更新tableview的y坐标位置
            [self.operationCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.subtitleLabel).offset(5);
            }];
            [self.bgImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(200 + iphoneXHeight);
                //底部超出12圆角位置，只显示左上右上圆角
                make.bottom.mas_equalTo(12);
            }];
        }
    }
    //更新点击消失弹框按钮覆盖区域
    [self.dismissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.bottom.equalTo(self.bgImageView.mas_top);
    }];
}

- (void)addConstraints {
    CGFloat iphoneXHeight = [RCMicUtil bottomSafeAreaHeight];
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        if (self.isGiftStyle) {
            make.height.mas_equalTo(434 + iphoneXHeight);
        }else {
            make.height.mas_equalTo(188 + iphoneXHeight);
        }
    }];
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgImageView);
        make.top.equalTo(self.bgImageView).offset(9);
        make.width.height.mas_equalTo(56);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgImageView);
        make.top.equalTo(self.headImageView.mas_bottom).offset(15);
    }];
    
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgImageView);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
    }];
    
    [self.operationCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subtitleLabel.mas_bottom).offset(10);
        if (self.isGiftStyle) {
            make.height.mas_equalTo(230);
            make.left.right.mas_equalTo(0);
        }else {
            make.height.mas_equalTo(106);
            make.left.mas_equalTo(26);
            make.right.mas_equalTo(-26);
        }
    }];
    
    [self.giveGiftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat iphoneXHeight = [RCMicUtil bottomSafeAreaHeight];
        //        make.top.equalTo(self.operationCollectionView.mas_bottom).offset(30);
        make.bottom.equalTo(self.bgImageView.mas_bottom).offset(-30 - iphoneXHeight);
        make.centerX.equalTo(self.bgImageView);
        make.height.mas_equalTo(34);
        make.width.mas_equalTo(90);
    }];
    
}

#pragma mark - Action
- (void)dismissAction {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)giveAction {
    if (self.currentBgGiftIndexPath){
        RCMicGiftInfo *giftInfo = self.operationMutableArray[self.currentBgGiftIndexPath.row];
        [self dismissViewControllerAnimated:false completion:nil];
        if (self.seletedGiftItemBlock) {//先判断
            self.seletedGiftItemBlock(giftInfo);
        }
    }else {
        RCMicMainThread(^{
            [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"please_choose_gift")];
        });
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.operationMutableArray.count;
}

//选中时的操作
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isGiftStyle){
        RCMicOperationGiftCollectionCell *cell = (RCMicOperationGiftCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
        //记录选择的礼物索引
        self.currentBgGiftIndexPath = indexPath;
        // 选中之后的cell变为选中样式
        [self updateGiftCellStatus:cell selected:YES];
    }else {
        //选择的伴音是无的话 停止旧的伴音
        if (indexPath.item == 0){
            [[RCMicRTCService sharedService] stopMixingMusic];
        }else {
            
            RCMicOperationAudioCollectionCell *cell = (RCMicOperationAudioCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
            // 选中之后的cell变为选中样式
            [self updateAudioCellStatus:cell selected:YES];
            // 先停止旧的混音
            [[RCMicRTCService sharedService] stopMixingMusic];
            // 根据真实素材和业务做调整
            
            NSDictionary *dictionary = self.operationMutableArray[indexPath.row];
            NSString *soundNameString = dictionary[@"soundName"];
            if (soundNameString.length >0){
                NSURL *url = [[NSBundle mainBundle] URLForResource:soundNameString withExtension:@"mp3"];
                [[RCMicRTCService sharedService] mixingMusicWithLocalUrl:url];
            }else {
                [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:RCMicLocalizedNamed(@"lack_of_material")];
            }
        }
        if (self.seletedItemBlock){
            self.seletedItemBlock(indexPath);
        }
        [self dismissViewControllerAnimated:false completion:nil];
    }
}

////取消选中操作
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isGiftStyle){
        RCMicOperationGiftCollectionCell *cell = (RCMicOperationGiftCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
        // 选中之后的cell变为选中样式
        [self updateGiftCellStatus:cell selected:NO];
        return;
    }
    RCMicOperationAudioCollectionCell *cell = (RCMicOperationAudioCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self updateAudioCellStatus:cell selected:NO];
}

// 改变音效cell的背景颜色
-(void)updateAudioCellStatus:(RCMicOperationAudioCollectionCell *)cell selected:(BOOL)selected
{
    if (selected){
        [cell.operationTitleButton setBackgroundImage:[UIImage imageNamed:@"selected_music_btn_bg"] forState:UIControlStateNormal];
        cell.operationTitleButton.layer.borderWidth = 0;
    }else {
        [cell.operationTitleButton setBackgroundImage:nil forState:UIControlStateNormal];
        cell.operationTitleButton.layer.borderWidth = 0.5;
    }
}
// 改变礼物cell的背景样式
-(void)updateGiftCellStatus:(RCMicOperationGiftCollectionCell *)cell selected:(BOOL)selected
{
    cell.seletedBgImageView.alpha = selected ? 1 : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isGiftStyle) {
        RCMicOperationGiftCollectionCell *giftCell = [collectionView dequeueReusableCellWithReuseIdentifier:RCMicOperationGiftCollectionCELL forIndexPath:indexPath];
        RCMicGiftInfo *giftInfo = self.operationMutableArray[indexPath.row];
        [giftCell setDataGiftInfoModel:giftInfo];
        return giftCell;
    }else {
        RCMicOperationAudioCollectionCell *roomCell = [collectionView dequeueReusableCellWithReuseIdentifier:RCMicOperationAudioCollectionCELL forIndexPath:indexPath];
        NSDictionary *dictionary = self.operationMutableArray[indexPath.row];
        [roomCell setDataDictionary:dictionary];
        if (self.currentBgSoundIndexPath == indexPath){
            roomCell.backgroundColor = [UIColor clearColor];
            //选中之后的cell变颜色
            [self updateAudioCellStatus:roomCell selected:YES];
        }
        //      roomCell.backgroundColor = [UIColor redColor];
        return roomCell;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isGiftStyle) {
        //横向 上下默认有 5 的间距
        return CGSizeMake(collectionView.frame.size.width / 4, 110);
    }else {
        return CGSizeMake(collectionView.frame.size.width / 4, 43);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat spacing = self.isGiftStyle ? 0 : 15;
    return spacing;
}

#pragma mark - Getters & Setters
- (UIImageView *)bgImageView {
    if(!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        //默认值
        _bgImageView.image = [UIImage imageNamed:@"alert_bottom_head_bg"];
        _bgImageView.clipsToBounds = true;
    }
    return _bgImageView;
}

- (UIButton *)dismissBtn {
    if (!_dismissBtn) {
        _dismissBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_dismissBtn addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissBtn;
}

- (UIImageView *)headImageView {
    if(!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        //默认值
        _headImageView.image = [UIImage imageNamed:@"room_portrait_temp"];
        _headImageView.clipsToBounds = true;
        _headImageView.layer.cornerRadius = 56/2;
    }
    return _headImageView;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        //默认值
        _titleLabel.text = @"";
        _titleLabel.textColor = RCMicColor([UIColor whiteColor], [UIColor whiteColor]);
        _titleLabel.font = RCMicFont(17, @"PingFangSC-Medium");
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if(!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        //默认值
        _subtitleLabel.text = @"";
        _subtitleLabel.font = RCMicFont(13, nil);
        _subtitleLabel.textColor = RCMicColor(HEXCOLOR(0xDFDFDF, 1.0), HEXCOLOR(0xDFDFDF, 1.0));
    }
    return _subtitleLabel;
}

- (UIButton *)giveGiftButton {
    if(!_giveGiftButton){
        _giveGiftButton = [[UIButton alloc] init];
        [_giveGiftButton setTitle:RCMicLocalizedNamed(@"room_gift_giving_button") forState:UIControlStateNormal];
        [_giveGiftButton setBackgroundImage:[UIImage imageNamed:@"give_btn_bg"] forState:UIControlStateNormal];
        [_giveGiftButton addTarget:self action:@selector(giveAction) forControlEvents:UIControlEventTouchUpInside];
        _giveGiftButton.titleLabel.font = RCMicFont(14, nil);
    }
    return _giveGiftButton;
}

- (UICollectionView *)operationCollectionView {
    if (!_operationCollectionView) {
        
        if (!_operationCollectionView) {
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
            // 当前是礼物样式的话设置UICollectionView为横向滚动
            flowLayout.scrollDirection  = self.isGiftStyle ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical;
            _operationCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
            //                                    _operationCollectionView.backgroundColor = [UIColor redColor];
            _operationCollectionView.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
            _operationCollectionView.pagingEnabled = true;
            _operationCollectionView.showsHorizontalScrollIndicator = false;
            if (self.isGiftStyle){
                [_operationCollectionView registerClass:[RCMicOperationGiftCollectionCell class] forCellWithReuseIdentifier:RCMicOperationGiftCollectionCELL];
            }else {
                [_operationCollectionView registerClass:[RCMicOperationAudioCollectionCell class] forCellWithReuseIdentifier:RCMicOperationAudioCollectionCELL];
            }
            if (@available(iOS 11.0, *)) {
                _operationCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            } else {
                self.automaticallyAdjustsScrollViewInsets = NO;
            }
            _operationCollectionView.dataSource = self;
            _operationCollectionView.delegate = self;
        }
        return _operationCollectionView;
    }
    return _operationCollectionView;
}

@end
