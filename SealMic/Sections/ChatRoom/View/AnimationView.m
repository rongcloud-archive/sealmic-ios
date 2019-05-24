//
//  AnimationView.m
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "AnimationView.h"
@interface Animation : UIView
@property (nonatomic ,assign) CGFloat CGfrom_x;
@end
@implementation Animation

- (void)drawRect:(CGRect)rect {
    //半径
    CGFloat redbius =_CGfrom_x/2;
    //开始角度
    CGFloat startAngle = 0;
    //中心点
    CGPoint point = CGPointMake(_CGfrom_x/2, _CGfrom_x/2);
    //结束角
    CGFloat endAngle = 2*M_PI;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:redbius startAngle:startAngle endAngle:endAngle clockwise:YES];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path=path.CGPath;   //添加路径
    layer.strokeColor=HEXCOLOR(0x5e82fa).CGColor;
    layer.fillColor=HEXCOLOR(0x5e82fa).CGColor;
    [self.layer addSublayer:layer];
    
}
@end

@interface AnimationView()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSTimer *timer;
@end
@implementation AnimationView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)setImage:(UIImage *)image{
    self.imageView.image = image;
}

- (void)startVoiceAnimation{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(repeatAnimation) userInfo:nil repeats:YES];
    [self.timer setFireDate:[NSDate distantPast]];
    [self repeatAnimation];
}

- (void)stopVoiceAnimation{
    [self.timer setFireDate:[NSDate distantFuture]];
    //取消定时器
    [self.timer invalidate];
    self.timer = nil;
}

- (void)repeatAnimation{
    __block Animation *andome = [[Animation alloc] initWithFrame:self.bounds];
    andome.CGfrom_x = self.bounds.size.width;
    andome.backgroundColor = [UIColor clearColor];
    andome.tag = 10001;
    [self addSubview:andome];
    [self sendSubviewToBack:andome];
    [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        andome.transform = CGAffineTransformScale(andome.transform, 1.5, 1.5);
        andome.alpha = 0;
    } completion:^(BOOL finished) {
        [andome removeFromSuperview];
    }];
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = self.bounds.size.width/2;
    }
    return _imageView;
}
@end
