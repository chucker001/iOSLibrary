//
//  AdaptableLight.h
//  TuneableLight
//
//  Created by Matthew Regan on 3/23/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEDColor.h"

@interface AdaptableLight : NSObject
@property (strong, retain) NSArray *primaryColorArray;
- (id)initWithType:(NSString *)type;
- (void)clearPowerPercentages;
@end
