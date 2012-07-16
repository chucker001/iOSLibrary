//
//  BluetoothDevice.h
//  DirectDriver
//
//  Created by Matthew Regan on 5/29/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BluetoothID.h"
#import "BluetoothQueue.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothDevice : NSObject

@property (strong, nonatomic) BluetoothID *bleId;
@property (nonatomic) BOOL connected;
@property (nonatomic) BOOL discovered;
@property (nonatomic) BOOL displayed;
@property (nonatomic) BOOL connectionRequest;
@property (nonatomic) BOOL connecting;
//@property (nonatomic) NSUInteger index;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) BluetoothQueue *queue;
@property (nonatomic) NSUInteger pendingWrites;
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) UITableViewCell *tableViewCell;

@end
