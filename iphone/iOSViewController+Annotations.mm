//
//  iOSViewController+Annotations.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Annotations.h"
#import "CustomAnnotationView.h"

@implementation iOSViewController (Annotations)

-(void) renderAnnotations{
    
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    
    // Add annotations one by one
    
    for (int i = 0; i < self.model->data_array.size(); ++i){
        data myData = self.model->data_array[i];
//        if (myData.isEnabled)
            [self.mapView addAnnotation: myData.annotation];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    // try to dequeue an existing pin view first
    static NSString *landmarkAnnotationID = @"landmarkAnnotationID";
    
    MKPinAnnotationView *pinView =
    (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:landmarkAnnotationID];
    
//    CustomAnnotationView *myCustomAnnotationView =
//    [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:landmarkAnnotationID];
//    return myCustomAnnotationView;
    

    if (pinView == nil)
    {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:landmarkAnnotationID];
        
        [pinView setAnimatesDrop:YES];
        [pinView setCanShowCallout:YES];
    }else{
        pinView.annotation = annotation;
    }
    
    //Decide which color to show
    UIImage *btnImage, *btnLeftImage;
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if ([annotation subtitle] == nil){
        //---------------
        // Custom droppin
        //---------------
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
        
    }else{
        int i = [[annotation subtitle] integerValue];
        if (self.model->data_array[i].isEnabled){
            pinView.pinColor = MKPinAnnotationColorRed;
            btnImage = [UIImage imageNamed:@"selected.png"];
        }else{
            pinView.pinColor = MKPinAnnotationColorGreen;
            btnImage = [UIImage imageNamed:@"unselected.png"];
        }
    }
    
    //---------------
    // Constructing a right button
    //---------------
    
//    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightButton setImage:btnImage forState:UIControlStateNormal];
//    rightButton.frame = CGRectMake(0, 0,
//                                   btnImage.size.width, btnImage.size.height);
//    [rightButton setBackgroundColor: [UIColor redColor]];
//    [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
//
//    
//    rightButton.tag = 1;  //right button has tag 0
//    pinView.rightCalloutAccessoryView = rightButton;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    rightButton.tag = 1;  //right button has tag 0
    pinView.rightCalloutAccessoryView = rightButton;
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
    NSLog(@"Do something");
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)view;
    // Check if this is a custom pin
    if ([pinView.annotation subtitle] == nil){
        //------------------
        // The pin is a custom pin
        //------------------
        UIButton *myButton = (UIButton *)control;
        if(myButton.tag == 0){
            // Left buttton tapped - remove the pin
            [self.mapView removeAnnotation:view.annotation];
        }else{
            // Right buttton tapped - add the pin to data_array
//            data myData;
//            myData.name = "custom";
//            myData.annotation = view.annotation;
//            
//            myData.annotation.title = @"custom";
//            myData.annotation.subtitle =
//            [NSString stringWithFormat:@"%lu",
//             self.model->data_array.size()];
//            
//            myData.latitude =  view.annotation.coordinate.latitude;
//            myData.longitude =  view.annotation.coordinate.longitude;
//            
//            // Add the new data to data_array
//            self.model->data_array.push_back(myData);
            
            [self performSegueWithIdentifier:@"DetailVC" sender:view];
            
            
        }
    }
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    NSLog(@"Annotation clicked");
//    MKPinAnnotationView *pinView = (MKPinAnnotationView *)view;
////    pinView.pinColor = MKPinAnnotationColorPurple;
//    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
//    [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
//    pinView.rightCalloutAccessoryView = rightButton;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(MKAnnotationView *)sender
{
    if ([segue.identifier isEqualToString:@"DetailVC"])
    {
//        DetailViewController *destinationViewController = segue.destinationViewController;
//        
//        // grab the annotation from the sender
//        
//        destinationViewController.receivedLocation = sender.annotation;
    } else {
        NSLog(@"PFS:something else");
    }
}

@end
