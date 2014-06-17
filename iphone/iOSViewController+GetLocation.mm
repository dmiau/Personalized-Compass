//
//  iOSViewController+GetLocation.m
//  Compass[transparent]
//
//  Created by dmiau on 6/13/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+GetLocation.h"

@implementation iOSViewController (GetLocation)
- (IBAction)getCurrentLocation:(id)sender {
    
    self.mapView.showsUserLocation = YES;
    // enable location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    
//    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
//    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    [self feedModelLatitude: newLocation.coordinate.latitude
                  longitude: newLocation.coordinate.longitude
                    heading: 0
                       tilt: 0];
    [self updateMapDisplayRegion];
    
    // Diable location service after 10 seconds
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 20
                                                      target:self
                                                    selector:@selector(handleTimer:)
                                                    userInfo:nil
                                                     repeats:NO];
}

-(void)handleTimer: (NSTimer *) timer
{
     self.mapView.showsUserLocation = NO;
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    
}

@end
