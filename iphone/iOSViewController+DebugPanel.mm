//
//  iOSViewController+DebugPanel.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 7/18/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+DebugPanel.h"

@implementation iOSViewController (DebugPanel)

- (IBAction)takeSnapshot:(id)sender {
    
    // Get the center coordinates
    MKCoordinateRegion display_region = self.mapView.region;
    
    // Get the orientation
    double orientation = self.model->camera_pos.orientation;
    
    // Need to save the file name too
    
    //--------------
    // Print out data for verification
    //--------------
    NSLog(@"===========");
    NSLog(@"Latitude: %f", display_region.center.latitude);
    NSLog(@"Latitude: %f", display_region.center.longitude);
    NSLog(@"Orientation: %f", orientation);
    NSLog(@"Span latitude: %f", display_region.span.latitudeDelta);
    NSLog(@"Span longitude: %f", display_region.span.longitudeDelta);
    
    
    
}
@end
