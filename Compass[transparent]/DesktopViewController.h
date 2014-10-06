//
//  DesktopViewController.h
//  Compass[transparent]
//
//  Created by dmiau on 3/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MapKit/MapKit.h>
#include "compassModel.h"
#include "compassRender.h"
#include <iostream>
//#import "SettingsViewController.h"
#import "TestManager.h"

#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

@class SettingsViewController; //Forward declaration

@interface DesktopViewController : NSViewController
<NSTableViewDataSource, NSTableViewDelegate, MKMapViewDelegate>{
    NSTimer *_updateUITimer;
    BOOL pinVisible;
    NSMutableArray *tableCellCache;
    NSArray *kml_files;
    
    //------------------
    // Search related stuff
    //------------------
	BOOL					completePosting;
    BOOL					commandHandling;
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
    HTTPServer *httpServer;
}

@property (weak) IBOutlet MKMapView *mapView;
@property (weak) IBOutlet NSOpenGLView *compassView;
@property (weak) IBOutlet NSScrollView *landmarkTable;

@property (weak) IBOutlet NSTextField *currentCoord;
@property (weak) IBOutlet NSComboBox *kmlComboBox;
@property (weak) IBOutlet NSTableView *locationTableView;
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSSearchField *toolbarSearchField;

@property compassMdl* model;
@property compassRender* renderer;
@property TestManager* testManager;
@property NSNumber *mapUpdateFlag;
@property bool conventionalCompassVisible;

@property NSMutableDictionary* UIConfigurations;
@property HTTPServer *httpServer; // expose the iv

//----------------
// Update and initialization functions
//----------------
- (void)initMapView;
- (void)updateMapDisplayRegion;
-(bool)updateModelCompassCenterXY;

//----------------
// Compass related stuff
//----------------
- (void) changeCompassLocationTo: (NSString*) label;
- (void) setFactoryCompassHidden: (BOOL) flag;

//-------------------
// Settings View
//-------------------
@property SettingsViewController *settingsViewController;
@property NSView *settingsView;

//-------------------
// Interactions
//-------------------
- (IBAction)toggleMap:(id)sender;
- (IBAction)toggleCompass:(id)sender;
- (IBAction)rotate:(id)sender;
- (IBAction)refreshConfigurations:(id)sender;
- (IBAction)showSettings:(id)sender;
- (IBAction)toggleLandmarkTable:(id)sender;



// KML combo box
- (IBAction)didChangeKMLCombo:(id)sender;

#pragma mark UI related stuff
- (void) vcTimerFired;

- (void) feedModelLatitude: (float) lat_float
                 longitude: (float) lon_float
                   heading: (float) heading_deg
                      tilt: (float) tilt_deg;


//----------------
//Annotation category
//----------------
-(void) renderAnnotations;


//----------------
//Server
//----------------
-(void)startServer;

@end
