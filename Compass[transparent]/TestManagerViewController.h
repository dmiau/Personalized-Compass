//
//  TestManagerViewController.h
//  Compass[transparent]
//
//  Created by Daniel on 2/11/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "compassModel.h"
#import "DesktopViewController.h"

@interface TestManagerViewController : NSViewController
//-------------
// Properties
//-------------
@property compassMdl *model;
@property DesktopViewController *rootViewController;

//-------------
// Test Manager
//-------------
- (IBAction)generateTests:(id)sender;

// Properties for parameter binding
@property NSNumber* close_begin_x;
@property NSNumber* close_end_x;
@property NSNumber* close_n; // # of locations in the close category
@property NSNumber* far_begin_x;
@property NSNumber* far_end_x;
@property NSNumber* far_n; // # of locations in the far category
@property NSNumber* participant_n; // # of users
@property NSNumber* participant_id;

// Visualization check box
@property NSNumber* viz_pcompass;
@property NSNumber* viz_wedge;
@property NSNumber* viz_overview;

// Display check box
@property NSNumber* disp_phone;
@property NSNumber* disp_watch;

// Tasks check box
@property NSNumber* task_locate;
@property NSNumber* task_triangulate;
@property NSNumber* task_orient;
@property NSNumber* task_closest;

@end
