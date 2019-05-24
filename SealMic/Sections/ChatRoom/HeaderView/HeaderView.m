//
//  HeaderView.m
//  SealMic
//
//  Created by 张改红 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "HeaderView.h"
#import "ClassroomService.h"
#import "AnimationView.h"
@interface HeaderView()
@property (nonatomic, strong) AnimationView *headerImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@end
@implementation HeaderView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview{
    [self addSubview:self.headerImageView];
    [self addSubview:self.nameLabel];
    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.width.height.offset(88);
        make.centerX.equalTo(self);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.width.equalTo(self);
        make.height.offset(20);
        make.centerX.equalTo(self);
    }];
    [self setInfo];
}

- (void)setInfo{
    if([[ClassroomService sharedService].currentRoom.creatorId isEqualToString:[ClassroomService sharedService].currentUser.userId]){
        self.nameLabel.text = MicLocalizedNamed(@"Me");
        self.nameLabel.textColor = HEXCOLOR(0x5e86fa);
    }else{
        self.nameLabel.text = [RandomUtil randomNameFor:[ClassroomService sharedService].currentRoom.creatorId];
        self.nameLabel.textColor = HEXCOLOR(0xffffff);
    }
}

- (void)startAnimation{
    [self.headerImageView startVoiceAnimation];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(stopAnimation) userInfo:nil repeats:NO];
    [timer setFireDate:[NSDate distantPast]];
}

- (void)stopAnimation{
    [self.headerImageView stopVoiceAnimation];
}

#pragma mark - getter or setter
- (AnimationView *)headerImageView{
    if (!_headerImageView) {
        _headerImageView = [[AnimationView alloc] init];        
        _headerImageView.image = [RandomUtil randomPortraitFor:[ClassroomService sharedService].currentRoom.creatorId];
    }
    return _headerImageView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = [UIFont systemFontOfSize:12];
        _nameLabel.textColor = [UIColor whiteColor];
    }
    return _nameLabel;
}
@end
