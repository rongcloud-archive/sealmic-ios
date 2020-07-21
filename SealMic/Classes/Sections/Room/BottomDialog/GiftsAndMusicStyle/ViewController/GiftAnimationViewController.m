
//
//  GiftAnimationViewController.m
//  SealMic
//
//  Created by rongyun on 2020/6/10.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "GiftAnimationViewController.h"
#import "RCMicMacro.h"
#import "RCMicGiftInfo.h"

@interface GiftAnimationViewController ()
/// 礼物图片视图
@property (nonatomic, strong) UIImageView *giftImageView;
/// 标题
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation GiftAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置类似遮罩的视图背景颜色
    self.view.backgroundColor = [UIColor colorWithRed:3/255.0f green:6/255.0f blue:47/255.0f alpha:0.5];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.giftImageView];
    [self addConstraints];
    //倒计时隐藏视图
    [self countdown];
}

- (void)countdown {
    //倒计时时间 - 2秒
    __block NSInteger timeOut = 2;
    //执行队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //计时器 -》dispatch_source_set_timer自动生成
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (timeOut <= 0) {
            dispatch_source_cancel(timer);
            RCMicMainThread(^{
                [self dismissViewControllerAnimated:true completion:nil];
            });
        }
        else {
            timeOut--;
        }
    });
    dispatch_resume(timer);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)addConstraints {
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(30);
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-60);
    }];
    
    [self.giftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(224.5);
        make.height.mas_equalTo(174.5);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.titleLabel).offset(90);
    }];
    
}

#pragma mark - Getters & Setters
- (UIImageView *)giftImageView {
    if(!_giftImageView) {
        _giftImageView = [[UIImageView alloc] init];
        //默认值
//        _giftImageView.image = [UIImage imageNamed:@"gift_airticket_big"];
        RCMicGiftInfo *giftInfo = [[RCMicGiftInfo alloc] initWithTag:self.tag];
        _giftImageView.image = [UIImage imageNamed:giftInfo.bigImageName];
        _giftImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _giftImageView;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        //默认值
        _titleLabel.textColor = RCMicColor(HEXCOLOR(0xF8E71C, 1.0), HEXCOLOR(0xF8E71C, 1.0));
        _titleLabel.font = RCMicFont(18, @"PingFangSC-Medium");
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        NSString *titleString = [NSString stringWithFormat:@"%@%@",self.gaveName,self.content];
        _titleLabel.text = titleString;
        if (self.gaveName.length > 0){
            NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:titleString];
            NSRange range;
            range = [titleString rangeOfString:self.gaveName];
            if (range.location != NSNotFound) {
                // 需要改变的区间(第一个参数，从第几位起，长度)
                NSRange range1 = NSMakeRange(0, range.length);
                // 改变文字颜色
                [noteStr addAttribute:NSForegroundColorAttributeName value:RCMicColor(HEXCOLOR(0x50E3C2, 1.0), HEXCOLOR(0x50E3C2, 1.0)) range:range1];
                // 为label添加Attributed
                [_titleLabel setAttributedText:noteStr];
            }
        }
    }
    return _titleLabel;
}

@end
