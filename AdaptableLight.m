//
//  AdaptableLight.m
//  TuneableLight
//
//  Created by Matthew Regan on 3/23/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import "AdaptableLight.h"

@implementation AdaptableLight

@synthesize primaryColorArray = _primaryColorArray;

- (id)initWithType:(NSString *)type {
    self = [super init];
    //define the colors used by the light
    if ([type isEqualToString:@"Glimpse1.0"]) {
        LEDColor *redLed = [[LEDColor alloc] initWithx:[[NSNumber alloc] initWithFloat:.6871] andy:[[NSNumber alloc] initWithFloat:.3119] andY:[[NSNumber alloc] initWithFloat:80] andName:[NSString stringWithString:@"red"]];
        [redLed completeLEDColorInfo];
        LEDColor *amberLed = [[LEDColor alloc] initWithx:[[NSNumber alloc] initWithFloat:.55] andy:[[NSNumber alloc] initWithFloat:.41] andY:[[NSNumber alloc] initWithFloat:42] andName:[NSString stringWithString:@"amber"]];
        [amberLed completeLEDColorInfo];
        LEDColor *greenLed = [[LEDColor alloc] initWithx:[[NSNumber alloc] initWithFloat:.189] andy:[[NSNumber alloc] initWithFloat:.713] andY:[[NSNumber alloc] initWithFloat:62] andName:[NSString stringWithString:@"green"]];
        [greenLed completeLEDColorInfo];
        LEDColor *cyanLed = [[LEDColor alloc] initWithx:[[NSNumber alloc] initWithFloat:.0741] andy:[[NSNumber alloc] initWithFloat:.5756] andY:[[NSNumber alloc] initWithFloat:88] andName:[NSString stringWithString:@"cyan"]];
        [cyanLed completeLEDColorInfo];
        LEDColor *blueLed = [[LEDColor alloc] initWithx:[[NSNumber alloc] initWithFloat:.1367] andy:[[NSNumber alloc] initWithFloat:.0526] andY:[[NSNumber alloc] initWithFloat:20] andName:[NSString stringWithString:@"blue"]];
        [blueLed completeLEDColorInfo];
        LEDColor *mintLed = [[LEDColor alloc] initWithx:[[NSNumber alloc] initWithFloat:.373] andy:[[NSNumber alloc] initWithFloat:.447] andY:[[NSNumber alloc] initWithFloat:117.5] andName:[NSString stringWithString:@"mint"]];
        mintLed.excludeFromSelection = TRUE;
        [mintLed completeLEDColorInfo];
        self.primaryColorArray = [NSArray arrayWithObjects:redLed,amberLed,greenLed,cyanLed,blueLed,mintLed,nil];
    }
    return self;
}

- (void)clearPowerPercentages {
    for (NSUInteger i = 0;i<[self.primaryColorArray count];i++) {
        [[self.primaryColorArray objectAtIndex:i] clearPowerPercentage];
    }
}

@end
