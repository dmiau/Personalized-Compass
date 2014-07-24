//
//  breadcrumbTableViewController.h
//  Compass[transparent]
//
//  Created by dmiau on 7/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "compassModel.h"
#import "iOSViewController.h"

@interface breadcrumbTableViewController : UIViewController<UITableViewDelegate, UIAlertViewDelegate>{
    int starting_index;
    NSArray* history_file_array;
    NSString* selected_filename;
    bool dirty_flag;
}


@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property compassMdl* model;
@property iOSViewController* rootViewController;

- (IBAction)saveKML:(id)sender;

//---------------
// iPad
//---------------
- (IBAction)dismissModalVC:(id)sender;


@end
