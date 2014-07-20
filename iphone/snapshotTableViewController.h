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

@interface snapshotTableViewController : UIViewController<UITableViewDelegate, UIAlertViewDelegate>



@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property compassMdl* model;
@property iOSViewController* rootViewController;

//---------------
// iPad
//---------------
- (IBAction)dismissModalVC:(id)sender;


//---------------
// Parking lot
//---------------
@property bool needUpdateAnnotations;
@property bool needToggleLocationService;
- (IBAction)toggleLandmakrSelection:(id)sender;

- (IBAction)toggleEditing:(id)sender;
- (IBAction)saveKML:(id)sender;
- (IBAction)saveKMLAs:(id)sender;
@end






