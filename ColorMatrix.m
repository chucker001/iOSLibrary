//
//  ColorMatrix.m
//  TuneableLight
//
//  Created by Matthew Regan on 3/16/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import "ColorMatrix.h"

@interface ColorMatrix () 
@property (strong, nonatomic) NSArray *colorsArray;
@property (strong, nonatomic) NSArray *inverseColorsArray;
@end

@implementation ColorMatrix
@synthesize colorsArray = _colorsArray;
@synthesize inverseColorsArray = _inverseColorsArray;
@synthesize colorPointCount = _colorPointCount;
@synthesize appliedColorArray = _appliedColorArray;

- (id)init {
    self = [super init];
    return self;
}

//sRGB
//red x,y,z .64,.33,.03  => Y/y = X+Y+Z => X = xY/y => Z = (1-x-y)Y/y
//green x,y,z .3,.6,.1
//blue x,y,z .15,.06,.79
/*
- (id)initWithSRGB {
    //{{1.939,1.33,.533},{1.0,2.66,.213},{.091,.443,2.805}};
    self = [self init];
    NSNumber *rX = [NSNumber numberWithFloat:1.939];
    NSNumber *rY = [NSNumber numberWithFloat:1.0];
    NSNumber *rZ = [NSNumber numberWithFloat:.091];
    
    NSNumber *gX = [NSNumber numberWithFloat:1.33];
    NSNumber *gY = [NSNumber numberWithFloat:2.66];
    NSNumber *gZ = [NSNumber numberWithFloat:.443];
     
    NSNumber *bX = [NSNumber numberWithFloat:.533];
    NSNumber *bY = [NSNumber numberWithFloat:.213];
    NSNumber *bZ = [NSNumber numberWithFloat:2.805];
    
    NSArray *array1 = [[NSArray alloc] initWithObjects:rX,rY,rZ, nil];
    NSArray *array2 = [[NSArray alloc] initWithObjects:gX,gY,gZ, nil];
    NSArray *array3 = [[NSArray alloc] initWithObjects:bX,bY,bZ, nil];
    self.colorsArray = [NSArray arrayWithObjects:array1,array2,array3, nil];
    return self;
}
*/
- (id)initWithSRGB {
    self = [self init];
    NSNumber *rX = [NSNumber numberWithFloat:.4124];
    NSNumber *rY = [NSNumber numberWithFloat:.2126];
    NSNumber *rZ = [NSNumber numberWithFloat:.0193];
    
    NSNumber *gX = [NSNumber numberWithFloat:.3576];
    NSNumber *gY = [NSNumber numberWithFloat:.7152];
    NSNumber *gZ = [NSNumber numberWithFloat:.1192];
    
    NSNumber *bX = [NSNumber numberWithFloat:.1805];
    NSNumber *bY = [NSNumber numberWithFloat:.0722];
    NSNumber *bZ = [NSNumber numberWithFloat:.9505];
    
    NSArray *array1 = [[NSArray alloc] initWithObjects:rX,rY,rZ, nil];
    NSArray *array2 = [[NSArray alloc] initWithObjects:gX,gY,gZ, nil];
    NSArray *array3 = [[NSArray alloc] initWithObjects:bX,bY,bZ, nil];
    self.colorsArray = [NSArray arrayWithObjects:array1,array2,array3, nil];
    return self;
}


/*
- (void)addColor:(NSArray *)array {    
    if (self.colorsArray) {
        NSMutableArray *colorsArray = [self.colorsArray mutableCopy];
        [colorsArray addObject:array];
        self.colorsArray = colorsArray;
    }
    else {
        NSMutableArray *colorsArray = [NSMutableArray arrayWithCapacity:1];
        [colorsArray addObject:array];
        self.colorsArray = colorsArray;
    }
    self.colorPointCount = self.colorsArray.count;
}
*/

- (void)addColor:(id)color {
    NSMutableArray *appliedColorArray;
    if (self.appliedColorArray) {
        //NSMutableArray *colorsArray = [self.colorsArray mutableCopy];
        //[colorsArray addObject:color.bigXYZArray];
        //self.colorsArray = colorsArray;
        appliedColorArray = [self.appliedColorArray mutableCopy];
        if ([color isKindOfClass:[LEDColor class]]) [appliedColorArray addObject:[[LEDApplied alloc] initWithLedColor:color]];
        else if ([color isKindOfClass:[LEDApplied class]]) [appliedColorArray addObject:color];
    }
    else {
        //NSMutableArray *colorsArray = [NSMutableArray arrayWithCapacity:1];
        //[colorsArray addObject:color.bigXYZArray];
        //self.colorsArray = colorsArray;
        appliedColorArray = [NSMutableArray arrayWithCapacity:1];
        if ([color isKindOfClass:[LEDColor class]]) [appliedColorArray addObject:[[LEDApplied alloc] initWithLedColor:color]];
        else if ([color isKindOfClass:[LEDApplied class]]) [appliedColorArray addObject:color];
    }
    self.appliedColorArray = appliedColorArray;
    self.colorPointCount = self.appliedColorArray.count;
}

- (void)addSubtractiveColor:(id)color {
    [self addColor:color];
    [[self.appliedColorArray lastObject] setIsSubtractive:TRUE];
}

- (NSArray *)negateArray:(NSArray *)array {
    NSMutableArray *returnArray = [array mutableCopy];
    for (NSUInteger i=0;i<array.count;i++) {
        float value = [[array objectAtIndex:i] floatValue] * -1;
        [returnArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:value]];
    }
    return returnArray;
}

- (void)createColorsArrayWithDimension:(NSUInteger)dimension {
    if (!self.appliedColorArray) return;
    NSMutableArray *colorsArray = [NSMutableArray arrayWithCapacity:self.appliedColorArray.count];
    for (NSUInteger i=0;i<self.appliedColorArray.count;i++) {
        NSArray *colorArray = [[[self.appliedColorArray objectAtIndex:i] ledColor] completeLEDColorInfoWithDimension:dimension];
        if ([[self.appliedColorArray objectAtIndex:i] isSubtractive]) colorArray = [self negateArray:colorArray];
        [colorsArray addObject:colorArray];
    }
    self.colorsArray = colorsArray;
}

- (NSArray *)multiplyDirectOutputFromInput:(NSArray *)array {
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:[[self.colorsArray objectAtIndex:0] count]];
    for (NSInteger i=0;i<[[self.colorsArray objectAtIndex:0] count];i++) {
        float returnNumber = 0;
        for (NSInteger j=0;j<self.colorsArray.count;j++) {
            returnNumber += ([[[self.colorsArray objectAtIndex:j] objectAtIndex:i] floatValue] * [[array objectAtIndex:j] floatValue]);
        }
        [returnArray addObject:[NSNumber numberWithFloat:returnNumber]];
    }
    return returnArray;
}

//multiply an RGB color matrix x RGB to obtain XYZ
- (NSArray *)multiplyRGBColorArrayToXYZ:(NSArray *)array {
    [self createColorsArrayWithDimension:self.appliedColorArray.count];
    return [self multiplyDirectOutputFromInput:array];
}

- (NSArray *)multiplyXYToXYFromInputArray:(NSArray *)array {
    [self createColorsArrayWithDimension:3];
    return [self multiplyDirectOutputFromInput:array];
}

- (void)createInverseMatrix {
    [self createColorsArrayWithDimension:self.appliedColorArray.count];
    
    NSMutableArray *inverseMatrix = [NSMutableArray arrayWithCapacity:self.colorsArray.count];
    NSMutableArray *colorMatrix = [NSMutableArray arrayWithCapacity:self.colorsArray.count];
    NSInteger i,j;
    for (i=0;i<self.colorsArray.count;i++) {
        NSMutableArray *inverseColumn = [NSMutableArray arrayWithCapacity:self.colorsArray.count];
        for (j=0;j<self.colorsArray.count;j++) {
            if (j==i) [inverseColumn addObject:[NSNumber numberWithFloat:1]];
            else [inverseColumn addObject:[NSNumber numberWithFloat:0]];
        }
        [inverseMatrix addObject:inverseColumn];
        [colorMatrix addObject:[[self.colorsArray objectAtIndex:i] mutableCopy]];
    }    
    //transform the colorsArray into the identity matrix, performing the same operations on the inverseMatrix
    //what remains in the inverseMatrix is in fact the inverse matrix
    float multiplyFactor;
    for (i=0;i<inverseMatrix.count;i++) {
        for (j=0;j<inverseMatrix.count;j++) {
            if (i==j) {
                multiplyFactor = 1/[[[colorMatrix objectAtIndex:i] objectAtIndex:j] floatValue];
                for (NSInteger k=0;k<inverseMatrix.count;k++) {
                    if (k >= i) {
                        [[colorMatrix objectAtIndex:k] replaceObjectAtIndex:j withObject:[NSNumber numberWithFloat:([[[colorMatrix objectAtIndex:k] objectAtIndex:j] floatValue]* multiplyFactor)]];
                    }
                    [[inverseMatrix objectAtIndex:k] replaceObjectAtIndex:j withObject:[NSNumber numberWithFloat:([[[inverseMatrix objectAtIndex:k] objectAtIndex:j] floatValue]* multiplyFactor)]];
                }                
            }
            else if ([[[colorMatrix objectAtIndex:i] objectAtIndex:j] floatValue] != 0) {
                multiplyFactor = [[[colorMatrix objectAtIndex:i] objectAtIndex:j] floatValue] / [[[colorMatrix objectAtIndex:i] objectAtIndex:i] floatValue] * -1;
                for (NSInteger k=0;k<inverseMatrix.count;k++) {
                    if (k >= i) {
                        [[colorMatrix objectAtIndex:k] replaceObjectAtIndex:j withObject:[NSNumber numberWithFloat:(([[[colorMatrix objectAtIndex:k] objectAtIndex:i] floatValue] * multiplyFactor) + [[[colorMatrix objectAtIndex:k] objectAtIndex:j] floatValue])]];
                    }
                    [[inverseMatrix objectAtIndex:k] replaceObjectAtIndex:j withObject:[NSNumber numberWithFloat:(([[[inverseMatrix objectAtIndex:k] objectAtIndex:i] floatValue] * multiplyFactor) + [[[inverseMatrix objectAtIndex:k] objectAtIndex:j] floatValue])]];
                }
            }
        }
    }
    
    self.inverseColorsArray = inverseMatrix;
    /*    
     float det = [[[self.colorsArray objectAtIndex:0] objectAtIndex:0] floatValue] * (([[[self.colorsArray objectAtIndex:1] objectAtIndex:1] floatValue] * [[[self.colorsArray objectAtIndex:2] objectAtIndex:2] floatValue]) - ([[[self.colorsArray objectAtIndex:1] objectAtIndex:2] floatValue] * [[[self.colorsArray objectAtIndex:2] objectAtIndex:1] floatValue]));
     det -= [[[self.colorsArray objectAtIndex:1] objectAtIndex:0] floatValue] * (([[[self.colorsArray objectAtIndex:0] objectAtIndex:1] floatValue] * [[[self.colorsArray objectAtIndex:2] objectAtIndex:2] floatValue]) - ([[[self.colorsArray objectAtIndex:0] objectAtIndex:2] floatValue] * [[[self.colorsArray objectAtIndex:2] objectAtIndex:1] floatValue]));
     det += [[[self.colorsArray objectAtIndex:2] objectAtIndex:0] floatValue] * (([[[self.colorsArray objectAtIndex:0] objectAtIndex:1] floatValue] * [[[self.colorsArray objectAtIndex:1] objectAtIndex:2] floatValue]) - ([[[self.colorsArray objectAtIndex:0] objectAtIndex:2] floatValue] * [[[self.colorsArray objectAtIndex:1] objectAtIndex:1] floatValue]));
     
     float val1 = (([[[self.colorsArray objectAtIndex:1] objectAtIndex:1] floatValue] * [[[self.colorsArray objectAtIndex:2] objectAtIndex:2] floatValue]) - ([[[self.colorsArray objectAtIndex:2] objectAtIndex:1] floatValue] * [[[self.colorsArray objectAtIndex:1] objectAtIndex:2] floatValue])) / det;
     float val2 = (([[[self.colorsArray objectAtIndex:2] objectAtIndex:1] floatValue] * [[[self.colorsArray objectAtIndex:0] objectAtIndex:2] floatValue]) - ([[[self.colorsArray objectAtIndex:0] objectAtIndex:1] floatValue] * [[[self.colorsArray objectAtIndex:2] objectAtIndex:2] floatValue])) / det;
     float val3 = (([[[self.colorsArray objectAtIndex:0] objectAtIndex:1] floatValue] * [[[self.colorsArray objectAtIndex:1] objectAtIndex:2] floatValue]) - ([[[self.colorsArray objectAtIndex:1] objectAtIndex:1] floatValue] * [[[self.colorsArray objectAtIndex:0] objectAtIndex:2] floatValue])) / det;
     NSArray *inverse1Array = [NSArray arrayWithObjects:[NSNumber numberWithFloat:val1],[NSNumber numberWithFloat:val2],[NSNumber numberWithFloat:val3], nil];
     
     val1 = (([[[self.colorsArray objectAtIndex:2] objectAtIndex:0] floatValue] * [[[self.colorsArray objectAtIndex:1] objectAtIndex:2] floatValue]) - ([[[self.colorsArray objectAtIndex:1] objectAtIndex:0] floatValue] * [[[self.colorsArray objectAtIndex:2] objectAtIndex:2] floatValue])) / det;
     val2 = (([[[self.colorsArray objectAtIndex:0] objectAtIndex:0] floatValue] * [[[self.colorsArray objectAtIndex:2] objectAtIndex:2] floatValue]) - ([[[self.colorsArray objectAtIndex:2] objectAtIndex:0] floatValue] * [[[self.colorsArray objectAtIndex:0] objectAtIndex:2] floatValue])) / det;
     val3 = (([[[self.colorsArray objectAtIndex:1] objectAtIndex:0] floatValue] * [[[self.colorsArray objectAtIndex:0] objectAtIndex:2] floatValue]) - ([[[self.colorsArray objectAtIndex:0] objectAtIndex:0] floatValue] * [[[self.colorsArray objectAtIndex:1] objectAtIndex:2] floatValue])) / det;
     NSArray *inverse2Array = [NSArray arrayWithObjects:[NSNumber numberWithFloat:val1],[NSNumber numberWithFloat:val2],[NSNumber numberWithFloat:val3], nil];
     
     val1 = (([[[self.colorsArray objectAtIndex:1] objectAtIndex:0] floatValue] * [[[self.colorsArray objectAtIndex:2] objectAtIndex:1] floatValue]) - ([[[self.colorsArray objectAtIndex:2] objectAtIndex:0] floatValue] * [[[self.colorsArray objectAtIndex:1] objectAtIndex:1] floatValue])) / det;
     val2 = (([[[self.colorsArray objectAtIndex:2] objectAtIndex:0] floatValue] * [[[self.colorsArray objectAtIndex:0] objectAtIndex:1] floatValue]) - ([[[self.colorsArray objectAtIndex:0] objectAtIndex:0] floatValue] * [[[self.colorsArray objectAtIndex:2] objectAtIndex:1] floatValue])) / det;
     val3 = (([[[self.colorsArray objectAtIndex:0] objectAtIndex:0] floatValue] * [[[self.colorsArray objectAtIndex:1] objectAtIndex:1] floatValue]) - ([[[self.colorsArray objectAtIndex:1] objectAtIndex:0] floatValue] * [[[self.colorsArray objectAtIndex:0] objectAtIndex:1] floatValue])) / det;
     NSArray *inverse3Array = [NSArray arrayWithObjects:[NSNumber numberWithFloat:val1],[NSNumber numberWithFloat:val2],[NSNumber numberWithFloat:val3], nil];
     
     self.inverseColorsArray = [NSArray arrayWithObjects:inverse1Array,inverse2Array,inverse3Array, nil];
     */    
}

- (NSArray *)multiplyXYZColorArrayToRGB:(NSArray *)array {
    if (!self.appliedColorArray) return nil;
    //if (!self.inverseColorsArray) [self createInverseMatrix];
    [self createInverseMatrix];
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:[self.inverseColorsArray count]];
    for (NSInteger i=0;i<self.inverseColorsArray.count;i++) {
        float returnNumber = 0;
        for (NSInteger j=0;j<self.inverseColorsArray.count;j++) {
            returnNumber += ([[[self.inverseColorsArray objectAtIndex:j] objectAtIndex:i] floatValue] * [[array objectAtIndex:j] floatValue]);
        }
        [returnArray addObject:[NSNumber numberWithFloat:returnNumber]];
    }
    return returnArray;
}

- (void)setFixedRatios:(NSArray *)fixedRatioArray {
    for (NSUInteger i=0;i<self.colorPointCount;i++) {
        [[self.appliedColorArray objectAtIndex:i] setPower:[fixedRatioArray objectAtIndex:i]];
    }
}

- (LEDColor *)getLEDColorFromRGBArray:(NSArray *)array {
    NSArray *xyzArray = [self multiplyRGBColorArrayToXYZ:array];
    LEDColor *returnColor = [[LEDColor alloc] init];
    [returnColor getxyYFromXYZArray:xyzArray];
    return returnColor;
}

@end
