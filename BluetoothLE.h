//
//  BluetoothLE.h
//  TuneableLight
//
//  Created by Matthew Regan on 3/27/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>

//delegate definition
//defined in here are methods that another class can "listen" for if that class assigns the delegate of this class to itself
@protocol BluetoothLEDelegate
@optional
- (void)bluetoothCMStateChangedToOn:(BOOL)on;
- (void)finishedDiscoveringPeripherals:(UInt16)numberOfPeripherals;
- (void)peripheral:(CBPeripheral *)peripheral connected:(BOOL)connected;
- (void)servicesDiscoveredOfPeripheral:(CBPeripheral *)peripheral;
- (void)peripheralFullyDiscovered:(CBPeripheral *)peripheral;
- (void)characteristicValueWriteCompleted:(CBPeripheral *)peripheral;
@end


@interface BluetoothLE : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {}

@property (nonatomic, assign) id <BluetoothLEDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *peripherals;
@property (strong, nonatomic) CBCentralManager *cm;


- (int)controlSetup:(int)s;
- (void)initCBCentralManagerWithQueue:(dispatch_queue_t)queue;

- (int)findBLEPeripheralsForSeconds:(int)timeout withServices:(NSArray *)services;
- (void)connectPeripheral:(CBPeripheral *)peripheral withTimeout:(float)time;
- (void)discoverServices:(NSArray *)services ofPeripheral:(CBPeripheral *)peripheral withTimeout:(float)time;

- (void)cancelPeripheral:(CBPeripheral *)peripheral;
- (void)getAllCharacteristicsFromAllServicesOfPeripheral:(CBPeripheral *)p;
- (void)writeValue:(int)serviceUUID ofCharacteristicUUID:(int)characteristicUUID toPeripheral:(CBPeripheral *)p withData:(NSData *)data;
- (void)readValue:(int)serviceUUID ofCharacteristicUUID:(int)characteristicUUID fromPeripheral:(CBPeripheral *)p;
- (void)notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on;

@end
