//
//  WebViewController.h
//  lab_webkit
//
//  Created by dmiau on 4/24/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WebKit/WebKit.h"
#import "DesktopViewController.h"

@interface WebViewController : NSViewController{
    NSTimer *_updateUITimer;
    NSString *preURL;
}

@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet NSTextField *textField;
@property NSString *URL;

- (IBAction)updateURL:(id)sender;
- (IBAction)fetchURL:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;

- (void) vcTimerFired;
- (void) updateCompassMode;

@property (unsafe_unretained) IBOutlet DesktopViewController *desktopViewController;

@end
