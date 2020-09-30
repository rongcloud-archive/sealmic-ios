//
//  RCMicUtil.m
//  SealMic
//
//  Created by lichenfeng on 2020/5/21.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicUtil.h"
#import "RCMicMacro.h"
#import "RCMicHTTPUtility.h"


#define LOG_EXPIRE_TIME -7 * 24 * 60 * 60

@implementation RCMicUtil
+ (UIColor *)colorWithLight:(UIColor *)lightColor dark:(UIColor *)darkColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                return lightColor;
            } else {
                return darkColor;
            }
        }];
    } else {
        return lightColor;
    }
}

+ (UIFont *)fontWithSize:(CGFloat)size name:(NSString *)name {
    if (name.length > 0) {
        return [UIFont fontWithName:name size:size];
    } else {
        return [UIFont systemFontOfSize:size];
    }
}

+ (CGFloat)statusBarHeight {
    CGFloat height;
    if (@available(iOS 13.0, *)) {
        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
        height = statusBarManager.statusBarFrame.size.height;
    } else {
        height = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    return height;
}

+ (CGFloat)topSafeAreaHeight {
    CGFloat height;
    if (@available(iOS 11.0, *)) {
        height = [[[UIApplication sharedApplication] delegate].window safeAreaInsets].top > 20 ? 88 : 64;
    } else {
        height = 64;
    }
    return height;
}

+ (CGFloat)bottomSafeAreaHeight {
    CGFloat height;
    if (@available(iOS 11.0, *)) {
        height = [[[UIApplication sharedApplication] delegate].window safeAreaInsets].bottom;
    } else {
        height = 0;
    }
    return height;
}

+ (NSDictionary *)randomResource {
    NSString *resourcePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"RandomResource.plist"];
    return [[NSDictionary alloc] initWithContentsOfFile:resourcePath];
}

+ (NSString *)randomName {
     NSDictionary *resourceDict = [RCMicUtil randomResource];
     NSArray *familyArray = resourceDict[@"Family"];
     NSArray *nameArray = resourceDict[@"Name"];
     NSInteger familyIndex = arc4random()%familyArray.count;
     NSInteger nameIndex = arc4random()%nameArray.count;
     return [NSString stringWithFormat:@"%@%@",familyArray[familyIndex], nameArray[nameIndex]];
}

+ (NSString *)randomPortrait {
    NSDictionary *resourceDict = [RCMicUtil randomResource];
    NSArray *portraitArray = resourceDict[@"Portrait"];
    NSInteger portraitIndex = arc4random()%portraitArray.count;
    return [[self formatServerAddress] stringByAppendingString:portraitArray[portraitIndex]];
}

+ (NSString *)randomRoomTheme {
    NSDictionary *resourceDict = [RCMicUtil randomResource];
    NSArray *themeArray = resourceDict[@"RoomTheme"];
    NSInteger themeIndex = arc4random()%themeArray.count;
    return [[self formatServerAddress] stringByAppendingString:themeArray[themeIndex]];
}

+ (NSString *)formatServerAddress {
    NSString *address = [RCMicHTTPUtility demoServer];
    
    if (address.length > 0) {
        if ([address hasSuffix:@"api/"]) {
            return [address substringToIndex:address.length - 4];
        } else if ([address hasSuffix:@"api"]) {
            return [address substringToIndex:address.length - 3];
        } else if ([address hasSuffix:@"/"]) {
            return address;
        } else {
            return [address stringByAppendingString:@"/"];
        }
    } else {
        return nil;
    }
}

+ (NSData *)secureArchivedDataWithObject:(id<NSSecureCoding>)object {
    NSError *error;
    NSData *resultData;
    if (@available(iOS 11.0, *)) {
        resultData = [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:YES error:&error];
    } else {
        resultData = [NSKeyedArchiver archivedDataWithRootObject:object];
    }
    if (error) {
        RCMicLog(@"archive data complete with error:%@",error);
    }
    
    return resultData;
}

+ (id<NSSecureCoding>)secureUnarchiveObjectOfClass:(Class)cls fromData:(NSData *)data {
    NSError *error;
    id<NSSecureCoding> object;
    if (@available(iOS 11.0, *)) {
        object = [NSKeyedUnarchiver unarchivedObjectOfClass:cls fromData:data error:&error];
    } else {
        object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    if (error) {
        RCMicLog(@"unarchive data complete with error:%@",error);
    }
    return object;
}

+ (NSDictionary *)dictionaryWithData:(NSData *)data {
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        NSLog(@"%@",error);
        RCMicLog(@"transform data to dictionary complete with error:%@",error);
    }
    return dict;
}

+ (NSData *)dataWithDictionary:(NSDictionary *)dict {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    if (error) {
        NSLog(@"%@",error);
        RCMicLog(@"transform dictionary to data complete with error:%@",error);
    }
    return data;
}

+ (void)redirectLogToLocal {
    NSLog(@"Log重定向到本地，如果您需要控制台Log，注释掉重定向逻辑即可。");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    [self removeExpireLogFiles:documentDirectory];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"MMddHHmmss"];
    NSString *formattedDate = [dateformatter stringFromDate:currentDate];
    
    NSString *fileName = [NSString stringWithFormat:@"SealMicLog%@.log", formattedDate];
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

+ (void)removeExpireLogFiles:(NSString *)logPath {
    //删除超过时间的log文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:logPath error:nil]];
    NSDate *currentDate = [NSDate date];
    NSDate *expireDate = [NSDate dateWithTimeIntervalSinceNow:LOG_EXPIRE_TIME];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour |
    NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *fileComp = [calendar components:unitFlags fromDate:currentDate];
    for (NSString *fileName in fileList) {
        // SealMicLogMMddHHmmss.log length is 24
        if (fileName.length != 24) {
            continue;
        }
        if (![[fileName substringWithRange:NSMakeRange(0, 10)] isEqualToString:@"SealMicLog"]) {
            continue;
        }
        int month = [[fileName substringWithRange:NSMakeRange(10, 2)] intValue];
        int date = [[fileName substringWithRange:NSMakeRange(12, 2)] intValue];
        if (month > 0) {
            [fileComp setMonth:month];
        } else {
            continue;
        }
        if (date > 0) {
            [fileComp setDay:date];
        } else {
            continue;
        }
        NSDate *fileDate = [calendar dateFromComponents:fileComp];
        
        if ([fileDate compare:currentDate] == NSOrderedDescending ||
            [fileDate compare:expireDate] == NSOrderedAscending) {
            [fileManager removeItemAtPath:[logPath stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}

+ (void)showTipWithErrorCode:(RCMicHTTPCode)code {
    RCMicMainThread(^{
        NSString *tipString;
        switch (code) {
            //通用错误
            case RCMicHTTPCodeParamIllegal:
                tipString = RCMicLocalizedNamed(@"http_param_illegal");
                break;
            case RCMicHTTPCodeErrOther:
                tipString = RCMicLocalizedNamed(@"http_serverError");
                break;
            case RCMicHTTPCodeErrRequestParaErr:
                tipString = RCMicLocalizedNamed(@"http_request_param_error");
                break;
            case RCMicHTTPCodeErrInvalidAuth:
                tipString = RCMicLocalizedNamed(@"http_invalid_auth");
                break;
            case RCMicHTTPCodeErrAccessDenied:
                tipString = RCMicLocalizedNamed(@"http_access_denied");
                break;
            case RCMicHTTPCodeErrBadRequest:
                tipString = RCMicLocalizedNamed(@"http_request_invalid");
                break;
            case RCMicHTTPCodeErrUserImTokenError:
                tipString = RCMicLocalizedNamed(@"http_getToken_error");
                break;
            //短信相关
            case RCMicHTTPCodeErrUserSendCodeOverFrequency:
                tipString = RCMicLocalizedNamed(@"http_sendCode_overFrequency");
                break;
            case RCMicHTTPCodeErrUserFailureExternal:
                tipString = RCMicLocalizedNamed(@"http_sendCode_failed");
                break;
            case RCMicHTTPCodeErrUserInvalidPhoneNumber:
                tipString = RCMicLocalizedNamed(@"http_sendCode_invalidPhonenumber");
                break;
            case RCMicHTTPCodeErrUserNotSendCode:
                tipString = RCMicLocalizedNamed(@"http_codeNotSend");
                break;
            case RCMicHTTPCodeErrUserVerifyCodeInvalid:
                tipString = RCMicLocalizedNamed(@"http_CodeInvalid");
                break;
            case RCMicHTTPCodeErrUserVerifyCodeEmpty:
                tipString = RCMicLocalizedNamed(@"http_codeEmpty");
                break;
            //房间相关
            case RCMicHTTPCodeErrRoomCreateRoomError:
                tipString = RCMicLocalizedNamed(@"http_createRoom_failed");
                break;
            case RCMicHTTPCodeErrRoomNotExist:
                tipString = RCMicLocalizedNamed(@"http_roomDestroy");
                break;
            case RCMicHTTPCodeErrRoomUserIdsSizeExceed:
                tipString = RCMicLocalizedNamed(@"http_userId_sizeExceed");
                break;
            case RCMicHTTPCodeErrRoomAddBlockUserError:
                tipString = RCMicLocalizedNamed(@"http_addBlock_failed");
                break;
            case RCMicHTTPCodeErrRoomUserIsNotIn:
                tipString = RCMicLocalizedNamed(@"http_userNotInRoom");
                break;
            case RCMicHTTPCodeErrRoomUserIsAlreadyInMic:
                tipString = RCMicLocalizedNamed(@"http_userAlreadyInMic");
                break;
            case RCMicHTTPCodeErrRoomUserIsAppliedForMic:
                tipString = RCMicLocalizedNamed(@"http_userHasApplied");
                break;
            case RCMicHTTPCodeErrRoomUserIsNotAppliedForMic:
                tipString = RCMicLocalizedNamed(@"http_userNotApplied");
                break;
            case RCMicHTTPCodeErrRoomUserIsNotInMic:
                tipString = RCMicLocalizedNamed(@"http_userNotInMic");
                break;
            case RCMicHTTPCodeErrRoomNoMicAvailable:
                tipString = RCMicLocalizedNamed(@"http_mic_null");
                break;
            case RCMicHTTPCodeErrRoomUserAlreadyTheHost:
                tipString = RCMicLocalizedNamed(@"http_alreadyHost");
                break;
            case RCMicHTTPCodeErrRoomTransferInfoInvalid:
                tipString = RCMicLocalizedNamed(@"http_transfer_expired");
                break;
            case RCMicHTTPCodeErrRoomUserAddGagUserError:
                tipString = RCMicLocalizedNamed(@"http_gagUser_failed");
                break;
            case RCMicHTTPCodeErrRoomTakeoverInfoInvalid:
                tipString = RCMicLocalizedNamed(@"http_takeover_expired");
                break;
            //版本升级
            case RCMicHTTPCodeErrAppNoNewVersions:
                tipString = RCMicLocalizedNamed(@"http_noNewVersion");
                break;
            //客户端单加
            case RCMicHTTPCodeErrRoomLocked:
                tipString = RCMicLocalizedNamed(@"http_room_locked");
                break;
            case RCMicHTTPCodeErrRoomNameInvalid:
                tipString = RCMicLocalizedNamed(@"createRoom_name_invalid");
                break;
            default:
                tipString = RCMicLocalizedNamed(@"http_failed");
                break;
        }
        [RCMicActiveWheel showPromptHUDAddedTo:RCMicKeyWindow text:tipString];
    })
}
@end
