//
//  DesktopViewController.h
//  Compass[transparent]
//
//  Created by dmiau on 3/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MapKit/MapKit.h>
#import "compassModel.h"
#import "compassRender.h"
#import <iostream>
//#import "SettingsViewController.h"
#import "AppDelegate.h"

#import "DemoManager.h"
#import "TestManager.h"

#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

// CLLocationDegress is typedef to double
typedef struct{
    double content[4][2];
}LatLons4x2;

@class ConfigurationsWindowController; //Forward declaration
//@class SettingsViewController; //Forward declaration
@class MyWebSocket;

//---------------------------------------
// DesktopViewController
//---------------------------------------
@interface DesktopViewController : NSViewController
<NSTableViewDataSource, NSTableViewDelegate, MKMapViewDelegate>{
    NSTimer *_updateUITimer;
    BOOL pinVisible;
    NSMutableArray *tableCellCache;
    
    //------------------
    // Search related stuff
    //------------------
	BOOL					completePosting;
    BOOL					commandHandling;
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
    HTTPServer *httpServer;
    
    //------------------
    // Interaction related stuff
    //------------------
    NSTimer *mouseTimer; // To indicate whether the mouse is held or not
}

@property (weak) IBOutlet MKMapView *mapView;
@property (weak) IBOutlet NSOpenGLView *compassView;
//@property (weak) IBOutlet NSScrollView *landmarkTable;

@property (weak) IBOutlet NSTextField *currentCoord;
@property (weak) IBOutlet NSComboBox *kmlComboBox;
@property (weak) IBOutlet NSTableView *locationTableView;
@property (weak) IBOutlet NSSearchField *toolbarSearchField;

@property compassMdl* model;
@property compassRender* renderer;
@property DemoManager* demoManager;
@property TestManager* testManager;
@property NSNumber *mapUpdateFlag;

@property NSMutableDictionary* UIConfigurations;
@property HTTPServer *httpServer; // expose the iv

// For the configuration panel
@property ConfigurationsWindowController *configurationWindowController;

//----------------
// Update and initialization functions
//----------------
- (void)initMapView;
- (void)updateMapDisplayRegion: (bool) animated;
-(bool)updateModelCompassCenterXY;
- (void)updateMainGUI;
-(void) updateLocationVisibility;

//----------------
// Compass related stuff
//----------------
- (void) changeCompassLocationTo: (NSString*) label;
- (void) setFactoryCompassHidden: (BOOL) flag;

//-------------------
// Settings View
//-------------------
//@property SettingsViewController *settingsViewController;
//@property NSView *settingsView;

//-------------------
// Interactions
//-------------------
- (IBAction)toggleMap:(id)sender;
- (IBAction)toggleCompass:(id)sender;
- (IBAction)rotate:(id)sender;
- (IBAction)refreshConfigurations:(id)sender;
//- (IBAction)showSettings:(id)sender;

// KML combo box
- (IBAction)didChangeKMLCombo:(id)sender;

// Configuraiton dialog
- (IBAction)showConfigurationsWindow:(id)sender;

#pragma mark UI related stuff
- (void) vcTimerFired;

- (void) feedModelLatitude: (float) lat_float
                 longitude: (float) lon_float
                   heading: (float) heading_deg
                      tilt: (float) tilt_deg;

//-------------------
// Convert the coordinates in 
//-------------------
- (CLLocationCoordinate2D) calculateLatLonFromiOSX: (int) x Y: (int) y;

//----------------
//Snapshot category
//----------------
- (bool)takeSnapshot;
- (bool)displaySnapshot: (int) id withVizSettings: (bool) setup_viz_flag
withPins: (bool) pin_flag;

//----------------
//Annotation category
//----------------
-(void) renderAnnotations;

// Change how annotations should be displayed
- (void)changeAnnotationDisplayMode: (NSString*) mode;

//----------------
//Tools
//----------------
- (CGPoint) convertOpenGLCoordToNSView: (CGPoint) coordInOpenGL;
- (CGPoint) convertNSViewCoordToOpenGL: (CGPoint) coordInNSView;
//----------------
//Server + iOSEmulation
//----------------
@property MyWebSocket* webSocket;
@property BOOL iOSSyncFlag;

-(void)startServer;
-(void)syncWithiOS: (NSDictionary*) dict;
@end
