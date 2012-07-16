//
//  LSGCComm.h
//  AdaptableLight
//
//  Created by Matthew Regan on 5/22/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LSGCComDelegate 
@optional
- (void)connectionMade:(BOOL)made;
@end

@interface LSGCComm : NSObject
@property (nonatomic, assign) id <LSGCComDelegate> delegate;

- (void)connect;
- (void)endConnection;
- (void)sendIntensity:(UILabel *)intensity;
- (void)sendColorMix:(NSArray *)colorArray;
- (void)sendColorsDirect:(NSArray *)array;

//prizmaline
- (void)sendColor1:(NSString *)color1 andColor2:(NSString *)color2 andColor3:(NSString *)color3 andColor4:(NSString *)color4;
@end
