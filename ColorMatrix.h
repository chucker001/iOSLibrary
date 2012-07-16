//
//  ColorMatrix.h
//  TuneableLight
//
//  Created by Matthew Regan on 3/16/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEDApplied.h"

@interface ColorMatrix : NSObject
@property (nonatomic) NSUInteger colorPointCount;
@property (nonatomic, strong) NSArray *appliedColorArray;

- (id)init;
- (id)initWithSRGB;
- (NSArray *)multiplyRGBColorArrayToXYZ:(NSArray *)array;
- (NSArray *)multiplyXYZColorArrayToRGB:(NSArray *)array;
- (NSArray *)multiplyXYToXYFromInputArray:(NSArray *)array;
//- (void)addColor:(NSArray *)array;
- (void)addColor:(id)color;
- (void)addSubtractiveColor:(id)color;
- (void)setFixedRatios:(NSArray *)fixedRatioArray;

- (LEDColor *)getLEDColorFromRGBArray:(NSArray *)array;

@end
