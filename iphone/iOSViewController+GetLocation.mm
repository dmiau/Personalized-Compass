//
//  iOSViewController+GetLocation.m
//  Compass[transparent]
//
//  Created by dmiau on 6/13/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+GetLocation.h"
#import <QuartzCore/QuartzCore.h>
#import "commonInclude.h"

@implementation iOSViewController (GetLocation)
- (void)toggleLocationService:(int) tapNumber {
    
    static enum findMe_enum button_status = LOCATION_OFF;
    
    findMe_enum mode;
    if (tapNumber == 1){
        if (button_status == LOCATION_OFF){
            mode = LOCATION_ON;
            button_status = LOCATION_ON;
        }else{
            mode = LOCATION_OFF;
            button_status = LOCATION_OFF;
        }
    }else{
        mode = MOVE2LOCATION;
    }
    
    //---------------
    // Check the state of the button
    //---------------
    if (mode == LOCATION_OFF){
        [self disableLocationUpdate];
        
    }else{
        self.findMeButton.backgroundColor = [UIColor orangeColor];
        self.findMeButton.selected = YES;
        self.findMeButton.layer.cornerRadius = 5;
        self.findMeButton.clipsToBounds = YES;
        
        // Use custom image istead
        self.mapView.showsUserLocation = NO;
        
        self.model->user_pos.isEnabled = true;
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];

        // This way the green arrow will be shown immediately
        if (mode == MOVE2LOCATION){
            self.move2UpdatedLocation  = true;
        }
    }
    [self.glkView setNeedsDisplay];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
//    self.findMeButton.backgroundColor = [UIColor clearColor];
}

//-------------------
// Locaiton is updated
//-------------------
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* myLocation = [locations lastObject];
    
    // When the findMe button is first pressed, we center the map
    // to the current user location, but we only do it once
    if (self.move2UpdatedLocation){
        [self feedModelLatitude: myLocation.coordinate.latitude
                      longitude: myLocation.coordinate.longitude
                        heading: 0
                           tilt: 0];
        [self updateMapDisplayRegion:YES];
        self.move2UpdatedLocation = false;
    }
    [self.mapView removeAnnotation:self.model->user_pos.annotation];
    // Update user position
    self.model->user_pos.latitude = myLocation.coordinate.latitude;
    self.model->user_pos.longitude = myLocation.coordinate.longitude;
    self.model->user_pos.annotation.coordinate = myLocation.coordinate;
    [self.mapView addAnnotation:self.model->user_pos.annotation];
    [self addBreadcrumb:myLocation.coordinate];
    [self updateFindMeView];
}

//-------------------
// Heading is updated
//-------------------
- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    self.model->user_heading_deg = [newHeading trueHeading]; // heading is in degree
    [self updateFindMeView];
}


-(void)handleTimer: (NSTimer *) timer
{
    [self disableLocationUpdate];
}

-(void)updateFindMeView{
    
    if (!self.model->user_pos.isEnabled)
        return;
    
    //----------------------
    // Update compass heading (image)
    //----------------------
    MKAnnotationView *aView = [self.mapView
                               viewForAnnotation:self.model->user_pos.annotation];
    
    if (aView != nil){
        UIImage *myImg = [UIImage imageNamed:@"heading.png"];
        //-------------
        // rotate the image according to the current heading
        //-------------
        aView.image = myImg;
        
        float radians = (self.model->user_heading_deg
                         + self.model->camera_pos.orientation)/180 * M_PI;
        
        //        NSLog(@"camera orientation: %f", self.model->camera_pos.orientation);
        //        NSLog(@"User orientation: %f", self.model->user_pos.orientation);
        
        CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, radians);
        aView.transform = transform;
    }
}

//-------------------
// Disable location service
//-------------------
- (void)disableLocationUpdate{
    self.mapView.showsUserLocation = NO;
    self.model->user_pos.isEnabled = false;
    // Stop Location Manager
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
    
    self.findMeButton.selected = NO;
    self.findMeButton.backgroundColor = [UIColor clearColor];
}

@end
