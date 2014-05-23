//
//  DebugWindowController.h
//  Compass[transparent]
//
//  Created by dmiau on 4/29/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "compassModel.h"

@interface DebugWindowController : NSWindowController

@property (weak) IBOutlet NSTextField *configuration_file_path;

- (IBAction)reloadConfigurationFile:(id)sender;
@property compassMdl* model;
@end
