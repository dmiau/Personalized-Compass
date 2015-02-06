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

@end
