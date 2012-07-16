//
//  CustomMath.h
//  Adaptable
//
//  Created by Matthew Regan on 6/18/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomMath : NSObject

+ (NSArray *)normalizeArray:(NSArray *)array;
+ (NSArray *)maximizeArray:(NSArray *)array;
+ (NSArray *)addObject:(id)object toArray:(NSArray *)array;
+ (NSArray *)scaleArray:(NSArray *)array usingNumber:(NSNumber *)number;
+ (float)findMaxValueFromArray:(NSArray *)array;
+ (BOOL)arrayContainsNegativeValue:(NSArray *)array;
+ (NSArray *)sortArray:(NSArray *)array inDescendingOrderFromIndex:(NSUInteger)index;
+ (NSArray *)sRGBToLinear:(NSArray *)array;
@end
