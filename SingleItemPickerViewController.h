//
//  SingleItemPickerViewController.h
//  Adaptable
//
//  Created by Matthew Regan on 6/22/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SingleItemPickerViewController;

@protocol SingleItemPickerViewControllerDelegate 
@optional
- (void)singleItemPickerViewController:(SingleItemPickerViewController *)picker didSelectRow:(NSUInteger)row;
- (void)singleItemPickerViewControllerIsFinished:(SingleItemPickerViewController *)picker; 
@end

@interface SingleItemPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) NSString *pickerTitle;
@property (strong, nonatomic) NSArray *pickerItems;
@property (nonatomic, retain) id <SingleItemPickerViewControllerDelegate> delegate;

@end
