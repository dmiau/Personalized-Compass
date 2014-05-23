//
//  DesktopViewController+MapViewAddition.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 4/2/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+MapViewAddition.h"

@implementation DesktopViewController (MapViewAddition)

#pragma mark map annotation

- (void) addAnnotationPins{
    //--------------
    // Adding an annotation pin for each location
    //--------------
    CLLocationCoordinate2D coord;
    
//    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
//    coord.latitude = self.model->current_pos.latitude;
//    coord.longitude = self.model->current_pos.longitude;
//    annotation.coordinate = coord;
//    annotation.title      = [NSString stringWithCString:self.model->current_pos.name.c_str() encoding:[NSString defaultCStringEncoding]];
//    
//    [self.mapView addAnnotation:annotation];
//    
//    [self.mapView selectAnnotation:annotation animated:YES];
    
    for (int i = 0; i < self.model->data_array.size(); ++i){
        
        // [todo] need to reuse annotation
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        coord.latitude = self.model->data_array[i].latitude;
        coord.longitude = self.model->data_array[i].longitude;
        annotation.coordinate = coord;
        annotation.title      = [NSString stringWithCString:self.model->data_array[i].name.c_str() encoding:[NSString defaultCStringEncoding]];
        //        annotation.subtitle   = @"Paris Test";
        
        [self.mapView addAnnotation:annotation];
//        [self.mapView deselectAnnotation:annotation animated:NO];
//        [[self.mapView viewForAnnotation:annotation] setHidden:YES];
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
    
    for (MKPointAnnotation *item in nearbySet){
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

@end
