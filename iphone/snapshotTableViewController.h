//
//  snapshotTableViewController.h
//  Compass[transparent]
//
//  Created by dmiau on 7/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "compassModel.h"
#import "iOSViewController.h"

@interface snapshotTableViewController : UIViewController<UITableViewDelegate, UIAlertViewDelegate>{
    int selected_snapshot_id;
    
    NSArray* snapshot_file_array;
    bool dirty_flag;
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property compassMdl* model;
@property iOSViewController* rootViewController;

- (IBAction)saveKML:(id)sender;
- (IBAction)saveSnspahotAs:(id)sender;
- (IBAction)reloadSnapshotFile:(id)sender;


//---------------
// Parking lot
//---------------
- (IBAction)toggleLandmakrSelection:(id)sender;

- (IBAction)toggleEditing:(id)sender;

@end






