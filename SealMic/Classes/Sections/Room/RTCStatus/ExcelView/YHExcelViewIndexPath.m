//
//  YBFPeportViewIndexPath.m
//
//  Created by Yahui on 16/3/4.
//  Copyright © 2016年 Yahui. All rights reserved.
//

#import "YHExcelViewIndexPath.h"

@implementation YHExcelViewIndexPath

- (instancetype)initWithCol:(NSInteger)col inRow:(NSInteger)row inSection:(NSInteger)section {
    if (self = [super init]) {
        _col = col;
        _row = row;
        _section = section;
    }
    return self;
}


+ (instancetype)indexPathForCol:(NSInteger)col inRow:(NSInteger)row inSection:(NSInteger)section {
    YHExcelViewIndexPath *indexpath = [[YHExcelViewIndexPath alloc] initWithCol:col inRow:row inSection:section];
    return indexpath;
}

+ (instancetype)indexPathForCol:(NSInteger)col atIndexPath:(NSIndexPath *)indexPath {
    YHExcelViewIndexPath *indexpath = [[YHExcelViewIndexPath alloc] initWithCol:col inRow:indexPath.row inSection:indexPath.section];
    return indexpath;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@-%@-%@",@(self.section),@(self.row),@(self.col)];
}

@end
