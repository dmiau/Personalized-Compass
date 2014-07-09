//
//  iOSViewController+GetLocation.m
//  Compass[transparent]
//
//  Created by dmiau on 6/13/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+GetLocation.h"
#import <QuartzCore/QuartzCore.h>

@implementation iOSViewController (GetLocation)
- (IBAction)getCurrentLocation:(id)sender {
    
    //---------------
    // Check the state of the button
    //---------------
    if (self.findMeButton.isSelected){
        [self disableLocationUpdate];
    }else{
        self.findMeButton.selected = YES;
        self.findMeButton.backgroundColor = [UIColor orangeColor];
        self.findMeButton.layer.cornerRadius = 5;
        self.findMeButton.clipsToBounds = YES;
        
        self.mapView.showsUserLocation = YES;
        // enable location manager
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.move2UpdatedLocation = true;
        [locationManager startUpdatingLocation];
        [locationManager startUpdatingHeading];
        
        //    // Diable location service after some time
        //    NSTimer *timer1 = [NSTimer scheduledTimerWithTimeInterval: 3
        //        target:self
        //        selector:@selector(handleTimer:)
        //        userInfo:nil
        //        repeats:NO];
        [self performSelector:@selector(handleTimer:)
                   withObject:self afterDelay:30];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    self.findMeButton.backgroundColor = [UIColor clearColor];
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
        [self updateMapDisplayRegion];
        self.move2UpdatedLocation = false;
    }
    
    // Update user position
    self.model->user_pos.latitude = myLocation.coordinate.latitude;
    self.model->user_pos.longitude = myLocation.coordinate.longitude;
    self.model->user_pos.annotation.coordinate = myLocation.coordinate;

    [self.mapView addAnnotation:self.model->user_pos.annotation];    
}

//-------------------
// Heading is updated
//-------------------
- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    self.model->user_pos.orientation = [newHeading trueHeading]; // heading is in degree

}


-(void)handleTimer: (NSTimer *) timer
{
    [self disableLocationUpdate];
}

//-------------------
// Disable location service
//-------------------
- (void)disableLocationUpdate{
    self.mapView.showsUserLocation = NO;
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
    
    self.findMeButton.selected = NO;
    self.findMeButton.backgroundColor = [UIColor clearColor];
}

@end
