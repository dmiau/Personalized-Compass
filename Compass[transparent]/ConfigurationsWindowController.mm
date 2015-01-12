//
//  ConfigurationsWindowController.m
//  Compass[transparent]
//
//  Created by dmiau on 12/24/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "ConfigurationsWindowController.h"
#import "OSXPinAnnotationView.h"
#import "HTTPServer.h"
#import "GCDAsyncSocket.h"

@interface ConfigurationsWindowController ()

@end

@implementation ConfigurationsWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

//configurationWindowController =
//[[ConfigurationsWindowController alloc] initWithWindowNibName:@"ConfigurationsWindow"];


- (id)initWithWindowNibName: (NSString *)windowNibName{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        // Initialization code here.
        self.model = compassMdl::shareCompassMdl();
    }
    return self;
}


- (IBAction)compassSegmentControl:(id)sender {
    NSSegmentedControl *segmentedControl = (NSSegmentedControl *)sender;
    
    int idx = [segmentedControl selectedSegment];
    switch (idx) {
        case 0:
            self.rootViewController.conventionalCompassVisible = NO;
            self.model->configurations[@"personalized_compass_status"] = @"off";
            [self.rootViewController setFactoryCompassHidden:YES];
            break;
        case 1:
            self.rootViewController.conventionalCompassVisible = NO;
            self.model->configurations[@"personalized_compass_status"] = @"on";
            [self.rootViewController setFactoryCompassHidden:YES];
            break;
        case 2:
            self.rootViewController.conventionalCompassVisible = YES;
            self.model->configurations[@"personalized_compass_status"] = @"off";
            //        [self.glkView setHidden:YES];
            [self.rootViewController setFactoryCompassHidden:NO];
            break;
    }
    //    [self.rootViewController.compassView setNeedsDisplay:YES];
    [self.rootViewController.compassView display];
}

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

//-----------------
// annotationNumberSegmentControl controls whether multiple callouts
// can be shown at the same time or not.
//-----------------
- (IBAction)annotationNumberSegmentControl:(NSSegmentedControl*)sender {
    
    bool canShowCallout = false;
    
    switch (sender.selectedSegment) {
        case 0:
            self.rootViewController.UIConfigurations
            [@"UIAllowMultipleAnnotations"] = [NSNumber numberWithBool:NO];
            canShowCallout = true;
            break;
        case 1:
            self.rootViewController.UIConfigurations
            [@"UIAllowMultipleAnnotations"] = [NSNumber numberWithBool:YES];
            canShowCallout = false;
            break;
    }
    
    for (id<MKAnnotation> annotation in
         self.rootViewController.mapView.annotations){
        OSXPinAnnotationView* pinView =
        (OSXPinAnnotationView*)
        [self.rootViewController.mapView
         viewForAnnotation: annotation];
        pinView.canShowCallout = canShowCallout;
        
        if (canShowCallout){
            [pinView showCustomCallout:NO];
        }
    }
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
- (IBAction)toggleLandmarkTableView:(NSButton*)sender {
    
    if ([sender state] == NSOnState) {
        [self.rootViewController.landmarkTable setHidden:NO];
    }
    else {
        [self.rootViewController.landmarkTable setHidden:YES];
        
    }
}

- (IBAction)toggleiOSSyncFlag:(NSSegmentedControl*)sender {
    self.rootViewController.iOSSyncFlag =
    !self.rootViewController.iOSSyncFlag;
}

- (IBAction)toggleiOSBoundary:(id)sender {
    self.rootViewController.renderer->isiOSBoxEnabled
    = !self.rootViewController.renderer->isiOSBoxEnabled;
    
    // If the syncflag is off and the box mode is enabled,
    // we need to manually initialize iOSFourCorners
    if (!self.rootViewController.iOSSyncFlag &&
        self.rootViewController.renderer->isiOSBoxEnabled)
    {
        float scale = [self.iOSScale floatValue];
        [self calculateiOSScreenSize:scale];
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
    [self calculateiOSScreenSize:scale];
}

- (void)calculateiOSScreenSize:(float)scale{
    //ul, ur, br, bl
    float height = self.rootViewController.renderer->orig_height;
    float width = self.rootViewController.renderer->orig_width;
    
    //iOS screen size is 320x503
    float iOS_height = height * scale;
    float iOS_width = iOS_height *320/503;
    
    CGPoint *tempFourCorners = self.rootViewController.renderer->iOSFourCorners;
    tempFourCorners[0].x = width/2 - iOS_width/2;
    tempFourCorners[0].y = height/2 - iOS_height/2;
    
    tempFourCorners[1].x = width/2 + iOS_width/2;
    tempFourCorners[1].y = height/2 - iOS_height/2;
    
    tempFourCorners[2].x = width/2 + iOS_width/2;
    tempFourCorners[2].y = height/2 + iOS_height/2;
    
    tempFourCorners[3].x = width/2 - iOS_width/2;
    tempFourCorners[3].y = height/2 + iOS_height/2;
}
@end
