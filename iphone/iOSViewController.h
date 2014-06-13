//
//  iOSViewController.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/3/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <GLKit/GLKit.h>
#include "compassModel.h"
#include "compassRender.h"
#include <iostream>
#import "iOSGLKView.h"

@interface iOSViewController : UIViewController
<CLLocationManagerDelegate>{
    NSTimer *_updateUITimer;
    CLLocationManager *locationManager;
}

@property (weak) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet GLKView *glkView;


@property compassMdl* model;
@property compassRender* renderer;

@property NSNumber *mapUpdateFlag;
- (IBAction)getCurrentLocation:(id)sender;


//----------------
// Functions attached to the timer
//----------------
- (void) vcTimerFired;
- (void) feedModelLatitude: (float) lat_float
                 longitude: (float) lon_float
                   heading: (float) heading_deg
                      tilt: (float) tilt_deg;
- (float) calculateCameraHeading;

//----------------
// Update functions
//----------------
- (void) updateMapDisplayRegion;
//- (void) updateMapDisplayRegion(CLLocationCoordinate2D coord);
-(void)rotate:(UIRotationGestureRecognizer *)gesture;
@end
