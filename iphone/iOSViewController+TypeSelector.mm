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
        self.renderer->isOverviewMapEnabled = true;
    }else{
        [[self overviewMapView] setHidden:YES];
        self.renderer->isOverviewMapEnabled = false;
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
//        [self.glkView setHidden:YES];
        self.model->configurations[@"personalized_compass_status"] = @"off";
        [self setFactoryCompassHidden:NO];
    }else if ([label isEqualToString:@"Personalized"]){
        self.conventionalCompassVisible = NO;
        self.model->configurations[@"personalized_compass_status"] = @"on";
        [self setFactoryCompassHidden:YES];
    }else{
        self.conventionalCompassVisible = NO;
        self.model->configurations[@"personalized_compass_status"] = @"off";
//        [self.glkView setHidden:YES];
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
    
    //-------------
    // Draw a box on the overview map
    //-------------
    
    //First we need to calculate the corners of the map so we get the points
    CGPoint ulPoint = CGPointMake(self.mapView.bounds.origin.x,
                                  self.mapView.bounds.origin.y);
    CGPoint urPoint = CGPointMake(self.mapView.bounds.origin.x
                                  + self.mapView.bounds.size.width
                                  , self.mapView.bounds.origin.y);
    CGPoint brPoint = CGPointMake(self.mapView.bounds.origin.x
                                  + self.mapView.bounds.size.width,
                                  self.mapView.bounds.origin.y+
                                  self.mapView.bounds.size.height);
    CGPoint blPoint = CGPointMake(self.mapView.bounds.origin.x,
                                  self.mapView.bounds.origin.y+
                                  self.mapView.bounds.size.height);
    
    //Then transform those point into lat,lng values
    CLLocationCoordinate2D coord_array[4];
    coord_array[0]
    = [self.mapView convertPoint:ulPoint toCoordinateFromView:self.mapView];
    coord_array[1]
    = [self.mapView convertPoint:urPoint toCoordinateFromView:self.mapView];
    
    coord_array[2]
    = [self.mapView convertPoint:brPoint toCoordinateFromView:self.mapView];
    coord_array[3]
    = [self.mapView convertPoint:blPoint toCoordinateFromView:self.mapView];
    
    
    // Covert the four coordinates (of the overview map)
    // to the view points (of the mapview)
    
    for (int i = 0; i < 4; ++i){
        self.renderer->box4Corners[i] =
        [self.overviewMapView convertCoordinate:coord_array[i]
                                  toPointToView:self.mapView];
    }
    //    //Draw a box
    //    MKPolyline *routeLine = [MKPolyline polylineWithCoordinates:coord_array count:4];
    //
    //    // There is probably some performance penalty
    //    [self.overviewMapView removeOverlays: self.overviewMapView.overlays];
    //    [self.overviewMapView addOverlay:routeLine];
    
}
@end
