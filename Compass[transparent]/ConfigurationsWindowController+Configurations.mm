//
//  ConfigurationsWindowController+Configurations.m
//  Compass[transparent]
//
//  Created by Daniel on 2/3/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "ConfigurationsWindowController.h"
#import "HTTPServer.h"
#import "GCDAsyncSocket.h"

@implementation ConfigurationsWindowController (Configurations)

//--------------------
// Refresh the configuration pane
//--------------------
- (void) updateConfigurationsPane{
    // Update the dropbox root
    [self.desktopDropboxDataRoot setStringValue:
     self.model->desktopDropboxDataRoot];
    
    // Update the white background checkbox
    self.whiteBackgroundCheckbox.state =
    self.rootViewController.isBlankMapEnabled;    
    
    // Update compass status
    if ([self.model->configurations[@"personalized_compass_status"]
         isEqualToString:@"off"])
    {
        self.compassSegmentControl.selectedSegment = 0;
    }else if ([self.model->configurations[@"personalized_compass_status"]
               isEqualToString:@"n"]){
        self.compassSegmentControl.selectedSegment = 1;
    }else if (self.rootViewController.mapView.showsCompass){
        self.compassSegmentControl.selectedSegment = 2;
    }
    
    // Update wedge status
    if ([self.model->configurations[@"wedge_status"] isEqualToString: @"off"]){
        self.wedgeSegmentControl.selectedSegment = 0;
    }else{
        // Wedge is on
        
        if ([self.model->configurations[@"wedge_style"] isEqualToString: @"original"]){
            self.wedgeSegmentControl.selectedSegment = 1;
        }else if ([self.model->configurations[@"wedge_style"] isEqualToString: @"orthographic"]){
            self.wedgeSegmentControl.selectedSegment = 2;
        }else{
            self.wedgeSegmentControl.selectedSegment = 3;
        }
    }
    
    // Update iOS emulation status
    self.iOSBoundaryControl.state = self.rootViewController.renderer->emulatediOS.is_enabled;
    self.iOSMaskControl.state = self.rootViewController.renderer->emulatediOS.is_mask_enabled;
}


//--------------------
// Toggle Blank Background
//--------------------
- (IBAction)toggleBlankBackground:(NSButton*)sender {
    bool flag = [sender state];
    [self.rootViewController toggleBlankMapMode:flag];
}

//--------------------
// Compass selection control
//--------------------
- (IBAction)compassSegmentControl:(id)sender {
    NSSegmentedControl *segmentedControl = (NSSegmentedControl *)sender;
    
    int idx = [segmentedControl selectedSegment];
    switch (idx) {
        case 0:
            self.model->configurations[@"personalized_compass_status"] = @"off";
            [self.rootViewController setFactoryCompassHidden:YES];
            break;
        case 1:
            self.model->configurations[@"personalized_compass_status"] = @"on";
            [self.rootViewController setFactoryCompassHidden:YES];
            break;
        case 2:
            self.model->configurations[@"personalized_compass_status"] = @"off";
            //        [self.glkView setHidden:YES];
            [self.rootViewController setFactoryCompassHidden:NO];
            break;
    }
    //    [self.rootViewController.compassView setNeedsDisplay:YES];
    [self.rootViewController.compassView display];
}

//--------------------
// Wedge selection control
//--------------------
- (IBAction)wedgeSegmentControl:(id)sender {
    NSSegmentedControl *segmentedControl = (NSSegmentedControl *)sender;
    
    switch (segmentedControl.selectedSegment) {
        case 0:
            //-----------
            // None
            //-----------
            self.model->configurations[@"wedge_status"] = @"off";
            break;
        case 1:
            //-----------
            // Original
            //-----------
            self.model->configurations[@"wedge_status"] = @"on";
            self.model->configurations[@"wedge_style"] = @"original";
            break;
        case 2:
            //-----------
            // Modified-Orthographic
            //-----------
            self.model->configurations[@"wedge_status"] = @"on";
            self.model->configurations[@"wedge_style"] = @"modified-orthographic";
            break;
        case 3:
            //-----------
            // Modified-Perspctive
            //-----------
            self.model->configurations[@"wedge_status"] = @"on";
            self.model->configurations[@"wedge_style"] = @"modified-perspective";
            break;
        default:
            throw(runtime_error("Undefined control, update needed"));
            break;
            
    }
    //    [self.rootViewController.compassView setNeedsDisplay:YES];
    [self.rootViewController.compassView display];
}

- (IBAction)toggleServer:(NSSegmentedControl*)sender {
    
    switch (sender.selectedSegment) {
        case 0:
            [self.rootViewController.httpServer stop];
            self.serverPort.stringValue =
            [NSString stringWithFormat:@"%@", @"????"];
            self.server_ip = @"ip????";
            
            self.rootViewController.socket_status =
            [NSNumber numberWithBool:NO];
            
            break;
        case 1:
            [self.rootViewController startServer];
            //---------------
            // Display port information
            //---------------
            int port = [[self.rootViewController.httpServer asyncSocket] localPort];
            
            self.serverPort.stringValue =
            [NSString stringWithFormat:@"%d", port];
            
            self.server_ip = [[[NSHost currentHost] addresses] objectAtIndex:1];
            break;
    }
}

- (IBAction)toggleGLView:(NSButton*)sender {
    if ([sender state] == NSOnState) {
        [self.rootViewController.compassView setHidden:NO];
    }
    else {
        [self.rootViewController.compassView setHidden:YES];
    }
}

- (IBAction)toggleiOSSyncFlag:(NSSegmentedControl*)sender {
    self.rootViewController.iOSSyncFlag =
    !self.rootViewController.iOSSyncFlag;
}

- (IBAction)toggleiOSBoundary:(NSButton*)sender {

    // Needs to be reworked 
    
    self.rootViewController.renderer->emulatediOS.is_enabled
    = [sender state];
    
    if (self.rootViewController.renderer->emulatediOS.is_enabled){
        [self.iOSMaskControl setState:1];
        self.rootViewController.renderer->emulatediOS.is_mask_enabled = true;
    }
    
    // If the syncflag is off and the box mode is enabled,
    // we need to manually initialize the dimensions of the emulated iOS device
    if (!self.rootViewController.iOSSyncFlag &&
        self.rootViewController.renderer->emulatediOS.is_enabled)
    {
        float scale = [self.iOSScale floatValue];
        self.rootViewController.renderer->emulatediOS.changeSizeByScale(scale);
    }
}

- (IBAction)toggleiOSScreenOnly:(NSButton*)sender {
    self.rootViewController.renderer->emulatediOS.is_mask_enabled
    = [sender state];
}

- (IBAction)adjustiOSScreenSize:(NSSlider *)sender {
    float scale = [self.iOSScale floatValue];
    self.rootViewController.renderer->emulatediOS.changeSizeByScale(scale);
}


- (IBAction)adjustWedgeCorrectionFactor:(NSSlider *)sender {
    float value = [sender floatValue];
    self.rootViewController.model->configurations[@"wedge_correction_x"]
    = [NSNumber numberWithFloat: value];
}

- (IBAction)changeDesktopDropboxDataRoot:(id)sender {
    
    if (self.desktopDropboxDataRoot != nil){
        self.model->desktopDropboxDataRoot =
        self.desktopDropboxDataRoot.stringValue;
    }
}

//-------------------
// Control the appearance of labels
//-------------------
- (IBAction)toggleLabels:(NSButton *)sender {
    self.rootViewController.renderer->label_flag = [sender state];
    [self.rootViewController.compassView setNeedsDisplay: YES];
}
@end
