//
//  iOSSettingViewController.h
//  Compass[transparent]
//
//  Created by dmiau on 6/13/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <GLKit/GLKit.h>
#include "compassModel.h"
#include "compassRender.h"
#include <iostream>
#import "iOSGLKView.h"

#import "iOSViewController.h"


@interface iOSSettingViewController : UIViewController<UIAlertViewDelegate>
{
    BOOL pinVisible;
}

@property compassMdl* model;
@property compassRender* renderer;
@property iOSViewController* rootViewController;

- (IBAction)toggleDataSource:(id)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *dataSource;
@property (weak, nonatomic) IBOutlet UISegmentedControl *toolbarSegmentControl;

- (IBAction)toggleToolbarMode:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *systemMessage;

- (IBAction)dismissModalVC:(id)sender;
- (IBAction)refreshConfiguraitons:(id)sender;

//--------------
// Label Control
//--------------
- (IBAction)labelSegmentControl:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *labelControl;

//--------------
// Communication
//--------------
@property (weak, nonatomic) IBOutlet UITextField *portTextfield;
@property (weak, nonatomic) IBOutlet UITextField *ipTextField;

- (IBAction)toggleServerConnection:(id)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *serverSegmentControl;

//--------------
// Normal/Watch mode
//--------------
@property (weak, nonatomic) IBOutlet UISegmentedControl *watchModeControl;
- (IBAction)toggleWatchMode:(id)sender;



@end
