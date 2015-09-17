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
#import "DemoManager.h"
#import "TestManager.h"

// SocketRocket
#import "SRWebSocket.h"

enum findMe_enum{
    LOCATION_ON,
    LOCATION_OFF,
    MOVE2LOCATION
};

enum KMLTYPE{
    LOCATION,
    SNAPSHOT,
    HISTORY
};

// CLLocationDegress is typedef to double
typedef struct{
    double content[4][2];
}LatLons4x2;


@interface iOSViewController : UIViewController
<CLLocationManagerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, SRWebSocketDelegate>
{
    NSTimer *_updateUITimer;
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
    CALayer *mapMask;
    NSArray *view_array;
    vector<CGSize> view_size_vector;
    
    
    
    // Coummunication
    SRWebSocket *_webSocket;
    NSMutableArray *_messages;
}

@property NSMutableDictionary* UIConfigurations;


//----------------
// Message label
//----------------
@property UILabel *messageLabel;
@property UILabel *devMessageLabel;

//----------------
// Cache MapView parameters
//----------------
@property LatLons4x2 latLons4x2;
- (void) updateCornerLatLon;

//----------------
// Scalar view
//----------------
@property (retain) UIView *scaleView;
@property (retain) UIView *watchScaleView;

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
@property UIView *watchSidebar;

// Toggle various components
- (void)toggleOverviewMap: (bool) state;
- (void)togglePCompass: (bool) state;
- (void)toggleConventionalCompass: (bool)state;
- (void)toggleWedge: (bool)state;


// View panel
@property (weak, nonatomic) IBOutlet UISegmentedControl *overviewSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *wedgeSegmentControl;
@property (weak, nonatomic) IBOutlet UILabel *scaleIndicator;
@property (weak, nonatomic) IBOutlet UISlider *scaleSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *overviewScaleSegmentControl;


// Model panel
@property (weak, nonatomic) IBOutlet UISwitch *homeBoxSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *landmarkLock;
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dataSegmentControl;
- (IBAction)toggleHomeBox:(id)sender;


// Compass panel
@property (weak, nonatomic) IBOutlet UISegmentedControl *compassSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *compassModeSegmentControl;
@property (weak, nonatomic) IBOutlet UISwitch *compassInteractionSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *compassCenterLockSwitch;


- (void) setupPhoneViewMode;
- (void) setupWatchViewMode;
- (void)pressOKToSwitchToWatchMode;
- (void)pressOKToSwitchToPhoneMode;

// Debug panel
-(void)updateDebugPanel;
@property (weak, nonatomic) IBOutlet UITextView *snapshotStatusTextView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *showPinSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *createPinSegmentControl;


// watch sidebar
@property (weak, nonatomic) IBOutlet UISwitch *watchLandmrkLockSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *watchCompassInteractionSwitch;


//----------------
// UI Components
//----------------
@property (weak, nonatomic) IBOutlet UISearchBar *ibSearchBar;
@property (weak, nonatomic) IBOutlet UIButton *findMeButton;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;


@property compassMdl* model;
@property compassRender* renderer;
@property DemoManager* demoManager;
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
- (bool)displaySnapshot: (int) snapshot_id
      withStudySettings: (TestManagerMode) mode;
- (void)toggleScaleView: (bool) state;

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
- (void) setFactoryCompassHidden: (BOOL) flag;
- (void)lockCompassRefToScreenCenter: (bool)state;
- (void) toggleAnswersVisibility: (bool) state;
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

- (void) hideAllPanels;
- (void) constructDebugToolbar:(NSString*) mode;
- (void) constructDemoToolbar:(NSString*)mode;
- (void) constructStudyToolbar:(NSString*)mode;

// The counter of the study toolbar. This is exposed so TestManager can update it
@property UIBarButtonItem *counter_button;

//----------------
// Update and initialization functions
//----------------
- (void)initMapView;
- (void) updateMapDisplayRegion: (MKCoordinateRegion) coord_region
                  withAnimation:(bool) animated;
-(void)rotate:(UIRotationGestureRecognizer *)gesture;
-(void)updateOverviewMap;
- (void)moveCompassCentroidToOpenGLPoint: (CGPoint) OpenGLPoint;
- (void)moveCompassRefToMapViewPoint:(CGPoint) MapViewPoint;
-(void) updateLocationVisibility;
-(void) updateAnswerLines;
//----------------
//MapView category
//----------------
@property bool isBlankMapEnabled;
- (void)toggleBlankMapMode:(bool)state;
-(void)enableMapInteraction:(bool)state;


//----------------
// Annotations related methods
//----------------
- (void) resetAnnotations;
- (void) renderAllDataAnnotations;
-(void) updateDataAnnotations;
// Change how annotations should be displayed
- (void)changeAnnotationDisplayMode: (NSString*) mode;

//----------------
// Communication
//----------------
@property int port_number;
@property NSString* ip_string;
@property NSNumber *socket_status;
- (void) toggleServerConnection: (bool) status;


// implemented in the communication category
@property NSString* received_message;
-(void) sendBoundaryLatLon;
- (void)sendMessage: (NSString*) message;
-(void)sendPackage: (NSDictionary *) package;
-(void)handlePackage: (NSData *) data;
-(void)handleMessage:(NSString*)message;

//----------------
// System message
//----------------
@property NSString* system_message;
- (void) logSystemMessage: (NSString*) message;
- (void) saveSystemMessage;
//----------------
// File saving
//----------------
- (void) saveKMLwithType: (KMLTYPE) type;

//----------------
// System service (implemented in the interaction category)
//----------------
- (void) displayPopupMessage: (NSString*) message;

@end
