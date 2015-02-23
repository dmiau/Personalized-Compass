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
// Update + Init Methods
//-------------
- (void) prepareWindow;
- (void) updateLocationsPane;
- (void) updateConfigurationsPane;

//-------------
// Configurations pane
//-------------
@property (weak) IBOutlet NSButton *whiteBackgroundCheckbox;

@property (weak) IBOutlet NSTextField *desktopDropboxDataRoot;
- (IBAction)changeDesktopDropboxDataRoot:(id)sender;
- (IBAction)toggleLabels:(id)sender;


// Control the visibility of OpenGL view
- (IBAction)toggleBlankBackground:(id)sender;

- (IBAction)toggleGLView:(id)sender;
@property (weak) IBOutlet NSSegmentedControl *compassSegmentControl;
@property (weak) IBOutlet NSSegmentedControl *wedgeSegmentControl;

// Control to show or hide the compass
- (IBAction)compassSegmentControl:(id)sender;

// Control to show or hide the wedge
- (IBAction)wedgeSegmentControl:(id)sender;

// Disable/enable iOS sync
- (IBAction)toggleiOSSyncFlag:(id)sender;
- (IBAction)toggleiOSBoundary:(id)sender;
- (IBAction)toggleiOSScreenOnly:(id)sender;

// emulated iOS visualization control
@property (weak) IBOutlet NSButton *iOSBoundaryControl;
@property (weak) IBOutlet NSButton *iOSMaskControl;
@property (weak) IBOutlet NSSegmentedControl *iOSEmulationSegmentControl;
- (IBAction)toggleiOSEumulation:(id)sender;


// Adjust the iOS screen size
- (IBAction)adjustiOSScreenSize:(id)sender;
@property (weak) IBOutlet NSSlider *iOSScale;
@property NSString* iOSScreenStr;

// Adjust wedge parameters
- (IBAction)adjustWedgeCorrectionFactor:(id)sender;
@property (weak) IBOutlet NSSlider *wedgeCorrectionFactor;

// Disable/enable the server
@property NSNumber* serverSegmentIndex;
- (IBAction)toggleServer:(id)sender;

//-------------
// Locations pane
//-------------
@property (weak) IBOutlet NSComboBox *kmlComboBox;

// KML combo box
- (IBAction)didChangeKMLCombo:(id)sender;
- (IBAction)toggleLandmarkSelection:(id)sender;
- (IBAction)refreshLocationTable:(id)sender;
- (IBAction)emptyAllLocations:(id)sender;

// Annotation control

@property (weak) IBOutlet NSSegmentedControl *showPinSegmentControl;
@property (weak) IBOutlet NSSegmentedControl *createPinSegmentControl;
@property (weak) IBOutlet NSSegmentedControl *multipleAnnotationsControl;

// Control whether multiple annotations can be displayed
// simultaneously
- (IBAction)annotationNumberSegmentControl:(id)sender;

- (IBAction)pinSegmentControl:(id)sender;
- (IBAction)createPinSegmentControl:(id)sender;


// Model control
@property (weak) IBOutlet NSButton *landmarkLock;

- (IBAction)toggleLandmarkLock:(NSButton*)sender;

@property (weak) IBOutlet NSSegmentedControl *dataPrefilterControl;
@property (weak) IBOutlet NSSegmentedControl *dataSelectionControl;
- (IBAction)dataPrefilterSegmentControl:(NSSegmentedControl*)sender;
- (IBAction)dataSelectionSegmentControl:(NSSegmentedControl*)sender;
- (IBAction)saveKML:(id)sender;
- (IBAction)saveKMLAs:(id)sender;

//-------------
// Test Manager
//-------------
//- (IBAction)generateTests:(id)sender;

// Properties for parameter binding
//@property NSNumber* close_begin_x;
//@property NSNumber* close_end_x;
//@property NSNumber* close_n; // # of locations in the close category
//@property NSNumber* far_begin_x;
//@property NSNumber* far_end_x;
//@property NSNumber* far_n; // # of locations in the far category
//@property NSNumber* participant_n; // # of users
//@property NSNumber* participant_id;
@end
