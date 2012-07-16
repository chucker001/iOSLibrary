//
//  LEDApplied.h
//  TuneableLight
//
//  Created by Matthew Regan on 4/27/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEDColor.h"

@interface LEDApplied : NSObject
@property (strong, nonatomic) LEDColor *ledColor;
@property (strong, nonatomic) NSNumber *power;
@property (strong, nonatomic) NSArray *combinedColors;
@property (nonatomic) BOOL isCombinedColor;
@property (strong, nonatomic) NSNumber *fixedRatio;
@property (nonatomic) BOOL isSubtractive;

- (id)init;
- (id)initWithLedColor:(LEDColor *)color;
- (void)clearPower;
- (LEDApplied *)createCombinedColorWithColor:(LEDColor *)color andDistancePercentage:(NSNumber *)percent;
- (void)findOutputPowerOfColorsWithStartingPowerFloat:(float)power;

@end
