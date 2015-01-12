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

@property compassMdl *model;
@property DesktopViewController *rootViewController;
@property NSString *server_ip;
@property (weak) IBOutlet NSTextField *serverPort;

//-------------
// Methods
//-------------
- (void) prepareWindow;


//-------------
// Controls
//-------------

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

// Disable/enable the landmark list
- (IBAction)toggleLandmarkTableView:(id)sender;

// Disable/enable iOS sync
- (IBAction)toggleiOSSyncFlag:(id)sender;
- (IBAction)toggleiOSBoundary:(id)sender;
- (IBAction)toggleiOSScreenOnly:(id)sender;

// Adjust the iOS screen size
- (IBAction)adjustiOSScreenSize:(id)sender;
@property (weak) IBOutlet NSSlider *iOSScale;

// Adjust wedge parameters
- (IBAction)adjustWedgeCorrectionFactor:(id)sender;
@property (weak) IBOutlet NSSlider *wedgeCorrectionFactor;



@end
