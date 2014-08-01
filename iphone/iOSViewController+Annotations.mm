//
//  iOSViewController+Annotations.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Annotations.h"
//#import "CustomAnnotationView.h"
#import "DetailViewController.h"
#import "commonInclude.h"

@implementation iOSViewController (Annotations)

-(void) renderAnnotations{
    
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    
    // Add annotations one by one
    for (int i = 0; i < self.model->data_array.size(); ++i){
        data myData = self.model->data_array[i];
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
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
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
    //------------------
    // The pin is a custom pin
    //------------------
    UIButton *myButton = (UIButton *)control;
    if([pinView pinColor] == MKPinAnnotationColorPurple &&
       myButton.tag == 0){
        // Left buttton tapped - remove the pin
        [self.mapView removeAnnotation:view.annotation];
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
