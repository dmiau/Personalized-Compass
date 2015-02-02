//
//  TestManager.h
//  Compass[transparent]
//
//  Created by Daniel on 1/20/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#ifndef __Compass_transparent___TestManager__
#define __Compass_transparent___TestManager__

#include <stdio.h>
#include <iostream>
#include <vector>
#include <map>
#include <random>
#import <MapKit/MapKit.h>
#import "compassModel.h" //To use the data object

#ifndef __IPHONE__
#import <Cocoa/Cocoa.h>
#else
#import <UIKit/UIKit.h>
#endif

using namespace std;
// Forward declaration
class compassRender;

#ifdef __IPHONE__
@class iOSViewController;
#else
@class DesktopViewController;
#endif

// Device type enum
typedef enum{
    PHONE,
    WATCH
}DeviceType;

// Visualization type enum
typedef enum{
    VIZNONE,
    VIZPCOMPASS,
    VIZWEDGE,
    VIZOVERVIEW
}VisualizationType;

//---------------
// Param object
//---------------
// This is necessary so we can conveniently count the number of enabled devices
// and visualizations, etc.
class param{
public:
    int type;
    bool  isEnabled;
    NSString *name;
public:
    param(){
        type = NULL;
        isEnabled = false;
        name = @"";
    };
};

//---------------
// Record object
//---------------
class record{
public:
    CLLocationCoordinate2D ground_truth;
    CLLocationCoordinate2D answer;
    double error;
    double duration;
public:
    record(){
        ground_truth    = CLLocationCoordinate2DMake(0, 0);
        answer          = CLLocationCoordinate2DMake(0, 0);
        error           = 0;
        duration        = 0;
    };
};

//---------------
// Pool object
//---------------

//Three methods to generate a pool
//FULL: fully counter-balanced
//FIXED: take the sequence as is
//LATIN: Latin square
enum POOLMODE {FULL, FIXED, LATIN};

class pool{
public:
    string name;
    int counter;
    
    // content:
    // {{{1, 2}, {2, 1}},
    // {{2, 1}, {1, 2}}}
    vector< vector<vector<string>> > content;
public:
    // pool takes a list of conditions (e.g., device types, viz types, etc.)
    // and generates a pool of string bundles, which can be used to generate
    // prefix.
    
    // The entire pool is stored in content, which is
    // vector < vector< vector<string> > >
    // An example of the visualization pool is like
    // { {{pcompass, wedge}, {wedge, pcompaass}},
    //   {{wedge, pcompass}, {pcompaass, wedge}}
    // }
    
    // leaf_n indicates the number of items of *the level above*
    // In the case of visualization, the level above is the device level.
    // Each participant has two device leaves (phone and watch),
    // thus leaf_n is 2 for the visualization condition
    
    // The idea is that at each iteration of device, the program can call the
    // the "next" method to get a visualization_list (which contains two
    // visualizations, pcompass and wedge)
    
    // leaf_n controls the number of items per pool unit
    pool(vector<string>, POOLMODE mode, int leaf_n);
    
    // Next should return the following in sequence
    // {1, 2}, {2, 1},   {2, 1}, {1, 2}
    // Note that next should be able to go through the boundary of cells.
    // so vector<string>
    vector<string> next();
};

//---------------
// Test Manager
//---------------
enum TaskType {LOCATE, TRIANGULATE, ORIENT};

class TestManager{
public:
    
    // Test parameters
    
    
    
    // Connections to other modules
    compassMdl *model;
#ifdef __IPHONE__
    iOSViewController *rootViewController;
#else
    DesktopViewController *rootViewController;
#endif
    // Test configurations
    // This parameters allow TestManager to decide the number of enabled devices
    bool phone_flag;
    bool watch_flag;
    
    vector<param> visualization_vector;
    vector<param> device_vector;
    
    vector<param> enabled_visualization_vector;
    vector<param> enabled_device_vector;
    
    // Number of users
    int participant_n;
    int participant_id;
    
    // A map holds all the IDs and (x, y) coordinates
    map<string, vector<int>> location_dict;
    // Stores all test vectors (each participant has a test vector)
    vector<vector<string>> all_test_vectors;
    
    //---------------
    // Parameters for close, far boundaries
    //---------------
    
    // watch_boundaries and phone_boundaries layout
    //              close       |   far
    // [0]desktop  [float, float]  | [float, float]
    // [1]mobile   [float, float]  | [float, float]
    vector<vector<pair<float, float>>> watch_boundaries;
    vector<vector<pair<float, float>>> phone_boundaries;
    
    float close_begin_x;
    float close_end_x;
    float far_begin_x;
    float far_end_x;
    int close_n;    // # of locations in the close category
    int far_n;      // # of locations in the far category
    
    //---------------
    // Parameters for the triangulate test generation
    //---------------
    int tri_test_n;
    
    //---------------
    // Parameters for the orient test generation
    //---------------
    int orient_test_n;
    
    //---------------
    // Counters
    //---------------
    int visualization_counter;
    int test_counter;

    //---------------
    // Random number generation
    //---------------
    int seed;
    std::mt19937  generator;
    
public:
    static TestManager* shareTestManager();
    int initTestManager();
    
    // Initialize watch_boundaries and phone_boundaries
    void initializeDeviceBoundaries();
    
    // Methods to generate tests
    int generateTests();
    
    //---------------
    // Location vector generation
    //---------------
    map<string, vector<int>> generateLocationVector();

    map<string, vector<int>> generateLocationsByTask
    (DeviceType deviceType, TaskType taskType);
    
    //--------------
    // Generate  close_bounary<  n random locations < far_boundary
    // The n random locations fall into n equally distant segments
    // btween close_boundary and far_boundary
    //--------------
    vector<vector<int>> generateRandomLocateLocations
    (double close_boundary, double far_boundary, int location_n);
    
    vector<vector<int>> generateRandomTriangulateLocations
    (double close_boundary, double far_boundary, int location_n);
    
    vector<vector<int>> generateRandomOrientLocations
    (double close_boundary, double far_boundary, int location_n);
    
    void generateKML();
    
    //---------------
    // Test vector generation
    //---------------
    
    void generateAllTestVectors(
        vector<string> device_list,
        vector<string> visualization_list,
        vector<string> task_list,
        vector<string> distance_list,
        vector<string> location_list
    );
    
    // I will need a snapshot generator too
    
    void saveLocationCSV();
    void saveAllTestVectorCSV();
};

//class test{
//public:
//
//    VisualizationType visualization;
//    DeviceType device;
//    int test_id;
//    int snapshot_id;
//    NSString *name;
//    NSString *instructions;
//    NSString *sectionMsg;
//    bool isEnabled;
//public:
//    test(){
//        visualization = VIZPCOMPASS;
//        device = PHONE;
//    };
//};

#endif /* defined(__Compass_transparent___TestManager__) */
