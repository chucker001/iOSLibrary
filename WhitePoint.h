//
//  WhitePoint.h
//  TuneableLight
//
//  Created by Matthew Regan on 3/19/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "LEDApplied.h"
//#import "DominantWavelength.h"
#import "LEDAppliedDW.h"
#import "LSGCLight.h"

@interface WhitePoint : NSObject

@property (strong, nonatomic) LEDColor *whiteColor;

- (id)initWithCCT:(NSString *)cct andLSGCLight:(LSGCLight *)lsgcLight;
- (void)findDominantWavelengthAndIntersectingColorOfColorPoint:(LEDColor *)selectedColor;
- (void)removeLastDWColor;
- (LEDAppliedDW *)getLastDWColor;
- (void)removeAllDWColors;
- (void)clearAllDWColorPowerOutputs;

@end
