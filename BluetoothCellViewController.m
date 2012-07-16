//
//  BluetoothCellViewController.m
//  DirectDriver
//
//  Created by Matthew Regan on 6/5/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import "BluetoothCellViewController.h"
#import "BluetoothDevice.h"

@interface BluetoothCellViewController () <UITextFieldDelegate>
@property (nonatomic, strong) NSString *typeOfLight;
@property (nonatomic) BOOL shouldHighlightSaveId;
@property (nonatomic, strong) UISwitch *autoConnectSwitch;
@property (nonatomic, strong) NSString *name;
@end

@implementation BluetoothCellViewController

@synthesize bluetoothDevice = _bluetoothDevice;
@synthesize typeOfLight = _typeOfLight;
@synthesize shouldHighlightSaveId = _shouldHighlightSaveId;
@synthesize autoConnectSwitch = _autoConnectSwitch;
@synthesize delegate = _delegate;
@synthesize name = _name;

- (void)assignBluetoothDevice:(BluetoothDevice *)device andLight:(NSString *)light {
    self.bluetoothDevice = device;
    self.typeOfLight = light;
}

- (void)idSaved:(BOOL)saved {
    if (saved) {
        //make the saveId a white background
        self.shouldHighlightSaveId = FALSE;
        [self.tableView reloadData];
    }
    else {
        //make the name cell name gray
    }
}

- (void)deviceConnected:(BOOL)connected {
    self.bluetoothDevice.connected = connected;
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0) return 5;
    else if (section == 1) return 3;
    else return 0;
}

- (IBAction)autoConnect:(UISwitch *)sender {
    self.shouldHighlightSaveId = TRUE;
    if (!sender.on) [sender setOn:FALSE];
    else [sender setOn:TRUE];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    UITableViewCell *cell; 
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cellIdentifier = @"name";
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            //create a UITextField in the same place as the textLabel
            //UITextField *edit = [[UITextField alloc] initWithFrame:CGRectMake(cell.textLabel.bounds.origin.x + 10, cell.contentView.bounds.size.height/3, cell.textLabel.bounds.size.width, cell.textLabel.bounds.size.height)];
            UITextField *edit = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, cell.contentView.bounds.size.width - 10, cell.contentView.bounds.size.height - 10)];
            edit.delegate = self;
            UIFont * font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
            [edit setFont:font];
            //cell.textLabel.text = self.bluetoothDevice.bleId.name;
            if (!self.name) self.name = self.bluetoothDevice.bleId.name;
            
            
            if ([self.name isEqualToString:@"New Device"]) edit.placeholder = self.name;
            else edit.text = self.name;
            //[cell.contentView addSubview:edit];
            [cell.contentView insertSubview:edit atIndex:0];
            //cell.accessoryView = edit;
            
            
            //if ([cell.textLabel.text isEqualToString:@"New Device"]) cell.textLabel.textColor = [UIColor lightGrayColor];
        }
        else if (indexPath.row == 1) {
            cellIdentifier = @"uuid";
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            if (self.bluetoothDevice.bleId.uuid) {
                cell.textLabel.text = self.bluetoothDevice.bleId.uuid;
                cell.detailTextLabel.text = @"UUID";
            }
            else cell.textLabel.text = @"No UUID";
        }
        else if (indexPath.row == 2) {
            cellIdentifier = @"autoConnect";
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.textLabel.text = @"Auto Connect";
            if (!self.autoConnectSwitch) {
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                if (self.bluetoothDevice.bleId.autoConnect) [switchView setOn:TRUE];
                else [switchView setOn:FALSE];
                [switchView addTarget:self action:@selector(autoConnect:) forControlEvents:UIControlEventValueChanged];
                self.autoConnectSwitch = switchView;
            }
            cell.accessoryView = self.autoConnectSwitch;
        }
        else {
            cellIdentifier = @"status";
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            if (indexPath.row == 3) {
                if (self.bluetoothDevice.discovered) cell.textLabel.text = @"Discovered";
                else cell.textLabel.text = @"Not Discovered";
            }
            else if (indexPath.row == 4) {
                if (self.bluetoothDevice.connected) cell.textLabel.text = @"Connected";
                else cell.textLabel.text = @"Not Connected";
            }
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }
    }
    else if (indexPath.section == 1) {
        cellIdentifier = @"option";
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryView.hidden = TRUE;
        if (indexPath.row == 0) cell.textLabel.text = @"Save ID";
        if (indexPath.row == 1) cell.textLabel.text = @"Remove ID";
        if (indexPath.row == 2) {
            if (self.bluetoothDevice.connected) cell.textLabel.text = @"Disconnect";
            else cell.textLabel.text = @"Connect";
            if (!self.bluetoothDevice.discovered) {
                cell.textLabel.textColor = [UIColor grayColor];
                cell.userInteractionEnabled = FALSE;
            }
            else {
                cell.textLabel.textColor = [UIColor blackColor];
                cell.userInteractionEnabled = TRUE;
            }
        }
        if (indexPath.row >= 3) cell.textLabel.text = @"N/A";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
    else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"option"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.row == 0) && (indexPath.section == 1)) {
        if (self.shouldHighlightSaveId) cell.backgroundColor = [UIColor redColor];
        else cell.backgroundColor = [UIColor whiteColor];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            /*
            cell.textLabel.hidden = TRUE;
            //create a UITextField in the same place as the textLabel
            UITextField *edit = [[UITextField alloc] initWithFrame:CGRectMake(cell.textLabel.bounds.origin.x + 10, cell.contentView.bounds.size.height/3, cell.textLabel.bounds.size.width, cell.textLabel.bounds.size.height)];
            edit.delegate = self;
            [cell.contentView insertSubview:edit atIndex:0];
             */
            //[edit becomeFirstResponder];
        }
    }
    else if (indexPath.section == 1) {
        //delegate method based on cell selected
        if (indexPath.row == 0) {
            self.bluetoothDevice.bleId.autoConnect = self.autoConnectSwitch.on;
            self.bluetoothDevice.bleId.name = self.name;
            [self.delegate sender:self saveId:TRUE];
        }
        else if (indexPath.row == 1) [self.delegate sender:self saveId:FALSE];
        else if (indexPath.row == 2) [self.delegate connectSender:self];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UI TEXT FIELD DELEGATE METHODS
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //called when return key is pressed
    [textField resignFirstResponder];
    return TRUE;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //called when carot goes away
    //[textField resignFirstResponder];
    if ((![textField.text isEqualToString:@""]) && (![textField.text isEqualToString:self.name])) {
        self.shouldHighlightSaveId = TRUE;
        self.name = textField.text;
        //UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        //UITextField *cellTextField = [cell.contentView.subviews objectAtIndex:0];
        //cellTextField.text = textField.text;
    }
    else {
        textField.text = self.name;
    }
    
    [self.tableView reloadData];
}


@end
