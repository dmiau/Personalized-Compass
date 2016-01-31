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

#pragma mark -----landmarkCell-----
@interface landmarkCell :UITableViewCell
@property UISwitch* mySwitch;
@property iOSViewController* rootViewController;
@property data* data_ptr;
@property bool isUserLocation;
@end


#pragma mark -----myTableViewController-----
@interface myTableViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>{
    int selected_id;
    bool data_dirty_flag;
    
    //In CoreData code base, kml_files is replaced by areas
    NSArray *kml_files;
    NSArray *areas;
    
    //this flag decides whether the kml file section should be expanded or collapsed
    bool expandAreaSection;
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property compassMdl* model;
@property iOSViewController* rootViewController;
@property (weak, nonatomic) IBOutlet UIToolbar *saveButton;

- (IBAction)toggleLandmakrSelection:(id)sender;
- (IBAction)toggleEditing:(id)sender;
- (IBAction)newKML:(id)sender;
- (IBAction)saveKML:(id)sender;
- (IBAction)saveKMLAs:(id)sender;
@end
