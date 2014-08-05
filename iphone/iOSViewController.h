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
#import "TestManager.h"


enum findMe_enum{
    LOCATION_ON,
    LOCATION_OFF,
    MOVE2LOCATION
};


@interface iOSViewController : UIViewController
<CLLocationManagerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate>
{
    NSTimer *_updateUITimer;
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
    CALayer *mapMask;
    NSArray *view_array;
    vector<CGSize> view_size_vector;
    
    // For toolbar
    UIBarButtonItem *counter_button;
}

@property NSMutableDictionary* UIConfigurations;

//----------------
// Views in ExtraPanels.xib
//----------------
@property (weak) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet MKMapView *overviewMapView;
@property (weak, nonatomic) IBOutlet GLKView *glkView;
@property UIView *viewPanel;
@property UIView *modelPanel;
@property UIView *watchPanel;
@property UIView *debugPanel;


// Toggle various components
- (void)toggleOverviewMap: (bool) state;
- (void)togglePCompass: (bool) state;
- (void)toggleConventionalCompass: (bool)state;
- (void)toggleWedge: (bool)state;


// View panel
@property (weak, nonatomic) IBOutlet UISegmentedControl *overviewSegmentControl;

// Model panel
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterSegmentControl;

// Compass panel
@property (weak, nonatomic) IBOutlet UISegmentedControl *compassSegmentControl;


// Debug panel


//----------------
// UI Components
//----------------
@property (weak, nonatomic) IBOutlet UISearchBar *ibSearchBar;
@property (weak, nonatomic) IBOutlet UIButton *findMeButton;
@property (weak, nonatomic) IBOutlet UILabel *scaleIndicator;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;


@property compassMdl* model;
@property compassRender* renderer;
@property TestManager* testManager;

@property NSNumber *mapUpdateFlag;
@property bool conventionalCompassVisible;

//----------------
// Segue communication related stuff
//----------------
// This is used for communication via segue
@property bool needUpdateDisplayRegion;
@property bool needUpdateAnnotations;
@property int snapshot_id_toshow;
@property int breadcrumb_id_toshow;
@property int landmark_id_toshow;

//----------------
// Snapshot related stuff
//----------------
- (bool)takeSnapshot;
- (bool)displaySnapshot: (int) id;
- (bool)saveSnapshotArray;
- (bool)loadSanpshotArray;

//----------------
// History related stuff
//----------------
- (bool) addBreadcrumb: (CLLocationCoordinate2D) coord2D;
- (bool) displayBreadcrumb;
- (bool) saveBreadcrumbArray;
- (bool) loadBreadkcrumbArray;
@property bool sprinkleBreadCrumbMode;

//----------------
// Location service related stuff
//----------------
@property bool move2UpdatedLocation;
@property bool needToggleLocationService;
//- (void) doSingleTapFindMe:(UITapGestureRecognizer *)gestureRecognizer;
//- (void) doDoubleTapFindMe:(UITapGestureRecognizer *)gestureRecognizer;
- (void)toggleLocationService:(int)tapNumber;

// this flag indicates whether the FindMe mode is turned on or not
@property CLLocationManager *locationManager;
-(void)updateFindMeView;

//----------------
// Compass related stuff
//----------------
- (void) changeCompassLocationTo: (NSString*) label;


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
- (IBAction)toggleWatchPanel:(id)sender;
- (IBAction)toggleDebugView:(id)sender;
- (IBAction)toggleViewPanel:(id)sender;
- (IBAction)toggleModelPanel:(id)sender;
- (IBAction)refreshApp:(id)sender;

- (void) setFactoryCompassHidden: (BOOL) flag;
- (void) removeCompass;
- (void) constructDebugToolbar:(NSString*) mode;
- (void) constructDemoToolbar:(NSString*)mode;

//----------------
// Update and initialization functions
//----------------
- (void)initMapView;
- (void) updateMapDisplayRegion;
//- (void) updateMapDisplayRegion(CLLocationCoordinate2D coord);
-(void)rotate:(UIRotationGestureRecognizer *)gesture;
-(void)updateOverviewMap;
-(bool)updateModelCompassCenterXY;
-(void) updateLocationVisibility;

//----------------
// Annotations related methods
//----------------
- (void) renderAnnotations;
@end
