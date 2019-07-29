//
//  ChangeBgViewController.m
//  SealMic
//
//  Created by 孙浩 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ChangeBgViewController.h"
#import "BackgroudItem.h"
#import "ClassroomService.h"

#define BgBtnWidth 104
#define BgBtnHeight 99

@interface ChangeBgViewController ()

@property (nonatomic, strong) NSMutableArray *btnArray;
@property (nonatomic, assign) int selectedBgId;

@end

@implementation ChangeBgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = MicLocalizedNamed(@"RoomBackgroud");
    self.view.backgroundColor = [UIColor colorWithHexString:@"F5F5F5" alpha:1];
    self.btnArray = [NSMutableArray arrayWithCapacity:9];
    [self addSubviews];
    [self setupNav];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

#pragma mark - Private Method
- (void)addSubviews {
    CGFloat space = (UIScreenWidth - 3 * BgBtnWidth - 20 * 2) / 2;
    for (int i = 0; i < 9; i ++) {
        BackgroudItem *button = [[BackgroudItem alloc] initWithFrame:CGRectMake(20 + (i % 3 * (BgBtnWidth + space)), 16 + 84 + (i / 3) * (BgBtnHeight + 14), BgBtnWidth, BgBtnHeight)];
        button.tag = i;
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        NSString *bgString = [NSString stringWithFormat:@"bg_icon_%d",i];
        [button setBackgroundImage:[UIImage imageNamed:bgString] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectedBackgroundImage:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [self.btnArray addObject:button];
    }
}

- (void)setupNav {
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting_back_blue"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:MicLocalizedNamed(@"Save") style:(UIBarButtonItemStylePlain) target:self action:@selector(save)];
}

#pragma mark - Target Action
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save {
    [[ClassroomService sharedService] changeRoomBackground:[ClassroomService sharedService].currentRoom.roomId bgId:self.selectedBgId success:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeRoomBg" object:@(self.selectedBgId)];
        [self back];
    } error:^(ErrorCode code) {
        dispatch_main_async_safe(^{
//            [self.view showHUDMessage:MicLocalizedNamed(@"ChangeBackgroundFailure")];
        });
        SealMicLog(@"更换背景失败: %@", @(code));
    }];
}

- (void)selectedBackgroundImage:(BackgroudItem *)button {
    for (BackgroudItem *btn in self.btnArray) {
        btn.isChecked = NO;
    }
    button.isChecked = YES;
    self.selectedBgId = (int)button.tag;
}

@end
