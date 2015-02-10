//
//  DesktopViewController+Interactions.m
//  Compass[transparent]
//
//  Created by dmiau on 8/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+Interactions.h"

@implementation DesktopViewController (Interactions)

- (IBAction)toggleMap:(id)sender {
    
    // Toggle MapView status
    if ([self.mapView isHidden] == NO){
        [self.mapView setHidden:YES];
        [(NSMenuItem *)sender setTitle:@"Show Map"];
    }else{
        [self.mapView setHidden:NO];
        
        // [4.24.2014]
        // [todo] The following is a hack to make sure views appear
        // in the desired order. It is basically a hack
        // but I couldn't figure out a better solution at the momnet.
        // We know that map view is always in the bottom
        NSArray *all_views = [[self.mapView superview] subviews];
        NSView *aView;
        for (aView in all_views){
            if (![aView isKindOfClass:[MKMapView class]]){
                [aView setHidden:YES];
                [aView setHidden:NO];
            }
        }
        
        //        [[self.mapView superview]
        //         sortSubviewsUsingFunction:myCustomViewAboveSiblingViewsComparator
        //         context:NULL];
        [(NSMenuItem *)sender setTitle:@"Hide Map"];
    }
}

//--------------------
// Toggle personalized compass
//--------------------
- (IBAction)toggleCompass:(id)sender {
    if ([self.model->configurations[@"personalized_compass_status"]
         isEqualToString: @"on"])
    {
        self.model->configurations[@"personalized_compass_status"] = @"off";
        [(NSMenuItem *)sender setTitle:@"Show Compass"];
    }else{
        self.model->configurations[@"personalized_compass_status"] = @"on";
        [(NSMenuItem *)sender setTitle:@"Hide Compass"];
    }
    [self.compassView display];
}

- (IBAction)rotate:(id)sender {
    // Get the sender title
    NSString *title = [(NSMenuItem *)sender title];
    
    //
    float step = 2;
    if (abs(self.mapView.camera.heading) < 10){
        step = 10;
    }
    
    if ([title rangeOfString:@"CCW"].location == NSNotFound){
        self.mapView.camera.heading -= step;
        
    }else{
        self.mapView.camera.heading += step;
    }
    // Update the compassModel's orientation
    self.model->camera_pos.orientation = - self.mapView.camera.heading;
//    cout << "Orientation: " << self.model->camera_pos.orientation << endl;
}

#pragma mark ------------- User Interface -------------
//--------------------
// Mouse event
//--------------------
- (void)mouseDown:(NSEvent *)theEvent{
    //----------------
    //http://lists.apple.com/archives/mac-opengl/2003/Feb/msg00069.html
    NSPoint mouseLoc = [self.compassView convertPoint:[theEvent locationInWindow] fromView:nil];
    
    // This reports the correct mouse position.
    NSLog(@"ViewController: %@", NSStringFromPoint(mouseLoc));
    
    //--------------------
    // Check if the compass is pressed
    //--------------------
    //    NSLog(@"***Mouse down");
    //	GLint viewport[4];
    //	GLubyte pixel[3];
    //
    //	glReadPixels(mouseLoc.x,mouseLoc.y,1,1,
    //                 GL_RGB,GL_UNSIGNED_BYTE,(void *)pixel);
    //
    //    // Print pixel colors
    //    printf("%d %d %d\n",pixel[0],pixel[1],pixel[2]);

    //--------------------
    // Check if the compass is pressed
    //--------------------
    if ([self isCompassTouched:mouseLoc]){
        [self compassSelectedMode:YES];
        [self.compassView setNeedsDisplay: YES];

    }else if (self.renderer->emulatediOS.is_enabled
              && self.renderer->emulatediOS.isTouched(
        [self convertNSViewCoordToOpenGL: mouseLoc]))
    {
        [self enableMapInteraction:NO];
        [self.compassView setNeedsDisplay: YES];
    }else{
        // Detecting long mouse click
        //http://stackoverflow.com/questions/9967118/detect-mouse-being-held-down
        mouseTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(mouseWasHeld:)
                                                    userInfo:theEvent
                                                     repeats:NO];
    }

    // http://stackoverflow.com/questions/6590763/mouse-events-bleeding-through-nsview
    // I want the event to bleed.
    [super mouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent{
    
    //http://lists.apple.com/archives/mac-opengl/2003/Feb/msg00069.html
    NSPoint mouseLoc = [self.compassView convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if ([self.UIConfigurations[@"UICompassTouched"] boolValue]){
        //-------------------------
        // When the compass is pressed,
        // enter here to continuously update the compass's position
        //-------------------------
        
        // update compass location
        recVec compassXY;
        compassXY.x = mouseLoc.x - self.compassView.frame.size.width/2;
        compassXY.y = mouseLoc.y - self.compassView.frame.size.height/2;
        
        self.renderer->compass_centroid = compassXY;
              
        if (![self.UIConfigurations[@"UICompassCenterLocked"] boolValue]){
            [self updateModelCompassCenterXY];
        }
    }
    
    if (self.renderer->emulatediOS.is_touched){
        self.renderer->emulatediOS.centroid_in_opengl = [self convertNSViewCoordToOpenGL: mouseLoc];
    }

    [self.compassView setNeedsDisplay: YES];
}


- (void)mouseUp:(NSEvent *)theEvent{
    [mouseTimer invalidate];
    mouseTimer = nil;
    if ([self.UIConfigurations[@"UICompassTouched"] boolValue]){
        [self compassSelectedMode:NO];
    }
    
    if (self.renderer->emulatediOS.is_touched){
        self.renderer->emulatediOS.is_touched = false;
        [self enableMapInteraction:YES];
    }
}

- (void)mouseWasHeld: (NSTimer *)tim {
    // Long mouse held will lead to this function
    
    //----------------------------
    // Do nothing when the creation mode is off
    //----------------------------
    if (![self.UIConfigurations[@"UIAcceptsPinCreation"] boolValue])
        return;
    
    NSEvent * mouseDownEvent = [tim userInfo];
    [mouseTimer invalidate];
    mouseTimer = nil;
    
    NSPoint mouseLoc = [self.mapView convertPoint:[mouseDownEvent locationInWindow] fromView:nil];
    
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:mouseLoc toCoordinateFromView:self.mapView];
    
    // Add drop-pin here
    CustomPointAnnotation *annotation = [[CustomPointAnnotation alloc] init];
    annotation.coordinate = touchMapCoordinate;
    annotation.title      = @"Dropped Pin";
    annotation.subtitle   = @"";
    annotation.point_type = dropped;
    
    [self.mapView addAnnotation:annotation];
}

#pragma mark ------------- Compass Interaction -------------
- (void)compassSelectedMode:(bool)state{
    [self enableMapInteraction:!state];
    if (state){
        self.model->configurations[@"disk_color"][3] = [NSNumber numberWithInt:255];
    }else{
        self.model->configurations[@"disk_color"][3] = [NSNumber numberWithInt:150];
    }

    self.UIConfigurations[@"UICompassTouched"] =
    [NSNumber numberWithBool: state];
    [self.compassView setNeedsDisplay:YES];
}

-(void)enableMapInteraction:(bool)state{
    if (!state){
        [self.mapView setPitchEnabled:NO];
        [self.mapView setZoomEnabled:NO];
        [self.mapView setRotateEnabled:NO];
        [self.mapView setScrollEnabled:NO];

    }else{
        [self.mapView setPitchEnabled:YES];
        [self.mapView setZoomEnabled:YES];
        [self.mapView setRotateEnabled:YES];
        [self.mapView setScrollEnabled:YES];
    }
}

- (bool)isCompassTouched: (CGPoint) touchPoint{
    
    if ([self.compassView isHidden])
        return false;
    
    //--------------------
    // Check if the compass is pressed
    //--------------------
    recVec compassXY = self.renderer->compass_centroid;
    compassXY.x = compassXY.x + self.compassView.frame.size.width/2;
    compassXY.y = self.compassView.frame.size.height/2 + compassXY.y;
    double dist = sqrt(pow((touchPoint.x - compassXY.x), 2) +
                       pow((touchPoint.y - compassXY.y), 2));
    double radius = self.renderer->compass_disk_radius;
    if (dist <= radius)
        return true;
    else
        return false;
}

@end
