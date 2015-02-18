//
//  iOSTestAuthoringViewController.h
//  Compass[transparent]
//
//  Created by Daniel on 2/12/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "compassModel.h"
#import "iOSViewController.h"

@interface iOSTestAuthoringViewController : UIViewController<UITableViewDelegate, UIAlertViewDelegate>{
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property compassMdl* model;
@property iOSViewController* rootViewController;

@property (weak, nonatomic) IBOutlet UISwitch *authoringModeControl;

- (IBAction)toggleAuthoringMode:(id)sender;
@end
