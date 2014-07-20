//
//  iOSViewController+History.m
//  Compass[transparent]
//
//  Created by dmiau on 7/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+History.h"

@implementation iOSViewController (History)
- (bool) addBreadcrumb: (CLLocationCoordinate2D) coord2D{
    breadcrumb myBreadcrumb;
    myBreadcrumb.coord2D = coord2D;
    self.model->breadcrumb_array.push_back(myBreadcrumb);
    
    if (self.model->breadcrumb_array.size() > 100){
        self.model->breadcrumb_array.erase(
        self.model->breadcrumb_array.begin());
    }
    return true;
}

- (bool) displayBreadcrumb{
    
    NSInteger numberOfSteps = self.model->breadcrumb_array.size();
    
    CLLocationCoordinate2D coordinates[numberOfSteps];
    
    for (NSInteger index = 0; index < numberOfSteps; index++) {
        coordinates[index] = self.model->breadcrumb_array[index].coord2D;
    }
    
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    [self.mapView addOverlay:polyLine];
    return true;
}

- (bool) saveBreadcrumbArray{
    return true;
}

- (bool) loadBreadkcrumbArray{
    return true;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor redColor];
    polylineView.lineWidth = 8.0;
    
    return polylineView;
}
@end
