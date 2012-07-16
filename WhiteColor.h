//
//  WhiteColor.h
//  Adaptable
//
//  Created by Matthew Regan on 7/2/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import "LEDColor.h"
#import "LEDAppliedDW.h"
#import "LSGCLight.h"

@interface WhiteColor : LEDColor

- (id)initWithCCT:(NSString *)cct andLSGCLight:(LSGCLight *)lsgcLight;
- (void)findDominantWavelengthAndIntersectingColorOfColorPoint:(LEDColor *)selectedColor;
- (void)removeLastDWColor;
- (BOOL)removeDWColorAtIndex:(NSUInteger)index;
- (LEDAppliedDW *)getLastDWColor;
- (void)removeAllDWColors;
- (void)clearAllDWColorPowerOutputs;

@end
