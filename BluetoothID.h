//
//  BluetoothID.h
//  DirectDriver
//
//  Created by Matthew Regan on 5/30/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BluetoothID : NSObject

@property (readonly, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSString *name;
@property (nonatomic) BOOL autoConnect;

- (id)initWithName:(NSString *)name andUUID:(NSString *)uuid andAutoConnect:(BOOL)autoconnect;

@end
