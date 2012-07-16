//
//  LSGCLight.m
//  DirectDriver
//
//  Created by Matthew Regan on 6/14/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import "LSGCLight.h"
#import "LEDColor.h"



@implementation LSGCLight

@synthesize colorOrderArray = _colorOrderArray;
@synthesize isDutyCycleSum100 = _isDutyCycleSum100;
@synthesize colorArray = _colorArray;
@synthesize type = _type;
@synthesize version = _version;

+ (NSArray *)getLightOptions {
    return [NSArray arrayWithObjects:@"Adaptable",@"Wall Wash",@"Prizmaline",@"Glimpse Horizon",@"SSLA", nil];
}

+ (NSArray *)getVersionOptionsFromLight:(NSString *)light {
    if ([light isEqualToString:@"Adaptable"]) return [NSArray arrayWithObjects:@"1.0", @"1.1", nil];
    else if ([light isEqualToString:@"Wall Wash"]) return [NSArray arrayWithObjects:@"1.0", nil];
    else if ([light isEqualToString:@"Prizmaline"]) return [NSArray arrayWithObjects:@"1.0", nil];
    else if ([light isEqualToString:@"Glimpse Horizon"]) return [NSArray arrayWithObjects:@"1.0", nil];
    else if ([light isEqualToString:@"SSLA"]) return [NSArray arrayWithObjects:@"1.0", nil];
    
    else return nil;
}

- (void)setType:(NSString *)type {
    _type = type;
}

- (void)setVersion:(NSString *)version {
    _version = version;
}

- (void)setColorArray:(NSArray *)colorArray {
    _colorArray = colorArray;
}

- (void)setColorOrderArray:(NSArray *)colorOrderArray {
    _colorOrderArray = colorOrderArray;
}

- (void)setIsDutyCycleSum100:(BOOL)isDutyCycleSum100 {
    _isDutyCycleSum100 = isDutyCycleSum100;
}

- (id)initWithLight:(NSString *)type andVersion:(NSString *)version {
    self = [super init];
    self.colorArray = nil;
    //define the colors used by the light
    if ([type isEqualToString:@"Adaptable"]) {
        if ([version isEqualToString:@"1.0"]) {
            LEDColor *redLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.6826] andy:[NSNumber numberWithFloat:.3163] andY:[NSNumber numberWithFloat:198.4] andName:@"red"];
            //changed from 185
            LEDColor *amberLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.5953] andy:[NSNumber numberWithFloat:.4033] andY:[NSNumber numberWithFloat:100.0] andName:@"amber"];
            LEDColor *greenLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.1909] andy:[NSNumber numberWithFloat:.7069] andY:[NSNumber numberWithFloat:243] andName:@"green"];
            LEDColor *cyanLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.0749] andy:[NSNumber numberWithFloat:.4969] andY:[NSNumber numberWithFloat:216.9] andName:@"cyan"];
            LEDColor *blueLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.1347] andy:[NSNumber numberWithFloat:.0597] andY:[NSNumber numberWithFloat:84.92] andName:@"blue"];
            LEDColor *mintLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.3798] andy:[NSNumber numberWithFloat:.4619] andY:[NSNumber numberWithFloat:809.5] andName:@"mint"];
            mintLed.excludeFromSelection = TRUE;
            
            LEDColor *blueWhiteLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.2673] andy:[NSNumber numberWithFloat:.3611] andY:[NSNumber numberWithFloat:678.6] andName:@"blueWhite"];
            blueWhiteLed.excludeFromSelection = TRUE;
            LEDColor *pinkWhiteLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.4463] andy:[NSNumber numberWithFloat:.3004] andY:[NSNumber numberWithFloat:697.2] andName:@"pinkWhite"];
            pinkWhiteLed.excludeFromSelection = TRUE;
             
            /*
            LEDColor *blueWhiteLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.2423] andy:[NSNumber numberWithFloat:.2828] andY:[NSNumber numberWithFloat:678.6] andName:@"blueWhite"];
            blueWhiteLed.excludeFromSelection = TRUE;
            LEDColor *pinkWhiteLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.5715] andy:[NSNumber numberWithFloat:.4215] andY:[NSNumber numberWithFloat:697.2] andName:@"pinkWhite"];
            pinkWhiteLed.excludeFromSelection = TRUE;
             */
            self.colorArray = [NSArray arrayWithObjects:pinkWhiteLed,greenLed,mintLed,blueWhiteLed,amberLed,cyanLed,blueLed,redLed,nil];
            self.colorOrderArray = [NSArray arrayWithObjects:@"PW",@"G",@"M",@"BW",@"A",@"C",@"B",@"R", nil];
            self.isDutyCycleSum100 = FALSE;
        }
        else if ([version isEqualToString:@"1.1"]) {
            //NOTE: LUMEN VALUES REFLECT ~600mA DRIVER (the current varied with each string)
            LEDColor *redLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.697] andy:[NSNumber numberWithFloat:.308] andY:[NSNumber numberWithFloat:211] andName:@"red"];
            //changed from 185
            LEDColor *amberLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.613] andy:[NSNumber numberWithFloat:.394] andY:[NSNumber numberWithFloat:219] andName:@"amber"];
            LEDColor *greenLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.184] andy:[NSNumber numberWithFloat:.690] andY:[NSNumber numberWithFloat:322] andName:@"green"];
            LEDColor *cyanLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.076] andy:[NSNumber numberWithFloat:.489] andY:[NSNumber numberWithFloat:287] andName:@"cyan"];
            LEDColor *blueLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.134] andy:[NSNumber numberWithFloat:.059] andY:[NSNumber numberWithFloat:120] andName:@"blue"];
            LEDColor *mintLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.380] andy:[NSNumber numberWithFloat:.461] andY:[NSNumber numberWithFloat:1230] andName:@"mint"];
            mintLed.excludeFromSelection = TRUE;
            LEDColor *blueWhiteLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.235] andy:[NSNumber numberWithFloat:.260] andY:[NSNumber numberWithFloat:1016] andName:@"blueWhite"];
            blueWhiteLed.excludeFromSelection = TRUE;
            LEDColor *phosphorAmberLed = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:.571] andy:[NSNumber numberWithFloat:.422] andY:[NSNumber numberWithFloat:912] andName:@"phosphorAmber"];
            phosphorAmberLed.excludeFromSelection = TRUE;
            self.colorArray = [NSArray arrayWithObjects:blueWhiteLed,greenLed,mintLed,phosphorAmberLed,amberLed,cyanLed,blueLed,redLed,nil];
            self.colorOrderArray = [NSArray arrayWithObjects:@"BW",@"G",@"M",@"PCA",@"A",@"C",@"B",@"R", nil];
            self.isDutyCycleSum100 = FALSE;
        }
    }
    else if ([type isEqualToString:@"Wall Wash"]) {
        if ([version isEqualToString:@"1.0"]) {
            self.colorOrderArray = [NSArray arrayWithObjects:@"R",@"G",@"B",@"M", nil];
            self.isDutyCycleSum100 = TRUE;
        }
    }
    else if ([type isEqualToString:@"Prizmaline"]) {
        if ([version isEqualToString:@"1.0"]) {
            self.colorOrderArray = [NSArray arrayWithObjects:@"R",@"G",@"B",@"M", nil];
            self.isDutyCycleSum100 = FALSE;
        }
    }
    else if ([type isEqualToString:@"Prizmaline Tunable"]) {
        if ([version isEqualToString:@"1.0"]) {
            LEDColor *redLed = [[LEDColor alloc] initWithx:[[NSNumber alloc] initWithFloat:.6869] andy:[[NSNumber alloc] initWithFloat:.3105] andY:[[NSNumber alloc] initWithFloat:8.61] andName:[NSString stringWithString:@"red"]];
            LEDColor *blueWhiteLed = [[LEDColor alloc] initWithx:[[NSNumber alloc] initWithFloat:.269] andy:[[NSNumber alloc] initWithFloat:.356] andY:[[NSNumber alloc] initWithFloat:23.16] andName:[NSString stringWithString:@"blueWhite"]];
            LEDColor *mintLed = [[LEDColor alloc] initWithx:[[NSNumber alloc] initWithFloat:.381] andy:[[NSNumber alloc] initWithFloat:.454] andY:[[NSNumber alloc] initWithFloat:48.28] andName:[NSString stringWithString:@"mint"]];
            self.colorArray = [NSArray arrayWithObjects:redLed,blueWhiteLed,mintLed,nil];
        }
    }
    else if ([type isEqualToString:@"Glimpse Horizon"]) {
        if ([version isEqualToString:@"1.0"]) {
            self.colorOrderArray = [NSArray arrayWithObjects:@"M",@"R",@"B", nil];
            self.isDutyCycleSum100 = FALSE;
        }
    }
    else if ([type isEqualToString:@"SSLA"]) {
        if ([version isEqualToString:@"1.0"]) {
            self.colorOrderArray = [NSArray arrayWithObjects:@"M",@"R",@"C",@"B", nil];
            self.isDutyCycleSum100 = TRUE;
        }
    }
    self.type = type;
    self.version = version;
    return self;
}

@end
