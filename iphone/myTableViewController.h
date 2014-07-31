//
//  myTableViewController.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "compassModel.h"
#import "iOSViewController.h"

@interface myTableViewController : UIViewController
<UITableViewDelegate, UIAlertViewDelegate>{
    int selected_id;
    bool data_dirty_flag;
}


@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property compassMdl* model;
@property iOSViewController* rootViewController;
@property (weak, nonatomic) IBOutlet UIToolbar *saveButton;

- (IBAction)toggleLandmakrSelection:(id)sender;
- (IBAction)toggleEditing:(id)sender;
- (IBAction)saveKML:(id)sender;
- (IBAction)saveKMLAs:(id)sender;

- (IBAction)dismissModalVC:(id)sender;
@end
