//
//  myTableViewController.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "compassModel.h"

@interface myTableViewController : UIViewController
<UITableViewDelegate, UIAlertViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property compassMdl* model;
@property bool needUpdateAnnotations;
- (IBAction)toggleLandmakrSelection:(id)sender;

- (IBAction)toggleEditing:(id)sender;
- (IBAction)saveKML:(id)sender;
- (IBAction)saveKMLAs:(id)sender;

@end
