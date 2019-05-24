//
//  RandomUtil.m
//  SealMic
//
//  Created by Sin on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RandomUtil.h"

@implementation RandomUtil
+ (NSString *)randomSubject {
    NSArray *subs = [self _getAllRoomSubjects];
    int index = rand() % subs.count;
    return [subs objectAtIndex:index];
}

+ (UIImage *)randomRoomBgImage {
    NSArray *subs = @[@"bg_0",@"bg_1",@"bg_2",@"bg_3",@"bg_4",@"bg_5",@"bg_6",@"bg_7",@"bg_8"];
    int index = rand() % subs.count;
    return [UIImage imageNamed:subs[index]];
}

+ (UIImage *)randomRoomCover:(NSString *)roomId {
    if(roomId.length <= 0) {
        return nil;
    }
    NSArray *subs = [self _getAllRoomCovers];
    int index = [roomId characterAtIndex:roomId.length - 1] % subs.count;
    return [UIImage imageNamed:subs[index]];
}

+ (UIImage *)randomPortraitFor:(NSString *)userId {
    if(userId.length <= 0) {
        return nil;
    }
    NSArray *subs = @[@"header0",@"header1",@"header2",@"header3",@"header4",@"header5",@"header6",@"header7",@"header8"];
    int index = [userId characterAtIndex:userId.length - 1] % subs.count;
    return [UIImage imageNamed:subs[index]];
}

+ (NSString *)randomPortraitStringFor:(NSString *)userId{
    if(userId.length <= 0) {
        return nil;
    }
    NSArray *subs = @[@"header0",@"header1",@"header2",@"header3",@"header4",@"header5",@"header6",@"header7",@"header8"];
    int index = [userId characterAtIndex:userId.length - 1] % subs.count;
    return subs[index];
}

+ (NSString *)randomNameFor:(NSString *)userId {
    if(userId.length <= 0) {
        return nil;
    }
    NSArray *names = [self _getAllUserNames];
    int index = [userId characterAtIndex:userId.length - 1] % names.count;
    return [names objectAtIndex:index];
}

#pragma mark - private
+ (NSArray <NSString *> *)_getAllUserNames {
    static NSArray *data = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"RandomData.plist"];
        NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:bundlePath];
        data = dic[@"UserNames"];
    });
    return data;
}

+ (NSArray <NSString *> *)_getAllRoomSubjects {
    static NSArray *data = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"RandomData.plist"];
        NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:bundlePath];
        data = dic[@"RoomSubjects"];
    });
    return data;
}

+ (NSArray <NSString *> *)_getAllRoomCovers {
    static NSArray *data = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"RandomData.plist"];
        NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:bundlePath];
        data = dic[@"RoomCovers"];
    });
    return data;
}
@end
