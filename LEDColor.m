//
//  LEDColor.m
//  TuneableLight
//
//  Created by Matthew Regan on 3/16/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import "LEDColor.h"

@implementation LEDColor

@synthesize bigY = _bigY;
@synthesize x = _x;
@synthesize y = _y;
@synthesize colorName = _colorName;
@synthesize excludeFromSelection = _excludeFromSelection;

- (void)setX:(NSNumber *)x {
    _x = x;
}

- (void)setY:(NSNumber *)y {
    _y = y;
}

- (id)init {
    self = [super init];
    self.excludeFromSelection = FALSE;
    return self;
}

- (id)initWithx:(NSNumber *)x andy:(NSNumber *)y andY:(NSNumber *)bigY {
    self = [self init];
    self.x = x;
    self.y = y;
    self.bigY = bigY;
    return self;
}

- (id)initWithx:(NSNumber *)x andy:(NSNumber *)y andY:(NSNumber *)bigY andName:(NSString *)name {
    self = [self initWithx:x andy:y andY:bigY];
    self.colorName = name;
    return self;
}

- (NSArray *)completeLEDColorInfoWithDimension:(NSUInteger)dimension {
    if (!self.x) self.x = [NSNumber numberWithFloat:0];
    if (!self.y) self.y = [NSNumber numberWithFloat:0];
    if (!self.bigY) self.bigY = [NSNumber numberWithFloat:1.0];
    NSNumber *bigX = [NSNumber numberWithFloat:(self.x.floatValue * self.bigY.floatValue / self.y.floatValue)];
    NSNumber *z = [NSNumber numberWithFloat:((1-self.x.floatValue-self.y.floatValue)/(dimension - 2))];
    NSNumber *bigZ = [NSNumber numberWithFloat:(z.floatValue * self.bigY.floatValue / self.y.floatValue)];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:dimension];
    [array addObject:bigX];
    [array addObject:self.bigY];
    for (NSInteger i = 2;i<dimension;i++) {
        [array addObject:bigZ];
    }
    return array;
}

- (void)getxyYFromXYZArray:(NSArray *)array {
    if (array.count < 2) return;
    float arrayTotal = 0;
    for (NSUInteger i=0;i<array.count;i++) {
        arrayTotal += [[array objectAtIndex:i] floatValue];
    }
    self.x = [NSNumber numberWithFloat:(([[array objectAtIndex:0] floatValue])/arrayTotal)];
    self.bigY = [array objectAtIndex:1];
    self.y = [NSNumber numberWithFloat:(self.bigY.floatValue/arrayTotal)];
}

@end
