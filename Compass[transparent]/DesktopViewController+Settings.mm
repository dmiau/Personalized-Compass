//
//  DesktopViewController+Settings.m
//  Compass[transparent]
//
//  Created by dmiau on 8/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+Settings.h"
#import "ConfigurationsWindowController.h"

@implementation DesktopViewController (Settings)

#pragma mark -------- Configuration Window
- (IBAction)showConfigurationsWindow:(id)sender {
    
    if (!self.configurationWindowController){
        self.configurationWindowController =
        [[ConfigurationsWindowController alloc] initWithWindowNibName:@"ConfigurationsWindow"];
        
        self.configurationWindowController.rootViewController = self;
    }
    
    [self.configurationWindowController showWindow:nil];
    [[self.configurationWindowController window] setIsVisible:YES];
}

@end
