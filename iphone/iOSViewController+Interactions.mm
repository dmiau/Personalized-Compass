//
//  iOSViewController+Interactions.m
//  Compass[transparent]
//
//  Created by dmiau on 8/2/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Interactions.h"

@implementation iOSViewController (Interactions)


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch* touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self.mapView];
    NSLog(@"****Touch detected");
    NSLog(@"Display Coordinates: %@", NSStringFromCGPoint(pos));
    
    // Convert it to the real coordinate
    CLLocationCoordinate2D myCoord = [self.mapView convertPoint:pos toCoordinateFromView:self.mapView];
    
    
    NSLog(@"Map latitude: %f, longitude: %f", myCoord.latitude, myCoord.longitude);
    MKMapPoint mappoint = MKMapPointForCoordinate(myCoord);
    NSLog(@"Mappoint X: %f, Y: %f", mappoint.x, mappoint.y);
    
    // pass touch event to super
    [super touchesBegan:touches withEvent:event];
    
    //------------------
    // Perform hitTest to dismiss dialogs
    //------------------
    NSArray* dialog_array = @[self.viewPanel, self.modelPanel
                              , self.watchPanel, self.debugPanel];
    
    for (UIView* aView in dialog_array){
        
        UIView* hitView = [aView
                           hitTest:[touch locationInView:aView]
                           withEvent:event];
        if ([aView isHidden] == NO &&
            hitView == nil){
            [aView setHidden:YES];
        }
    }
}


- (void) doSingleTapFindMe:(UITapGestureRecognizer *)gestureRecognizer
{
    [self toggleLocationService:1];
    NSLog(@"Single tap!");
}

- (void) doDoubleTapFindMe:(UITapGestureRecognizer *)gestureRecognizer
{
    [self toggleLocationService:2];
    
    if([self.model->configurations[@"UIBreadcrumbDisplay"] boolValue]){
        [self.mapView removeOverlays: self.mapView.overlays];
        [self displayBreadcrumb];
    }
    NSLog(@"Double tap!");
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CGPoint glkTouchPoint = [gestureRecognizer locationInView:self.glkView];
    if ([self.UIConfigurations[@"UICompassTouched"] boolValue]){
        //-------------------------
        // When the compass is pressed,
        // enter here to continuously update the compass's position
        //-------------------------
        
        
#ifndef __IPAD__
        // update compass location
        recVec compassXY = self.renderer->compass_centroid;
        compassXY.x = touchPoint.x - self.glkView.frame.size.width/2;
        compassXY.y = self.glkView.frame.size.height/2 - touchPoint.y;
        
        self.model->configurations[@"compass_centroid"][0] =
        [NSNumber numberWithInt:compassXY.x];
        self.model->configurations[@"compass_centroid"][1] =
        [NSNumber numberWithInt:compassXY.y];
#endif
        
#ifdef __IPAD__
        CGPoint new_centroid;
        new_centroid.x = glkTouchPoint.x - self.glkView.frame.size.width/2;
        new_centroid.y = self.glkView.frame.size.height/2 - glkTouchPoint.y;

        recVec compassXY = self.renderer->compass_centroid;

        
        CGRect orig_frame = self.glkView.frame;
        self.glkView.frame = CGRectMake
        (orig_frame.origin.x + new_centroid.x - compassXY.x,
         orig_frame.origin.y + compassXY.y - new_centroid.y,
         orig_frame.size.width, orig_frame.size.height);
        
        NSLog(@"glkframe: %@", NSStringFromCGRect(self.glkView.frame));
#endif
        
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
            [self compassSelectedMode:NO];

        }
        // The order is important
        self.renderer->loadParametersFromModelConfiguration();
        [self updateModelCompassCenterXY];
        [self.glkView setNeedsDisplay];
        return;
    }else if (gestureRecognizer.state != UIGestureRecognizerStateBegan){
        //----------------
        // Do nothing is the compress is not pressed
        // and the recognition mode is not begin
        //----------------
        return;
    }
    
    //--------------------
    // Check if the compass is pressed
    //--------------------
    if ([self isCompassTouched:glkTouchPoint]){
        [self compassSelectedMode:YES];
        [self.glkView setNeedsDisplay];
        return;
    }
    
    //----------------------------
    // Do nothing when the creation mode is off
    //----------------------------
    if (![self.UIConfigurations[@"UIAcceptsPinCreation"] boolValue])
        return;
    
    
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    CustomPointAnnotation *pa = [[CustomPointAnnotation alloc] init];
    pa.coordinate = touchMapCoordinate;
    pa.title = @"Dropped Pin";
    pa.point_type = dropped;
    
    if (self.sprinkleBreadCrumbMode){
        [self addBreadcrumb:touchMapCoordinate];
    }
    
    [self.mapView addAnnotation:pa];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer
{
//    NSLog(@"****Pinch gesture detected!");

    static float starting_scale = 1;
    if(recognizer.state == UIGestureRecognizerStateBegan){
        
        // Check if the compass is touched
        CGPoint point0 = [recognizer locationOfTouch:0
                                              inView:self.glkView];
        CGPoint point1 = [recognizer locationOfTouch:1
                                              inView:self.glkView];

        if ([self isCompassTouched:point0] ||
            [self isCompassTouched:point1])
        {
            [self compassSelectedMode:YES];
            starting_scale =
            [self.model->configurations[@"compass_scale"] floatValue];
            [self.mapView setUserInteractionEnabled:NO];
            [self.mapView setZoomEnabled:NO];
            [self.mapView setRotateEnabled:NO];
            [self.mapView setScrollEnabled:NO];
            self.model->configurations[@"disk_color"][3] = [NSNumber numberWithInt:255];
            [self.glkView setNeedsDisplay];
        }
    }
    
//    NSLog(@"%f",recognizer.scale);
    
    if ( [self.UIConfigurations[@"UICompassTouched"] boolValue]
        && recognizer.state == UIGestureRecognizerStateChanged)
    {
        double scale = recognizer.scale;
        self.model->configurations[@"compass_scale"] =
        [NSNumber numberWithFloat: starting_scale * scale];
        
        self.renderer->loadParametersFromModelConfiguration();
        [self updateModelCompassCenterXY];
        [self.glkView setNeedsDisplay];
    }
    
    if(recognizer.state == UIGestureRecognizerStateEnded){
        starting_scale = 1;
        [self compassSelectedMode:NO];
    }
}

- (void)compassSelectedMode:(bool)state{
    if (state){
        [self.mapView setUserInteractionEnabled:NO];
        [self.mapView setZoomEnabled:NO];
        [self.mapView setRotateEnabled:NO];
        [self.mapView setScrollEnabled:NO];
        self.model->configurations[@"disk_color"][3] = [NSNumber numberWithInt:255];
    }else{
        [self.mapView setUserInteractionEnabled:YES];
        [self.mapView setZoomEnabled:YES];
        [self.mapView setRotateEnabled:YES];
        [self.mapView setScrollEnabled:YES];
        self.model->configurations[@"disk_color"][3] = [NSNumber numberWithInt:150];
    }
    self.UIConfigurations[@"UICompassTouched"] =
    [NSNumber numberWithBool: state];
    [self.glkView setNeedsDisplay];
}


- (bool)isCompassTouched: (CGPoint) touchPoint{
    //--------------------
    // Check if the compass is pressed
    //--------------------
    recVec compassXY = self.renderer->compass_centroid;
    compassXY.x = compassXY.x + self.glkView.frame.size.width/2;
    compassXY.y = self.glkView.frame.size.height/2 - compassXY.y;
    double dist = sqrt(pow((touchPoint.x - compassXY.x), 2) +
                       pow((touchPoint.y - compassXY.y), 2));
    double radius = self.renderer->half_canvas_size
    * [self.model->configurations[@"outer_disk_ratio"] floatValue]
    * [self.model->configurations[@"compass_scale"] floatValue];
    if (dist <= radius)
        return true;
    else
        return false;
}
@end
