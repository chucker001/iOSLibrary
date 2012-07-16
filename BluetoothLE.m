//
//  BluetoothLE.m
//  TuneableLight
//
//  Created by Matthew Regan on 3/27/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import "BluetoothLE.h"

@implementation BluetoothLE

@synthesize delegate = _delegate;
@synthesize peripherals = _peripherals;
//@synthesize activePeripheral = _activePeripheral;
@synthesize cm = _cm;

/************************************************************************************************************************/
//METHODS USED TO SUPPORT THE METHODS BELOW

//- (const char *) centralManagerStateToString: (int)state{
- (NSString *)centralManagerStateToString: (int)state {
    switch(state) {
        case CBCentralManagerStateUnknown: 
            return @"State unknown (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateResetting:
            return @"State resetting (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateUnsupported:
            return @"State BLE unsupported (CBCentralManagerStateResetting)";
        case CBCentralManagerStateUnauthorized:
            return @"State unauthorized (CBCentralManagerStateUnauthorized)";
        case CBCentralManagerStatePoweredOff:
            return @"State BLE powered off (CBCentralManagerStatePoweredOff)";
        case CBCentralManagerStatePoweredOn:
            return @"State powered up and ready (CBCentralManagerStatePoweredOn)";
        default:
            return @"State unknown";
    }
    return @"Unknown state";
}

- (int) UUIDSAreEqual:(CFUUIDRef)u1 u2:(CFUUIDRef)u2 {
    CFUUIDBytes b1 = CFUUIDGetUUIDBytes(u1);
    CFUUIDBytes b2 = CFUUIDGetUUIDBytes(u2);
    if (memcmp(&b1, &b2, 16) == 0) {
        return 1;
    }
    else return 0;
}

-(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}

-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);		    
}

-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

-(int) compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2 {
    char b1[16];
    [UUID1.data getBytes:b1];
    UInt16 b2 = [self swap:UUID2];
    if (memcmp(b1, (char *)&b2, 2) == 0) return 1;
    else return 0;
}

-(UInt16) CBUUIDToInt:(CBUUID *) UUID {
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}

-(CBUUID *) IntToCBUUID:(UInt16)UUID {
    char t[16];
    t[0] = ((UUID >> 8) & 0xff); t[1] = (UUID & 0xff);
    NSData *data = [[NSData alloc] initWithBytes:t length:16];
    return [CBUUID UUIDWithData:data];
}

-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p {
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}

- (void) printKnownPeripherals {
    int i;
    NSLog(@"List of currently known peripherals : \r\n");
    for (i=0; i < self.peripherals.count; i++)
    {
        CBPeripheral *p = [self.peripherals objectAtIndex:i];
        CFStringRef s = CFUUIDCreateString(NULL, p.UUID);
        NSLog(@"%d  |  %s\r\n",i,CFStringGetCStringPtr(s, 0));
        [self printPeripheralInfo:p];
    }
}

- (void) printPeripheralInfo:(CBPeripheral*)peripheral {
    CFStringRef s = CFUUIDCreateString(NULL, peripheral.UUID);
    NSLog(@"------------------------------------\r\n");
    NSLog(@"Peripheral Info :\r\n");
    NSLog(@"UUID : %s\r\n",CFStringGetCStringPtr(s, 0));
    NSLog(@"RSSI : %d\r\n",[peripheral.RSSI intValue]);
    NSLog(@"Name : %s\r\n",[peripheral.name cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    NSLog(@"isConnected : %d\r\n",peripheral.isConnected);
    NSLog(@"-------------------------------------\r\n");
    
}

//this method is called when the timer to scan for peripherals expires
- (void) scanTimer:(NSTimer *)timer {
    [self.cm stopScan];
    NSLog(@"Stopped Scanning\r\n");
    NSLog(@"Known peripherals : %d\r\n",[self.peripherals count]);
    if ([self.peripherals count]) [self printKnownPeripherals];	
    [self.delegate finishedDiscoveringPeripherals:[self.peripherals count]];
}

- (void) discoverServicesTimer:(NSTimer *)timer {
    CBPeripheral *peripheral = timer.userInfo;
    if (!(peripheral.services)) {
        [self.cm cancelPeripheralConnection:peripheral];
    }
}

- (void)peripheralConnectionTimeout:(NSTimer *)timer {
    CBPeripheral *peripheral = timer.userInfo;
    if (peripheral.isConnected == FALSE) {
        [self.cm cancelPeripheralConnection:peripheral];
    }
}
/************************************************************************************************************************/






//THIS IS CALLED TO INITIALIZE THE CBCENTRALMANAGER INSTANCE OF THIS CLASS
//INITIALIZATION OF THIS CLASS IS NEEDED IN ORDER TO SEARCH FOR BLE DEVICES
//a delegate method is called once the central manager is initialized
- (void)initCBCentralManagerWithQueue:(dispatch_queue_t)queue {
    self.cm = [[CBCentralManager alloc] initWithDelegate:self queue:queue];
}


- (int)controlSetup:(int)s {
    self.cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    return 0;
}


//search for advertising peripherals in the area for a specified period of time
//"STARTING POINT" FOR THIS CLASS
- (int)findBLEPeripheralsForSeconds:(int)timeout withServices:(NSArray *)services {
    if (self.cm.state  != CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth not correctly initialized !\r\n");
        NSLog(@"State = %d (%@)\r\n",self.cm.state,[self centralManagerStateToString:self.cm.state]);
        return -1;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:(float)timeout target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    
    NSMutableArray *serviceArray;
    if (services) {
        serviceArray = [NSMutableArray arrayWithCapacity:[services count]];
        for (UInt16 i = 0;i<[services count];i++) {
            [serviceArray addObject:[CBUUID UUIDWithString:[services objectAtIndex:i] ]];
        }
    }
    [self.cm scanForPeripheralsWithServices:serviceArray options:0]; // Start scanning
    return 0; // Started scanning OK !
}

//called by another method to connect to a specified peripheral
//THIS METHOD SHOULD BE CALLED AFTER TRYING TO FIND PERIPHERALS AT LEAST ONCE
- (void)connectPeripheral:(CBPeripheral *)peripheral withTimeout:(float)time {
    printf("Connecting to peripheral with UUID : %s\r\n",[self UUIDToString:peripheral.UUID]);
    peripheral.delegate = self;
    [self.cm connectPeripheral:peripheral options:nil];
    [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(peripheralConnectionTimeout:) userInfo:peripheral repeats:NO];
}

- (void)discoverServices:(NSArray *)services ofPeripheral:(CBPeripheral *)peripheral withTimeout:(float)time {
    NSMutableArray *serviceArray;
    if (services) {
        serviceArray = [NSMutableArray arrayWithCapacity:[services count]];
        for (UInt16 i = 0;i<[services count];i++) {
            [serviceArray addObject:[CBUUID UUIDWithString:[services objectAtIndex:i] ]];
        }
    }
    [peripheral discoverServices:serviceArray];
    [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(discoverServicesTimer:) userInfo:peripheral repeats:NO];
}

- (void)cancelPeripheral:(CBPeripheral *)peripheral {
    [self.cm cancelPeripheralConnection:peripheral];
}

//ONCE ALL CHARACTERISTICS OF ALL SERVICES HAVE BEEN DISCOVERED, COMMUNICATION CAN TAKE PLACE BETWEEN
//THE iOS DEVICE AND THE BLUETOOTH DEVICE

- (void)getAllCharacteristicsFromAllServicesOfPeripheral:(CBPeripheral *)peripheral {
    for (int i=0; i < peripheral.services.count; i++) {
        CBService *s = [peripheral.services objectAtIndex:i];
        printf("Fetching characteristics for service with UUID : %s\r\n",[self CBUUIDToString:s.UUID]);
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

/*!
 *  @method writeValue:
 *
 *  @param serviceUUID Service UUID to write to (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to write to (e.g. 0x2401)
 *  @param data Data to write to peripheral
 *  @param p CBPeripheral to write to
 *
 *  @discussion Main routine for writeValue request, writes without feedback. It converts integer into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service. 
 *  If this is found, value is written. If not nothing is done.
 *
 */

- (void)writeValue:(int)serviceUUID ofCharacteristicUUID:(int)characteristicUUID toPeripheral:(CBPeripheral *)p withData:(NSData *)data {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    //[p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}


/*!
 *  @method readValue:
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for read value request. It converts integers into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service. 
 *  If this is found, the read value is started. When value is read the didUpdateValueForCharacteristic 
 *  routine is called.
 *
 *  @see didUpdateValueForCharacteristic
 */

- (void)readValue:(int)serviceUUID ofCharacteristicUUID:(int)characteristicUUID fromPeripheral:(CBPeripheral *)p {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }  
    [p readValueForCharacteristic:characteristic];
}

/*!
 *  @method notification:
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for enabling and disabling notification services. It converts integers 
 *  into CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service. 
 *  If this is found, the notfication is set. 
 *
 */
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}





//----------------------------------------------------------------------------------------------------
//
//
//
//
//CBCentralManagerDelegate protocol methods beneeth here
// Documented in CoreBluetooth documentation
//
//
//
//
//----------------------------------------------------------------------------------------------------



//a delegate method should be sent here notifiying the change of state
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"Status of CoreBluetooth central manager changed %d (%@)\r\n",central.state,[self centralManagerStateToString:central.state]);
    if ([central state] == CBCentralManagerStatePoweredOn) {
        [self.delegate bluetoothCMStateChangedToOn:TRUE];
    }
    else [self.delegate bluetoothCMStateChangedToOn:FALSE];
}


//this method is called when a peripheral is discovered
//when a peripheral is found, it is compared against already found peripherals, then it is added if not already existing in the array
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (!self.peripherals) self.peripherals = [[NSMutableArray alloc] initWithObjects:peripheral,nil];
    else {
        for(int i = 0; i < self.peripherals.count; i++) {
            CBPeripheral *p = [self.peripherals objectAtIndex:i];
            if ([self UUIDSAreEqual:p.UUID u2:peripheral.UUID]) {
                [self.peripherals replaceObjectAtIndex:i withObject:peripheral];
                printf("Duplicate UUID found updating ...\r\n");
                return;
            }
        }
        [self.peripherals addObject:peripheral];
        printf("New UUID, adding\r\n");
    }
    printf("didDiscoverPeripheral\r\n");
    //NSLog(@"%s",[advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey]);
}


//this method is called when a peripheral is connected to
//RIGHT NOW, SERVICES FOR THE CONNECTED PERIPHERAL ARE AUTOMATICALLY DISCOVERED!!
//WHEN SERVICES ARE DISCOVERED, CHARACTERISTICS OF SERVICES ARE AUTOMATICALLY DISCOVERED!!
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connection to peripheral with UUID : %s successfull\r\n",[self UUIDToString:peripheral.UUID]);
    [self.delegate peripheral:peripheral connected:TRUE];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self.delegate peripheral:peripheral connected:FALSE];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Disconnection from peripheral with UUID : %s successfull\r\n",[self UUIDToString:peripheral.UUID]);
    [self.delegate peripheral:peripheral connected:FALSE];
}

//----------------------------------------------------------------------------------------------------
//
//
//
//
//
//CBPeripheralDelegate protocol methods beneeth here
//
//
//
//
//
//----------------------------------------------------------------------------------------------------


/*
 *  @method didDiscoverCharacteristicsForService
 *
 *  @param peripheral Pheripheral that got updated
 *  @param service Service that characteristics where found on
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverCharacteristicsForService is called when CoreBluetooth has discovered 
 *  characteristics on a service, on a peripheral after the discoverCharacteristics routine has been called on the service
 *
 */
//AS WRITTEN NOW, THIS IS THE LAST METHOD CALLED 
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        NSLog(@"Characteristics of service with UUID : %s found\r\n",[self CBUUIDToString:service.UUID]);
        for(int i=0; i < service.characteristics.count; i++) {
            CBCharacteristic *c = [service.characteristics objectAtIndex:i]; 
            NSLog(@"Found characteristic %s\r\n",[ self CBUUIDToString:c.UUID]);
            CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
            //is this the last service that characteristics were discovered for?
            if(([self compareCBUUID:service.UUID UUID2:s.UUID]) && (i == (service.characteristics.count - 1))) {
                NSLog(@"Finished discovering characteristics");
                [self.delegate peripheralFullyDiscovered:peripheral];
            }
        }
    }
    else {
        NSLog(@"Characteristic discorvery unsuccessfull !\r\n");
        //temporary
        [self cancelPeripheral:peripheral];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
}

/*
 *  @method didDiscoverServices
 *
 *  @param peripheral Pheripheral that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverServices is called when CoreBluetooth has discovered services on a 
 *  peripheral after the discoverServices routine has been called on the peripheral
 *
 */
//WHEN SERVICES ARE DISCOVERED, DISCOVERING CHARACTERISTICS OF SERVICES IS AUTOMATICALLY CALLED!!
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        printf("Services of peripheral with UUID : %s found\r\n",[self UUIDToString:peripheral.UUID]);
        //[self getAllCharacteristicsFromAllServicesOfPeripheral:peripheral];
        [self.delegate servicesDiscoveredOfPeripheral:peripheral];
    }
    else {
        printf("Service discovery was unsuccessfull !\r\n");
        [self cancelPeripheral:peripheral];
    }
}

/*
 *  @method didUpdateNotificationStateForCharacteristic
 *
 *  @param peripheral Pheripheral that got updated
 *  @param characteristic Characteristic that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didUpdateNotificationStateForCharacteristic is called when CoreBluetooth has updated a 
 *  notification state for a characteristic
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        printf("Updated notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:peripheral.UUID]);
    }
    else {
        printf("Error in setting notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:peripheral.UUID]);
        printf("Error code was %s\r\n",[[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    }
    
}

/*
 *  @method didUpdateValueForCharacteristic
 *
 *  @param peripheral Pheripheral that got updated
 *  @param characteristic Characteristic that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didUpdateValueForCharacteristic is called when CoreBluetooth has updated a 
 *  characteristic for a peripheral. All reads and notifications come here to be processed.
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
    if (!error) {
        NSLog(@"Updated notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:peripheral.UUID]);
        /*
        switch(characteristicUUID){
            case TI_KEYFOB_LEVEL_SERVICE_UUID:
            {
                char batlevel;
                [characteristic.value getBytes:&batlevel length:TI_KEYFOB_LEVEL_SERVICE_READ_LEN];
                self.batteryLevel = (float)batlevel;
                break;
            }
            case TI_KEYFOB_KEYS_NOTIFICATION_UUID:
            {
                char keys;
                [characteristic.value getBytes:&keys length:TI_KEYFOB_KEYS_NOTIFICATION_READ_LEN];
                if (keys & 0x01) self.key1 = YES;
                else self.key1 = NO;
                if (keys & 0x02) self.key2 = YES;
                else self.key2 = NO;
                [[self delegate] keyValuesUpdated: keys];
                break;
            }
            case TI_KEYFOB_ACCEL_X_UUID:
            {
                char xval; 
                [characteristic.value getBytes:&xval length:TI_KEYFOB_ACCEL_READ_LEN];
                self.x = xval;
                [[self delegate] accelerometerValuesUpdated:self.x y:self.y z:self.z];
                break;
            }
            case TI_KEYFOB_ACCEL_Y_UUID:
            {
                char yval; 
                [characteristic.value getBytes:&yval length:TI_KEYFOB_ACCEL_READ_LEN];
                self.y = yval;
                [[self delegate] accelerometerValuesUpdated:self.x y:self.y z:self.z];
                break;
            }
            case TI_KEYFOB_ACCEL_Z_UUID:
            {
                char zval; 
                [characteristic.value getBytes:&zval length:TI_KEYFOB_ACCEL_READ_LEN];
                self.z = zval;
                [[self delegate] accelerometerValuesUpdated:self.x y:self.y z:self.z];
                break;
            }
            case TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID:
            {
                char TXLevel;
                [characteristic.value getBytes:&TXLevel length:TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_READ_LEN];
                self.TXPwrLevel = TXLevel;
                [[self delegate] TXPwrLevelUpdated:TXLevel];
            }
        }
         */
    }    
    else {
        printf("updateValueForCharacteristic failed !");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        //NSLog(@"Updated notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:peripheral.UUID]);
    }    
    else {
        NSLog(@"updateValueForCharacteristic failed !");
    }
    [self.delegate characteristicValueWriteCompleted:peripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    
}

@end
