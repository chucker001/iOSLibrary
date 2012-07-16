//
//  BluetoothViewController.h
//  DirectDriver
//
//  Created by Matthew Regan on 5/29/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGCLightingComm.h"

@class BluetoothViewController;

@protocol BluetoothViewControllerDelegate 
- (NSString *)getLSGCLightName;
- (NSInteger)getQueue;
@optional
- (BOOL)shouldRepeatLastCommand;
@end

@interface BluetoothViewController : UITableViewController <LSGCLightingComm>
@property (nonatomic, strong) NSArray *bluetoothDevices;
@property (nonatomic, retain) id <BluetoothViewControllerDelegate> delegate;
@end
