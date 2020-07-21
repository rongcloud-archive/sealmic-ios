//
//  YBFPeportViewIndexPath.h
//
//  Created by Yahui on 16/3/4.
//  Copyright © 2016年 Yahui. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YHExcelViewIndexPath : NSObject

+ (instancetype)indexPathForCol:(NSInteger)col inRow:(NSInteger)row inSection:(NSInteger)section;

+ (instancetype)indexPathForCol:(NSInteger)col atIndexPath:(NSIndexPath *)indexPath;


@property (nonatomic, readonly ,assign) NSInteger section;
@property (nonatomic, readonly ,assign) NSInteger row;
@property (nonatomic, readonly ,assign) NSInteger col;

@end
