//
//  LSGCLightingComm.h
//  
//
//  Created by Matthew Regan on 5/31/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PixelCommands.h"


@protocol LSGCLightingComm <NSObject>
@optional
- (void)sendDirectLabels:(NSArray *)array;
- (void)sendIntensityLabel:(UILabel *)intensity;
- (void)sendColorMixLabels:(NSArray *)array;
- (void)sendColorMixNumbers:(NSArray *)array;
- (void)sendIntensityNumber:(NSNumber *)intensity;
- (void)sendDirectNumbers:(NSArray *)array;
- (void)sendColorCode:(NSNumber *)colorCode;
- (void)sendIntensityCode:(NSNumber *)intensityCode;
- (void)sendWhiteMix:(NSArray *)whiteMix;
- (void)sendOnOff:(NSNumber *)onOff;
- (void)sendDataString:(NSData *)data;
- (void)sendDirectFadeFreq:(float)fadeFreq;
- (void)sendIntensityFadeFreq:(float)fadeFreq;
- (void)sendColorMixFadeFreq:(float)fadeFreq;
@end
