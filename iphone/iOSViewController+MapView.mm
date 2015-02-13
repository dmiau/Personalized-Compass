//
//  iOSViewController+MapView.m
//  Compass[transparent]
//
//  Created by Daniel on 2/5/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "iOSViewController+MapView.h"

@implementation iOSViewController (MapView)

// New annotation will be generated as the map is changed.
// Need to update the annotation appearance status again.
- (void)mapView:(MKMapView *)mapViewHandle regionDidChangeAnimated:(BOOL)animated{
    [self changeAnnotationDisplayMode:self.UIConfigurations[@"ShowPins"]];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    
//    MKPolyline
//    if ([overlay isKindOfClass:[MKPolyline class]){
        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        polylineView.strokeColor = [UIColor redColor];
        polylineView.lineWidth = 3.0;
        
        return polylineView;
//    }else{
//        
//    }
    
}

- (IBAction)toggleHomeBox:(UISwitch*)sender {
    static MKPolyline* poly;
    
    if (sender.on){
        // Define an overlay that covers Colorado.
        CLLocationCoordinate2D  points[5];
        points[0] = CLLocationCoordinate2DMake
        (self.model->homeCoordinateRegion.center.latitude-
         self.model->homeCoordinateRegion.span.latitudeDelta/2,
         self.model->homeCoordinateRegion.center.longitude+
         self.model->homeCoordinateRegion.span.longitudeDelta/2);
        points[1] = CLLocationCoordinate2DMake
        (self.model->homeCoordinateRegion.center.latitude+
         self.model->homeCoordinateRegion.span.latitudeDelta/2,
         self.model->homeCoordinateRegion.center.longitude+
         self.model->homeCoordinateRegion.span.longitudeDelta/2);
        points[2] = CLLocationCoordinate2DMake
        (self.model->homeCoordinateRegion.center.latitude+
         self.model->homeCoordinateRegion.span.latitudeDelta/2,
         self.model->homeCoordinateRegion.center.longitude-
         self.model->homeCoordinateRegion.span.longitudeDelta/2);
        points[3] = CLLocationCoordinate2DMake
        (self.model->homeCoordinateRegion.center.latitude-
         self.model->homeCoordinateRegion.span.latitudeDelta/2,
         self.model->homeCoordinateRegion.center.longitude-
         self.model->homeCoordinateRegion.span.longitudeDelta/2);
        points[4] = CLLocationCoordinate2DMake
        (self.model->homeCoordinateRegion.center.latitude-
         self.model->homeCoordinateRegion.span.latitudeDelta/2,
         self.model->homeCoordinateRegion.center.longitude+
         self.model->homeCoordinateRegion.span.longitudeDelta/2);
        poly = [MKPolyline polylineWithCoordinates:points count:5];
        poly.title = @"Blank";
        [self.mapView addOverlay:poly];
    }else{
        [self.mapView removeOverlay:poly];
    }
}


@end
