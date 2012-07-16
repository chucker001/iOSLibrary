//
//  CustomMath.m
//  Adaptable
//
//  Created by Matthew Regan on 6/18/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import "CustomMath.h"

@implementation CustomMath

+ (NSArray *)normalizeArray:(NSArray *)array {
    float outputTotal = 0;
    for (NSUInteger i=0;i<array.count;i++) {
        outputTotal += [[array objectAtIndex:i] floatValue];
    }
    NSMutableArray *outputArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSUInteger i=0;i<array.count;i++) {
        [outputArray addObject:[NSNumber numberWithFloat:([[array objectAtIndex:i] floatValue]/outputTotal)]];
    }
    return outputArray;
}

+ (NSArray *)maximizeArray:(NSArray *)array {
    float maxValue = 0;
    for (NSUInteger i=0;i<array.count;i++) {
        if ([[array objectAtIndex:i] floatValue] > maxValue) {
            maxValue = [[array objectAtIndex:i] floatValue];
        }
    }
    if (maxValue == 0) return nil;
    NSMutableArray *outputArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSUInteger i=0;i<array.count;i++) {
        [outputArray addObject:[NSNumber numberWithFloat:([[array objectAtIndex:i] floatValue] / maxValue)]];
    }
    return outputArray;
}

+ (NSArray *)addObject:(id)object toArray:(NSArray *)array {
    NSMutableArray *mutableArray = [array mutableCopy];
    [mutableArray addObject:object];
    return mutableArray;
}

+ (NSArray *)scaleArray:(NSArray *)array usingNumber:(NSNumber *)number {
    NSMutableArray *outputArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSUInteger i=0;i<array.count;i++) {
        [outputArray addObject:[NSNumber numberWithFloat:([[array objectAtIndex:i] floatValue]/ number.floatValue)]];
    }
    return outputArray;
}

+ (float)findMaxValueFromArray:(NSArray *)array {
    float maxValue = 0;
    for (NSUInteger i=0;i<array.count;i++) {
        if ([[array objectAtIndex:i] floatValue] > maxValue) maxValue = [[array objectAtIndex:i] floatValue];
    }
    return maxValue;
}

+ (BOOL)arrayContainsNegativeValue:(NSArray *)array {
    for (NSUInteger i=0;i<array.count;i++) {
        if ([[array objectAtIndex:i] floatValue] < 0) return TRUE;
    }
    return FALSE;
}

+ (NSArray *)swapIndex1:(NSUInteger)index1 forIndex2:(NSUInteger)index2 inArray:(NSArray *)array {
    NSMutableArray *swappedArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSUInteger i=0;i<array.count;i++) {
        if (i == index1) [swappedArray addObject:[array objectAtIndex:index2]];
        else if (i == index2) [swappedArray addObject:[array objectAtIndex:index1]];
        else [swappedArray addObject:[array objectAtIndex:i]];
    }
    return swappedArray;
}

+ (void)sortArray:(NSArray *)array inRecursiveDescendingOrderFromIndex:(NSUInteger)index {
    if (index == array.count-1) return;
    NSUInteger maxIndex = index;
    for (NSUInteger i=index;i<array.count;i++) {
        if ([[array objectAtIndex:i] floatValue] > [[array objectAtIndex:maxIndex]floatValue]) maxIndex = i;
    }
    if (index != maxIndex) array = [CustomMath swapIndex1:index forIndex2:maxIndex inArray:array];
    [CustomMath sortArray:array inRecursiveDescendingOrderFromIndex:index++];
}

+ (NSArray *)sortArray:(NSArray *)array inDescendingOrderFromIndex:(NSUInteger)index {
    [CustomMath sortArray:array inRecursiveDescendingOrderFromIndex:0];
    return array;
}

+ (NSArray *)sRGBToLinear:(NSArray *)array {
    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSUInteger i=0;i<array.count;i++) {
        float linearValue = [[array objectAtIndex:i] floatValue];
        if (linearValue <= .04045) linearValue = linearValue / 12.92;
        else linearValue = powf(((linearValue + .055)/1.055),2.4);
        [returnArray addObject:[NSNumber numberWithFloat:linearValue]];
    }
    return returnArray;
}

@end
