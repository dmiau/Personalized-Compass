//
//  DemoSettingViewController.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/1/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSViewController.h"


@interface DemoSettingViewController : UIViewController
<UITableViewDelegate, UIAlertViewDelegate>{
        NSArray* snapshot_file_array;
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property DemoManager* demoManager;
@property compassMdl* model;
@property iOSViewController* rootViewController;
- (IBAction)generateTests:(id)sender;

@property (weak, nonatomic) IBOutlet UISwitch *demoSwitch;
- (IBAction)toggleDemoSwitch:(id)sender;

- (IBAction)dismissModalVC:(id)sender;
@end
