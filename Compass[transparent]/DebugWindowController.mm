//
//  DebugWindowController.m
//  Compass[transparent]
//
//  Created by dmiau on 4/29/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DebugWindowController.h"
//#include "jsonReader.h"

@interface DebugWindowController ()

@end

@implementation DebugWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        self.model = compassMdl::shareCompassMdl();
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSString *file_str = [NSString stringWithUTF8String:
                          self.model->configuration_filename.c_str()];
    
    [[self configuration_file_path] setStringValue: file_str];
}

- (IBAction)reloadConfigurationFile:(id)sender {
    // Reload configuations
    readConfigurations(self.model);
}
@end
