//
//  UserStudyViewController.h
//  Compass[transparent]
//
//  Created by Daniel on 2/18/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "compassModel.h"
#import "DesktopViewController.h"

@interface UserStudyViewController : NSViewController

//-------------
// Properties
//-------------
@property compassMdl *model;
@property DesktopViewController *rootViewController;

@property (weak) IBOutlet NSSegmentedControl *studyModeSegmentControl;
@property (weak) IBOutlet NSTextField *recordFileNameTextField;

- (IBAction)toggleStudyMode:(id)sender;
- (IBAction)saveStudyRecords:(id)sender;

- (IBAction)changeRecordFileName:(id)sender;
@end
