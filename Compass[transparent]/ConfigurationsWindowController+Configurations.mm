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
    self.iOSBoundaryControl.state = self.rootViewController.renderer->isiOSBoxEnabled;
    
    self.iOSMaskControl.state = self.rootViewController.renderer->isiOSMaskEnabled;
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

- (IBAction)toggleiOSBoundary:(id)sender {

    // Needs to be reworked 
    
    self.rootViewController.renderer->isiOSBoxEnabled
    = !self.rootViewController.renderer->isiOSBoxEnabled;
    
    if (self.rootViewController.renderer->isiOSBoxEnabled){
        [self.iOSMaskControl setState:1];
        [self toggleiOSScreenOnly:nil];
    }
    
    // If the syncflag is off and the box mode is enabled,
    // we need to manually initialize iOSFourCornersInNSView
    if (!self.rootViewController.iOSSyncFlag &&
        self.rootViewController.renderer->isiOSBoxEnabled)
    {
        float scale = [self.iOSScale floatValue];
        [self.rootViewController calculateiOSScreenSize:scale];
    }
}

- (IBAction)toggleiOSScreenOnly:(id)sender {
    self.rootViewController.renderer->isiOSMaskEnabled
    = !self.rootViewController.renderer->isiOSMaskEnabled;
    
    //    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0,
    //                self.rootViewController.mapView.bounds.size.width,
    //                self.rootViewController.mapView.bounds.size.height) cornerRadius:0];
    //
    //    Corners4x2 corners4x2 = self.rootViewController.corners4x2;
    //    NSBezierPath *rectPath = [NSBezierPath bezierPathWithRoundedRect:CGRectMake(
    //                corners4x2.content[0][0], corners4x2.content[0][1],
    //                corners4x2.content[1][0] - corners4x2.content[0][0],
    //                corners4x2.content[1][0] - corners4x2.content[2][0]) cornerRadius:0];
    //    [path appendBezierPath:rectPath];
    ////
    ////    [path setUsesEvenOddFillRule:YES];
    ////
    ////
    ////
    //
    //    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    ////    fillLayer.path = path.CGPath;
    ////    fillLayer.fillRule = kCAFillRuleEvenOdd;
    ////    fillLayer.fillColor = [UIColor blackColor].CGColor;
    ////    fillLayer.opacity = 1;
    ////    [self.glkView.layer addSublayer:fillLayer];
    ////    self.view.backgroundColor = [UIColor blackColor];
}

- (IBAction)adjustiOSScreenSize:(NSSlider *)sender {
    float scale = [sender floatValue];
    [self.rootViewController calculateiOSScreenSize:scale];
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

@end
