//
//  DesktopViewController+Annotations.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/1/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+Annotations.h"

//---------------
// CalloutButton
//---------------
@interface CalloutButton :NSButton
@property OSXPinAnnotationView *pinView;
@end


@implementation CalloutButton

@end

//---------------
// DesktopViewController (Annotations)
//---------------
@implementation DesktopViewController (Annotations)
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
            if (myData.isEnabled){
                [self.mapView addAnnotation: myData.annotation];
                
                // visible will be controlled by the changeAnnotation method
                [[self.mapView viewForAnnotation:myData.annotation] setHidden:YES];
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

//------------------
// This function is called to prepare a view for an annotation
//------------------
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(CustomPointAnnotation*)annotation {
    
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    NSImage *blueDot_image = [[NSImage alloc] initWithContentsOfFile:
                              [[NSBundle mainBundle] pathForResource:@"blueDot" ofType:@"png"]];
    NSImage *redDot_image = [[NSImage alloc] initWithContentsOfFile:
                             [[NSBundle mainBundle] pathForResource:@"redDot" ofType:@"png"]];
    
    //----------------
    // In study mode we will use MKAnnotationView, because we want to use
    // custom images
    //----------------
    if ((self.testManager->testManagerMode == OSXSTUDY)
         && [annotation point_type] != answer)
    {
        // try to dequeue an existing pin view first
        static NSString *studyAnnotationID = @"StudyAnnotationID";
        
        OSXAnnotationView *pinView =
        (OSXAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:studyAnnotationID];
        
        if (pinView == nil)
        {
            pinView = [[OSXAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:studyAnnotationID];
        }else{
            // TODO: the callOutViewController needs to be reinitialized!
            pinView = [pinView initWithAnnotation:annotation reuseIdentifier:studyAnnotationID];
        }
        
        if ([annotation point_type] == dropped){
            [pinView showCustomCallout:NO];
            pinView.image = blueDot_image;
        }else if ([annotation point_type] == landmark){
            [pinView showCustomCallout:YES];
            pinView.image = redDot_image;
        }else{
            [pinView showCustomCallout:YES];
            pinView.image = redDot_image;
        }
        return pinView;
    }
    
    
    if ([annotation point_type] != heading){
        
        // try to dequeue an existing pin view first
        static NSString *landmarkAnnotationID = @"landmarkAnnotationID";
        
        OSXPinAnnotationView *pinView =
        (OSXPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:landmarkAnnotationID];
        
        if (pinView == nil)
        {
            pinView = [[OSXPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:landmarkAnnotationID];
        }else{
            // TODO: the callOutViewController needs to be reinitialized!
            pinView = [pinView initWithAnnotation:annotation reuseIdentifier:landmarkAnnotationID];
        }
        
        if([self.UIConfigurations[@"UIAllowMultipleAnnotations"] boolValue]){
            [pinView setCanShowCallout:NO];
        }else{
            [pinView setCanShowCallout:YES];
        }

        if (annotation.point_type == landmark){
            [pinView setAnimatesDrop:NO];
        }else{
            [pinView setAnimatesDrop:YES];
        }
        

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
        }else if ([annotation point_type] == answer){
            //---------------
            // Search pin
            //---------------
            pinView = [self configureAnswerPinView: pinView];
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
- (OSXPinAnnotationView *) configureUserDroppedPinView: (OSXPinAnnotationView *) pinView
{
    //-----------------
    // Only do address look up when the Test Manager is off
    //-----------------
    if (self.testManager->testManagerMode == OFF &&
        [((CustomPointAnnotation *)pinView.annotation).address
         isEqualToString: @""] )
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
                 copyAnnotation.address = address;
                 pinView.annotation = copyAnnotation;
             }
         }];
    }
    pinView.pinColor = MKPinAnnotationColorPurple;
    
    //---------------
    //Configure the left button (tag: 0)
    //---------------
    CalloutButton *leftButton;
    if (pinView.leftCalloutAccessoryView == nil){
        leftButton = [[CalloutButton alloc] init];
    }else{
        leftButton = pinView.leftCalloutAccessoryView;
    }
    
    NSImage *btnLeftImage = [NSImage imageNamed:@"remove.png"];
    [leftButton setImage:btnLeftImage];
    leftButton.frame = CGRectMake(0, 0,
                                  btnLeftImage.size.width,
                                  btnLeftImage.size.height);
    [leftButton setTarget:self];    
    leftButton.action = nil;
    [leftButton setAction:@selector(leftButtonAction:)];
    leftButton.pinView = pinView;
    leftButton.tag = 0; //left button has tag 0
    pinView.leftCalloutAccessoryView = leftButton;
    
    // Add a right button
    [self addRightButton:pinView];
    
    return pinView;
}
//---------------
// Landmark pin
//---------------
- (OSXPinAnnotationView *) configureLandmarkPinView: (OSXPinAnnotationView *) pinView
{
    NSImage *btnImage;
    CustomPointAnnotation *myAnnotation =
    (CustomPointAnnotation *) pinView.annotation;
    
    int i = [myAnnotation data_id];
    if (self.model->data_array[i].isEnabled){
        pinView.pinColor = MKPinAnnotationColorRed;
        btnImage = [NSImage imageNamed:@"selected.png"];
    }else{
        pinView.pinColor = MKPinAnnotationColorGreen;
        btnImage = [NSImage imageNamed:@"unselected.png"];
    }

    //---------------
    // Constructing a left button (tag: 0)
    //---------------
    CalloutButton *leftButton;
    if (pinView.leftCalloutAccessoryView == nil){
        leftButton = [[CalloutButton alloc] init];
    }else{
        leftButton = pinView.leftCalloutAccessoryView;
    }
    

    leftButton.frame = CGRectMake(0, 0,
                                  btnImage.size.width, btnImage.size.height);
    [leftButton setImage:btnImage];    
    [leftButton setTarget:self];
    leftButton.action = nil;
    [leftButton setAction:@selector(leftButtonAction:)];
    leftButton.pinView = pinView;

    leftButton.tag = 0;  //right button has tag 0
    pinView.leftCalloutAccessoryView = leftButton;

    // Add a right button
    [self addRightButton:pinView];
    
    return pinView;
}


- (void) addRightButton: (MKPinAnnotationView *) pinView{
    //---------------
    // Constructing a right button (tag: 1)
    //---------------
    CalloutButton *rightButton;
    rightButton = [[CalloutButton alloc] init];
    rightButton.title = @"Detail";
    rightButton.tag = 1;  //right button has tag 1
    [rightButton setTarget:self];
    [rightButton setAction:@selector(detailButtonAction:)];
    rightButton.pinView = pinView;
    pinView.rightCalloutAccessoryView = rightButton;
}

- (OSXPinAnnotationView *) configureSearchPinView: (OSXPinAnnotationView *) pinView
{
    return pinView;
}

//-----------------
// Answer pin
//-----------------
- (OSXPinAnnotationView *) configureAnswerPinView: (OSXPinAnnotationView *) pinView
{
    pinView.pinColor = MKPinAnnotationColorRed;
    return pinView;
}

- (MKAnnotationView *) configureHeadingImageView: (MKAnnotationView *) pinView
{
    return pinView;
}



//------------------
// When the callout of a pin is tapped
//------------------
- (void)detailButtonAction:(CalloutButton*) control{
    OSXPinAnnotationView *pinView = control.pinView;
    NSLog(@"Right button clicked");
    [pinView showDetailCallout:YES];
}

- (void)leftButtonAction:(CalloutButton*) control{
    NSLog(@"Left button clicked");
    OSXPinAnnotationView *pinView = control.pinView;
    
    // Left buttton tapped
    if ([pinView pinColor] == MKPinAnnotationColorPurple){
        // if it is a dropped pin, remove the pin
        [self.mapView removeAnnotation:pinView.annotation];
    }else{
        // if it is a landmark pin, flip the enable status
        CustomPointAnnotation* myCustomAnnotation =
        (CustomPointAnnotation*) pinView.annotation;
        int idx = myCustomAnnotation.data_id;
        data* data_ptr = &(self.model->data_array[idx]);
        
        data_ptr->isEnabled = !data_ptr->isEnabled;
        pinView = [self configureLandmarkPinView:pinView];
        
    }
    
}


//------------------
// This one might be useless for the desktop application
//------------------
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(NSControl *)control
{
    
    NSLog(@"Do something");
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)view;
    //------------------
    // The pin is a custom pin
    //------------------
    NSButton *myButton = (NSButton *)control;
    if(myButton.tag == 0){
        // Left buttton tapped
        if ([pinView pinColor] == MKPinAnnotationColorPurple){
            // if it is a dropped pin, remove the pin
            [self.mapView removeAnnotation:view.annotation];
        }else{
            // if it is a landmark pin, flip the enable status
            CustomPointAnnotation* myCustomAnnotation =
            (CustomPointAnnotation*) view.annotation;
            int idx = myCustomAnnotation.data_id;
            data* data_ptr = &(self.model->data_array[idx]);
            
            data_ptr->isEnabled = !data_ptr->isEnabled;
            
            pinView = [self configureLandmarkPinView:pinView];
            
        }
    }else if (myButton.tag == 1){
//        [self performSegueWithIdentifier:@"DetailVC" sender:view];
    }
}

//------------------
// When a pin is selected
//------------------
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:
(OSXPinAnnotationView *)pinView{
    NSLog(@"Annotation clicked");
    if([self.UIConfigurations[@"UIAllowMultipleAnnotations"] boolValue]){
        [pinView showCustomCallout:!pinView.customCalloutStatus];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:
(OSXPinAnnotationView *)pinView
{
//    // do nothing
//    NSLog(@"Deselect annoation");
//    if(!pinView.canShowCallout)
//        [pinView showCustomCallout:NO];
    [pinView showDetailCallout:NO];
}

//-------------------
// Change how annotations should be displayed
//-------------------
- (void)changeAnnotationDisplayMode: (NSString*) mode{
    NSArray* annotation_array = self.mapView.annotations;
    NSImage *redDot_image = [[NSImage alloc] initWithContentsOfFile:
                                    [[NSBundle mainBundle] pathForResource:@"redDot" ofType:@"png"]];
    
    if ([mode isEqualToString:@"All"]){
        for (CustomPointAnnotation* annotation in annotation_array){
            [[self.mapView viewForAnnotation:annotation] setHidden:NO];
        }
    }else if ([mode isEqualToString:@"Enabled"]){
        for (CustomPointAnnotation* annotation in annotation_array){
            int i = annotation.data_id;
            if (annotation.point_type == landmark && self.model->data_array[i].isEnabled){
                [[self.mapView viewForAnnotation:annotation] setHidden:NO];
            }else{
                [[self.mapView viewForAnnotation:annotation] setHidden:YES];
            }
        }
    }else if ([mode isEqualToString:@"Study"]){
        for (CustomPointAnnotation* annotation in annotation_array){
            int i = annotation.data_id;
            
//            cout << self.model->data_array[i].name << endl;
            if (annotation.point_type == landmark &&
                self.model->data_array[i].isEnabled)
            {
                if (self.testManager->testManagerMode == DEVICESTUDY ||
                    self.testManager->testManagerMode == OSXSTUDY)
                {
                    if (self.model->data_array[i].isAnswer){
                        [[self.mapView viewForAnnotation:annotation] setHidden:YES];
                    }else{
                        //-----------
                        // In the study mode, a landmark, enabled location
                        // will be displayed as a red dot
                        //-----------
                        [[self.mapView viewForAnnotation:annotation] setHidden:NO];
                        OSXAnnotationView* temp = (OSXAnnotationView*)
                        [self.mapView viewForAnnotation:annotation];
                        temp.image = redDot_image;
                    }
                }else{
                    [[self.mapView viewForAnnotation:annotation] setHidden:NO];
                }
                
            }else{
                [[self.mapView viewForAnnotation:annotation] setHidden:YES];
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
    }else if ([mode isEqualToString:@"None"]){
        for (CustomPointAnnotation* annotation in annotation_array){
            [[self.mapView viewForAnnotation:annotation] setHidden:YES];
        }
    }else{
        throw(runtime_error("Unknown showPin mode."));
    }
    
    self.UIConfigurations[@"ShowPins"] = mode;
}

@end
