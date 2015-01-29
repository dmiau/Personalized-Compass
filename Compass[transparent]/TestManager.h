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
class pool{
public:
    string name;
    int counter;
    
    // content:
    // {{{1, 2}, {2, 1}},
    // {{2, 1}, {1, 2}}}
    vector< vector<vector<string>> > content;
public:
    // constructor
    pool(vector<string>, int leaf_n);
    
    // Next should return the following in sequence
    // {1, 2}, {2, 1},   {2, 1}, {1, 2}
    // Note that next should be able to go through the boundary of cells.
    // so vector<string>
    vector<string> next();
};

//---------------
// Test Manager
//---------------


class TestManager{
public:
    // Connections to other modules
    compassMdl *model;
    
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
    
    //---------------
    // Parameters for the locate test generation
    //---------------
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
    
    // Methods to generate tests
    int generateTests();
    
    
    map<string, vector<int>> generateLocationVector();
    
    map<string, vector<int>> generateLocateTests(DeviceType deviceType);
    
    //--------------
    // Generate  close_bounary<  n random locations < far_boundary
    // The n random locations fall into n equally distant segments
    // btween close_boundary and far_boundary
    //--------------
    vector<vector<int>> generateRandomLocations
    (double close_boundary, double far_boundary, int location_n);
    
    map<string, vector<int>> generateTriangulateTests(DeviceType deviceType);
    map<string, vector<int>> generateOrientTests(DeviceType deviceType);

    vector<string> generateTestVector(
        vector<string> device_list,
        vector<string> visualization_list,
        vector<string> task_list,
        vector<string> distance_list,
        vector<int> location_list
    );
    
    // I will need a snapshot generator too
    
    void saveLocationCSV();
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
