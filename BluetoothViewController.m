//
//  BluetoothViewController.m
//  DirectDriver
//
//  Created by Matthew Regan on 5/29/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import "BluetoothViewController.h"
#import "BluetoothLE.h"
#import "BluetoothDevice.h"
#import "BluetoothQueue.h"
#import "SplitViewBarButtonItemPresenter.h"
#import "BluetoothCellViewController.h"

#define LSGC_PASS_THROUGH_SERVICE_UUID  0xFFF0
#define LSGC_PASS_THROUGH_UUID          0xFFF1
#define CONNECT_DURATION        5

#define INTENSITY_MAX   65535
#define COLOR_MIX_MAX   65535

#define DISCOVER_SECONDS    5

@interface BluetoothViewController () <BluetoothLEDelegate, BluetoothCellViewControllerDelegate, UISplitViewControllerDelegate> //<LSGCCommDelegate> 

@property (nonatomic, strong) BluetoothLE *comm;
@property (nonatomic, strong) NSString *light;
//@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSArray *bluetoothIDArray;
@property (nonatomic) BOOL shouldConnectToNextPeripheral;
@property (nonatomic, strong) id buttonHolder;
@property (nonatomic) BOOL resetComm;
@property (nonatomic) NSUInteger queue;
@property (nonatomic) BOOL shouldRepeatLastCommand;

@end

@implementation BluetoothViewController

@synthesize comm = _comm;
@synthesize bluetoothDevices = _bluetoothDevices;
//@synthesize version = _version;
@synthesize light = _light;
@synthesize bluetoothIDArray = _bluetoothIDArray;
@synthesize shouldConnectToNextPeripheral = _shouldConnectToNextPeripheral;
@synthesize buttonHolder = _buttonHolder;
@synthesize delegate = _delegate;
@synthesize resetComm = _resetComm;
@synthesize queue = _queue;
@synthesize shouldRepeatLastCommand = _shouldRepeatLastCommand;

- (void)buttonToSpinner {
    //change the discover button to a spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    NSMutableArray *barButtonItems = [self.toolbarItems mutableCopy];
    self.buttonHolder = [barButtonItems objectAtIndex:(barButtonItems.count - 1)];
    [barButtonItems replaceObjectAtIndex:(barButtonItems.count-1) withObject:[[UIBarButtonItem alloc] initWithCustomView:spinner]]; 
    self.toolbarItems = barButtonItems;
}

- (void)spinnerToButton {
    if (self.buttonHolder) {
        NSMutableArray *barButtonItems = [self.toolbarItems mutableCopy];
        [barButtonItems replaceObjectAtIndex:(barButtonItems.count-1) withObject:self.buttonHolder]; 
        self.toolbarItems = barButtonItems;
    }
}

- (void)getDeviceImageForDevice:(BluetoothDevice *)device {
    NSString *imageName;
    if ([self.light isEqualToString:@"Adaptable"]) imageName = [[NSBundle mainBundle] pathForResource:@"adaptable_ipad" ofType:@"png"];
    else if ([self.light isEqualToString:@"Wall Wash"]) imageName = [[NSBundle mainBundle] pathForResource:@"wall_wash_ipad" ofType:@"png"];
    else if ([self.light isEqualToString:@"Glimpse Horizon"]) imageName = [[NSBundle mainBundle] pathForResource:@"horizon_ipad" ofType:@"png"];
    else return;
    device.image = [[UIImage alloc] initWithContentsOfFile:imageName];
}

- (void)createNewBluetoothDeviceWithId:(BluetoothID *)bleId inArray:(NSMutableArray *)array {
    BluetoothDevice *device = [[BluetoothDevice alloc] init];
    device.bleId = bleId;
    //device.index = array.count;
    //device.connected = TRUE;
    device.connected = FALSE;
    device.discovered = FALSE;
    device.displayed = FALSE;
    if (device.bleId.autoConnect) device.connectionRequest = TRUE;
    else device.connectionRequest = FALSE;
    [self getDeviceImageForDevice:device];
    [array addObject:device];
}

- (void)startSpinnerForBluetoothDevice:(BluetoothDevice *)device {
    if (device.tableViewCell) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        [spinner setFrame:CGRectMake(device.tableViewCell.imageView.bounds.origin.x + 20, device.tableViewCell.imageView.bounds.origin.y, device.tableViewCell.imageView.bounds.size.height, device.tableViewCell.contentView.bounds.size.height)];
        [[device.tableViewCell contentView] insertSubview:spinner atIndex:0];
        device.tableViewCell.imageView.hidden = TRUE;
    }
}

- (void)endSpinnerForBluetoothDevice:(BluetoothDevice *)device {
    if (device.tableViewCell) {
        if (device.tableViewCell.imageView.hidden) {
            device.tableViewCell.imageView.hidden = FALSE;
            [[device.tableViewCell.contentView.subviews objectAtIndex:0] removeFromSuperview];
        }
        [self.tableView reloadData];
    }
}

- (void)connectToDevice:(BluetoothDevice *)device {
    if (device.peripheral) {
        device.connectionRequest = FALSE;
        [self.comm connectPeripheral:device.peripheral withTimeout:10.0];
        device.connecting = TRUE;
        //[self startSpinnerForBluetoothDevice:device];
        [self.tableView reloadData];
    }
    else if (self.shouldConnectToNextPeripheral) [self connectToNextPeripheral];
}

- (void)connectToNextPeripheral {
    //connect to any peripheral with the following:
    //discovered = TRUE
    //connected = FALSE
    //connectionRequest = TRUE
    //connectionAttempted = FALSE
    if (self.bluetoothDevices) {
        for (NSUInteger i=0;i<self.bluetoothDevices.count;i++) {
            BluetoothDevice *device = [self.bluetoothDevices objectAtIndex:i];
            if ((device.discovered) && (!device.connected) && (device.connectionRequest)) {
                //connect to the peripheral whose index matches the index property of the bluetooth device
                [self connectToDevice:device];
                return;
            }
        }
        self.shouldConnectToNextPeripheral = FALSE; 
    }
}

- (NSInteger)findBleIdInArray:(BluetoothID *)bleId {
    for (NSUInteger i=0;i<self.bluetoothIDArray.count;i++) {
        if ([bleId.uuid isEqualToString:[[self.bluetoothIDArray objectAtIndex:i] uuid]]) return i;
    }
    return -1;
}

- (BluetoothDevice *)findCorrespondingBluetoothDeviceToPeripheral:(CBPeripheral *)peripheral {
    if (self.bluetoothDevices) {
        NSString *uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(nil, peripheral.UUID));
        for (NSUInteger i=0;i<self.bluetoothDevices.count;i++) {
            if ([uuidString isEqualToString:[[[self.bluetoothDevices objectAtIndex:i] bleId] uuid]]) return [self.bluetoothDevices objectAtIndex:i];
        }
    }
    return nil;
}

- (BluetoothID *)findCorrespondingBluetoothIDToPeripheral:(CBPeripheral *)peripheral {
    if (!self.bluetoothIDArray) {
        self.bluetoothIDArray = [self createBluetoothIDsFromUserDefaults];
        if (!self.bluetoothIDArray) return nil;
        NSString *uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(nil, peripheral.UUID));
        for (NSUInteger i=0;i<self.bluetoothIDArray.count;i++) {
            if ([uuidString isEqualToString:[[self.bluetoothIDArray objectAtIndex:i] uuid]]) return [self.bluetoothIDArray objectAtIndex:i];
        }
    }
    return nil;
}

#pragma mark USER DEFAULTS

- (void)updateUserDefaults {
    NSMutableArray *nameArray = [NSMutableArray arrayWithCapacity:self.bluetoothIDArray.count];
    NSMutableArray *uuidArray = [NSMutableArray arrayWithCapacity:self.bluetoothIDArray.count];
    //NSMutableArray *typeArray = [NSMutableArray arrayWithCapacity:self.bluetoothIDArray.count];
    NSMutableArray *autoConnectArray = [NSMutableArray arrayWithCapacity:self.bluetoothIDArray.count];
    for (NSUInteger i=0;i<self.bluetoothIDArray.count;i++) {
        BluetoothID *bleID = [self.bluetoothIDArray objectAtIndex:i];
        [nameArray addObject:bleID.name];
        [uuidArray addObject:bleID.uuid];
        //[typeArray addObject:bleID.type];
        [autoConnectArray addObject:[NSNumber numberWithBool:bleID.autoConnect]];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nameArray forKey:[self.light stringByAppendingString:@" name"]];
    [defaults setObject:uuidArray forKey:[self.light stringByAppendingString:@" uuid"]];
    //[defaults setObject:typeArray forKey:[self.light stringByAppendingString:@" type"]];
    [defaults setObject:autoConnectArray forKey:[self.light stringByAppendingString:@" autoconnect"]];
    [defaults synchronize];
}

- (NSArray *)createBluetoothIDsFromUserDefaults {
    if (!self.light) return nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *nameArray = [defaults objectForKey:[self.light stringByAppendingString:@" name"]];
    NSArray *uuidArray = [defaults objectForKey:[self.light stringByAppendingString:@" uuid"]];
    //NSArray *typeArray = [defaults objectForKey:[self.light stringByAppendingString:@" type"]];
    NSArray *autoConnectArray = [defaults objectForKey:[self.light stringByAppendingString:@" autoconnect"]];
    if (!nameArray) return nil;
    NSMutableArray *bluetoothIDArray = [NSMutableArray arrayWithCapacity:nameArray.count];
    for (NSUInteger i=0;i<nameArray.count;i++) {
        BluetoothID *bleID = [[BluetoothID alloc] initWithName:[nameArray objectAtIndex:i] andUUID:[uuidArray objectAtIndex:i] andAutoConnect:[[autoConnectArray objectAtIndex:i] boolValue]];
        [bluetoothIDArray addObject:bleID];
    }
    return bluetoothIDArray;
}

- (void)removeUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:[self.light stringByAppendingString:@" name"]];
    [defaults removeObjectForKey:[self.light stringByAppendingString:@" uuid"]];
    [defaults removeObjectForKey:[self.light stringByAppendingString:@" type"]];
    [defaults removeObjectForKey:[self.light stringByAppendingString:@" autoconnect"]];
}

#pragma mark BLUETOOTH LE DELEGATES

//DELEGATE OF BLUETOOTH LE
- (void)bluetoothCMStateChangedToOn:(BOOL)on {
    if (on) {
        //find out what devices are out there
        NSArray *services = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%X",LSGC_PASS_THROUGH_SERVICE_UUID], nil];
        //change the discover button to a spinner
        [self buttonToSpinner];
        if ([self.comm findBLEPeripheralsForSeconds:DISCOVER_SECONDS withServices:services] == -1) {
            //change the spinner to the discover button
            [self spinnerToButton];
        }
    }
    //otherwise we are done, bluetooth was not initialized properly!!
}

//DELEGATE OF BLUETOOTH LE
- (void)finishedDiscoveringPeripherals:(UInt16)numberOfPeripherals {
    //we now know how many peripherals have been found
    //create bluetooth devices from these peripherals
    NSMutableArray *bluetoothDeviceArray;
    if (!self.bluetoothDevices) bluetoothDeviceArray = [NSMutableArray arrayWithCapacity:self.comm.peripherals.count];
    else bluetoothDeviceArray = [self.bluetoothDevices mutableCopy];
    //do the discovered peripherals already exist
    for (NSUInteger i=0;i<self.comm.peripherals.count;i++) {
        if ([[[self.comm.peripherals objectAtIndex:i] name] isEqualToString:self.light]) {
            BluetoothDevice *device = [self findCorrespondingBluetoothDeviceToPeripheral:[self.comm.peripherals objectAtIndex:i]];
            if (device) device.peripheral = [self.comm.peripherals objectAtIndex:i];
            else {
                //the peripheral is not in the bluetoothDevice array
                //compare the devices to the bluetooth ID uuids
                //if the uuids match, use the bluetooth ID name as the bluetooth device name
                //otherwise title the bluetooth device "New Device"
                BluetoothID *bleID = [self findCorrespondingBluetoothIDToPeripheral:[self.comm.peripherals objectAtIndex:i]];
                if (!bleID) {
                    bleID = [[BluetoothID alloc] initWithName:@"New Device" andUUID:(NSString *)CFBridgingRelease(CFUUIDCreateString(nil, [[self.comm.peripherals objectAtIndex:i] UUID])) andAutoConnect:TRUE];
                }
                [self createNewBluetoothDeviceWithId:bleID inArray:bluetoothDeviceArray];
                [[bluetoothDeviceArray lastObject] setDiscovered:TRUE];
                [[bluetoothDeviceArray lastObject] setPeripheral:[self.comm.peripherals objectAtIndex:i]];
            }
        }
    }
    self.bluetoothDevices = bluetoothDeviceArray;
    //change the spinner to the discover button
    [self spinnerToButton];
    //MIGHT WANT TO USE A SEPARATE THREAD HERE!!!!
    //reload the table
    [self.tableView reloadData];
    //attempt to connect to all devices not known, and all devices with auto-connect set to true
    //ONE AT A TIME!!
    self.shouldConnectToNextPeripheral = TRUE;
    [self connectToNextPeripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral connected:(BOOL)connected {
    if (connected) {
        NSArray *services = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%X",LSGC_PASS_THROUGH_SERVICE_UUID], nil];
        [self.comm discoverServices:services ofPeripheral:peripheral withTimeout:10.0];
    }
    else {
        BluetoothDevice *device = [self findCorrespondingBluetoothDeviceToPeripheral:peripheral];
        if (device) {
            device.connected = FALSE;
            device.connecting = FALSE;
            [self.tableView reloadData];
            //[self endSpinnerForBluetoothDevice:device];
            //NOTIFY CELL CONTROLLER THAT DEVICE HAS BEEN DISCONNECTED
            if ((self.navigationController) && ([self.navigationController.visibleViewController isMemberOfClass:[BluetoothCellViewController class]])) {
                [(BluetoothCellViewController *)self.navigationController.visibleViewController deviceConnected:device.connected]; 
            }
            if (self.resetComm) {
                self.shouldConnectToNextPeripheral = FALSE;
                for (NSUInteger i=0;i<self.bluetoothDevices.count;i++) {
                    BluetoothDevice *bleDevice = [self.bluetoothDevices objectAtIndex:i];
                    if (bleDevice.connected) return;
                }
                [self initComm];
            }
        }
        if (self.shouldConnectToNextPeripheral) [self connectToNextPeripheral];
        
    }
}

//BLE DELEGATE, services for peripheral discovered
- (void)servicesDiscoveredOfPeripheral:(CBPeripheral *)peripheral {
    [self.comm getAllCharacteristicsFromAllServicesOfPeripheral:peripheral];
}

//BLE DELEGATE, all characteristics of all services of a peripheral discovered
- (void)peripheralFullyDiscovered:(CBPeripheral *)peripheral {
    //set the connected property to true
    BluetoothDevice *device = [self findCorrespondingBluetoothDeviceToPeripheral:peripheral];
    if (device) device.connected = TRUE;
    //set the color of the cell to green
    device.connecting = FALSE;
    [self.tableView reloadData];
    //[self endSpinnerForBluetoothDevice:device];
    //NOTIFY CELL CONTROLLER THAT THE DEVICE HAS BEEN CONNECTED
    if ((self.navigationController) && ([self.navigationController.visibleViewController isMemberOfClass:[BluetoothCellViewController class]])) {
        [(BluetoothCellViewController *)self.navigationController.visibleViewController deviceConnected:device.connected]; 
    }
    if (self.shouldConnectToNextPeripheral) [self connectToNextPeripheral];
}

//BLE DELEGATE, device characteristic written
- (void)characteristicValueWriteCompleted:(CBPeripheral *)peripheral {
    BluetoothDevice *device = [self findCorrespondingBluetoothDeviceToPeripheral:peripheral];
    if (device.pendingWrites) {
        --device.pendingWrites;
        if ((device.queue) && (device.queue.sent == FALSE)) {
            if (![self shouldRepeatLastCommand]) device.queue.sent = TRUE;
            ++device.pendingWrites;
            [self sendData:device.queue.data toDevice:device];
        }
    }
    else if (([self shouldRepeatLastCommand]) && (device.queue.sent == FALSE)) {
        device.queue.sent = TRUE;
        [self sendData:device.queue.data toDevice:device];
    }
}

#pragma mark VIEW RELATED

- (IBAction)directControlButton:(id)sender {
    [self performSegueWithIdentifier:@"ShowDriver" sender:self];
}

//CALLED AFTER THE VIEW CONTROLLER IS CREATED!!
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //NSString *light = self.light;
    //NSString *version = self.version;
    if ([segue.identifier isEqualToString:@"ShowDriver"]) {
        //used when the segue is to a (DirectDriverViewController *)
        [segue.destinationViewController setDelegate:[self.navigationController.viewControllers objectAtIndex:0]];
        //[segue.destinationViewController setupDirectIntensitiesForLight:light andVersion:version withCommController:self];
    }
    else if ([segue.identifier isEqualToString:@"ShowBluetoothCell"]) {
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController assignBluetoothDevice:sender andLight:self.light];
    }
}

- (IBAction)connectAllButton:(id)sender {
    for (NSUInteger i=0;i<self.bluetoothDevices.count;i++) {
        BluetoothDevice *device = [self.bluetoothDevices objectAtIndex:i];
        if ((!device.connected) && (device.discovered)) device.connectionRequest = TRUE;
    }
    self.shouldConnectToNextPeripheral = TRUE;
    [self connectToNextPeripheral];
}

- (IBAction)disconnectAllButton:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"Reset"]) {
        //THIS CODE WILL DISCONNECT ALL DEVICES AND RESET THE COMM CONTROLLER
        self.resetComm = TRUE;
        for (NSUInteger i=0;i<self.bluetoothDevices.count;i++) {
            BluetoothDevice *device = [self.bluetoothDevices objectAtIndex:i];
            if ((device.peripheral) && (device.connected)) [self.comm cancelPeripheral:device.peripheral];
        }
    }
    else if ([sender.title isEqualToString:@"Show All"]) {
        //THIS CODE WILL DISPLAY ALL SAVED IDs
        NSArray *bluetoothIDs = [self createBluetoothIDsFromUserDefaults];
        //compare the array above to the array of bluetooth devices
        //if there is no match, create a new bluetooth device and add the id to the device
        if (bluetoothIDs) {
            NSMutableArray *ble;
            if (self.bluetoothDevices) {
                ble = [self.bluetoothDevices mutableCopy];
                NSUInteger j=0;
                if (self.bluetoothDevices) {
                    for (NSUInteger i=0;i<bluetoothIDs.count;i++) {
                        for (j=0;j<self.bluetoothDevices.count;j++) {
                            if ([[bluetoothIDs objectAtIndex:i] name] == [[[self.bluetoothDevices objectAtIndex:j] bleId] name]) break;
                        }
                        if (j == self.bluetoothDevices.count) [self createNewBluetoothDeviceWithId:([bluetoothIDs objectAtIndex:i]) inArray:ble];
                    }
                }
            }
            else {
                ble = [NSMutableArray array];
                for (NSUInteger i=0;i<bluetoothIDs.count;i++) {
                    [self createNewBluetoothDeviceWithId:([bluetoothIDs objectAtIndex:i]) inArray:ble];
                } 
            }
            self.bluetoothDevices = ble;
            [self.tableView reloadData];
        }
    }
}

- (IBAction)discoverButton:(id)sender {
    if (self.comm.cm.state == CBCentralManagerStatePoweredOn) [self bluetoothCMStateChangedToOn:TRUE];
    else [self.comm initCBCentralManagerWithQueue:nil];
    
    /*
    dispatch_queue_t bleDiscover = dispatch_queue_create("BLE discover", NULL);
    dispatch_async(bleDiscover, ^{
        //do something
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = sender;
        });
        
    });
    */
}

//THIS HAS TO BE USED OR AT LOAD TIME
- (void)awakeFromNib  {
    [super awakeFromNib];
    if (self.splitViewController) {
        if ((self.navigationController) && (self.navigationController.topViewController == self)) {
            self.splitViewController.delegate = self;
            self.splitViewController.presentsWithGesture = FALSE;
        }
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initComm {
    if (self.comm) {
        self.bluetoothDevices = nil;
        [self.tableView reloadData];
        self.comm = nil;
    }
    self.resetComm = FALSE;
    self.comm = [[BluetoothLE alloc] init];
    self.comm.delegate = self;
    [self.comm initCBCentralManagerWithQueue:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.light = [self.delegate getLSGCLightName];
    self.queue = [self.delegate getQueue];
    if ([self.delegate shouldRepeatLastCommand]) self.shouldRepeatLastCommand = TRUE;
    if (self.queue < 1) self.queue = 1;
    [self initComm];
    
    
    //DEBUG
    /*
    [self removeUserDefaults];
    NSMutableArray *bleIDArray = [[self createBluetoothIDsFromUserDefaults] mutableCopy];
    if (!bleIDArray) bleIDArray = [NSMutableArray arrayWithCapacity:1];
    BluetoothID *bleId = [[BluetoothID alloc] init];
    bleId.name = @"Abby's Light";
    bleId.uuid = @"0000";
    //bleId.type = self.light;
    bleId.autoConnect = TRUE;
    [bleIDArray addObject:bleId];
    //[self addToUserDefaults:bleId]; 
    self.bluetoothIDArray = bleIDArray;
    [self updateUserDefaults];
    */
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.navigationController) self.navigationController.toolbarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.navigationController) self.navigationController.toolbarHidden = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - TABLE VIEW DATA SOURCE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //determined by # of devices found
    if (!self.bluetoothDevices) return 0;
    return [self.bluetoothDevices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Bluetooth Device Description";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    // Configure the cell...
    //cell.textLabel.text = (NSString *)CFBridgingRelease(CFUUIDCreateString(nil, [[self.comm.ble.peripherals objectAtIndex:indexPath.row] UUID]));
    if (!self.bluetoothDevices) {
        cell.textLabel.text = @"New Device";
        return cell;
    }
    BluetoothDevice *bleDevice = [self.bluetoothDevices objectAtIndex:indexPath.row];
    if (bleDevice.bleId.name == nil) {
        bleDevice.bleId.name = @"New Device";
        
    }
    cell.textLabel.text = bleDevice.bleId.name;
    if (bleDevice.bleId.uuid) cell.detailTextLabel.text = bleDevice.bleId.uuid;
    if (bleDevice.image) cell.imageView.image = bleDevice.image;
    bleDevice.tableViewCell = cell;
    return cell;
}

#pragma mark - TABLE VIEW DELEGATE

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((![[self.bluetoothDevices objectAtIndex:indexPath.row] connected]) && ([[self.bluetoothDevices objectAtIndex:indexPath.row] discovered])) {
        //try to connect to the device
        self.shouldConnectToNextPeripheral = FALSE;
        [self connectToDevice:[self.bluetoothDevices objectAtIndex:indexPath.row]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //BluetoothDevice *device = [self.bluetoothDevices objectAtIndex:indexPath.row];
    //device.connected = TRUE;
    //[tableView reloadData];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    BluetoothDevice *device = [self.bluetoothDevices objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ShowBluetoothCell" sender:device];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    BluetoothDevice *device = [self.bluetoothDevices objectAtIndex:indexPath.row];
    if (device.connected) cell.backgroundColor = [UIColor greenColor];
    else cell.backgroundColor = [UIColor whiteColor];
    if (device.connecting) [self startSpinnerForBluetoothDevice:device];
    else if (cell.imageView.hidden) [self endSpinnerForBluetoothDevice:device];
    
}

#pragma mark BLUETOOTH SUPPORT METHODS

//send data to all devices at the same time
- (void)sendData:(NSData *)data {
    for (NSUInteger i=0;i<self.bluetoothDevices.count;i++) {
        BluetoothDevice *device = [self.bluetoothDevices objectAtIndex:i];
        if (device.connected) {
            if (device.pendingWrites < self.queue) {
                ++device.pendingWrites;
                [self.comm writeValue:LSGC_PASS_THROUGH_SERVICE_UUID ofCharacteristicUUID:LSGC_PASS_THROUGH_UUID toPeripheral:device.peripheral withData:data];
            }
            else {
                device.queue = [[BluetoothQueue alloc] init];
                device.queue.sent = FALSE;
                device.queue.serviceIDNumber = LSGC_PASS_THROUGH_SERVICE_UUID;
                device.queue.characteristicIDNumber = LSGC_PASS_THROUGH_UUID;
                device.queue.data = data;
            }
        }
    }
}

//send data to one peripheral from the queue
- (void)sendData:(NSData *)data toDevice:(BluetoothDevice *)device {
    [self.comm writeValue:LSGC_PASS_THROUGH_SERVICE_UUID ofCharacteristicUUID:LSGC_PASS_THROUGH_UUID toPeripheral:device.peripheral withData:data];
}

#pragma mark LSGC COMM PROTOCOL
- (void)sendDirectLabels:(NSArray *)array {
    Byte data[(array.count*2) +1];
    data[0] = COMMAND_COLORS_DIRECT;
    for (NSUInteger i=0;i<array.count;i++) {
        data[2*i+1] = [[[array objectAtIndex:i] text] floatValue]/100*COLOR_MIX_MAX;
        data[2*i+2] = [[[array objectAtIndex:i] text] floatValue]/100*COLOR_MIX_MAX/256;
    }
    NSData *d = [NSData dataWithBytes:data length:sizeof(data)];
    [self sendData:d];
}

- (void)sendDirectNumbers:(NSArray *)array {
    Byte data[(array.count*2) +1];
    data[0] = COMMAND_COLORS_DIRECT;
    for (NSUInteger i=0;i<array.count;i++) {
        data[2*i+1] = [[array objectAtIndex:i] floatValue]*COLOR_MIX_MAX;
        data[2*i+2] = [[array objectAtIndex:i] floatValue]*COLOR_MIX_MAX/256;
    }
    NSData *d = [NSData dataWithBytes:data length:sizeof(data)];
    [self sendData:d];
}

- (void)sendIntensityLabel:(UILabel *)intensity {
    Byte data[3];
    data[0] = COMMAND_INTENSITY_16BIT;
    data[1] = intensity.text.floatValue / 100 * COLOR_MIX_MAX;
    data[2] = intensity.text.floatValue / 100 * COLOR_MIX_MAX / 256;
    NSData *d = [NSData dataWithBytes:data length:sizeof(data)];
    [self sendData:d];
}

- (void)sendIntensityNumber:(NSNumber *)intensity {
    Byte data[3];
    data[0] = COMMAND_INTENSITY_16BIT;
    data[1] = intensity.floatValue * COLOR_MIX_MAX;
    data[2] = intensity.floatValue * COLOR_MIX_MAX / 256;
    NSData *d = [NSData dataWithBytes:data length:sizeof(data)];
    [self sendData:d];
}

- (void)sendColorMixLabels:(NSArray *)array {
    Byte data[(array.count*2) +1];
    data[0] = COMMAND_COLOR_MIX_16BIT;
    for (NSUInteger i=0;i<array.count;i++) {
        data[2*i+1] = [[[array objectAtIndex:i] text] floatValue]/100*COLOR_MIX_MAX;
        data[2*i+2] = [[[array objectAtIndex:i] text] floatValue]/100*COLOR_MIX_MAX/256;
    }
    NSData *d = [NSData dataWithBytes:data length:sizeof(data)];
    [self sendData:d];
}

- (void)sendColorMixNumbers:(NSArray *)array {
    Byte data[(array.count*2) +1];
    data[0] = COMMAND_COLOR_MIX_16BIT;
    for (NSUInteger i=0;i<array.count;i++) {
        data[2*i+1] = [[array objectAtIndex:i] floatValue]*COLOR_MIX_MAX;
        data[2*i+2] = [[array objectAtIndex:i] floatValue]*COLOR_MIX_MAX/256;
    }
    NSData *d = [NSData dataWithBytes:data length:sizeof(data)];
    [self sendData:d];
}

- (void)sendColorCode:(NSNumber *)colorCode {
    Byte data[2];
    data[0] = COMMAND_COLOR;
    data[1] = colorCode.unsignedCharValue;
    NSData *d = [NSData dataWithBytes:data length:sizeof(data)];
    [self sendData:d];
}

- (void)sendIntensityCode:(NSNumber *)intensityCode {
    Byte data[2];
    data[0] = COMMAND_INTENSITY;
    data[1] = intensityCode.unsignedCharValue;
    NSData *d = [NSData dataWithBytes:data length:sizeof(data)];
    [self sendData:d];
}

- (void)sendWhiteMix:(NSArray *)whiteMix {
    if (whiteMix.count < 2) return;
    Byte data[3];
    data[0] = COMMAND_WHITE_MIX;
    data[1] = [[whiteMix objectAtIndex:0] unsignedCharValue];
    data[2] = [[whiteMix objectAtIndex:1] unsignedCharValue];
    NSData *d = [NSData dataWithBytes:data length:sizeof(data)];
    [self sendData:d];
}

- (void)sendOnOff:(NSNumber *)onOff {
    Byte data[2];
    data[0] = COMMAND_ON_OFF;
    data[1] = onOff.unsignedCharValue;
    NSData *d = [NSData dataWithBytes:data length:sizeof(data)];
    [self sendData:d];
}

- (void)sendIntensityFadeFreq:(float)fadeFreq {
    Byte command = COMMAND_INTENSITY_FADE_FREQ;
    NSMutableData *data = [[NSData dataWithBytes:&command length:sizeof(command)] mutableCopy];
    [data appendData:[NSData dataWithBytes:&fadeFreq length:sizeof(float)]];
    [self sendData:data];
}

- (void)sendDirectFadeFreq:(float)fadeFreq {
    Byte command = COMMAND_DIRECT_FADE_FREQ;
    NSMutableData *data = [[NSData dataWithBytes:&command length:sizeof(command)] mutableCopy];
    [data appendData:[NSData dataWithBytes:&fadeFreq length:sizeof(float)]];
    [self sendData:data];
}

- (void)sendColorMixFadeFreq:(float)fadeFreq {
    Byte command = COMMAND_COLOR_MIX_FADE_FREQ;
    NSMutableData *data = [[NSData dataWithBytes:&command length:sizeof(command)] mutableCopy];
    [data appendData:[NSData dataWithBytes:&fadeFreq length:sizeof(float)]];
    [self sendData:data];
}

//PRIZMALINE
- (void)sendDataString:(NSData *)data {
    [self sendData:data];
}

#pragma mark BLUETOOTH CELL VIEW CONTROLLER DELEGATE

- (void)sender:(BluetoothCellViewController *)cell saveId:(BOOL)save {
    NSInteger index = [self findBleIdInArray:cell.bluetoothDevice.bleId];
    if (save) {
        //either add a bleId or replace a bleID        
        if (index >= 0) {
            [[self.bluetoothIDArray objectAtIndex:index] setName:cell.bluetoothDevice.bleId.name];
            [[self.bluetoothIDArray objectAtIndex:index] setAutoConnect:cell.bluetoothDevice.bleId.autoConnect];
            cell.bluetoothDevice.bleId = [self.bluetoothIDArray objectAtIndex:index];
        }
        else {
            NSMutableArray *bleIdArray = [self.bluetoothIDArray mutableCopy];
            [bleIdArray addObject:cell.bluetoothDevice.bleId];
            self.bluetoothIDArray = bleIdArray;
            cell.bluetoothDevice.bleId = [self.bluetoothIDArray lastObject];
        }
    }
    else {
        if (index >= 0) {
            NSMutableArray *bleIDArray = [self.bluetoothIDArray mutableCopy];
            [bleIDArray removeObjectAtIndex:index];
            self.bluetoothIDArray = bleIDArray;
            BluetoothID *bleId = [[BluetoothID alloc] initWithName:@"New Device" andUUID:cell.bluetoothDevice.bleId.uuid andAutoConnect:TRUE];
            cell.bluetoothDevice.bleId = bleId;
        }
    }
    //UPDATE THE BLUETOOTH DEVICE WITH THE NEW BLUETOOTH ID
    [self updateUserDefaults];
    [self.tableView reloadData];
    [cell idSaved:save];
}

- (void)connectSender:(BluetoothCellViewController *)cell {
    if (cell.bluetoothDevice.connected) {
        [self.comm cancelPeripheral:cell.bluetoothDevice.peripheral];
    }
    else {
        self.shouldConnectToNextPeripheral = FALSE;
        [self connectToDevice:cell.bluetoothDevice];
    }
}

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter {
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

#pragma mark SPLIT VIEW CONTROLLER DELEGATE METHODS

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return [self splitViewBarButtonItemPresenter] ? ((orientation == UIInterfaceOrientationPortrait) || (orientation == UIInterfaceOrientationPortraitUpsideDown)) : NO;
    //return FALSE;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    barButtonItem.title = @"Bluetooth";
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
    
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController {
    //if (!pc) {
    //   pc = [[UIPopoverController alloc] initWithContentViewController:self.navigationController];
    //}
    /*
     //pc = self;
     id controller1 = [self.splitViewController.viewControllers objectAtIndex:0];
     id controller2 = [self.splitViewController.viewControllers objectAtIndex:1];
     id controller3 = pc.contentViewController;
     id controller4 = self.navigationController;
     //id controller5 = svc.
     if ((controller1 == controller2) && (controller4 == controller3)) return;
     */
}

@end
