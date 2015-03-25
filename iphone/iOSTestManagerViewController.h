//
//  iOSTestManagerViewController.h
//  Compass[transparent]
//
//  Created by Daniel on 2/11/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "compassModel.h"
#import "iOSViewController.h"

@interface iOSTestManagerViewController : UIViewController<UITableViewDelegate, UIAlertViewDelegate>{
    int selected_snapshot_id;
    
    NSArray* snapshot_file_array;
    bool dirty_flag;
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property compassMdl* model;
@property iOSViewController* rootViewController;
@property NSString *folderAfterExit;
// Keeps tracking the folder path AFTER leaving this pane

@property (weak, nonatomic) IBOutlet UISwitch *studyModeSwitch;
- (IBAction)toggleStudyMode:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *testStatus;
- (IBAction)pingOSX:(id)sender;
@end
