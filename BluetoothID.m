//
//  BluetoothID.m
//  DirectDriver
//
//  Created by Matthew Regan on 5/30/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import "BluetoothID.h"

@implementation BluetoothID

@synthesize uuid = _uuid;
@synthesize name = _name;
@synthesize autoConnect = _autoConnect;

- (void)setUuid:(NSString *)uuid {
    _uuid = uuid;
}

- (id)init {
    self = [super init];
    return self;
}

- (id)initWithName:(NSString *)name andUUID:(NSString *)uuid andAutoConnect:(BOOL)autoconnect {
    self = [self init];
    self.name = name;
    self.uuid = uuid;
    self.autoConnect = autoconnect;
    return self;
}

@end
