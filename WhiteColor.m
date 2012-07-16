//
//  WhiteColor.m
//  Adaptable
//
//  Created by Matthew Regan on 7/2/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import "WhiteColor.h"
#import "CustomMath.h"

@interface WhiteColor() 
@property (strong, nonatomic) NSNumber *c1;
@property (strong, nonatomic) NSNumber *c2;
@property (strong, nonatomic) NSNumber *c3;
@property (strong, nonatomic) NSNumber *c4;
@property (strong, nonatomic) NSNumber *c5;
@property (strong, nonatomic) NSNumber *c6;
@property (strong, nonatomic) NSNumber *c7;
@property (strong, nonatomic) NSNumber *c8;
@property (strong, nonatomic) NSNumber *verticalWavelength;

//array of dominant wavelength NSNumbers for each color point of an LSGC light
@property (strong, nonatomic) NSMutableArray *dwPrimaryArray;
//array of dominant wavelength objects
@property (strong, nonatomic) NSMutableArray *dwColorArray;
//pointer to the LSGCLight
@property LSGCLight *lsgcLight;
@property (strong, nonatomic) NSMutableArray *sortedDWPrimaryArray;
@property (strong, nonatomic) NSMutableArray *sortedLSGCLightArray;

@end

@implementation WhiteColor
@synthesize c1 = _c1;
@synthesize c2 = _c2;
@synthesize c3 = _c3;
@synthesize c4 = _c4;
@synthesize c5 = _c5;
@synthesize c6 = _c6;
@synthesize c7 = _c7;
@synthesize c8 = _c8;
@synthesize verticalWavelength = _verticalWavelength;
@synthesize dwPrimaryArray = _dwPrimaryArray;
@synthesize dwColorArray = _dwColorArray;
@synthesize lsgcLight = _lsgcLight;
@synthesize sortedDWPrimaryArray = _sortedPrimaryArray;
@synthesize sortedLSGCLightArray = _sortedLSGCLightArray;

- (void)sortDWColorsInDescendingOrder {
    NSMutableArray *arrayToSort = [self.dwPrimaryArray mutableCopy];
    self.sortedDWPrimaryArray = [NSMutableArray arrayWithCapacity:self.dwPrimaryArray.count];
    self.sortedLSGCLightArray = [NSMutableArray arrayWithCapacity:self.dwPrimaryArray.count];
    NSInteger maxWavelength = -2;
    NSUInteger maxIndex = 0;
    NSUInteger i,j;
    for (j=0;j<arrayToSort.count;j++) {
        maxWavelength = -2;
        maxIndex = 0;
        for (i=0;i<arrayToSort.count;i++) {
            if (maxWavelength < [[arrayToSort objectAtIndex:i] integerValue]) {
                maxIndex = i;
                maxWavelength = [[arrayToSort objectAtIndex:i] integerValue];
            }
        }
        [self.sortedDWPrimaryArray addObject:[self.dwPrimaryArray objectAtIndex:maxIndex]];
        [self.sortedLSGCLightArray addObject:[self.lsgcLight.colorArray objectAtIndex:maxIndex]];
        [arrayToSort replaceObjectAtIndex:maxIndex withObject:[NSNumber numberWithInteger:-2]];
    }
}

- (void)findDominantWavelengthOfPrimaryColor:(LEDColor *)point {
    if ([point excludeFromSelection]) [self.dwPrimaryArray addObject:[NSNumber numberWithInteger:-1]];
    else {
        NSNumber *wavelength;
        if ([point.x floatValue] != [self.x floatValue]) {
            float slope = (([point.y floatValue] - [self.y floatValue])/([point.x floatValue] - [self.x floatValue]));
            if ((slope <= 3.0) && (slope >= -3.0)) {
                if ([point.x floatValue] < .333) wavelength = [NSNumber numberWithUnsignedInteger:(([self.c1 floatValue] * slope) + [self.c2 floatValue])];
                else if (slope > 0.0) wavelength = [NSNumber numberWithUnsignedInteger:(([self.c3 floatValue] * slope) + [self.c4 floatValue])]; 
                else wavelength = [NSNumber numberWithUnsignedInteger:(([self.c5 floatValue] * powf(slope,3)) + ([self.c6 floatValue] * powf(slope,2)) + ([self.c7 floatValue] * slope) + [self.c8 floatValue])];
            }
            else if ([point.y floatValue] > [self.y floatValue]) wavelength = self.verticalWavelength;
            else wavelength = [NSNumber numberWithUnsignedInteger:-1];
        }
        else if ([point.y floatValue] > [self.y floatValue]) wavelength = self.verticalWavelength;
        else wavelength = [NSNumber numberWithUnsignedInteger:-1];
        [self.dwPrimaryArray addObject:wavelength];
    }
}

-  (id)initWithCCT:(NSString *)cct andLSGCLight:(LSGCLight *)lsgcLight{
    if ([cct isEqualToString:@"2700"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.459] andy:[NSNumber numberWithFloat:.411] andY:[NSNumber numberWithFloat:100] andName:@"2700K"];
        self.c1 = [NSNumber numberWithFloat:-28.578];
        self.c2 = [NSNumber numberWithFloat:493.49];
        self.c3 = [NSNumber numberWithFloat:-5.2294];
        self.c4 = [NSNumber numberWithFloat:589.01];
        self.c5 = [NSNumber numberWithFloat:-1966.7];
        self.c6 = [NSNumber numberWithFloat:-1275.7];
        self.c7 = [NSNumber numberWithFloat:-270.44];
        self.c8 = [NSNumber numberWithFloat:582.25];
        self.verticalWavelength = [NSNumber numberWithInteger:573];
    }
    else if ([cct isEqualToString:@"2800"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.452] andy:[NSNumber numberWithFloat:.409] andY:[NSNumber numberWithFloat:100] andName:@"2800K"];
    }
    else if ([cct isEqualToString:@"2900"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.444] andy:[NSNumber numberWithFloat:.406] andY:[NSNumber numberWithFloat:100] andName:@"2900K"];
    }
    else if ([cct isEqualToString:@"3000"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.437] andy:[NSNumber numberWithFloat:.404] andY:[NSNumber numberWithFloat:100] andName:@"3000K"];
        self.c1 = [NSNumber numberWithFloat:-25.915];
        self.c2 = [NSNumber numberWithFloat:492.54];
        self.c3 = [NSNumber numberWithFloat:-8.7684];
        self.c4 = [NSNumber numberWithFloat:590.5];
        self.c5 = [NSNumber numberWithFloat:-2477.9];
        self.c6 = [NSNumber numberWithFloat:-1375.8];
        self.c7 = [NSNumber numberWithFloat:-259];
        self.c8 = [NSNumber numberWithFloat:585.69];
        self.verticalWavelength = [NSNumber numberWithInteger:569];
    }
    else if ([cct isEqualToString:@"3100"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.430] andy:[NSNumber numberWithFloat:.402] andY:[NSNumber numberWithFloat:100] andName:@"3100K"];
    }
    else if ([cct isEqualToString:@"3200"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.423] andy:[NSNumber numberWithFloat:.399] andY:[NSNumber numberWithFloat:100] andName:@"3200K"];
    }
    else if ([cct isEqualToString:@"3300"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.417] andy:[NSNumber numberWithFloat:.396] andY:[NSNumber numberWithFloat:100] andName:@"3300K"];
    }
    else if ([cct isEqualToString:@"3400"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.411] andy:[NSNumber numberWithFloat:.394] andY:[NSNumber numberWithFloat:100] andName:@"3400K"];
    }
    else if ([cct isEqualToString:@"3500"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.405] andy:[NSNumber numberWithFloat:.390] andY:[NSNumber numberWithFloat:100] andName:@"3500K"];
        self.c1 = [NSNumber numberWithFloat:-22.847];
        self.c2 = [NSNumber numberWithFloat:491.16];
        self.c3 = [NSNumber numberWithFloat:-14.875];
        self.c4 = [NSNumber numberWithFloat:593.69];
        self.c5 = [NSNumber numberWithFloat:-4026.5];
        self.c6 = [NSNumber numberWithFloat:-1778.5];
        self.c7 = [NSNumber numberWithFloat:-286.07];
        self.c8 = [NSNumber numberWithFloat:588.86];
        self.verticalWavelength = [NSNumber numberWithInteger:565];
    }
    else if ([cct isEqualToString:@"3600"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.400] andy:[NSNumber numberWithFloat:.388] andY:[NSNumber numberWithFloat:100] andName:@"3600K"];
    }
    else if ([cct isEqualToString:@"3700"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.395] andy:[NSNumber numberWithFloat:.385] andY:[NSNumber numberWithFloat:100] andName:@"3700K"];
    }
    else if ([cct isEqualToString:@"3800"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.390] andy:[NSNumber numberWithFloat:.382] andY:[NSNumber numberWithFloat:100] andName:@"3800K"];
    }
    else if ([cct isEqualToString:@"3900"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.385] andy:[NSNumber numberWithFloat:.380] andY:[NSNumber numberWithFloat:100] andName:@"3900K"];
    }
    else if ([cct isEqualToString:@"4000"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.380] andy:[NSNumber numberWithFloat:.377] andY:[NSNumber numberWithFloat:100] andName:@"4000K"];
        self.c1 = [NSNumber numberWithFloat:-20.723];
        self.c2 = [NSNumber numberWithFloat:490.11];
        self.c3 = [NSNumber numberWithFloat:-19.06];
        self.c4 = [NSNumber numberWithFloat:595.9];
        self.c5 = [NSNumber numberWithFloat:-6091.1];
        self.c6 = [NSNumber numberWithFloat:-2131.5];
        self.c7 = [NSNumber numberWithFloat:-292.79];
        self.c8 = [NSNumber numberWithFloat:593.24];
        self.verticalWavelength = [NSNumber numberWithInteger:561];
    }
    else if ([cct isEqualToString:@"4100"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.376] andy:[NSNumber numberWithFloat:.374] andY:[NSNumber numberWithFloat:100] andName:@"4100K"];
    }
    else if ([cct isEqualToString:@"4200"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.372] andy:[NSNumber numberWithFloat:.371] andY:[NSNumber numberWithFloat:100] andName:@"4200K"];
    }
    else if ([cct isEqualToString:@"4300"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.368] andy:[NSNumber numberWithFloat:.369] andY:[NSNumber numberWithFloat:100] andName:@"4300K"];
    }
    else if ([cct isEqualToString:@"4400"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.364] andy:[NSNumber numberWithFloat:.366] andY:[NSNumber numberWithFloat:100] andName:@"4400K"];
    }
    else if ([cct isEqualToString:@"4500"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.361] andy:[NSNumber numberWithFloat:.364] andY:[NSNumber numberWithFloat:100] andName:@"4500K"];
        self.c1 = [NSNumber numberWithFloat:-19.234];
        self.c2 = [NSNumber numberWithFloat:490.11];
        self.c3 = [NSNumber numberWithFloat:-19.06];
        self.c4 = [NSNumber numberWithFloat:595.9];
        self.c5 = [NSNumber numberWithFloat:-6091.1];
        self.c6 = [NSNumber numberWithFloat:-2131.5];
        self.c7 = [NSNumber numberWithFloat:-292.79];
        self.c8 = [NSNumber numberWithFloat:593.24];
        self.verticalWavelength = [NSNumber numberWithInteger:558];
    }
    else if ([cct isEqualToString:@"4600"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.357] andy:[NSNumber numberWithFloat:.361] andY:[NSNumber numberWithFloat:100] andName:@"4600K"];
    }
    else if ([cct isEqualToString:@"4700"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.354] andy:[NSNumber numberWithFloat:.359] andY:[NSNumber numberWithFloat:100] andName:@"4700K"];
    }
    else if ([cct isEqualToString:@"4800"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.351] andy:[NSNumber numberWithFloat:.356] andY:[NSNumber numberWithFloat:100] andName:@"4800K"];
    }
    else if ([cct isEqualToString:@"4900"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.348] andy:[NSNumber numberWithFloat:.354] andY:[NSNumber numberWithFloat:100] andName:@"4900K"];
    }
    else if ([cct isEqualToString:@"5000"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.345] andy:[NSNumber numberWithFloat:.352] andY:[NSNumber numberWithFloat:100] andName:@"5000K"];
        self.c1 = [NSNumber numberWithFloat:-18.281];
        self.c2 = [NSNumber numberWithFloat:489.6];
        self.c3 = [NSNumber numberWithFloat:-26.067];
        self.c4 = [NSNumber numberWithFloat:600.31];
        self.c5 = [NSNumber numberWithFloat:-11603];
        self.c6 = [NSNumber numberWithFloat:-2505.5];
        self.c7 = [NSNumber numberWithFloat:-262.59];
        self.c8 = [NSNumber numberWithFloat:602.39];
        self.verticalWavelength = [NSNumber numberWithInteger:556];
    }
    else if ([cct isEqualToString:@"5100"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.342] andy:[NSNumber numberWithFloat:.349] andY:[NSNumber numberWithFloat:100] andName:@"5100K"];
    }
    else if ([cct isEqualToString:@"5200"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.340] andy:[NSNumber numberWithFloat:.347] andY:[NSNumber numberWithFloat:100] andName:@"5200K"];
    }
    else if ([cct isEqualToString:@"5300"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.337] andy:[NSNumber numberWithFloat:.345] andY:[NSNumber numberWithFloat:100] andName:@"5300K"];
    }
    else if ([cct isEqualToString:@"5400"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.335] andy:[NSNumber numberWithFloat:.343] andY:[NSNumber numberWithFloat:100] andName:@"5400K"];
    }
    else if ([cct isEqualToString:@"5500"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.332] andy:[NSNumber numberWithFloat:.341] andY:[NSNumber numberWithFloat:100] andName:@"5500K"];
    }
    else if ([cct isEqualToString:@"5600"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.330] andy:[NSNumber numberWithFloat:.339] andY:[NSNumber numberWithFloat:100] andName:@"5600K"];
    }
    else if ([cct isEqualToString:@"5700"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.328] andy:[NSNumber numberWithFloat:.337] andY:[NSNumber numberWithFloat:100] andName:@"5700K"];
        self.c1 = [NSNumber numberWithFloat:-17.095];
        self.c2 = [NSNumber numberWithFloat:488.06];
        self.c3 = [NSNumber numberWithFloat:-31.062];
        self.c4 = [NSNumber numberWithFloat:603.86];
        self.c5 = [NSNumber numberWithFloat:-20968];
        self.c6 = [NSNumber numberWithFloat:-3642.6];
        self.c7 = [NSNumber numberWithFloat:-335.52];
        self.c8 = [NSNumber numberWithFloat:605.78];
        self.verticalWavelength = [NSNumber numberWithInteger:554];
    }
    else if ([cct isEqualToString:@"5800"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.326] andy:[NSNumber numberWithFloat:.335] andY:[NSNumber numberWithFloat:100] andName:@"5800K"];
    }
    else if ([cct isEqualToString:@"5900"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.324] andy:[NSNumber numberWithFloat:.334] andY:[NSNumber numberWithFloat:100] andName:@"5900K"];
    }
    else if ([cct isEqualToString:@"6000"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.322] andy:[NSNumber numberWithFloat:.332] andY:[NSNumber numberWithFloat:100] andName:@"6000K"];
    }
    else if ([cct isEqualToString:@"6100"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.320] andy:[NSNumber numberWithFloat:.330] andY:[NSNumber numberWithFloat:100] andName:@"6100K"];
    }
    else if ([cct isEqualToString:@"6200"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.318] andy:[NSNumber numberWithFloat:.328] andY:[NSNumber numberWithFloat:100] andName:@"6200K"];
    }
    else if ([cct isEqualToString:@"6300"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.317] andy:[NSNumber numberWithFloat:.327] andY:[NSNumber numberWithFloat:100] andName:@"6300K"];
    }
    else if ([cct isEqualToString:@"6400"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.315] andy:[NSNumber numberWithFloat:.325] andY:[NSNumber numberWithFloat:100] andName:@"6400K"];
    }
    else if ([cct isEqualToString:@"6500"]) {
        self = [super initWithx:[NSNumber numberWithFloat:.313] andy:[NSNumber numberWithFloat:.323] andY:[NSNumber numberWithFloat:100] andName:@"6500K"];
        self.c1 = [NSNumber numberWithFloat:-16.191];
        self.c2 = [NSNumber numberWithFloat:487.48];
        self.c3 = [NSNumber numberWithFloat:-35.347];
        self.c4 = [NSNumber numberWithFloat:607.03];
        self.c5 = [NSNumber numberWithFloat:-33767];
        self.c6 = [NSNumber numberWithFloat:-3967.5];
        self.c7 = [NSNumber numberWithFloat:-320.05];
        self.c8 = [NSNumber numberWithFloat:612.24];
        self.verticalWavelength = [NSNumber numberWithInteger:552];
    }
    else self = [super init];
    self.dwPrimaryArray = [[NSMutableArray alloc] init];
    self.dwColorArray = [[NSMutableArray alloc] init];
    if (lsgcLight) {
        self.lsgcLight = lsgcLight;
        for (NSUInteger i=0;i<self.lsgcLight.colorArray.count;i++) {
            [self findDominantWavelengthOfPrimaryColor:[self.lsgcLight.colorArray objectAtIndex:i]];
        }
        [self sortDWColorsInDescendingOrder];
    }
    return self;
}

- (void)findDominantWavelengthAndIntersectingColorOfColorPoint:(LEDColor *)selectedColor {
    LEDAppliedDW *dw = [[LEDAppliedDW alloc] init];
    if ([selectedColor.x floatValue] != [self.x floatValue]) {
        dw.slope = [NSNumber numberWithFloat:((selectedColor.y.floatValue - self.y.floatValue)/(selectedColor.x.floatValue - self.x.floatValue))];
        if ((dw.slope.floatValue <= 3.0) && (dw.slope.floatValue >= -3.0)) {
            if (selectedColor.x.floatValue < .333) dw.dominantWavelength = [NSNumber numberWithInteger:((self.c1.floatValue * dw.slope.floatValue) + self.c2.floatValue)];
            else if (dw.slope.floatValue > 0.0) dw.dominantWavelength = [NSNumber numberWithInteger:((self.c3.floatValue * dw.slope.floatValue) + self.c4.floatValue)]; 
            else dw.dominantWavelength = [NSNumber numberWithInteger:((self.c5.floatValue * powf(dw.slope.floatValue,3)) + (self.c6.floatValue * powf(dw.slope.floatValue,2)) + (self.c7.floatValue * dw.slope.floatValue) + self.c8.floatValue)];
        }
        else if (selectedColor.y.floatValue > self.y.floatValue) dw.dominantWavelength = self.verticalWavelength;
        else dw.dominantWavelength = [NSNumber numberWithInteger:-1];
    }
    else if (selectedColor.y.floatValue > self.y.floatValue) dw.dominantWavelength = self.verticalWavelength;
    else dw.dominantWavelength = [NSNumber numberWithInteger:-1];
    
    //find the minimum and maximum dominant wavelength of each color point in the adaptable light
    //find the 2 closest colors to the color point dominant wavelength
    //primary color array needs to be sorted in descending dominantWavelength order for colors not excluded from selection!  
    
    NSUInteger minWavelength = 1000;
    NSUInteger maxWavelength = 0;
    LEDApplied *closestColor = [[LEDApplied alloc] init];
    LEDApplied *secondClosestColor = [[LEDApplied alloc] init];
    //compare the dominant wavelength of the color point to the dominant wavelength of the primary colors to find the closest color    
    for (NSUInteger j = 0;j<self.sortedLSGCLightArray.count;j++) {
        if ([[self.sortedLSGCLightArray objectAtIndex:j] excludeFromSelection] == FALSE) {
            if ([[self.sortedDWPrimaryArray objectAtIndex:j] unsignedIntegerValue] < minWavelength) minWavelength = [[self.sortedDWPrimaryArray objectAtIndex:j] unsignedIntegerValue];
            if ([[self.sortedDWPrimaryArray objectAtIndex:j] unsignedIntegerValue] > maxWavelength) maxWavelength = [[self.sortedDWPrimaryArray objectAtIndex:j] unsignedIntegerValue];
        }
    }
    //find the closest colors to the dominant wavelength
    if (([dw.dominantWavelength unsignedIntegerValue] < minWavelength) || ([dw.dominantWavelength unsignedIntegerValue] > maxWavelength)) {
        //assign the closest color object of the white point object to point to the first primary color object in the primary color array
        
        for (NSUInteger j = 0;j<self.sortedLSGCLightArray.count;j++) {
            if ([[self.sortedLSGCLightArray objectAtIndex:j] excludeFromSelection] == FALSE) {
                closestColor.ledColor = [self.sortedLSGCLightArray objectAtIndex:j];
                break;
            }
        }
        for (NSUInteger j=self.sortedLSGCLightArray.count;j > 0;j--) {
            if ([[self.sortedLSGCLightArray objectAtIndex:(j-1)] excludeFromSelection] == FALSE) {
                secondClosestColor.ledColor = [self.sortedLSGCLightArray objectAtIndex:(j-1)];
                break;
            }
        }
        dw.dominantWavelength = [NSNumber numberWithUnsignedInteger:0];
        //dw.appliedColor = [[LEDApplied alloc] init];
        dw.combinedColors = [NSArray arrayWithObjects:closestColor, secondClosestColor, nil];
        dw.isCombinedColor = TRUE;
    }
    else {
        //find two primary color wavelengths that the picked color fits in between
        NSUInteger k;
        for (NSUInteger j = 0;j<(self.sortedLSGCLightArray.count-1);j++) {
            if ([[self.sortedLSGCLightArray objectAtIndex:j] excludeFromSelection] == FALSE) {
                for (k = (j+1);k<self.sortedLSGCLightArray.count;k++) {
                    if ([[self.sortedLSGCLightArray objectAtIndex:k] excludeFromSelection] == FALSE) break;
                }
                if (([dw.dominantWavelength unsignedIntegerValue] <= [[self.sortedDWPrimaryArray objectAtIndex:j] unsignedIntegerValue]) && ([dw.dominantWavelength unsignedIntegerValue] >= [[self.sortedDWPrimaryArray objectAtIndex:(j+1)] unsignedIntegerValue])) {
                    closestColor.ledColor = [self.sortedLSGCLightArray objectAtIndex:j];
                    secondClosestColor.ledColor = [self.sortedLSGCLightArray objectAtIndex:k];
                    //dw.appliedColor = [[LEDApplied alloc] init];
                    dw.combinedColors = [NSArray arrayWithObjects:closestColor, secondClosestColor, nil];
                    dw.isCombinedColor = TRUE;
                    break;
                }
            }
        }
    }
    
    float x1 = [[[[dw.combinedColors objectAtIndex:0] ledColor] x] floatValue];
    float y1 = [[[[dw.combinedColors objectAtIndex:0] ledColor] y] floatValue];
    float x2 = [[[[dw.combinedColors objectAtIndex:1] ledColor] x] floatValue];
    float y2 = [[[[dw.combinedColors objectAtIndex:1] ledColor] y] floatValue];
    
    float primaryColorSlope = (y2 - y1) / (x2 - x1);
    float primaryIntercept = y1 - (primaryColorSlope * x1);
    float xSecondary;
    if (dw.slope) {
        float b1 = selectedColor.y.floatValue - dw.slope.floatValue * selectedColor.x.floatValue;
        xSecondary = (b1 - primaryIntercept)/(primaryColorSlope - dw.slope.floatValue);        
    }
    else xSecondary = self.x.floatValue;
    //we now have two equations and 2 unknowns, solve for x and y
    float ySecondary = primaryColorSlope * xSecondary + primaryIntercept;
    //now find the distance between the secondary point and the primary color points
    float distance1 = sqrtf((ySecondary - y1)*(ySecondary - y1) + (xSecondary - x1)*(xSecondary - x1));
    float distance2 = sqrtf((ySecondary - y2)*(ySecondary - y2) + (xSecondary - x2)*(xSecondary - x2));
    //used for a variable color
    if (dw.dominantWavelength.unsignedIntegerValue == 0) {
        if (distance1 > distance2) dw.dominantWavelength = [NSNumber numberWithUnsignedInteger:1000];
    }
    float totalDistance = sqrtf((y2 - y1)*(y2 - y1) + (x2 - x1)*(x2 - x1));  
    if ((distance1 + distance2 - .02) <= totalDistance) {
        float xFactor = (distance2 * [[[[dw.combinedColors objectAtIndex:1] ledColor] bigY] floatValue]) / (distance1 * [[[[dw.combinedColors objectAtIndex:0] ledColor] bigY] floatValue]);
        xFactor = (xFactor/(xFactor + 1));
        float yFactor = 1 - xFactor; 
        float bigYSecondary = (xFactor * [[[[dw.combinedColors objectAtIndex:0] ledColor] bigY] floatValue]) + (yFactor * [[[[dw.combinedColors objectAtIndex:1] ledColor] bigY] floatValue]);
        //we now have one of the points needed to generate the matrices
        //the point we are trying to reach is the x,y of the white point
        //the point we have is xSecondary, ySecondary, bigYSecondary 
        //[[dw.combinedColor.combinedColors objectAtIndex:0] setPower:[NSNumber numberWithFloat:xFactor]];
        [[dw.combinedColors objectAtIndex:0] setFixedRatio:[NSNumber numberWithFloat:xFactor]];
        //[[dw.combinedColor.combinedColors objectAtIndex:1] setPower:[NSNumber numberWithFloat:yFactor]];
        [[dw.combinedColors objectAtIndex:1] setFixedRatio:[NSNumber numberWithFloat:yFactor]];
        LEDColor *color = [[LEDColor alloc] initWithx:[NSNumber numberWithFloat:xSecondary] andy:[NSNumber numberWithFloat:ySecondary] andY:[NSNumber numberWithFloat:bigYSecondary] andName:@"combined"];
        //[color completeLEDColorInfoWithDimension:dimension];
        dw.ledColor = color;
        dw.isCombinedColor = TRUE;
        
        //dw.powerArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:xFactor], [NSNumber numberWithFloat:yFactor],nil];
    }
    else dw.ledColor = nil;
    
    [self.dwColorArray addObject:dw];
}

- (void)removeLastDWColor {
    if (self.dwColorArray.count) [self.dwColorArray removeLastObject];
}

- (void)removeAllDWColors {
    self.dwColorArray = [[NSMutableArray alloc] init];
}

- (LEDAppliedDW *)getLastDWColor {
    return self.dwColorArray.lastObject;
}

- (BOOL)removeDWColorAtIndex:(NSUInteger)index {
    if (self.dwColorArray.count > index) {
        [self.dwColorArray removeObjectAtIndex:index];
        return TRUE;
    }
    return FALSE;
}

- (void)clearAllDWColorPowerOutputs {
    for (NSUInteger i=0;i<self.dwColorArray.count;i++) {
        [[self.dwColorArray objectAtIndex:i] findOutputPowerOfColorsWithStartingPowerFloat:0];
    }
}
@end
