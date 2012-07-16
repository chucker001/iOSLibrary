//
//  BluetoothCellViewController.h
//  DirectDriver
//
//  Created by Matthew Regan on 6/5/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BluetoothDevice.h"

@class BluetoothCellViewController;

@protocol BluetoothCellViewControllerDelegate

- (void)sender:(BluetoothCellViewController *)cell saveId:(BOOL)save;
- (void)connectSender:(BluetoothCellViewController *)cell;

@end

@interface BluetoothCellViewController : UITableViewController
@property (nonatomic, strong) BluetoothDevice *bluetoothDevice;
@property (nonatomic, assign) id <BluetoothCellViewControllerDelegate> delegate; 

- (void)assignBluetoothDevice:(BluetoothDevice *)device andLight:(NSString *)light;
- (void)idSaved:(BOOL)saved;
- (void)deviceConnected:(BOOL)connected;

@end
