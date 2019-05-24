//
//  SettingView.m
//  SealMic
//
//  Created by 孙浩 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "SettingView.h"
#define SettingTableViewWidht 292

@interface SettingView ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *quitButton;
@property (nonatomic, strong) NSArray *resolutionArray;

@end

@implementation SettingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubviews];
        [self addGesture];
    }
    return self;
}

#pragma mark - Private Method
- (void)addSubviews {
    self.backgroundColor = [UIColor colorWithHexString:@"000000 " alpha:0.7];
    [self addSubview:self.tableView];
    [self addSubview:self.quitButton];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self);
        make.width.offset(SettingTableViewWidht);
    }];
    
    [self.quitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tableView);
        make.width.offset(174);
        make.height.offset(36);
        make.bottom.equalTo(self.tableView).offset(-20);
    }];
}

- (void)addGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.cancelsTouchesInView = NO;
    [tap addTarget:self action:@selector(didTapView)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

- (void)didTapView {
    [self hiden];
}

- (void)quitChatRoom {
    if (self.settingDelegate && [self.settingDelegate respondsToSelector:@selector(settingViewQuitChatRoom)]) {
        [self.settingDelegate settingViewQuitChatRoom];
    }
}

- (UIView *)getHeaderView {
    
    CGFloat topSpace = 20;
    if (@available(iOS 11.0, *)) {
        topSpace = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 45 + topSpace)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"5B6FFA" alpha:1];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, topSpace, SettingTableViewWidht, 45)];
    label.text = MicLocalizedNamed(@"Setting");
    label.textColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
    if (@available(iOS 8.2, *)) {
        label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    } else {
        label.font = [UIFont systemFontOfSize:15];
    }
    label.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:label];
    return headerView;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint tp = [touch locationInView:self.tableView];
    if (CGRectContainsPoint(self.tableView.bounds, tp)) {
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"333333" alpha:1];
    cell.textLabel.text = MicLocalizedNamed(@"RoomBackgroud");
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 38;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.settingDelegate && [self.settingDelegate respondsToSelector:@selector(settingViewChangeBackground)]) {
        [self.settingDelegate settingViewChangeBackground];
    }
}

#pragma mark - Pubic
- (void)showSettingViewInView:(UIView *)view{
    [view addSubview:self];
}

- (void)hiden{
    [self removeFromSuperview];
}

#pragma mark - getter or setter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.scrollEnabled = NO;
        _tableView.tableHeaderView = [self getHeaderView];
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _tableView.insetsContentViewsToSafeArea = NO;
        }
    }
    return _tableView;
}

- (UIButton *)quitButton {
    if (!_quitButton) {
        _quitButton = [[UIButton alloc] init];
        _quitButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_quitButton setTitleColor:[UIColor colorWithHexString:@"7A9AF9" alpha:1] forState:UIControlStateNormal];
        _quitButton.backgroundColor = [UIColor whiteColor];
        [_quitButton setTitle:MicLocalizedNamed(@"QuitChatRoom") forState:UIControlStateNormal];
        [_quitButton setBackgroundImage:[UIImage imageNamed:@"quitChatRoomBtn"] forState:UIControlStateNormal];
        [_quitButton addTarget:self action:@selector(quitChatRoom) forControlEvents:UIControlEventTouchUpInside];
    }
    return _quitButton;
}
@end
