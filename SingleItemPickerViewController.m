//
//  SingleItemPickerViewController.m
//  Adaptable
//
//  Created by Matthew Regan on 6/22/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import "SingleItemPickerViewController.h"

@interface SingleItemPickerViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *singleItemPicker;
@property (nonatomic) NSUInteger rowSelected;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation SingleItemPickerViewController
@synthesize singleItemPicker = _singleItemPicker;
@synthesize pickerTitle = _pickerTitle;
@synthesize pickerItems = _pickerItems;
@synthesize rowSelected = _rowSelected;
@synthesize titleLabel = _titleLabel;
@synthesize delegate = _delegate;

#pragma mark PICKER DATA SOURCE METHODS
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.pickerItems) return self.pickerItems.count;
    else return 0;
}

//there is only one component in the picker, which is an array of CCTs
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

#pragma mark PICKER DELEGATE METHODS
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.rowSelected = row;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return pickerView.bounds.size.width*.9;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 50;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.pickerItems objectAtIndex:row];
}

#pragma mark BUTTON ACTIONS

- (IBAction)select:(UIButton *)sender {
    [self.delegate singleItemPickerViewController:self didSelectRow:self.rowSelected];
    //if (self.navigationController) [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)exit:(UIButton *)sender {
    [self.delegate singleItemPickerViewControllerIsFinished:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.singleItemPicker.delegate = self;
    self.singleItemPicker.dataSource = self;
    if (self.pickerTitle) self.titleLabel.text = self.pickerTitle;
    else self.titleLabel.text = @"";
}

- (void)viewDidUnload
{
    [self setSingleItemPicker:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
