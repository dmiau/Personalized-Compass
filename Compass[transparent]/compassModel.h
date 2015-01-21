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

class texture_info{
public:
    CGSize size;
    NSAttributedString *attr_str; // for debug purposes
    bool box_flag;
public:
    texture_info(){
        box_flag = true;
    };
};

//--------------
// label info
//--------------
class label_info{
public:
    double distance;
    float orientation;
    CGPoint centroid;
    // Wedge related info
    double aperture;
    double leg;
public:
    label_info(){
        centroid = CGPointMake(0, 0);
        distance = 0;
        orientation = 0;
        aperture = 0.0;
        leg = 0.0;
    }
};

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
    
    //-------------
    // label related stuff
    //-------------
    texture_info my_texture_info;
    label_info my_label_info;
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
    
    // Visualization Status
    bool wedgeStatus;
    bool overviewMapStatus;
    bool pcompassStatus;
    
    NSString* name;
    MKMapType mapType;
    NSDate* time_stamp;
    NSString* date_str;
    NSString* notes;
    NSString* address;
    // This stores the ids of the selected landmarks
    // i.e., indices for rendering
    vector<int> selected_ids;
public:
    snapshot(){
        kmlFilename = @"";
        address     = @"";
        notes       = @"";
        date_str    = @"";
        selected_ids.clear();
    }
};

class breadcrumb{
public:
    CLLocationCoordinate2D coord2D;
    NSString* name;
    NSString* date_str;
public:
    breadcrumb(){
        date_str    = @"";
        name        = @"";
    }
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

//----------------------------
// compassModel class
//----------------------------

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
    NSMutableDictionary *cache_configurations;
        
    NSString* configuration_filename;
    NSString* location_filename;
    NSString* snapshot_filename;
    NSString* history_filename;
    NSString* history_notes;
    
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
    vector<double> mode_max_dist_array;
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

    
    //--------------
    // Filter and analysis tools
    //--------------
    
    filter_enum hashFilterStr (NSString *inString);
    
    vector<int>
    applyFilter(filter_enum filter_type, int filter_param);
    
    vector<int> prefilterDataByDistance(vector<int> id_list);
    
    vector<int> filter_none();
    vector<int> filter_kNearestLocations(int k);
    vector<int> filter_kOrientations(int k);
    vector<int> filter_forceEquilibrium(int k);
    vector<int> filter_manual(int k);
    vector<int> sortIDByDistance(vector<int> id_list);
    int findMaxDistIdx(vector<int> id_list);
    
    vector<double> clusterData(vector<int> indices_for_rendering);
    vector<pair<double, int>> generateOrientDiffList
    (vector<int> id_list);
    
    //---------------
    // Label related stuff
    //---------------
    texture_info generateTextureInfo(NSString *label);
    void initTextureArray();
    
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
NSString* genHistoryString(compassMdl* mdl_instance);
double computeOrientationFromA2B
(CLLocationCoordinate2D A, CLLocationCoordinate2D B);
#endif /* defined(__Exploration__model__) */
