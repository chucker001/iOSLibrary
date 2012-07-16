//
//  LEDColor.h
//  TuneableLight
//
//  Created by Matthew Regan on 3/16/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LEDColor : NSObject

@property (strong, readonly) NSNumber *x;
@property (strong, readonly) NSNumber *y;
@property (strong, nonatomic) NSNumber *bigY;
@property (strong, nonatomic) NSString *colorName;
@property BOOL excludeFromSelection;

- (id)init;
- (id)initWithx:(NSNumber *)x andy:(NSNumber *)y andY:(NSNumber *)bigY;
- (id)initWithx:(NSNumber *)x andy:(NSNumber *)y andY:(NSNumber *)bigY andName:(NSString *)name;
- (NSArray *)completeLEDColorInfoWithDimension:(NSUInteger)dimension;
- (void)getxyYFromXYZArray:(NSArray *)array;

@end
