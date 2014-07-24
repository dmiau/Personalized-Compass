//
//  iOSViewController+TypeSelector.m
//  Compass[transparent]
//
//  Created by dmiau on 6/22/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+ViewPanel.h"
#import "CustomAnnotationView.h"

@implementation iOSViewController (ViewPanel)

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
// Wedge Control
//------------------

- (IBAction)wedgeSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            //-----------
            // None
            //-----------
            self.model->configurations[@"wedge_status"] = @"off";
            break;
        case 1:
            //-----------
            // Original
            //-----------
            self.model->configurations[@"wedge_status"] = @"on";
            self.model->configurations[@"wedge_style"] = @"original";
            break;
        case 2:
            //-----------
            // Modified
            //-----------
            self.model->configurations[@"wedge_status"] = @"on";
            self.model->configurations[@"wedge_style"] = @"modified";
            break;
        default:
            throw(runtime_error("Undefined control, update needed"));
            break;
            
    }
    [self.glkView setNeedsDisplay];
}

//------------------
// Overview segment control
//------------------
- (IBAction)overviewSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    switch ([segmentedControl selectedSegmentIndex]) {
        case 0:
            //------------
            // None
            //------------
            [[self overviewMapView] setHidden:YES];
            self.renderer->isOverviewMapEnabled = false;
            self.model->configurations[@"personalized_compass_status"] = @"off";
            break;
        case 1:
            //------------
            // Overview
            //------------
            self.model->configurations[@"personalized_compass_status"] = @"off";
            [[self overviewMapView] setHidden:NO];
            
            self.overviewMapView.layer.borderColor = [UIColor blackColor].CGColor;
            self.overviewMapView.layer.borderWidth = 2.0f;
            self.renderer->isOverviewMapEnabled = true;
            [self updateOverviewMap];
            break;
        case 2:
            //------------
            // PCompass
            //------------
            [[self overviewMapView] setHidden:YES];
            self.renderer->isOverviewMapEnabled = false;
            self.conventionalCompassVisible = NO;
            self.model->configurations[@"personalized_compass_status"] = @"on";
            [self setFactoryCompassHidden:YES];
            break;
        default:
            break;
    }
    [self.glkView setNeedsDisplay];
}


//------------------
// Select map style
//------------------
- (IBAction)mapStyleSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    
    if ([label isEqualToString:@"Standard"]){
        self.mapView.mapType = MKMapTypeStandard;
    }else if ([label isEqualToString:@"Hybrid"]){
        self.mapView.mapType = MKMapTypeHybrid;
    }else{
        self.mapView.mapType = MKMapTypeSatellite;
    }
}

//------------------
// Update Overview map
//------------------
- (void)updateOverviewMap{
    
    if ([[self overviewMapView] isHidden]){
        // Don't need to update if it is hidden
        return;
    }
    
    float scale = [self.model->configurations[@"overview_map_scale"]
                   floatValue];
    MKCoordinateRegion region;
    region.center.latitude = self.mapView.region.center.latitude;
    region.center.longitude = self.mapView.region.center.longitude;

    region.span.latitudeDelta = self.mapView.region.span.latitudeDelta * scale;
    region.span.longitudeDelta = self.mapView.region.span.longitudeDelta * scale;

    
    // Check if the data is within the range
    if (region.span.latitudeDelta > 90) region.span.latitudeDelta = 90;
    if (region.span.latitudeDelta < -90) region.span.latitudeDelta = -90;

    if (region.span.longitudeDelta > 180) region.span.longitudeDelta = 180;
    if (region.span.longitudeDelta < -180) region.span.longitudeDelta = -180;
    
    [self.overviewMapView setRegion:region animated:NO];
    self.overviewMapView.camera.heading = -self.model->camera_pos.orientation;
    
    
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
                                  toPointToView:self.glkView];
    }
    //    //Draw a box
    //    MKPolyline *routeLine = [MKPolyline polylineWithCoordinates:coord_array count:4];
    //
    //    // There is probably some performance penalty
    //    [self.overviewMapView removeOverlays: self.overviewMapView.overlays];
    //    [self.overviewMapView addOverlay:routeLine];
    [self.glkView setNeedsDisplay];
    
}

- (IBAction)scaleSlider:(UISlider *)sender {
    
    float scale  = [sender value];
    
    self.model->configurations[@"overview_map_scale"] =
    [NSNumber numberWithFloat:scale];
    
    self.scaleIndicator.text = [NSString stringWithFormat:@"%2.1f",
                                scale];
    [self updateOverviewMap];
}
@end
