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

@property NSString* serverInfoString;
@property NSString* testMessage;


// Dev mode
@property (weak) IBOutlet NSSegmentedControl *studyModeSegmentControl;
- (IBAction)toggleStudyMode:(id)sender;

// Load files
@property NSNumber* participant_id;
- (IBAction)loadStudyFiles:(id)sender;

// File paths
@property NSString* practice_filepath;
@property NSString* snapshot_filepath;
@property NSString* record_filepath;
@property NSString* test_kml_path;

// Test flow buttons
@property NSNumber* isPracticeButtonEnabled;
@property NSNumber* isEndPracticeButtonEnabled;
@property NSNumber* isPauseButtonEnabled;
@property NSNumber* isResumeButtonEnabled;
@property NSNumber* isEndButtonEnabled;

// Test flow controls
- (IBAction)checkPairingAndStartPracticing:(id)sender;
- (IBAction)endPracticingAndStartStudy:(id)sender;
- (IBAction)pauseStudy:(id)sender;
- (IBAction)resumeStudy:(id)sender;
- (IBAction)endStudy:(id)sender;

// Save record
- (IBAction)changeRecordFileName:(id)sender;
@property (weak) IBOutlet NSTextField *recordFileNameTextField;
- (IBAction)saveStudyRecords:(id)sender;

// Auto save button
@property (weak) IBOutlet NSButton *autoSaveCheckbox;
- (IBAction)toggleAutoSave:(id)sender;

@end
