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

//-------------
// Controls
//-------------
- (IBAction)compassSegmentControl:(id)sender;
- (IBAction)wedgeSegmentControl:(id)sender;


@end
