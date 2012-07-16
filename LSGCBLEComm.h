//
//  LSGCBLEComm.h
//  PrizmalineTunable
//
//  Created by Matthew Regan on 4/16/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BluetoothLE.h"

@protocol LSGCCommDelegate 
- (NSArray *)getServicesToDiscover;
@optional
- (void)commReady:(BOOL)ready;
- (void)commOn;
- (void)queueZeroed:(UInt16)peripheralNum;
- (void)peripheralsDiscovered:(UInt16)peripherals;
@end

@interface LSGCBLEComm : NSObject <BluetoothLEDelegate> {}
@property (nonatomic, assign) id <LSGCCommDelegate> delegate;
@property (strong, retain) BluetoothLE *ble;

- (void)writeCharValue:(NSData *)data toCharacteristic:(UInt16)charID ofService:(UInt16)serviceID andPeripheral:(UInt16)peripheral;
- (void)connectToBluetoothDevicesWithServices:(NSArray *)services andDuration:(UInt16)seconds;
- (void)setupComm;
- (void)disconnectComm;
- (BOOL)readyToConnect;

@end
