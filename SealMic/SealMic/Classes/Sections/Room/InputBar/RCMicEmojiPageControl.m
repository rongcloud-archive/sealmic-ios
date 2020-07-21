//
//  RCMicEmojiPageControl.m
//  iOS-IMKit
//
//  Created by Heq.Shinoda on 14-7-12.
//  Copyright (c) 2014年 Heq.Shinoda. All rights reserved.
//

#import "RCMicEmojiPageControl.h"
@implementation RCMicEmojiPageControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        activeImage = [UIImage imageNamed:@"input_emojipage_select"];
        inactiveImage = [UIImage imageNamed:@"input_emojipage_normal"];

        self.hidesForSinglePage = YES;
        self.enabled = NO;
        self.currentPage = 0;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)updateDots {

    for (int i = 0; i < [self.subviews count]; i++) {

        UIImageView *dot = (self.subviews)[i];

        if (i == self.currentPage) {

            if ([dot isKindOfClass:UIImageView.class]) {

                ((UIImageView *)dot).image = activeImage;
            } else {

                dot.backgroundColor = [UIColor colorWithPatternImage:activeImage];
            }
        } else {

            if ([dot isKindOfClass:UIImageView.class]) {

                ((UIImageView *)dot).image = inactiveImage;
            } else {

                dot.backgroundColor = [UIColor colorWithPatternImage:inactiveImage];
            }
        }
    }
}

- (void)setCurrentPage:(NSInteger)page {

    [super setCurrentPage:page];

    [self updateDots];
}

@end
