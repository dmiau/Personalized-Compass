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
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MKPointAnnotation*)annotation {
    
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
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
    
    [pinView setAnimatesDrop:YES];
    [pinView setCanShowCallout:YES];

    
    //-----------------------------------------
    
    //Decide which color to show
    UIImage *btnImage, *btnLeftImage;
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if ([annotation subtitle] == nil){
        //---------------
        // User triggered droppin
        //---------------

        NSString *address;
        CLLocation *location = [[CLLocation alloc]
                                initWithLatitude:[annotation coordinate].latitude
                                longitude:[annotation coordinate].longitude];
        
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
                 MKPointAnnotation *copyAnnotation = annotation;
                 copyAnnotation.subtitle = address;
             }
         }];

        pinView.pinColor = MKPinAnnotationColorPurple;
        btnImage = [UIImage imageNamed:@"add.png"];
        btnLeftImage = [UIImage imageNamed:@"remove.png"];
        
        [leftButton setImage:btnLeftImage forState:UIControlStateNormal];
        leftButton.frame = CGRectMake(0, 0,
                                       btnLeftImage.size.width,
                                      btnLeftImage.size.height);
        [leftButton setBackgroundColor: [UIColor redColor]];
        
        [leftButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        leftButton.tag = 0; //left button has tag 0
        pinView.leftCalloutAccessoryView = leftButton;

        //---------------
        // Constructing a right button
        //---------------
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        rightButton.tag = 1;  //right button has tag 1
        pinView.rightCalloutAccessoryView = rightButton;
    }else{
        //---------------
        // Landmark pin
        //---------------
        int i = [[annotation subtitle] integerValue];
        if (self.model->data_array[i].isEnabled){
            pinView.pinColor = MKPinAnnotationColorRed;
            btnImage = [UIImage imageNamed:@"selected.png"];
        }else{
            pinView.pinColor = MKPinAnnotationColorGreen;
            btnImage = [UIImage imageNamed:@"unselected.png"];
        }

        //---------------
        // Constructing a right button
        //---------------
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setImage:btnImage forState:UIControlStateNormal];
        rightButton.frame = CGRectMake(0, 0,
                                       btnImage.size.width, btnImage.size.height);
        [rightButton setBackgroundColor: [UIColor redColor]];
        [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        
        
        rightButton.tag = 1;  //right button has tag 0
        pinView.rightCalloutAccessoryView = rightButton;
    }
    return pinView;
}


//------------------
// When the callout of a pin is tapped
//------------------
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
    NSLog(@"Do something");
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)view;
    // Check if this is a custom pin
    if ([pinView pinColor] == MKPinAnnotationColorPurple){
        //------------------
        // The pin is a custom pin
        //------------------
        UIButton *myButton = (UIButton *)control;
        if(myButton.tag == 0){
            // Left buttton tapped - remove the pin
            [self.mapView removeAnnotation:view.annotation];
        }else{
            [self performSegueWithIdentifier:@"DetailVC" sender:view];
            
            
        }
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
