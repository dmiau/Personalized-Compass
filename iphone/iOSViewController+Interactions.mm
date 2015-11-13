//
//  iOSViewController+Interactions.m
//  Compass[transparent]
//
//  Created by dmiau on 8/2/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Interactions.h"
#import "DetailViewController.h"

@implementation iOSViewController (Interactions)


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    UITouch* touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self.mapView];
    if ([touch view] == self.gmap) {
               NSLog(@"FUN TESTING gmap");
    }
    
    if ([touch view] == self.mapView) {
        NSLog(@"FUN TESTING Amap");
    }
    
    
    // Convert it to the real coordinate
    CLLocationCoordinate2D myCoord = [self.mapView convertPoint:pos toCoordinateFromView:self.mapView];
    MKMapPoint mappoint = MKMapPointForCoordinate(myCoord);
    
    NSLog(@"****Touch detected");
    NSLog(@"MapViewPoint: %@", NSStringFromCGPoint(pos));
    NSLog(@"CGViewPoint: %@", NSStringFromCGPoint([touch locationInView:self.glkView]));
    NSLog(@"Map latitude: %f, longitude: %f", myCoord.latitude, myCoord.longitude);
    NSLog(@"Mappoint X: %f, Y: %f", mappoint.x, mappoint.y);
    
    
    NSLog(@"True");
    NSLog(@"Center:");
    NSLog(@"latitude: %f, longitude: %f", self.mapView.centerCoordinate.latitude,
          self.mapView.centerCoordinate.longitude);
    NSLog(@"latitudeSpan: %f, longitudeSpan: %f", self.mapView.region.span.latitudeDelta,
          self.mapView.region.span.longitudeDelta);
    
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
         isEqualToString: @"on"]
        && [self.UIConfigurations[@"UICompassInteractionEnabled"] boolValue])
    {
        CGPoint touch_pt = [touch locationInView:self.mapView];
        NSLog(@"MapUV U: %f, V: %f", touch_pt.x, touch_pt.y);
        for (int i = 0; i < self.model->indices_for_rendering.size(); ++i){
            int j = self.model->indices_for_rendering[i];
            // convert from compass coordinate to map uv coordinate
            CGPoint label_pt_compass =
            self.model->data_array[j].my_label_info.centroid;
            
            //            NSLog(@"Name: %@",
            //                  [NSString stringWithUTF8String: self.model->data_array[j].name.c_str()]);
            //            NSLog(@"Centroid: %@", NSStringFromCGPoint(label_pt_compass));
            CGPoint label_pt = self.renderer->
            convertCompassPointToMapUV(label_pt_compass,
                                       self.glkView.frame.size.width,
                                       self.glkView.frame.size.height);
            
            //            NSLog(@"%@", NSStringFromCGPoint(label_pt));
            double width = self.model->data_array[j].my_texture_info.size.width;
            double height = self.model->data_array[j].my_texture_info.size.height;
            
            if ((touch_pt.x - label_pt.x) <= width
                && (touch_pt.x - label_pt.x) >= 0
                && (label_pt.y - touch_pt.y) <= height
                && (label_pt.y - touch_pt.y) >=0)
            {
                MKCoordinateRegion temp = MKCoordinateRegionMake
                (CLLocationCoordinate2DMake(self.model->data_array[j].latitude, self.model->data_array[j].longitude),self.mapView.region.span);
                [self updateMapDisplayRegion: temp withAnimation:YES];
                
                self.landmark_id_toshow = -1;
                [self.glkView setNeedsDisplay];
            }
            
        }
    }
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self.mapView];
    //--------------------
    // Update interactive line
    //--------------------
    if (self.renderer->isInteractiveLineVisible
        && self.renderer->isInteractiveLineEnabled)
    {
        double x = pos.x - 0.5*self.renderer->view_width;
        double_t y = 0.5*self.renderer->view_height - pos.y;
        self.renderer->interactiveLineRadian = atan2(y, x);
        
        double deg_angles = atan2(y, x) * 180/M_PI;
        if (deg_angles < 0)
            deg_angles = 360 + deg_angles;
        
        // The following lines has no effect on OSX
        // sendPackage is only functional when called on iOS
        NSDictionary *myDict = @{@"Type" : @"Message",
                                 @"Content" : [NSString stringWithFormat:@"%g",
                                               deg_angles]
                                 };
        [self sendPackage: myDict];
    }
    [self.glkView setNeedsDisplay];
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
// Handle tap event in Google Map
//--------------------
-(void) touch: (UIGestureRecognizer *) gestureRecognizer {
    CGPoint locationInGmap = [gestureRecognizer locationInView:self.gmap];
    NSArray* dialog_array = @[self.viewPanel, self.modelPanel
                              , self.watchPanel, self.debugPanel];
    
    for (UIView* aView in dialog_array){
        if (!CGRectContainsPoint(aView.bounds, [aView convertPoint:locationInGmap fromView:self.gmap]) && [aView isHidden] == NO){
            [aView setHidden:YES];
        }
    }
    
    // Handle the label spatial in Compass
    if ([self.model->configurations[@"personalized_compass_status"]
         isEqualToString: @"on"]
        && [self.UIConfigurations[@"UICompassInteractionEnabled"] boolValue]) {
        for (int i = 0; i < self.model->indices_for_rendering.size(); i++) {
            int j = self.model->indices_for_rendering[i];
            CGPoint label_pt_compass =
            self.model->data_array[j].my_label_info.centroid;
            CGPoint label_pt = self.renderer->
            convertCompassPointToMapUV(label_pt_compass,
                                       self.glkView.frame.size.width,
                                       self.glkView.frame.size.height);
            
            double width = self.model->data_array[j].my_texture_info.size.width;
            double height = self.model->data_array[j].my_texture_info.size.height;
            
            if ((locationInGmap.x - label_pt.x) <= width
                && (locationInGmap.x - label_pt.x) >= 0
                && (label_pt.y - locationInGmap.y) <= height
                && (label_pt.y - locationInGmap.y) >=0) {
                GMSCameraPosition *camera = [GMSCameraPosition
                                             cameraWithLatitude:self.model->data_array[j].latitude
                                             longitude:self.model->data_array[j].longitude
                                             zoom:self.gmap.camera.zoom
                                             bearing:self.gmap.camera.bearing
                                             viewingAngle:self.gmap.camera.viewingAngle];
                self.gmap.camera = camera;
            }
        }
    }
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
        
        [self moveCompassCentroidToOpenGLPoint: self.renderer->compass_centroid];
        
        [self.glkView setNeedsDisplay];
        return;
    }else if (gestureRecognizer.state != UIGestureRecognizerStateBegan){
        //----------------
        // Do nothing if the compress is not pressed
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
    // Only accept drop pins when the drop pin creation mode is enabled
    //----------------------------
    if ([self.UIConfigurations[@"UIAcceptsPinCreation"] boolValue] && !self.mapView.hidden){
        CLLocationCoordinate2D touchMapCoordinate =
        [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        
        CustomPointAnnotation *pa = [[CustomPointAnnotation alloc] init];
        pa.coordinate = touchMapCoordinate;
        
        
        if (self.testManager->testManagerMode == AUTHORING){
            //------------------
            // When the testManagerMode is in the AUTHORING mode
            //------------------
            pa.title = @"Authored Pin";
            pa.point_type = landmark;
            
            
            //----------------
            // Add the authored pin to the data_array
            //----------------
            data myData;
            myData.name = "Authored Pin";
            myData.annotation = pa;
            myData.annotation.point_type = landmark;
            
            myData.annotation.subtitle =
            [NSString stringWithFormat:@"%lu",
             self.model->data_array.size()];
            
            myData.latitude =  pa.coordinate.latitude;
            myData.longitude =  pa.coordinate.longitude;
            
            myData.annotation.data_id = self.model->data_array.size();
            
            myData.my_texture_info = self.model->generateTextureInfo
            ([NSString stringWithUTF8String:myData.name.c_str()]);
            // Add the new data to data_array
            self.model->data_array.push_back(myData);
            
            self.model->updateMdl();
            [self.glkView setNeedsDisplay];
        }else{
            //------------------
            // When the drop pin creation mode is enabled
            //------------------
            pa.title = @"Dropped Pin";
            pa.point_type = dropped;
        }
        
        if (self.sprinkleBreadCrumbMode){
            [self addBreadcrumb:touchMapCoordinate];
        }
        
        [self.mapView addAnnotation:pa];
    } else if ([self.UIConfigurations[@"UIAcceptsPinCreation"] boolValue] && !self.gmap.hidden) {
        CGPoint touchInGmap = [self.mapView convertPoint:touchPoint toView:self.gmap];
        CLLocationCoordinate2D touchCoordinate = [self.gmap.projection coordinateForPoint:touchInGmap];
        GMSMarker *pin = [[GMSMarker alloc] init];
        pin.position = touchCoordinate;
        pin.title = @"Dropped Pin";
        pin.map = self.gmap;
        
        //fetch the address based on lat and lon
        CLLocation *location = [[CLLocation alloc] initWithLatitude:touchCoordinate.latitude longitude:touchCoordinate.longitude];
        CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
        [geoCoder reverseGeocodeLocation:location completionHandler:
         
         ^(NSArray *placemarks, NSError *error) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             pin.snippet = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         }];
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    MKAnnotationView *view = [[MKAnnotationView alloc] init];
    CustomPointAnnotation *annotation = [[CustomPointAnnotation alloc] init];
    annotation.coordinate = marker.position;
    annotation.title = @"Dropped Pin";
    view.annotation = annotation;
    [self performSegueWithIdentifier:@"DetailVC" sender:view];
}


//--------------------
// This controls how the compass is zoomed
//--------------------
- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    
    //----------------------
    // Basically, skip this method is the compass is disabled,
    // or the interation is disabled.
    //----------------------
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
            min_limit = 0.5;
        }else{
            min_limit = 0.6;
        }
        
        NSLog(@"starting scale: %f, scale %f", starting_scale, scale);
        
        
        if ((scale >= min_limit) && (scale <= max_limit)){
            // Set a limit to the scale
            self.renderer->adjustAbsoluteCompassScale(scale);
        }
        
        //        if (![self.UIConfigurations[@"UICompassCenterLocked"] boolValue]){
        //            [self updateModelCompassCenterXY];
        //        }
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
        self.gmap.settings.scrollGestures = NO;
        self.gmap.settings.zoomGestures = NO;
        self.gmap.settings.rotateGestures = NO;
        
    }else{
        [self.mapView setUserInteractionEnabled:YES];
        [self.mapView setZoomEnabled:YES];
        [self.mapView setRotateEnabled:YES];
        [self.mapView setScrollEnabled:YES];
        self.gmap.settings.scrollGestures = YES;
        self.gmap.settings.zoomGestures = YES;
        self.gmap.settings.rotateGestures = YES;
    }
    self.UIConfigurations[@"UICompassTouched"] =
    [NSNumber numberWithBool: state];
    self.renderer->isCompassTouched = state;
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


- (void) displayPopupMessage: (NSString*) message{
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:@"System Message"
                                message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction =
    [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {[alert dismissViewControllerAnimated:YES completion:nil];}];
    
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
@end