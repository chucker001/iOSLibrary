//
//  BluetoothQueue.h
//  wwRemote
//
//  Created by Matthew Regan on 4/13/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BluetoothQueue : NSObject

@property (nonatomic) UInt16 serviceIDNumber;
@property (nonatomic) UInt16 characteristicIDNumber;
@property (nonatomic) UInt16 peripheralNumber;
@property (nonatomic) BOOL sent;
@property (strong, nonatomic) NSData *data;

@end
