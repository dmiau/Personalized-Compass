//
//  DesktopViewController+MapView.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 4/2/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+MapView.h"

@implementation DesktopViewController (MapView)

#pragma mark map annotation

- (void) addAnnotationPins{
    //--------------
    // Adding an annotation pin for each location
    //--------------
    CLLocationCoordinate2D coord;
    
    for (int i = 0; i < self.model->data_array.size(); ++i){
        
        // [todo] need to reuse annotation
        CustomPointAnnotation *annotation = [[CustomPointAnnotation alloc] init];
        coord.latitude = self.model->data_array[i].latitude;
        coord.longitude = self.model->data_array[i].longitude;
        annotation.coordinate = coord;
        annotation.title      = [NSString stringWithCString:self.model->data_array[i].name.c_str() encoding:[NSString defaultCStringEncoding]];
        //        annotation.subtitle   = @"Paris Test";
        
        [self.mapView addAnnotation:annotation];

        if (pinVisible)
            [self.mapView selectAnnotation:annotation animated:YES];
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{

}

- (IBAction)togglePins:(id)sender {
    // Adding annotations
    static BOOL once = false;
    if (!once){
        [self addAnnotationPins];
        pinVisible = true;
        once = true;
        return;
    }
    
    NSSet *nearbySet = [self.mapView annotationsInMapRect:self.mapView.visibleMapRect];
    
    for (CustomPointAnnotation *item in nearbySet){
        if (!pinVisible){
            //http://stackoverflow.com/questions/2918154/how-to-hide-mkannotationview-callout

            [[self.mapView viewForAnnotation:item] setHidden:NO];
            //            MKAnnotationView *temp =[self.mapView viewForAnnotation:item];
            //            temp.canShowCallout = NO;
        }else{
            [[self.mapView viewForAnnotation:item] setHidden:YES];
            
            // Print out the camera information
            NSLog(@"%@", self.mapView.camera);
        }
    }
    pinVisible = !pinVisible;
}

- (IBAction)toggleMapMode:(id)sender {
    
    switch([[sender selectedCell] tag]){
        case 1:
            self.mapView.mapType = MKMapTypeStandard;
            self.mapView.showsBuildings = YES;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            self.mapView.showsBuildings = YES;
            break;
        case 3:
            self.mapView.mapType = MKMapTypeSatellite;
            self.mapView.showsBuildings = YES;
            break;
    }
    
}

//// Updating current location indicator
//- (void)mapView:(MKMapView *)mapViewHandle regionDidChangeAnimated:(BOOL)animated{
//
//    NSString *latlon_str = [NSString stringWithFormat:@"%2.4f, %2.4f",
//                    [mapViewHandle centerCoordinate].latitude,
//                    [mapViewHandle centerCoordinate].longitude];
//    [[self currentCoord] setStringValue: latlon_str];
//}

//------------------
// Coordinate conversion
//------------------
- (CLLocationCoordinate2D) calculateLatLonFromiOSX: (int) x Y: (int) y {
    CLLocationCoordinate2D result;
    
    // Note: (x, y) are in the iOS OpenGL coordinate system
    
    // The (x, y) coordinates in the OSX screen coordinate frame
    CGPoint osx_xy;
    osx_xy.x = (float)x * self.renderer->em_ios_width / self.renderer->true_ios_width;
    osx_xy.y = (float)y * self.renderer->em_ios_height / self.renderer->true_ios_height;
    
    osx_xy.x = self.renderer->orig_width/2 + osx_xy.x;
    osx_xy.y = self.renderer->orig_height/2 + osx_xy.y;
    
    result = [self.mapView convertPoint:osx_xy toCoordinateFromView:self.compassView];
    return result;
}

@end
