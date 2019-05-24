//
//  MessageHelper.m
//  SealMeeting
//
//  Created by 张改红 on 2019/3/6.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "MessageHelper.h"
#import "TextMessageCell.h"
#import "TipMessageCell.h"
#import "ClassroomService.h"
#import "RoomMemberChangedMessage.h"
@interface MessageHelper ()
@property (nonatomic, assign) CGFloat contentMaxWidth;
@end

@implementation MessageHelper

+ (instancetype)sharedInstance {
    static MessageHelper *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[self alloc] init];
    });
    return service;
}

- (RCMessage *)sendMessage:(RCMessageContent *)content
               pushContent:(NSString *)pushContent
                  pushData:(NSString *)pushData
                toTargetId:(NSString *)targetId
          conversationType:(RCConversationType)conversationType {
    __block RCMessage *message = nil;
    void (^success)(long messageId) = ^(long messageId) {
        NSError *error = nil;
        if (self.delegate && [self.delegate respondsToSelector:@selector(onSendMessage:didCompleteWithError:)]) {
            [self.delegate onSendMessage:message didCompleteWithError:error];
        }
    };
    
    void (^error)(RCErrorCode nErrorCode, long messageId) = ^(RCErrorCode nErrorCode, long messageId) {
        NSError *error = [NSError errorWithDomain:@"IMSendMessage" code:nErrorCode userInfo:nil];
        if (self.delegate && [self.delegate respondsToSelector:@selector(onSendMessage:didCompleteWithError:)]) {
            [self.delegate onSendMessage:message didCompleteWithError:error];
        }
    };
    message = [IMClient
               sendMessage:conversationType
               targetId:targetId
               content:content
               pushContent:pushContent
               pushData:pushData
               success:success
               error:error];
    if (self.delegate && [self.delegate respondsToSelector:@selector(willSendMessage:)]) {
        [self.delegate willSendMessage:message];
    }
    return message;
}

- (void)setMaximumContentWidth:(CGFloat)width{
    self.contentMaxWidth = width;
}

- (CGSize)getMessageContentSize:(RCMessageContent *)content{
    NSString *display = [self formatMessage:content];
    CGFloat maxWidth = ceil(self.contentMaxWidth * 0.83);//TODO
    if ([content isKindOfClass:[RCTextMessage class]]) {
        CGSize textSize =  [self getTextDrawingSize:display
                                                       font:[UIFont systemFontOfSize:Text_Message_Font_Size]
                                            constrainedSize:CGSizeMake(maxWidth - 33, 8000)];
        textSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
        CGSize tipLabelSize = CGSizeMake(textSize.width + 20, textSize.height + 8);
        if (tipLabelSize.height < 25) {
            tipLabelSize.height = 25;
        }
        return tipLabelSize;
    } else if ([content isKindOfClass:[RoomMemberChangedMessage class]]){
        CGSize textSize =  [self getTextDrawingSize:display font:[UIFont systemFontOfSize:InfoTextFont] constrainedSize:CGSizeMake(maxWidth - 33, 8000)];
        textSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
        CGSize tipLabelSize = CGSizeMake(textSize.width + 20, textSize.height);
        if (tipLabelSize.height < 20) {
            tipLabelSize.height = 20;
        }
        return tipLabelSize;
    }
    return CGSizeZero;
}

- (NSString *)convertChatMessageTime:(long long)secs {
    NSString *timeText = nil;
    
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:secs];
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [self getDateFormatter];
    [formatter setDateFormat:@"yyyy"];
    NSInteger currentYear=[[formatter stringFromDate:now] integerValue];
    NSInteger msgYear=[[formatter stringFromDate:messageDate] integerValue];
    
    [formatter setDateFormat:@"MM"];
    NSInteger currentMonth=[[formatter stringFromDate:now] integerValue];
    NSInteger msgMonth=[[formatter stringFromDate:messageDate] integerValue];
    
    [formatter setDateFormat:@"dd"];
    NSInteger currentDay=[[formatter stringFromDate:now] integerValue];
    NSInteger msgDay=[[formatter stringFromDate:messageDate] integerValue];
    
    [formatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:NSLocalizedStringFromTable(@"locale", @"SealMeeting", nil)]];
    
    NSString *formatStr = [self getDateFormatterString:messageDate];
    [formatter setDateFormat:formatStr];
    if (currentYear == msgYear) {
        if (currentMonth == msgMonth) {
            if (currentDay == msgDay) {
                return timeText = [formatter stringFromDate:messageDate];
            }else{
                if (currentDay - msgDay == 1) {
                    return timeText =
                    [NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"Yesterday", @"SealMeeting", nil),
                     [formatter stringFromDate:messageDate]];
                }else if(currentDay - msgDay < 7){
                    [formatter setDateFormat:[NSString stringWithFormat:@"eeee %@", formatStr]];
                    return timeText = [formatter stringFromDate:messageDate];
                }else{
                    return [self getMessageDate:messageDate dateFormat:formatter];
                }
            }
        }else{
            return [self getMessageDate:messageDate dateFormat:formatter];
        }
    }
    return [self getMessageDate:messageDate dateFormat:formatter];
}

- (NSArray<NSString *> *)getAllSupportMessage{
    return @[RCTextMessageTypeIdentifier, RoomMemberChangedMessageIdentifier, RCInformationNotificationMessageIdentifier];
}

- (NSString *)formatMessage:(RCMessageContent *)content{
    NSString *formatString;
    if ([content isKindOfClass:[RCTextMessage class]]) {
        RCTextMessage *textMessage = (RCTextMessage *)content;
        formatString = textMessage.content;
    }else if ([content isKindOfClass:[RCInformationNotificationMessage class]]){
        RCInformationNotificationMessage *infoMsg = (RCInformationNotificationMessage *)content;
        formatString = infoMsg.message;
    } else if ([content isKindOfClass:[RoomMemberChangedMessage class]]) {
        RoomMemberChangedMessage *infoMsg = (RoomMemberChangedMessage *)content;
        NSString *userName = [RandomUtil randomNameFor:infoMsg.userId];
        NSString *string = @"";
        if (infoMsg.action == MemberChangeActionJoin) {
            string = [NSString stringWithFormat:MicLocalizedNamed(@"JoinRoom"), userName];
        } else if(infoMsg.action == MemberChangeActionLeave) {
            string = [NSString stringWithFormat:MicLocalizedNamed(@"LeaveRoom"), userName];
        } else if (infoMsg.action == MemberChangeActionKick) {
            string = [NSString stringWithFormat:MicLocalizedNamed(@"KickRoom"), userName];
        }
        formatString = string;
    }
    return formatString;
}

#pragma mark - help
- (NSString *)getMessageDate:(NSDate*)messageDate dateFormat:(NSDateFormatter *)formatter{
    [formatter setDateFormat:[NSString stringWithFormat:@"%@ %@",
                              NSLocalizedStringFromTable(@"chatDate", @"SealMeeting", nil),
                              [self getDateFormatterString:messageDate]]];
    return [formatter stringFromDate:messageDate];
}

- (NSString *)getDateFormatterString:(NSDate *)messageDate{
    NSString *formatStringForHours =
    [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    NSString *formatStr = nil;
    if (hasAMPM) {
        formatStr = [self getFormatStringByMessageDate:messageDate];
    } else {
        formatStr = @"HH:mm";
    }
    return formatStr;
}

- (NSString *)getFormatStringByMessageDate:(NSDate *)messageDate {
    NSString *formatStr = nil;
    if ([self isBetweenFromHour:0 toHour:6 currentDate:messageDate]) {
        formatStr = NSLocalizedStringFromTable(@"Dawn", @"SealMeeting", nil);
    } else if ([self isBetweenFromHour:6 toHour:12 currentDate:messageDate]) {
        formatStr = NSLocalizedStringFromTable(@"Forenoon", @"SealMeeting", nil);
    } else if ([self isBetweenFromHour:12 toHour:13 currentDate:messageDate]) {
        formatStr = NSLocalizedStringFromTable(@"Noon", @"SealMeeting", nil);
    } else if ([self isBetweenFromHour:13 toHour:18 currentDate:messageDate]) {
        formatStr = NSLocalizedStringFromTable(@"Afternoon", @"SealMeeting", nil);
    } else {
        formatStr = NSLocalizedStringFromTable(@"Evening", @"SealMeeting", nil);
    }
    return formatStr;
}

- (BOOL)isBetweenFromHour:(NSInteger)fromHour toHour:(NSInteger)toHour currentDate:(NSDate *)currentDate {
    NSDate *date1 = [self getCustomDateWithHour:fromHour currentDate:currentDate];
    NSDate *date2 = [self getCustomDateWithHour:toHour currentDate:currentDate];
    if ([currentDate compare:date1] == NSOrderedDescending &&
        ([currentDate compare:date2] == NSOrderedAscending || [currentDate compare:date1] == NSOrderedSame))
        return YES;
    return NO;
}

- (NSDate *)getCustomDateWithHour:(NSInteger)hour currentDate:(NSDate *)currentDate {
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *currentComps;
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    //设置当天的某个点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [resultCalendar dateFromComponents:resultComps];
}

- (NSDateFormatter *)getDateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    return dateFormatter;
}

- (CGSize)getTextDrawingSize:(NSString *)text font:(UIFont *)font constrainedSize:(CGSize)constrainedSize {
    if (text.length <= 0) {
        return CGSizeZero;
    }
    return [text boundingRectWithSize:constrainedSize
                              options:(NSStringDrawingTruncatesLastVisibleLine |
                                       NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                           attributes:@{NSFontAttributeName : font}
                              context:nil].size;
}
@end
