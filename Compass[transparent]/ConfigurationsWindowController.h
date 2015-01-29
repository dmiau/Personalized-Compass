//
//  ConfigurationsWindowController.h
//  Compass[transparent]
//
//  Created by dmiau on 12/24/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "compassModel.h"
#import "DesktopViewController.h"

@interface ConfigurationsWindowController : NSWindowController
<NSTableViewDataSource, NSTableViewDelegate>{
    // Location pane
    NSArray *kml_files;
}

//-------------
// Properties
//-------------
@property compassMdl *model;
@property DesktopViewController *rootViewController;
@property NSString *server_ip;
@property (weak) IBOutlet NSTextField *serverPort;
@property (weak) IBOutlet NSTableView *locationTableView;


//-------------
// Methods
//-------------
- (void) prepareWindow;


//-------------
// Configurations pane
//-------------

@property (weak) IBOutlet NSTextField *desktopDropboxDataRoot;
- (IBAction)changeDesktopDropboxDataRoot:(id)sender;


// Control the visibility of OpenGL view
- (IBAction)toggleGLView:(id)sender;


// Control to show or hide the compass
- (IBAction)compassSegmentControl:(id)sender;

// Control to show or hide the wedge
- (IBAction)wedgeSegmentControl:(id)sender;

// Control whether multiple annotations can be displayed
// simultaneously
- (IBAction)annotationNumberSegmentControl:(id)sender;

// Disable/enable the server
- (IBAction)toggleServer:(id)sender;

// Disable/enable iOS sync
- (IBAction)toggleiOSSyncFlag:(id)sender;
- (IBAction)toggleiOSBoundary:(id)sender;
- (IBAction)toggleiOSScreenOnly:(id)sender;

// Adjust the iOS screen size
- (IBAction)adjustiOSScreenSize:(id)sender;
@property (weak) IBOutlet NSSlider *iOSScale;
@property NSString* iOSScreenStr;

// Adjust wedge parameters
- (IBAction)adjustWedgeCorrectionFactor:(id)sender;
@property (weak) IBOutlet NSSlider *wedgeCorrectionFactor;

//-------------
// Locations pane
//-------------
@property (weak) IBOutlet NSComboBox *kmlComboBox;

// KML combo box
- (IBAction)didChangeKMLCombo:(id)sender;
- (IBAction)toggleLandmarkSelection:(id)sender;

// Model control
@property (weak) IBOutlet NSSegmentedControl *dataSegmentControl;
@property (weak) IBOutlet NSSegmentedControl *filterSegmentControl;

- (IBAction)toggleLandmarkLock:(NSButton*)sender;
- (IBAction)filterTypeSegmentControl:(NSSegmentedControl*)sender;
- (IBAction)dataPrefilterSegmentControl:(NSSegmentedControl*)sender;


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
@end
