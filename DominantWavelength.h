//
//  DominantWavelength.h
//  TuneableLight
//
//  Created by Matthew Regan on 3/23/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEDApplied.h"

@interface DominantWavelength : NSObject
@property (strong, nonatomic) NSNumber *dominantWavelength;
@property (strong, nonatomic) NSNumber *slope;
@property (strong, nonatomic) LEDApplied *appliedColor;
@end
