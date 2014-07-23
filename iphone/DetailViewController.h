//
//  DetailViewController.h
//  Compass[transparent]
//
//  Created by dmiau on 7/5/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "compassModel.h"
#import "iOSViewController.h"

@interface DetailViewController : UIViewController

@property iOSViewController *rootViewController;

@property CustomPointAnnotation *annotation;
@property (weak, nonatomic) IBOutlet UITextView *addressView;
@property compassMdl* model;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *noteTextField;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property BOOL needUpdateAnnotation;

@property (weak, nonatomic) IBOutlet UISegmentedControl *statusSegmentControl;


- (IBAction)doneEditing:(id)sender;
- (IBAction)addLocation:(id)sender;
- (IBAction)removeLocation:(id)sender;
- (IBAction)toggleEnable:(id)sender;

- (IBAction)dismissModalVC:(id)sender;
@end
