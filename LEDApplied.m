//
//  LEDApplied.m
//  TuneableLight
//
//  Created by Matthew Regan on 4/27/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import "LEDApplied.h"
#import "ColorMatrix.h"
#import "CustomMath.h"

@implementation LEDApplied
@synthesize ledColor = _ledColor;
@synthesize power = _power;
@synthesize combinedColors = _combinedColors;
@synthesize isCombinedColor = _isCombinedColor;
@synthesize fixedRatio = _fixedRatio;
@synthesize isSubtractive = _isSubtractive;

- (id)init {
    self = [super init];
    //self.power = [NSNumber numberWithFloat:0];
    return self;
}

- (id)initWithLedColor:(LEDColor *)color {
    self = [self init];
    self.ledColor = color;
    return self;
}

- (void)clearPower {
    self.power = [NSNumber numberWithFloat:0];
}

//CAN GET A POINT ON THE LINE CREATED BY TWO COLOR POINTS
- (LEDApplied *)createCombinedColorWithColor:(LEDApplied *)color andDistancePercentage:(NSNumber *)percent {
    if (percent.floatValue == 0) {
        LEDApplied *returnColor = [[LEDApplied alloc] initWithLedColor:color.ledColor];
        returnColor.isCombinedColor = color.isCombinedColor;
        if (returnColor.isCombinedColor) returnColor.combinedColors = color.combinedColors;
        return returnColor;
    }
    else if (percent.floatValue == 1) {
        LEDApplied *returnColor = [[LEDApplied alloc] initWithLedColor:self.ledColor];
        returnColor.isCombinedColor = self.isCombinedColor;
        if (returnColor.isCombinedColor) returnColor.combinedColors = self.combinedColors;
        return returnColor;
    }
    float scalingFactor = color.ledColor.bigY.floatValue/self.ledColor.bigY.floatValue;
    
    //multiply the two colors together to get the output color coordinate
    ColorMatrix *matrix = [[ColorMatrix alloc] init];
    [matrix addColor:self.ledColor];
    [matrix addColor:color.ledColor];
    LEDColor *dummyColor = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.1] andy:[NSNumber numberWithFloat:.1] andY:[NSNumber numberWithFloat:0]];
    [matrix addColor:dummyColor];
    self.power = [NSNumber numberWithFloat:(percent.floatValue*scalingFactor)/(percent.floatValue*scalingFactor + (1-percent.floatValue))];
    color.power = [NSNumber numberWithFloat:(1-percent.floatValue)/(percent.floatValue*scalingFactor + (1 - percent.floatValue))];
    
    NSMutableArray *input = [NSMutableArray arrayWithCapacity:matrix.colorPointCount];
    [input addObject:self.power];
    [input addObject:color.power];
    for (NSUInteger i=2;i<matrix.colorPointCount;i++) {
        [input addObject:[NSNumber numberWithFloat:0]];
    }
    NSArray *output = [matrix multiplyRGBColorArrayToXYZ:input];
    LEDColor *varColor = [[LEDColor alloc] init];
    [varColor getxyYFromXYZArray:output];
    varColor.colorName = @"Variable Color";
    LEDApplied *returnColor = [[LEDApplied alloc] initWithLedColor:varColor];
    returnColor.isCombinedColor = TRUE;
    returnColor.combinedColors = [NSArray arrayWithObjects:self,color, nil];
    return returnColor;
}

//assumption is that if you are part of a combined color, you have a power associated with you

//if you are of a combined color, you have a fixed ratio associated with you
//if you are of a combined color, your power value gets passed to your colors that made you
//if you are not a combined color, then your "power" value is the output intensity for that color
- (void)findOutputPowerOfColorsWithStartingPowerFloat:(float)power {
    if (self.fixedRatio) power *= self.fixedRatio.floatValue;
    self.power = [NSNumber numberWithFloat:power];
    if (self.isCombinedColor) {
        for (NSUInteger i=0;i<self.combinedColors.count;i++) {
            [[self.combinedColors objectAtIndex:i] findOutputPowerOfColorsWithStartingPowerFloat:power];
        }
    }
}

@end
