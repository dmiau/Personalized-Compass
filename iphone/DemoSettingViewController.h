//
//  DemoSettingViewController.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/1/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSViewController.h"

@interface debugCell :UITableViewCell
@property UISwitch* mySwitch;
@property iOSViewController* rootViewController;
@property param* param_ptr;
@end

@interface DemoSettingViewController : UIViewController
<UITableViewDelegate, UIAlertViewDelegate>{
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property DemoManager* demoManager;

@property iOSViewController* rootViewController;
- (IBAction)generateTests:(id)sender;


- (IBAction)dismissModalVC:(id)sender;
@end
