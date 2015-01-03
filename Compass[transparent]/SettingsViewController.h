//
//  SettingsViewController.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "compassModel.h"
#import "DesktopViewController.h"

@interface SettingsViewController : NSViewController

@property compassMdl *model;
@property DesktopViewController *rootViewController;
@property (weak) IBOutlet NSTextField *serverPort;

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




@end
