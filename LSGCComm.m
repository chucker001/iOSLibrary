//
//  LSGCComm.m
//  AdaptableLight
//
//  Created by Matthew Regan on 5/22/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import "LSGCComm.h"
#import "PixelCommands.h"
#import "LSGCBLEComm.h"

#define LSGC_PASS_THROUGH_SERVICE_UUID  0xFFF0
#define LSGC_PASS_THROUGH_UUID          0xFFF1
#define CONNECT_DURATION        5

#define INTENSITY_MAX   65535
#define COLOR_MIX_MAX   65535

#define PRIZMA_TUNABLE_SERVICE_UUID     0xFFD0
#define LSGC_COLOR_INTENSITIES_UUID     0xFFD1

@interface LSGCComm() <LSGCCommDelegate> 
@property (strong, nonatomic) LSGCBLEComm *ble;
@end

@implementation LSGCComm

@synthesize delegate = _delegate;
@synthesize ble = _ble;

- (NSArray *)getServicesToDiscover {
    NSArray *services = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%X",PRIZMA_TUNABLE_SERVICE_UUID], nil];
    return services;
}

//Mandatory Delegate from BLE
//backward compatible for prizmaline
/*
- (NSArray *)getServicesToDiscover {
    NSArray *services = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%X",LSGC_PASS_THROUGH_SERVICE_UUID], nil];
    return services;
}
*/

- (void)connect {
    if ((self.ble) && ([self.ble readyToConnect])) [self commOn];
    else {
        self.ble = [[LSGCBLEComm alloc] init];
        self.ble.delegate = self;
        [self.ble setupComm];
    }
}

- (void)endConnection {
    [self.ble disconnectComm];
}

//BLE delegate
- (void)commReady:(BOOL)ready {
    [self.delegate connectionMade:ready];
}

//BLE delegate
- (void)commOn {
    NSArray *services = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%X",LSGC_PASS_THROUGH_SERVICE_UUID], nil];
    //only connect to services with the name WALL WASH
    [self.ble connectToBluetoothDevicesWithServices:services andDuration:CONNECT_DURATION];
}

//backward compatible for prizmaline
/*
- (void)commOn {
    NSArray *services = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%X",PRIZMA_TUNABLE_SERVICE_UUID], nil];
    [self.ble connectToBluetoothDevicesWithServices:services andDuration:5];
}
*/

//send the data
//intensity received is a float between 0 and 1
- (void)sendIntensity:(UILabel *)intensity {
    Byte data[3];
    data[0] = COMMAND_INTENSITY_16BIT;
    data[1] = intensity.text.floatValue/100 * INTENSITY_MAX;
    data[2] = intensity.text.floatValue/100 * INTENSITY_MAX / 256;
    NSData *d = [NSData dataWithBytes:data length:sizeof(data)];
    [self sendData:d];
}

//color data received are floats between 0 and 1
- (void)sendColorMix:(NSArray *)colorArray {
    Byte data[9];
    data[0] = COMMAND_COLOR_MIX_16BIT;
    for (NSUInteger i=0;i<colorArray.count;i++) {
        data[2*i+1] = [[[colorArray objectAtIndex:i] text] floatValue]*COLOR_MIX_MAX;
        data[2*i+2] = [[[colorArray objectAtIndex:i] text] floatValue]*COLOR_MIX_MAX/256;
    }
    NSData *d = [NSData dataWithBytes:data length:sizeof(data)];
    [self sendData:d];
}

//THE ARRAY IS ASSUMED TO BE A UILABEL ARRAY
- (void)sendColorsDirect:(NSArray *)array {
    Byte data[17];
    data[0] = COMMAND_COLORS_DIRECT;
    for (NSUInteger i=0;i<array.count;i++) {
        data[2*i + 1] = [[[array objectAtIndex:i] text] floatValue]/100*COLOR_MIX_MAX;
        data[2*i + 2] = [[[array objectAtIndex:i] text] floatValue]/100*COLOR_MIX_MAX/256;
    }
    NSData *d = [NSData dataWithBytes:data length:sizeof(data)];
    [self sendData:d];
}

- (void)sendData:(NSData *)data {
    for (UInt16 i = 0;i<[self.ble.ble.peripherals count];i++) {
        [self.ble writeCharValue:data toCharacteristic:LSGC_PASS_THROUGH_UUID ofService:LSGC_PASS_THROUGH_SERVICE_UUID andPeripheral:i];
    }
}

- (void)string:(NSString *)string ToHexChars:(Byte *)output {
    *output = ((Byte)[string intValue] / 16);
    if (*output > 9) *output += 0x37;
    else *output += 0x30;
    *(output+1) = ((Byte)[string intValue] & 0x0F);
    if (*(output+1) > 9) *(output+1) += 0x37;
    else *(output+1) += 0x30;
}

- (void)sendColor1:(NSString *)color1 andColor2:(NSString *)color2 andColor3:(NSString *)color3 andColor4:(NSString *)color4 {
    Byte stringChar[8];
    [self string:color1 ToHexChars:stringChar];
    [self string:color2 ToHexChars:&stringChar[2]];
    [self string:color3 ToHexChars:&stringChar[4]];
    [self string:color4 ToHexChars:&stringChar[6]];
    NSData *d = [[NSData alloc] initWithBytes:stringChar length:8];
    for (UInt16 i = 0;i<[self.ble.ble.peripherals count];i++) {
        [self.ble writeCharValue:d toCharacteristic:LSGC_COLOR_INTENSITIES_UUID ofService:PRIZMA_TUNABLE_SERVICE_UUID andPeripheral:i];
    }
}

- (void)peripheralsDiscovered:(UInt16)peripherals {
    
}

- (void)queueZeroed:(UInt16)peripheralNum {
    
}

@end
