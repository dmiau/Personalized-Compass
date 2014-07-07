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
<CLLocationManagerDelegate, UISearchDisplayDelegate, UISearchBarDelegate,
MKMapViewDelegate>
{
    NSTimer *_updateUITimer;
    CLLocationManager *locationManager;
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
}

@property (weak) IBOutlet MKMapView *mapView;
@property UIView *debugView;
@property UITextView *debugTextView;

@property (weak, nonatomic) IBOutlet MKMapView *overviewMapView;

@property (weak, nonatomic) IBOutlet GLKView *glkView;
@property (weak, nonatomic) IBOutlet UISearchBar *ibSearchBar;
@property (weak, nonatomic) IBOutlet UIView *menuView;

@property UIView *viewPanel;
@property UIView *modelPanel;

@property compassMdl* model;
@property compassRender* renderer;

@property NSNumber *mapUpdateFlag;
@property bool conventionalCompassVisible;
@property bool move2UpdatedLocation;

// This is used for communication via segue
@property bool needUpdateDisplayRegion;
@property bool needUpdateAnnotations;
- (IBAction)getCurrentLocation:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *findMeButton;


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
// Toolbar and menu related functions
//----------------
- (IBAction)toggleExplrMode:(id)sender;

- (void) removeCompass;

- (IBAction)toggleDebugView:(id)sender;

- (IBAction)toggleViewPanel:(id)sender;
- (IBAction)toggleModelPanel:(id)sender;

- (IBAction)refreshApp:(id)sender;
- (IBAction)openIPADSettings:(id)sender;


- (void) setFactoryCompassHidden: (BOOL) flag;

//----------------
// Update and initialization functions
//----------------
- (void)initMapView;
- (void) updateMapDisplayRegion;
//- (void) updateMapDisplayRegion(CLLocationCoordinate2D coord);
-(void)rotate:(UIRotationGestureRecognizer *)gesture;
-(void)updateOverviewMap;
-(bool)updateModelCompassCenterXY;

//----------------
// Annotations related methods
//----------------
- (void) renderAnnotations;
@end
