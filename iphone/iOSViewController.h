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
<CLLocationManagerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
{
    NSTimer *_updateUITimer;
    CLLocationManager *locationManager;
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
}

@property (weak) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet GLKView *glkView;
@property (weak, nonatomic) IBOutlet UISearchBar *ibSearchBar;
@property (weak, nonatomic) IBOutlet UIView *menuView;


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
// Toolbar Items
//----------------
- (IBAction)toggleCompass:(id)sender;
- (IBAction)toggleExplrMode:(id)sender;

- (void) removeCompass;
- (IBAction)toggleMenu:(id)sender;

//----------------
// Update functions
//----------------
- (void) updateMapDisplayRegion;
//- (void) updateMapDisplayRegion(CLLocationCoordinate2D coord);
-(void)rotate:(UIRotationGestureRecognizer *)gesture;
@end
