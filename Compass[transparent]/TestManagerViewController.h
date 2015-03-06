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

// Properties for parameter binding
@property NSNumber* participant_n; // # of users


// File names
// Test generation parameters
// These parameters specify where the generated tests should go
@property NSString *test_foldername;          //e.g., study0
@property NSString *test_kml_filename;        //e.g., t_locations.kml
@property NSString *test_location_filename;   //e.g., temp.locations
@property NSString *alltest_vector_filename;     //e.g., allTestVectors.tests
@property NSString *test_snapshot_prefix;     //e.g., snapshot-participant0.kml
@property NSString *practice_filename;        //e.g., practice.snapshot
@property NSString *record_filename;
@property NSString *custom_test_vectorname;

//-------------
// Manual test creation
//-------------

// Test generation methods
- (IBAction)generateTests:(id)sender;
- (IBAction)generateTestFromCustomVector:(id)sender;
- (IBAction)reloadTaskSpec:(id)sender;

// Actions
- (IBAction)resetManualTestCreation:(id)sender;
- (IBAction)addTestLocations:(id)sender;
- (IBAction)addiOSCoordRegion:(id)sender;
- (IBAction)addOSXCoordRegion:(id)sender;
- (IBAction)commitTestToMemory:(id)sender;
- (IBAction)generateManualTests:(id)sender;

@end
