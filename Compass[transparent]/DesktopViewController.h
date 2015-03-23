//
//  DesktopViewController.h
//  Compass[transparent]
//
//  Created by dmiau on 3/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "compassModel.h"
#import "compassRender.h"
#import <iostream>
#import "AppDelegate.h"

#import "DemoManager.h"
#import "TestManager.h"

#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

enum KMLTYPE{
    LOCATION,
    SNAPSHOT,
    HISTORY
};

// CLLocationDegress is typedef to double
typedef struct{
    double content[4][2];
}LatLons4x2;

@class ConfigurationsWindowController; //Forward declaration
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
- (void)updateMapDisplayRegion: (MKCoordinateRegion) coord_region
                 withAnimation: (bool) animated;
- (void)moveCompassCentroidToOpenGLPoint: (CGPoint) OpenGLPoint;
- (void)updateMainGUI;
-(void) updateLocationVisibility;
- (void) windowDidResize:(NSNotification *) notification;
- (void)moveCompassRefToMapViewPoint:(CGPoint) MapViewPoint;
//----------------
// Compass related stuff
//----------------
- (void) changeCompassLocationTo: (NSString*) label;
- (void) setFactoryCompassHidden: (BOOL) flag;
- (void)lockCompassRefToScreenCenter: (bool)state;

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
- (vector<CLLocationCoordinate2D>) getBoundaryLatLon;

//----------------
//MapView category
//----------------
@property bool isBlankMapEnabled;
- (void)toggleBlankMapMode:(bool)state;
-(void)enableMapInteraction:(bool)state;
- (MKCoordinateSpan) scaleCoordinateSpanForDeviceInSnapshot: (snapshot)mySnapshot;
- (MKCoordinateSpan) calculateCoordinateSpanForDevice: (DeviceType)deviceType;
- (CGPoint) calculateOpenGLPointFromMapCoord: (CLLocationCoordinate2D) coord;
- (MKCoordinateRegion) calculateOSXCoordinateSpanForTriangulateTask: (snapshot)mySnapshot;
//----------------
//Snapshot category
//----------------
- (bool)takeSnapshot;
- (bool)displaySnapshot: (int) tid
    withStudySettings: (TestManagerMode) mode;

//----------------
//Annotation category
//----------------
-(void) resetAnnotations;
- (void) renderAllDataAnnotations;

// Change how annotations should be displayed
- (void)changeAnnotationDisplayMode: (NSString*) mode;

//----------------
//Tools
//----------------
- (CGPoint) convertOpenGLCoordToNSView: (CGPoint) coordInOpenGL;
- (CGPoint) convertNSViewCoordToOpenGL: (CGPoint) coordInNSView;
// shiftTestingEnvironmentBy shift the entire environment, including the map,
// the emulated iOS and the compass, by the vector specified in shift (in pixels)
- (void) shiftTestingEnvironmentBy: (CGPoint) shift;

//----------------
//Server + iOSEmulation
//----------------
@property MyWebSocket* webSocket;
@property NSNumber* socket_status;
@property BOOL iOSSyncFlag;

-(void)startServer;
-(void)syncWithiOS: (NSDictionary*) dict;

// implemented in the communication category
@property NSString* received_message;
- (void)sendMessage: (NSString*) message;
- (void)sendMessageAndCheckReceipt: (NSString*) message;
-(void)sendPackage: (NSDictionary *) package;
-(void)handlePackage: (NSData *) data;
-(void)handleMessage: (NSString *) message;
@property NSTimer *commuicationTimer; // To indicate whether the mouse is held or not

//----------------
//Files
//----------------
- (void) saveKMLwithType: (KMLTYPE) type;

//----------------
//Study
//----------------
@property NSString* testInformationMessage;
@property (weak) IBOutlet NSButton *showAnswerButton;
@property (weak) IBOutlet NSButton *nextTestButton;
@property (weak) IBOutlet NSButton *previousTestButton;

@property NSNumber* studyIntAnswer;
@property NSNumber* isDistanceEstControlAvailable;
//----------------
// System service (implemented in the interaction category)
//----------------
- (void) displayPopupMessage: (NSString*) message;

//----------------
// Information View
//----------------
- (void)setInformationViewVisibility: (BOOL)state;
@property NSNumber* isInformationViewVisible;
@property NSString* studyTitle;
@property (weak) IBOutlet NSView *informationView;
- (IBAction)clickInformationViewOK:(id)sender;
@property (weak) IBOutlet NSImageView *informationImageView;
@property (weak) IBOutlet NSTextField *informationTextField;
@property (weak) IBOutlet AVPlayerView *AVPlayerView;

- (void) displayTestInstructionsByCode: (NSString*) code;
- (void) displayInformationText;
@end
