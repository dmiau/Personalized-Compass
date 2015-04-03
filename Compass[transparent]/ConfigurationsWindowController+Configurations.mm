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
    
    // Update map interaction status
    self.mapInteractionCheckbox.state =
    self.rootViewController.mapView.zoomEnabled;
    
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
        
        if ([self.model->configurations[@"wedge_style"] isEqualToString: @"modified-orthographic"]){
            self.wedgeSegmentControl.selectedSegment = 1;
        }else{
            self.wedgeSegmentControl.selectedSegment = 2;
        }
    }
    
    // Update iOS emulation status
    if (!self.rootViewController.renderer->emulatediOS.is_enabled){
        self.iOSEmulationSegmentControl.selectedSegment = 0;
    }else{
        switch (self.rootViewController.renderer->emulatediOS.deviceType) {
            case PHONE:
                self.iOSEmulationSegmentControl.selectedSegment = 1;
                break;
            case SQUAREWATCH:
                self.iOSEmulationSegmentControl.selectedSegment = 2;
                break;
            case WATCH:
                self.iOSEmulationSegmentControl.selectedSegment = 3;
                break;
            default:
                break;
        }
    }
    self.iOSMaskControl.state = self.rootViewController.renderer->emulatediOS.is_mask_enabled;
    
    // Update the server pane

    if ([self.rootViewController.socket_status boolValue]){
        self.serverSegmentIndex = [NSNumber numberWithInt:1];
        //---------------
        // Display port information
        //---------------
        int port = [[self.rootViewController.httpServer asyncSocket] localPort];
        
        self.serverPort.stringValue =
        [NSString stringWithFormat:@"%d", port];
        
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            // Find the string starting with number
            for (NSString* anItem : [[NSHost currentHost] addresses]){
                if ([anItem rangeOfString:@":"].location == NSNotFound)
                {
                    self.server_ip = anItem;
                    break;
                }
            }
        });
    }else{
        self.serverSegmentIndex = [NSNumber numberWithInt:0];
    }
}


//--------------------
// Toggle Blank Background
//--------------------
- (IBAction)toggleBlankBackground:(NSButton*)sender {
    bool flag = (sender.state == NSOnState);
    [self.rootViewController toggleBlankMapMode:flag];
}

- (IBAction)toggleMapInteractions:(NSButton*)sender {
    [self.rootViewController enableMapInteraction:[sender state]];    
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
            // Modified-Orthographic
            //-----------
            self.model->configurations[@"wedge_status"] = @"on";
            self.model->configurations[@"wedge_style"] = @"modified-orthographic";
            break;
        case 2:
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
            
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                // Find the string starting with number
                for (NSString* anItem : [[NSHost currentHost] addresses]){
                    if ([anItem rangeOfString:@":"].location == NSNotFound)
                    {
                        self.server_ip = anItem;
                        break;
                    }
                }
            });
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

//--------------------
// iOS emulation segment control
//--------------------
- (IBAction)toggleiOSEumulation:(NSSegmentedControl*)sender {
    switch (sender.selectedSegment) {
        case 0:
            //----------------
            // NO
            //----------------
            self.rootViewController.renderer->emulatediOS.is_enabled = NO;
            break;
        case 1:
            //----------------
            // Phone
            //----------------
            self.rootViewController.renderer->emulatediOS.is_enabled = YES;
            [self.iOSMaskControl setState:1];
            self.rootViewController.renderer->emulatediOS.is_mask_enabled = true;

            self.rootViewController.renderer->emulatediOS.changeDeviceType(PHONE);
            
            // If the syncflag is off and the box mode is enabled,
            // we need to manually initialize the dimensions of the emulated iOS device
            if (!self.rootViewController.iOSSyncFlag &&
                self.rootViewController.renderer->emulatediOS.is_enabled)
            {
                float scale = [self.iOSScale floatValue];
                self.rootViewController.renderer->emulatediOS.changeSizeByScale(scale);
            }
            break;
        case 2:
            //----------------
            // Square watch
            //----------------
            self.rootViewController.renderer->emulatediOS.is_enabled = YES;
            [self.iOSMaskControl setState:1];
            self.rootViewController.renderer->emulatediOS.is_mask_enabled = true;
            
            self.rootViewController.renderer->emulatediOS.changeDeviceType(SQUAREWATCH);
            
            // If the syncflag is off and the box mode is enabled,
            // we need to manually initialize the dimensions of the emulated iOS device
            if (!self.rootViewController.iOSSyncFlag &&
                self.rootViewController.renderer->emulatediOS.is_enabled)
            {
                float scale = [self.iOSScale floatValue];
                self.rootViewController.renderer->emulatediOS.changeSizeByScale(scale);
            }
            break;
        case 3:
            //----------------
            // circle watch
            //----------------
            // do something
            break;
        default:
            break;
    }
    self.iOSScreenStr = [NSString stringWithFormat:
                         @"WxH: %.0fx%.0f", self.rootViewController.renderer->emulatediOS.width, self.rootViewController.renderer->emulatediOS.height ];
}

- (IBAction)toggleiOSScreenOnly:(NSButton*)sender {
    self.rootViewController.renderer->emulatediOS.is_mask_enabled
    = [sender state];
}

- (IBAction)adjustiOSScreenSize:(NSSlider *)sender {
    float scale = [self.iOSScale floatValue];
    self.rootViewController.renderer->emulatediOS.changeSizeByScale(scale);
    self.iOSScreenStr = [NSString stringWithFormat:
                         @"WxH: %.0fx%.0f", self.rootViewController.renderer->emulatediOS.width, self.rootViewController.renderer->emulatediOS.height ];
}


- (IBAction)adjustWedgeCorrectionFactor:(NSSlider *)sender {
    float value = [sender floatValue];
    self.rootViewController.model->configurations[@"wedge_correction_x"]
    = [NSNumber numberWithFloat: value];
    NSLog(@"Correction factor value: %@",
          self.rootViewController.model->configurations[@"wedge_correction_x"]);
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
