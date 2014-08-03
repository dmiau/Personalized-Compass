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
    
    // Need to cache glkview's inital location:
    static CGRect cache_rect =  self.glkView.frame;
    
    self.glkView.frame = cache_rect;
    switch ([segmentedControl selectedSegmentIndex]) {
        case 0:
            //------------
            // None
            //------------
            [self toggleOverviewMap:NO];
            [self togglePCompass:NO];
            break;
        case 1:
            //------------
            // Overview
            //------------
            [self togglePCompass:NO];
            [self toggleOverviewMap:YES];
            break;
        case 2:
            //------------
            // PCompass
            //------------
            [self toggleOverviewMap:NO];
            [self togglePCompass:YES];
            [self toggleConventionalCompass:NO];
            break;
        default:
            break;
    }
//    [self.glkView setNeedsDisplay];
}

//------------------
// Controlling the state of diffrent views
//------------------
- (void)toggleOverviewMap: (bool) state{
    if (state){
#ifdef __IPAD__
        self.glkView.frame = CGRectMake(0, 0,
        self.glkView.frame.size.width,
        self.glkView.frame.size.height);
#endif
        [[self overviewMapView] setHidden:NO];
        
        self.overviewMapView.layer.borderColor = [UIColor blackColor].CGColor;
        self.overviewMapView.layer.borderWidth = 2.0f;
        self.renderer->isOverviewMapEnabled = true;
        [self updateOverviewMap];
    }else{
        [[self overviewMapView] setHidden:YES];
        self.renderer->isOverviewMapEnabled = false;
    }
}

- (void)togglePCompass: (bool) state{
    if (state){
        self.model->configurations[@"personalized_compass_status"] = @"on";
    }else{
        self.model->configurations[@"personalized_compass_status"] = @"off";
    }
    [self.glkView setNeedsDisplay];
}


- (void)toggleConventionalCompass: (bool)state{
    if (state){
        self.conventionalCompassVisible = YES;
        [self setFactoryCompassHidden:NO];
    }else{
        self.conventionalCompassVisible = NO;
        [self setFactoryCompassHidden:YES];
    }
}

- (void)toggleWedge: (bool)state{
    if (state){
        self.model->configurations[@"wedge_status"] = @"on";
    }else{
        self.model->configurations[@"wedge_status"] = @"off";
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
    [self.glkView setNeedsDisplay];
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
    
    if (self.model->tilt > - 0.1)
        [self.overviewMapView setRegion:region animated:NO];
    else
        [self.overviewMapView setCenterCoordinate:region.center];
    
    self.overviewMapView.camera.heading = -self.model->camera_pos.orientation;
    
    
    //-------------
    // Disable overview map's compass
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
