//
//  LSGCBLEComm.m
//  PrizmalineTunable
//
//  Created by Matthew Regan on 4/16/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import "LSGCBLEComm.h"
#import "BluetoothQueue.h"

#define PERIPHERAL_DISCOVERED           0
#define PERIPHERAL_CONNECTED            2
#define PERIPHERAL_DISCONNECTED         1
#define PERIPHERAL_READY                3

@interface LSGCBLEComm()
@property (nonatomic, strong) NSMutableArray *peripheralStatus;
@property (nonatomic, strong) NSMutableArray *pendingWrites;
@property (nonatomic, strong) NSMutableArray *queues;
@end

@implementation LSGCBLEComm
@synthesize ble = _ble;
@synthesize delegate = _delegate;
@synthesize peripheralStatus = _peripheralsFullyDiscovered;
@synthesize pendingWrites = _pendingWrites;
@synthesize queues = _queues;

//BLE DELEGATE, called when CBManager is initialized
- (void)bluetoothCMStateChangedToOn:(BOOL)on {
    //discover peripherals
    if (on) [self.delegate commOn];
    else [self.delegate commReady:FALSE];
}

//two step process
//first, discover peripherals
//second, connect to peripherals (see bluetooth peripheral finished searching)
- (void)connectToBluetoothDevicesWithServices:(NSArray *)services andDuration:(UInt16)seconds {
    [self.ble findBLEPeripheralsForSeconds:seconds withServices:services];
}

- (void)initQueuesWithSize:(UInt16)size {
    self.queues = [NSMutableArray arrayWithCapacity:size];
    BluetoothQueue *queue = [[BluetoothQueue alloc] init];
    queue.sent = TRUE;
    for (UInt16 i = 0;i<size;i++) [self.queues addObject:queue];
}

//BLE DELEGATE
//called when the search for bluetooth peripherals has finished
- (void)finishedDiscoveringPeripherals:(UInt16)numberOfPeripherals {
    //send a delegate method to the view controller indicating that a bluetooth link is made
    if (numberOfPeripherals == 0) [self.delegate commReady:FALSE];
    else {
        self.peripheralStatus = [NSMutableArray arrayWithCapacity:numberOfPeripherals];
        self.pendingWrites = [NSMutableArray arrayWithCapacity:numberOfPeripherals];
        [self initQueuesWithSize:numberOfPeripherals];
        for (UInt16 i = 0;i<numberOfPeripherals;i++) {
            [self.pendingWrites addObject:[NSNumber numberWithUnsignedInt:0]];
            [self.peripheralStatus addObject:[NSNumber numberWithUnsignedInt:PERIPHERAL_DISCOVERED]];
            [self.ble connectPeripheral:[self.ble.peripherals objectAtIndex:i] withTimeout:10.0];
        }
        [self.delegate peripheralsDiscovered:numberOfPeripherals];
    }
}

- (void)checkStatusOfAllPeripherals {
    UInt16 peripheralsDisconnected = 0;
    for (UInt16 i=0;i<self.ble.peripherals.count;i++) {
        if ([[self.peripheralStatus objectAtIndex:i] unsignedIntValue] == PERIPHERAL_DISCOVERED) return;
        if ([[self.peripheralStatus objectAtIndex:i] unsignedIntValue] == PERIPHERAL_CONNECTED) return;
        if ([[self.peripheralStatus objectAtIndex:i] unsignedIntValue] == PERIPHERAL_DISCONNECTED) peripheralsDisconnected++;
    }
    if (peripheralsDisconnected == self.ble.peripherals.count) [self.delegate commReady:FALSE];
    else [self.delegate commReady:TRUE];
}

//BLE DELEGATE, peripheral connection
//if a peripheral is disconnected, make sure there is still at least one peripheral connected
//if a peripheral is connected, mark it as such and discover its services
- (void) peripheral:(CBPeripheral *)peripheral connected:(BOOL)connected {
    UInt16 i;
    for (i=0;i<self.ble.peripherals.count;i++) {
        if (peripheral == [self.ble.peripherals objectAtIndex:i]) {
            if (connected) {
                //NSArray *services = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%X",WALL_WASH_SERVICE_UUID],[NSString stringWithFormat:@"%X",LSGC_BASIC_SERVICE_UUID],nil];
                NSArray *services = [self.delegate getServicesToDiscover];
                [self.peripheralStatus replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:PERIPHERAL_CONNECTED]];
                [self.ble discoverServices:services ofPeripheral:peripheral withTimeout:10.0];
            }
            else [self.peripheralStatus replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:PERIPHERAL_DISCONNECTED]];
            break;
        }
    }
    if (!connected) {
        [self checkStatusOfAllPeripherals];
    }
    
}

//BLE DELEGATE, services for peripheral discovered
- (void)servicesDiscoveredOfPeripheral:(CBPeripheral *)peripheral {
    [self.ble getAllCharacteristicsFromAllServicesOfPeripheral:peripheral];
}

//BLE DELEGATE, all characteristics of all services of a peripheral discovered
- (void)peripheralFullyDiscovered:(CBPeripheral *)peripheral {
    UInt16 i;
    for (i = 0;i<self.ble.peripherals.count;i++) {
        if (peripheral == [self.ble.peripherals objectAtIndex:i]) break;
    }
    [self.peripheralStatus replaceObjectAtIndex:i withObject:[NSNumber numberWithUnsignedInt:PERIPHERAL_READY]];
    //check to see if all peripherals are either ready or disconnected
    [self checkStatusOfAllPeripherals];
}

- (void)setupComm {
    self.ble = [[BluetoothLE alloc] init];
    self.ble.delegate = self;
    [self.ble controlSetup:1];    
}

- (void)disconnectComm {
    if (self.ble.peripherals) {
        for (UInt16 i = 0;i<self.ble.peripherals.count;i++) {
            if (([self.ble.peripherals objectAtIndex:i]) && ([[self.ble.peripherals objectAtIndex:i] isConnected])) [self.ble cancelPeripheral:[self.ble.peripherals objectAtIndex:i]];
        }
    }
}

//checks to see if the core bluetooth manager is on
- (BOOL)readyToConnect {
    if (self.ble) {
        if (self.ble.cm.state == CBCentralManagerStatePoweredOn) return TRUE;
        else return FALSE;
    }
    else return FALSE;
}

- (void)writeCharValue:(NSData *)data toCharacteristic:(UInt16)charID ofService:(UInt16)serviceID andPeripheral:(UInt16)peripheral {
    if ([[self.ble.peripherals objectAtIndex:peripheral] isConnected]) {
        if ([[self.pendingWrites objectAtIndex:peripheral] unsignedIntValue] < 3) {
            [self.ble writeValue:serviceID ofCharacteristicUUID:charID toPeripheral:[self.ble.peripherals objectAtIndex:peripheral] withData:data];
            [self.pendingWrites replaceObjectAtIndex:peripheral withObject:[NSNumber numberWithUnsignedInt:([[self.pendingWrites objectAtIndex:peripheral] unsignedIntValue] + 1)]];
            //NSLog(@"Pending %d",[[self.pendingWrites objectAtIndex:peripheral] unsignedIntValue]);
        }
        else {
            //place the request in a holding area, the holding area needs the data and the three IDs
            BluetoothQueue *queue = [[BluetoothQueue alloc] init];
            queue.sent = FALSE;
            queue.serviceIDNumber = serviceID;
            queue.characteristicIDNumber = charID;
            queue.data = data;
            queue.peripheralNumber = peripheral;
            [self.queues insertObject:queue atIndex:peripheral];
        }
    }
}

//DELEGATE, called after sendData was used to write a characteristic value to a peripheral
- (void)characteristicValueWriteCompleted:(CBPeripheral *)peripheral {
    UInt16 i;
    for (i=0;i<self.ble.peripherals.count;i++) {
        if ([self.ble.peripherals objectAtIndex:i] == peripheral) break;
    }
    [self.pendingWrites replaceObjectAtIndex:i withObject:[NSNumber numberWithUnsignedInt:([[self.pendingWrites objectAtIndex:i] unsignedIntValue] - 1)]];
    //NSLog(@"Pending %d",[[self.pendingWrites objectAtIndex:i] unsignedIntValue]);
    if ([[self.pendingWrites objectAtIndex:i] unsignedIntValue] == 0) [self.delegate queueZeroed:i];
    //if the number is 2, if queue is unsent, send data, update number, and mark queue as sent
    //otherwise delete the queue
    //if (([self.queues objectAtIndex:i]) && ([[self.pendingWrites objectAtIndex:i] unsignedIntValue] <= 2)) {
    if ([self.queues objectAtIndex:i]) {
        if ([[self.queues objectAtIndex:i] sent] == FALSE) {
            //send the data to bluetooth
            [self.pendingWrites replaceObjectAtIndex:i withObject:[NSNumber numberWithUnsignedInt:([[self.pendingWrites objectAtIndex:i] unsignedIntValue] + 1)]];
            //NSLog(@"Pending %d",[[self.pendingWrites objectAtIndex:i] unsignedIntValue]);
            [[self.queues objectAtIndex:i] setSent:TRUE];
            [self.ble writeValue:[[self.queues objectAtIndex:i] serviceIDNumber] ofCharacteristicUUID:[[self.queues objectAtIndex:i] characteristicIDNumber] toPeripheral:[self.ble.peripherals objectAtIndex:i] withData:[[self.queues objectAtIndex:i] data]];
            //[self.ble writeValue:[[self.queues objectAtIndex:i] serviceIDNumber] ofCharacteristicUUID:[[self.queues objectAtIndex:i] characteristicIDNumber] toPeripheral:[self.ble.peripherals objectAtIndex:i] withData:[[self.queues objectAtIndex:i] data]];
        }
    }
}

@end
