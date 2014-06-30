//
//  iOSViewController+TypeSelector.m
//  Compass[transparent]
//
//  Created by dmiau on 6/22/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+TypeSelector.h"

@implementation iOSViewController (TypeSelector)

//------------------
// Toggle between conventional compass and personalized compass
//------------------
//- (IBAction)toggleCompass:(id)sender {
//    if ([self.glkView isHidden] == NO){
//        [self.glkView setHidden:YES];
//        [self setFactoryCompassHidden:NO];
//    }else{
//        [self.glkView setHidden:NO];
//        [self setFactoryCompassHidden:YES];
//    }
//}


//------------------
// Toggle the overview map
//------------------
- (IBAction)toggleOverviewMap:(id)sender {
    if ([[self overviewMapView] isHidden]){
        [[self overviewMapView] setHidden:NO];
                
        self.overviewMapView.layer.borderColor = [UIColor blackColor].CGColor;
        self.overviewMapView.layer.borderWidth = 2.0f;
        
    }else{
        [[self overviewMapView] setHidden:YES];
    }
}

//------------------
// Select compass type
//------------------
- (IBAction)compassSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    
    if ([label isEqualToString:@"Conventional"]){
        self.conventionalCompassVisible = YES;
        [self.glkView setHidden:YES];
        [self setFactoryCompassHidden:NO];
    }else if ([label isEqualToString:@"Personalized"]){
        self.conventionalCompassVisible = NO;
        [self.glkView setHidden:NO];
        [self setFactoryCompassHidden:YES];
    }else{
        self.conventionalCompassVisible = NO;
        [self.glkView setHidden:YES];
        [self setFactoryCompassHidden:YES];
    }
}

//------------------
// Update Overview map
//------------------
- (void)updateOverviewMap{
    float scale = 5;
    MKCoordinateRegion region;
    region.center.latitude = self.mapView.region.center.latitude;
    region.center.longitude = self.mapView.region.center.longitude;

    region.span.latitudeDelta = self.mapView.region.span.latitudeDelta * scale;
    region.span.longitudeDelta = self.mapView.region.span.longitudeDelta * scale;

    [self.overviewMapView setRegion:region animated:NO];
    self.overviewMapView.camera.heading = -self.model->current_pos.orientation;
    
    
    //-------------
    // Disable compass
    //-------------
    NSArray *mapSubViews = self.overviewMapView.subviews;
    
    for (UIView *view in mapSubViews) {
        // Checks if the view is of class MKCompassView
        if ([view isKindOfClass:NSClassFromString(@"MKCompassView")]) {
            // Removes view from mapView
            [view removeFromSuperview];
        }
    }
}
@end
