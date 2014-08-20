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
}

@property (weak) IBOutlet MKMapView *mapView;
@property (weak) IBOutlet NSOpenGLView *compassView;
@property (weak) IBOutlet NSTextField *currentCoord;
@property (weak) IBOutlet NSComboBox *kmlComboBox;
@property (weak) IBOutlet NSTableView *locationTableView;
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSSearchField *toolbarSearchField;

@property compassMdl* model;
@property compassRender* renderer;

@property NSNumber *mapUpdateFlag;

@property NSMutableDictionary* UIConfigurations;

- (IBAction)toggleMap:(id)sender;
- (IBAction)toggleCompass:(id)sender;

- (IBAction)rotate:(id)sender;
- (void) updateMapDisplayRegion;
-(bool)updateModelCompassCenterXY;
- (IBAction)refreshConfigurations:(id)sender;

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
@end
