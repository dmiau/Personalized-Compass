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
    
    
    //------------------
    // Check if any of the label is clicked (only when the compass is enabled)
    //------------------
    if ([self.model->configurations[@"personalized_compass_status"]
        isEqualToString: @"on"])
    {
        CGPoint touch_pt = [touch locationInView:self.mapView];
        NSLog(@"MapUV U: %f, V: %f", touch_pt.x, touch_pt.y);
        for (int i = 0; i < self.model->indices_for_rendering.size(); ++i){
            int j = self.model->indices_for_rendering[i];
            // convert from compass coordinate to map uv coordinate
            CGPoint label_pt_compass =
            self.model->data_array[j].my_label_info.centroid;
            
            NSLog(@"Name: %@",
                  [NSString stringWithUTF8String: self.model->data_array[j].name.c_str()]);
            NSLog(@"Centroid: %@", NSStringFromCGPoint(label_pt_compass));
            CGPoint label_pt = self.renderer->
            convertCompassPointToMapUV(label_pt_compass,
                                       self.glkView.frame.size.width,
                                       self.glkView.frame.size.height);
            
            NSLog(@"%@", NSStringFromCGPoint(label_pt));
            double width = self.model->data_array[j].my_texture_info.size.width;
            double height = self.model->data_array[j].my_texture_info.size.height;
            
            if ((touch_pt.x - label_pt.x) <= width
                && (touch_pt.x - label_pt.x) >= 0
                && (label_pt.y - touch_pt.y) <= height
                && (label_pt.y - touch_pt.y) >=0)
            {
                int id = j;
                self.model->camera_pos.latitude =
                self.model->data_array[id].latitude;
                self.model->camera_pos.longitude =
                self.model->data_array[id].longitude;
                self.landmark_id_toshow = -1;
                [self updateMapDisplayRegion:YES];
                
                
                [self.glkView setNeedsDisplay];
            }
            
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

//--------------------
// handleGesture detects long pauses, which triggers the following events
// - drop pin
// - move the compass
//--------------------
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
        CGPoint compassXY;
        compassXY.x = touchPoint.x - self.glkView.frame.size.width/2;
        compassXY.y = self.glkView.frame.size.height/2 - touchPoint.y;
        
        self.renderer->compass_centroid = compassXY;
#endif
        
#ifdef __IPAD__
        CGPoint new_centroid;
        new_centroid.x = glkTouchPoint.x - self.glkView.frame.size.width/2;
        new_centroid.y = self.glkView.frame.size.height/2 - glkTouchPoint.y;

        CGPoint compassXY = self.renderer->compass_centroid;

        
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
        
        if (![self.UIConfigurations[@"UICompassCenterLocked"] boolValue]){
            [self updateModelCompassCenterXY];
        }
        
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


//--------------------
// This controls how the compass is zoomed
//--------------------
- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    if (![self.UIConfigurations[@"UICompassInteractionEnabled"] boolValue]
        || [self.glkView isHidden]
        || [self.model->configurations[@"personalized_compass_status"]
         isEqualToString:@"off"])
        return;

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
            starting_scale = self.renderer->compass_disk_radius /
            [self.model->configurations[@"compass_disk_radius"] floatValue];
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
        double scale = starting_scale * recognizer.scale;
        double min_limit, max_limit;
        max_limit = 2.0;
        if (self.renderer->watchMode){
            min_limit = 0.15;
        }else{
            min_limit = 0.2;
        }
                
        if ((scale >= min_limit) && (scale <= max_limit)){
            // Set a limit to the scale
            self.renderer->adjustAbsoluteCompassScale(scale);
        }
                    
        if (![self.UIConfigurations[@"UICompassCenterLocked"] boolValue]){
            [self updateModelCompassCenterXY];
        }
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
    
    if ([self.glkView isHidden])
        return false;    
    
    //--------------------
    // Check if the compass is pressed
    //--------------------
    CGPoint compassXY = self.renderer->compass_centroid;
    compassXY.x = compassXY.x + self.glkView.frame.size.width/2;
    compassXY.y = self.glkView.frame.size.height/2 - compassXY.y;
    double dist = sqrt(pow((touchPoint.x - compassXY.x), 2) +
                       pow((touchPoint.y - compassXY.y), 2));
    double radius = self.renderer->compass_disk_radius;
    if (dist <= radius)
        return true;
    else
        return false;
}
@end
