//
//  iOSViewController+Annotations.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Annotations.h"
#import "DetailViewController.h"
#import "commonInclude.h"

@implementation iOSViewController (Annotations)

-(void) resetAnnotations{
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    
    // Add annotations one by one
    for (int i = 0; i < self.model->data_array.size(); ++i){
        data myData = self.model->data_array[i];
        
        if (self.testManager->testManagerMode == OFF){
            [self.mapView addAnnotation: myData.annotation];
        }else if (self.testManager->testManagerMode == DEVICESTUDY ||
                  self.testManager->testManagerMode == OSXSTUDY)
        {
            if (myData.isEnabled && !myData.isAnswer){
                [self.mapView addAnnotation: myData.annotation];
            }
        }
    }
}

-(void) resetGmapMarkers {
    [self.gmap clear];
    self.gmapMarkers = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.model->data_array.size(); i++) {
        data myData = self.model->data_array[i];
        
        if (self.testManager->testManagerMode == OFF){
            GMSMarker *marker = [[GMSMarker alloc] init];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(myData.latitude, myData.longitude);
            NSLog(@"FUN lat %f lon %f", coordinate.latitude, coordinate.longitude);
            marker.position = coordinate;
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:2];
            [dic setObject:@"landmark" forKey:@"point_type"];
            if (!self.model->data_array[i].isEnabled) {
                [dic setValue:@"NO" forKey:@"isEnabled"];
                marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
            } else if (self.model->data_array[i].annotation.point_type == dropped) {
                marker.icon = [GMSMarker markerImageWithColor:[UIColor purpleColor]];
            } else {
                [dic setValue:@"YES" forKey:@"isEnabled"];
            }
            marker.userData = dic;
            marker.title = [NSString stringWithCString:myData.name.c_str()
                                              encoding:[NSString defaultCStringEncoding]];
            marker.map = self.gmap;
            [self.gmapMarkers addObject:marker];
        }else if (self.testManager->testManagerMode == DEVICESTUDY ||
                  self.testManager->testManagerMode == OSXSTUDY)
        {
            if (myData.isEnabled && !myData.isAnswer){
                GMSMarker *marker = [[GMSMarker alloc] init];
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(myData.latitude, myData.longitude);
                marker.position = coordinate;
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:2];
                [dic setObject:@"landmark" forKey:@"point_type"];
                if (!self.model->data_array[i].isEnabled) {
                    [dic setValue:@"NO" forKey:@"isEnabled"];
                    marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
                } else {
                    [dic setValue:@"YES" forKey:@"isEnabled"];
                }
                marker.userData = dic;
                marker.title = [NSString stringWithCString:myData.name.c_str()
                                                  encoding:[NSString defaultCStringEncoding]];
                marker.map = self.gmap;
                [self.gmapMarkers addObject:marker];
            }
        }
    }
}

- (void) renderAllDataAnnotations{
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    
    // Add annotations one by one
    for (int i = 0; i < self.model->data_array.size(); ++i){
        data myData = self.model->data_array[i];
        [self.mapView addAnnotation: myData.annotation];
        [[self.mapView viewForAnnotation:myData.annotation] setHidden:YES];
    }
}

-(void)updateDataAnnotations{
    // Add annotations one by one
    for (int i = 0; i < self.model->data_array.size(); ++i){
        data myData = self.model->data_array[i];
        [self.mapView removeAnnotation: myData.annotation];
        [self.mapView addAnnotation: myData.annotation];
    }
}

//------------------
// This function is called to prepare a view for an annotation
//------------------
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(CustomPointAnnotation*)annotation {
    
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    if ([annotation point_type] != heading){
        
        // try to dequeue an existing pin view first
        static NSString *landmarkAnnotationID = @"landmarkAnnotationID";
        
        MKPinAnnotationView *pinView =
        (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:landmarkAnnotationID];
        
        if (pinView == nil)
        {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:landmarkAnnotationID];
        }else{
            pinView.annotation = annotation;
        }
        
        if (annotation.point_type == landmark){
            [pinView setAnimatesDrop:NO];
        }else{
            [pinView setAnimatesDrop:YES];
        }

        [pinView setCanShowCallout:YES];
        
        
        if ([annotation point_type] == dropped){
            //---------------
            // User triggered drop pin
            //---------------
            pinView = [self configureUserDroppedPinView: pinView];
        }else if ([annotation point_type] == landmark){
            //---------------
            // Landmark pin
            //---------------
            pinView = [self configureLandmarkPinView: pinView];
        }else if ([annotation point_type] == search_result){
            //---------------
            // Search pin
            //---------------
            pinView = [self configureUserDroppedPinView: pinView];
        }
        return pinView;
    }else{
        //---------------
        // Heading image
        //---------------
        
        // try to dequeue an existing pin view first
        static NSString *headingAnnotationID = @"headingAnnotationID";
        
        MKAnnotationView *pinView =
        (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:headingAnnotationID];
        
        if (pinView == nil)
        {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:headingAnnotationID];
        }else{
            pinView.annotation = annotation;
        }
        [pinView setCanShowCallout:NO];
        
        pinView = [self configureHeadingImageView: pinView];
        return pinView;
    }
}

//---------------
// User triggered drop pin
//---------------
- (MKPinAnnotationView *) configureUserDroppedPinView: (MKPinAnnotationView *) pinView
{
    NSString *address;
    CLLocation *location = [[CLLocation alloc]
                            initWithLatitude:[pinView.annotation coordinate].latitude
                            longitude:[pinView.annotation coordinate].longitude];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if(placemarks && placemarks.count > 0)
         {
             CLPlacemark *placemark= [placemarks objectAtIndex:0];
             //address is NSString variable that declare in .h file.
             NSString* address =
             [NSString stringWithFormat:@"%@ %@ , %@ , %@",
              [placemark subThoroughfare],
              [placemark thoroughfare],[placemark locality],[placemark administrativeArea]];
             
             NSLog(@"New Address Is:%@",address);
             
             CustomPointAnnotation *copyAnnotation = pinView.annotation;
             copyAnnotation.subtitle = address;
         }
     }];
    
    pinView.pinColor = MKPinAnnotationColorPurple;

    //---------------
    //Configure the left button (tag: 0)
    //---------------
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnLeftImage = [UIImage imageNamed:@"remove.png"];
    [leftButton setImage:btnLeftImage forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(0, 0,
                                  btnLeftImage.size.width,
                                  btnLeftImage.size.height);
    [leftButton setBackgroundColor: [UIColor whiteColor]];
    [leftButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    leftButton.tag = 0; //left button has tag 0
    
    pinView.leftCalloutAccessoryView = leftButton;
    
    //---------------
    // Constructing a right button (tag: 1)
    //---------------
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    rightButton.tag = 1;  //right button has tag 1
    pinView.rightCalloutAccessoryView = rightButton;
    
    return pinView;
}
//---------------
// Landmark pin
//---------------
- (MKPinAnnotationView *) configureLandmarkPinView: (MKPinAnnotationView *) pinView
{
    UIImage *btnImage;
    CustomPointAnnotation *myAnnotation =
    (CustomPointAnnotation *) pinView.annotation;
    
    int i = [myAnnotation data_id];
    if (self.model->data_array[i].isEnabled){
        pinView.pinColor = MKPinAnnotationColorRed;
        btnImage = [UIImage imageNamed:@"selected.png"];
    }else{
        pinView.pinColor = MKPinAnnotationColorGreen;
        btnImage = [UIImage imageNamed:@"unselected.png"];
    }
    
    //---------------
    // Constructing a left button (tag: 0)
    //---------------
    
    UIButton *leftButton;
    if (pinView.leftCalloutAccessoryView == nil){
        leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }else{
        leftButton = pinView.leftCalloutAccessoryView;
    }
    
//    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:btnImage forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(0, 0,
                                   btnImage.size.width, btnImage.size.height);
    [leftButton setBackgroundColor: [UIColor redColor]];
    [leftButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    
    
    leftButton.tag = 0;  //right button has tag 0
    pinView.leftCalloutAccessoryView = leftButton;
    
    //---------------
    // Constructing a right button (tag: 1)
    //---------------
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    rightButton.tag = 1;  //right button has tag 1
    pinView.rightCalloutAccessoryView = rightButton;
    
    return pinView;
}

- (MKPinAnnotationView *) configureSearchPinView: (MKPinAnnotationView *) pinView
{
    return pinView;
}

- (MKAnnotationView *) configureHeadingImageView: (MKAnnotationView *) pinView
{
    return pinView;
}

//------------------
// When the callout of a pin is tapped
//------------------
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
    NSLog(@"Do something");
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)view;

    CustomPointAnnotation* myCustomAnnotation =
    (CustomPointAnnotation*) view.annotation;
    //------------------
    // The pin is a custom pin
    //------------------
    UIButton *myButton = (UIButton *)control;
    if(myButton.tag == 0){
        // Left buttton tapped
        if (myCustomAnnotation.point_type == dropped){
            // if it is a dropped pin, remove the pin
            [self.mapView removeAnnotation:view.annotation];
        }else{
            // if it is a landmark pin, flip the enable status

            int idx = myCustomAnnotation.data_id;
            data* data_ptr = &(self.model->data_array[idx]);
            
            //---------------
            // The behavior is slightly different in the AUTHORING mode
            //---------------
            if (self.testManager->testManagerMode == AUTHORING){                
                // Flip between red and purple
                if (data_ptr->isAnswer){
                    pinView.pinColor = MKPinAnnotationColorRed;
                }else{
                    pinView.pinColor = MKPinAnnotationColorPurple;
                }
                
                data_ptr->isAnswer = !data_ptr->isAnswer;
            }else{
                data_ptr->isEnabled = !data_ptr->isEnabled;
                pinView = [self configureLandmarkPinView:pinView];
            }
        }
    }else if (myButton.tag == 1){
        [self performSegueWithIdentifier:@"DetailVC" sender:view];
    }
}

//------------------
// When a pin is selected
//------------------
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    NSLog(@"Annotation clicked");
//    MKPinAnnotationView *pinView = (MKPinAnnotationView *)view;
////    pinView.pinColor = MKPinAnnotationColorPurple;
//    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
//    [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
//    pinView.rightCalloutAccessoryView = rightButton;
}

//-------------------
// Change how annotations should be displayed
//-------------------
- (void)changeAnnotationDisplayMode: (NSString*) mode{
    NSArray* annotation_array = self.mapView.annotations;
    NSLog(@"Pin test");
    NSLog(@"%lu", [self.gmapMarkers count]);
    if ([mode isEqualToString:@"All"]){
        for (CustomPointAnnotation* annotation in annotation_array){
            [[self.mapView viewForAnnotation:annotation] setHidden:NO];
        }
        for (int i = 0; i < [self.gmapMarkers count]; i++) {
            ((GMSMarker *) self.gmapMarkers[i]).map = self.gmap;
        }
    }else if ([mode isEqualToString:@"Enabled"]){
        for (CustomPointAnnotation* annotation in annotation_array){
            
            // Note we need to skip the dropped pin
            if (annotation.point_type != dropped){
                int i = annotation.data_id;
                if (annotation.point_type == landmark  && self.model->data_array[i].isEnabled){
                    [[self.mapView viewForAnnotation:annotation] setHidden:NO];
                }else{
                    [[self.mapView viewForAnnotation:annotation] setHidden:YES];
                }
            }
        }
        NSLog(@"Pin test");
        for (int i = 0; i < [self.gmapMarkers count]; i++) {
            GMSMarker *marker =  ((GMSMarker *) self.gmapMarkers[i]);
            if ([[marker.userData valueForKey:@"isEnabled"] isEqualToString:@"YES"]) {
                marker.map = self.gmap;
            } else {
                marker.map = nil;
            }
        }
    }else if ([mode isEqualToString:@"Dropped"]){
        for (CustomPointAnnotation* annotation in annotation_array){
            if (annotation.point_type == dropped){
                [[self.mapView viewForAnnotation:annotation] setHidden:NO];
            }else{
                [[self.mapView viewForAnnotation:annotation] setHidden:YES];
            }
        }
        
        for (int i = 0; i < [self.gmapMarkers count]; i++) {
            GMSMarker *marker =  ((GMSMarker *) self.gmapMarkers[i]);
            if ([[marker.userData valueForKey:@"point_type"] isEqualToString:@"dropped"]) {
                marker.map = self.gmap;
            } else {
                marker.map = nil;
            }
        }
    }else if ([mode isEqualToString:@"None"]){
        for (CustomPointAnnotation* annotation in annotation_array){
            [[self.mapView viewForAnnotation:annotation] setHidden:YES];
        }
        for (int i = 0; i < [self.gmapMarkers count]; i++) {
            ((GMSMarker *) self.gmapMarkers[i]).map = nil;
        }
    }else if ([mode isEqualToString:@"Study"]){
        for (CustomPointAnnotation* annotation in annotation_array){
            
            // Note we need to skip the dropped pin
            if (annotation.point_type != dropped){
                int i = annotation.data_id;
                if (annotation.point_type == landmark  &&
                    self.model->data_array[i].isEnabled &&
                    !self.model->data_array[i].isAnswer)
                {
                    [[self.mapView viewForAnnotation:annotation] setHidden:NO];
                }else{
                    [[self.mapView viewForAnnotation:annotation] setHidden:YES];
                }
            }
        }
    }else{
        throw(runtime_error("Unknown showPin mode."));
    }
    
    self.UIConfigurations[@"ShowPins"] = mode;
}

//------------------
// Prepare for the detail view
//------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(MKAnnotationView *)sender
{
    if ([segue.identifier isEqualToString:@"DetailVC"])
    {
        DetailViewController *destinationViewController = segue.destinationViewController;
        
        // grab the annotation from the sender
        destinationViewController.annotation = sender.annotation;
    } else {
        NSLog(@"PFS:something else");
    }
}

@end
