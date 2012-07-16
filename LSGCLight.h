//
//  LSGCLight.h
//  DirectDriver
//
//  Created by Matthew Regan on 6/14/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSGCLight : NSObject 
@property (nonatomic, readonly) NSArray *colorArray;
@property (nonatomic, readonly) NSArray *colorOrderArray;
@property (nonatomic, readonly) BOOL isDutyCycleSum100;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *version;

- (id)initWithLight:(NSString *)type andVersion:(NSString *)version;
//used with a UIPicker
+ (NSArray *)getLightOptions;
+ (NSArray *)getVersionOptionsFromLight:(NSString *)light;
@end
