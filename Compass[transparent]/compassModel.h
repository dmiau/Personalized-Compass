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

#ifndef __IPHONE__
#import <Cocoa/Cocoa.h>
#else
#import <UIKit/UIKit.h>
#endif

using namespace std;

class data {
public:
    // Properties
    std::string name;
    double distance;
    float orientation;
    float latitude;
    float longitude;
public:    
    // Methods
    double computeDistanceFromLocation(data& another_data);
    double computeOrientationFromLocation(data& another_data);
};

enum filter_enum{
    DEFAULT_FILTER = 0,
    NONE = 1,
    K_NEARESTLOCATIONS = 2,
    K_ORIENTATIONS = 3,
    FORCE_EQUILIBRIUM = 4
};

//--------------
// compassModel class
//--------------

class compassMdl{
public:
    static compassMdl* instance;
    float tilt;
    
    CGPoint compassCenterXY;
    
    NSMutableDictionary *configurations;
        
    std::string configuration_filename;
    std::string location_filename;
    
    // data_array stores the data of each location
    vector<data> data_array;
    vector<int> indices_sorted_by_distance;  // indices ordered by distance
    vector<int> indices_for_rendering;
    vector<int *> color_map;
    data current_pos;
    float latitudedelta;
    float longitudedelta;
    
    vector<double> distance_list;
    //http://stackoverflow.com/questions/936687/how-do-i-declare-a-2d-array-in-c-using-new
    //Check this too
    //http://www.cplusplus.com/forum/beginner/51598/
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
    
private:
    compassMdl(){}; // Private so that it can not be called
};

//--------------
// tools
//--------------
int readConfigurations(compassMdl* mdl_instance);

#endif /* defined(__Exploration__model__) */
