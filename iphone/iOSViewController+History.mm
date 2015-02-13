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
    
    NSString *dateString = [NSDateFormatter
                            localizedStringFromDate:[NSDate date]
                            dateStyle:NSDateFormatterShortStyle
                            timeStyle:NSDateFormatterFullStyle];
    NSLog(@"%@",dateString);
    
    breadcrumb myBreadcrumb;
//    myBreadcrumb.name = ;
    myBreadcrumb.coord2D = coord2D;
    myBreadcrumb.date_str = dateString;
    self.model->breadcrumb_array.push_back(myBreadcrumb);
    
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

@end
