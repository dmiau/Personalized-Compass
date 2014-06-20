//
//  iOSViewController+Annotations.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Annotations.h"

@implementation iOSViewController (Annotations)

-(void) renderAnnotations{
    
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    
    // Add annotations one by one
    
    for (int i = 0; i < self.model->data_array.size(); ++i){
        data myData = self.model->data_array[i];
        if (myData.isEnabled)
            [self.mapView addAnnotation: myData.annotation];
    }
}

-(void) drawAnnotations{
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
    if (pinView == nil)
    {
        MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:landmarkAnnotationID];
        
        [pinView setAnimatesDrop:YES];
        [pinView setCanShowCallout:YES];
        pinView.pinColor = MKPinAnnotationColorPurple;
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        pinView.rightCalloutAccessoryView = rightButton;
    }else{
        pinView.annotation = annotation;
    }
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
    NSLog(@"Do something");
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    NSLog(@"Annotation clicked");
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)view;
    pinView.pinColor = MKPinAnnotationColorPurple;
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    pinView.rightCalloutAccessoryView = rightButton;
}

@end
