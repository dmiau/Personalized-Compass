//
//  compassModel.h
//  Exploration
//
//  Created by Daniel Miau on 2/8/14.
//  Copyright (c) 2014 Daniel Miau. All rights reserved.
//

#ifndef __Exploration__model__
#define __Exploration__model__

#include <iostream>
#include <vector>
#import <MapKit/MapKit.h>
#import "CustomPointAnnotation.h"

#ifndef __IPHONE__
#import <Cocoa/Cocoa.h>
#else
#import <UIKit/UIKit.h>
#import "filesystem.h"
#endif

using namespace std;

//--------------
// landmark object
//--------------
class data {
public:
    // Properties
    std::string name;
    double distance;
    float orientation;
    float latitude;
    float longitude;
    CustomPointAnnotation* annotation;
    bool isEnabled; // indicates wheather the landmark is enabled or not
    bool isVisible; // indicates the locaiton is within the current
                    // visible region or not.
public:    
    // Methods
    double computeDistanceFromLocation(data& another_data);
    double computeOrientationFromLocation(data& another_data);
    // Constructor
    data(){
        name = "";
        latitude = 0;
        longitude = 0;
        distance = 0;
        orientation = 0;
        isEnabled = YES;
        isVisible = NO;
        annotation = [[CustomPointAnnotation alloc] init];
    };
};

//--------------
// snapshot and breadcrumb
//--------------
class snapshot{
public:
    MKCoordinateRegion coordinateRegion;
    double orientation;
    NSString* kmlFilename;
    bool wedgeStatus;
    bool overviewMapStatus;
    NSString* name;
    MKMapType mapType;
    int time;
    NSDate* time_stamp;
};

class breadcrumb{
public:
    CLLocationCoordinate2D coord2D;
    int id;
    NSDate* time_stamp;
};

//--------------
// filter types
//--------------
enum filter_enum{
    DEFAULT_FILTER = 0,
    NONE = 1,
    K_NEARESTLOCATIONS = 2,
    K_ORIENTATIONS = 3,
    FORCE_EQUILIBRIUM = 4,
    MANUAL = 5
};

//--------------
// compassModel class
//--------------

class compassMdl{
public:
    static compassMdl* instance;
    
    // File system
#ifdef __IPHONE__
    FILESYS_TYPE filesys_type;
    filesystem* docFilesystem;
    filesystem* dbFilesystem;
#endif
    
    //-----------------
    // Configurations
    //-----------------
    NSNumber *configurationFileReadFlag;
    NSMutableDictionary *configurations;
        
    NSString* configuration_filename;
    NSString* location_filename;
    // Do not update indices_for_rendering when this is on.
    bool lockLandmarks;
    
    //-----------------
    // For Renderer
    //-----------------
    // indicates the centroid of compass in the map window coordinate frame
    // (in terms of u, v, not in terms of latitude and longitude)
    CGPoint compassCenterXY;
    // list of distances computed from the current location
    vector<double> distance_list;
    // indices of locations, ordered by distance
    vector<int> indices_sorted_by_distance;
    // indices of the filtered locations, for rendering
    vector<int> indices_for_rendering;
    vector<int *> color_map;
    
    //-----------------
    // User and Camera Locations
    //-----------------
    float tilt;
    data camera_pos; // Specify the camera position
    data user_pos; // Specify the user position
    // Need this field because the orientation in user_pos
    // indicating the orientation from the current camera_pos
    double user_heading_deg;
    //
    float latitudedelta;
    float longitudedelta;
    
    //http://stackoverflow.com/questions/936687/how-do-i-declare-a-2d-array-in-c-using-new
    //Check this too
    //http://www.cplusplus.com/forum/beginner/51598/
    
    //-----------------
    // Data Arrays
    //-----------------
    // data_array stores the data of each location
    vector<data> data_array;
    bool data_array_dirty;
    vector<snapshot> snapshot_array;
    bool snapshot_array_dirty;
    vector<breadcrumb> breadcrumb_array;
    bool breadcrumb_array_dirty;
    
public:
    static compassMdl* shareCompassMdl();
    int initMdl();
    int reloadFiles();
    int updateMdl();
    void watchConfigurationFile();
    int cleanMdl();

    filter_enum hashFilterStr (NSString *inString);
    
    vector<int>
    applyFilter(filter_enum filter_type, int filter_param);
    
    vector<int> filter_none();
    vector<int> filter_kNearestLocations(int k);
    vector<int> filter_kOrientations(int k);
    vector<int> filter_forceEquilibrium(int k);
    vector<int> filter_manual(int k);
    vector<int> sortIDByDistance(vector<int> id_list);
    
private:
    compassMdl(){}; // Private so that it can not be called
};

//--------------
// tools
//--------------
int readConfigurations(compassMdl* mdl_instance);
double DegreesToRadians(double degrees);
double RadiansToDegrees(double radians);
NSString* genKMLString(vector<data> my_data_array);
NSString* genSnapshotString(vector<snapshot> my_snapshot_array);
#endif /* defined(__Exploration__model__) */
