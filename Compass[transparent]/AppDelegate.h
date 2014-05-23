//
//  AppDelegate.h
//  Compass[transparent]
//
//  Created by dmiau on 3/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "compassModel.h"
#include "DebugWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    DebugWindowController *debugWindowController;
    NSWindowController *styleWindowController;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)showDebugInfo:(id)sender;

- (IBAction)showStyleSelector:(id)sender;
@end
