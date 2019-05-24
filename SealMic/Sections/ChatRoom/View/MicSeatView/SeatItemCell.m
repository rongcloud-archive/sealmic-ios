//
//  SeatItemCell.m
//  SealMic
//
//  Created by 张改红 on 2019/5/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "SeatItemCell.h"
#import "AnimationView.h"
#import "ClassroomService.h"
#import "RTCService.h"
@interface SeatItemCell()
@property (nonatomic, strong) AnimationView *imageView;
@property (nonatomic, strong) UIImageView *forbidImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@end
@implementation SeatItemCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.forbidImageView];
    }
    return self;
}

#pragma mark - pulic
- (void)setModel:(MicPositionInfo *)info{
    [self stopAnimation];
    self.forbidImageView.hidden = YES;
    self.nameLabel.text = @"";
    NSString *imageName = @"seat_empty";
    if (info.state == MicStateNone) {
        imageName = @"seat_empty";
    }
    if (info.state & MicStateHold && info.userId.length > 0){
        imageName = [RandomUtil randomPortraitStringFor:info.userId];
    }
    if(info.state & MicStateLocked){
        imageName = @"seat_lock";
    }
    if(info.state & MicStateForbidden){
        self.forbidImageView.hidden = NO;
    }
    self.imageView.image = [UIImage imageNamed:imageName];
    if (info.userId.length > 0) {
        if ([info.userId isEqualToString:[ClassroomService sharedService].currentUser.userId]) {
            self.nameLabel.text = MicLocalizedNamed(@"Me");
            self.nameLabel.textColor = HEXCOLOR(0x5e86fa);
        }else{
            self.nameLabel.text = [RandomUtil randomNameFor:info.userId];
            self.nameLabel.textColor = HEXCOLOR(0xffffff);
        }
    }
}

- (void)startHeaderAnimation{
    [self.imageView startVoiceAnimation];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(stopAnimation) userInfo:nil repeats:NO];
    [timer setFireDate:[NSDate distantPast]];
}

#pragma mark - private
- (void)stopAnimation{
    [self.imageView stopVoiceAnimation];
}

#pragma mark - getter or setter
- (AnimationView *)imageView{
    if (!_imageView) {
        _imageView = [[AnimationView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.frame.size.height-20)];
        _imageView.image = [UIImage imageNamed:@""];
    }
    return _imageView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imageView.frame.size.height, self.contentView.bounds.size.width, 20)];
        _nameLabel.font = [UIFont systemFontOfSize:11];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UIImageView *)forbidImageView{
    if (!_forbidImageView) {
        _forbidImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width-16, self.contentView.bounds.size.height-36, 16, 16)];
        _forbidImageView.image = [UIImage imageNamed:@"seat_mute"];
        _forbidImageView.hidden = YES;
    }
    return _forbidImageView;
}
@end
