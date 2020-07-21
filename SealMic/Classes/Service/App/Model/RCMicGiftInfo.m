//
//  RCMicGiftInfo.m
//  SealMic
//
//  Created by lichenfeng on 2020/6/18.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicGiftInfo.h"
#import "RCMicMacro.h"

#define Smell @"gift_smell"
#define Ice @"gift_ice"
#define AirTicket @"gift_airTicket"
#define LovingCar @"gift_lovingCar"
#define Honey @"gift_honey"
#define SavingPot @"gift_savingPot"
#define TreasureBox @"gift_treasureBox"
#define SportsCar @"gift_sportsCar"

@implementation RCMicGiftInfo

- (instancetype)initWithType:(RCMicGiftType)type {
    self = [super init];
    if (self) {
        _type = type;
        _tag = [self transformTypeToTag:type];
        [self configWithType:type];
    }
    return self;
}

- (instancetype)initWithTag:(NSString *)tag {
    self = [super init];
    if (self) {
        _tag = tag;
        _type = [self transformTagToType:tag];
        [self configWithType:_type];
    }
    return self;
}

- (RCMicGiftType)transformTagToType:(NSString *)tag {
    RCMicGiftType type;
    if ([tag isEqualToString:Smell]) {
        type = RCMicGiftTypeSmell;
    } else if ([tag isEqualToString:Ice]) {
        type = RCMicGiftTypeIce;
    } else if ([tag isEqualToString:AirTicket]) {
        type = RCMicGiftTypeAirTicket;
    } else if ([tag isEqualToString:LovingCar]) {
        type = RCMicGiftTypeLovingCar;
    } else if ([tag isEqualToString:Honey]) {
        type = RCMicGiftTypeHoney;
    } else if ([tag isEqualToString:SavingPot]) {
        type = RCMicGiftTypeSavingPot;
    } else if ([tag isEqualToString:TreasureBox]) {
        type = RCMicGiftTypeTreasureBox;
    } else {
        type = RCMicGiftTypeSportsCar;
    }
    return type;
}

- (NSString *)transformTypeToTag:(RCMicGiftType)type {
    NSString *tag;
    switch (type) {
        case RCMicGiftTypeSmell:
            tag = Smell;
            break;
        case RCMicGiftTypeIce:
            tag = Ice;
            break;
        case RCMicGiftTypeAirTicket:
            tag = AirTicket;
            break;
        case RCMicGiftTypeLovingCar:
            tag = LovingCar;
            break;
        case RCMicGiftTypeHoney:
            tag = Honey;
            break;
        case RCMicGiftTypeSavingPot:
            tag = SavingPot;
            break;
        case RCMicGiftTypeTreasureBox:
            tag = TreasureBox;
            break;
        case RCMicGiftTypeSportsCar:
            tag = SportsCar;
            break;
        default:
            tag = @"";
            break;
    }
    return tag;
}

- (void)configWithType:(RCMicGiftType)type {
    switch (type) {
            
        case RCMicGiftTypeSmell:
            _name = RCMicLocalizedNamed(@"dialog_gift_smile_face");
            _image = [UIImage imageNamed:@"gift_smail"];
            _bigImageName = @"gift_smail_big";
            break;
        case RCMicGiftTypeIce:
            _name = RCMicLocalizedNamed(@"dialog_gift_ice_cream");
            _image = [UIImage imageNamed:@"gift_icecream"];
            _bigImageName = @"gift_icecream_big";
            break;
        case RCMicGiftTypeAirTicket:
            _name = RCMicLocalizedNamed(@"dialog_gift_airticket");
            _image = [UIImage imageNamed:@"gift_airticket"];
            _bigImageName = @"gift_airticket_big";
            break;
        case RCMicGiftTypeLovingCar:
            _name = RCMicLocalizedNamed(@"dialog_gift_car");
            _image = [UIImage imageNamed:@"gift_car"];
            _bigImageName = @"gift_car_big";
            break;
        case RCMicGiftTypeHoney:
            _name = RCMicLocalizedNamed(@"dialog_gift_honey");
            _image = [UIImage imageNamed:@"gift_honey"];
            _bigImageName = @"gift_honey_big";
            break;
        case RCMicGiftTypeSavingPot:
            _name = RCMicLocalizedNamed(@"dialog_gift_savingpot");
            _image = [UIImage imageNamed:@"gift_savingpot"];
            _bigImageName = @"gift_savingpot_big";
            break;
        case RCMicGiftTypeTreasureBox:
            _name = RCMicLocalizedNamed(@"dialog_gift_treasurebox");
            _image = [UIImage imageNamed:@"gift_treasurebox"];
            _bigImageName = @"gift_treasurebox_big";
            break;
        case RCMicGiftTypeSportsCar:
            _name = RCMicLocalizedNamed(@"dialog_gift_roadster");
            _image = [UIImage imageNamed:@"gift_roadster"];
            _bigImageName = @"gift_roadster_big";
            break;
        default:
            _name = @"";
            _image = nil;
            _bigImageName = @"";
            break;
    }
}
@end
