//
//  UIView+YHCategory.m
//
//  Created by Yahui on 16/3/4.
//  Copyright © 2016年 Yahui. All rights reserved.
//
#import "UIView+YHCategory.h"

@implementation UIView (YBFCategory)

#pragma mark - origin 坐标点
-(CGPoint)yh_origin
{
    return self.frame.origin;
}

-(void)setYh_origin:(CGPoint)origin
{
    CGRect frame   = self.frame;
    frame.origin   = origin;
    self.frame     = frame;
}

#pragma mark - size 大小
-(CGSize)yh_size
{
    return self.frame.size;
}

-(void)setYh_size:(CGSize)size
{
    CGRect frame   = self.frame;
    frame.size     = size;
    self.frame     = frame;
}

#pragma mark - width 宽度
-(CGFloat)yh_width
{
    return self.yh_size.width;
}

-(void)setYh_width:(CGFloat)width
{
    CGSize size    = self.yh_size;
    size.width     = width;
    self.yh_size      = size;
}

#pragma mark - height 高度
-(CGFloat)yh_height
{
    return self.yh_size.height;
}

-(void)setYh_height:(CGFloat)height
{
    CGSize size    = self.yh_size;
    size.height    = height;
    self.yh_size      = size;
}

#pragma mark - x 横坐标
-(CGFloat)yh_x
{
    return self.yh_origin.x;
}

-(void)setYh_x:(CGFloat)x
{
    CGPoint origin = self.yh_origin;
    origin.x       = x;
    self.yh_origin    = origin;
}

#pragma mark - y 纵坐标
-(CGFloat)yh_y
{
    return self.yh_origin.y;
}

-(void)setYh_y:(CGFloat)y
{
    CGPoint origin = self.yh_origin;
    origin.y       = y;
    self.yh_origin    = origin;
}

- (void)setYh_centerX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)yh_centerX
{
    return self.center.x;
}

- (void)setYh_centerY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)yh_centerY
{
    return self.center.y;
}


@end