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
@class DesktopViewController;
#else
#import <UIKit/UIKit.h>
@class iOSViewController;
#endif

using namespace std;

//------------------------------
// Test Specifications
//------------------------------
enum TaskType {LOCATE, TRIANGULATE, ORIENT, LOCATEPLUS};

//class BoundarySpec{
//public:
//    double close;
//    double far;
//    int count;
//};

class TaskSpec{
public:
    // Properties
    TaskType taskType;
    DeviceType deviceType;
    VisualizationType visualizationType;
    
    string deviceVizCode;
    string taskCode;
    int support_n;
    vector<int> trial_n_list;
    vector<string> trial_string_list;
    vector<int> shuffled_order;
    vector<string> shuffled_trial_string_list;
public:
    // Constructor
    TaskSpec(TaskType taskType);
    TaskSpec(string taskTypeString);
};

TaskType stringToTaskType(string aString);

//------------------------------
// Param object
//------------------------------
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

//------------------------------
// Record object
//------------------------------
class record{
public:
    int snapshot_id;
    bool isAnswered;
    NSString* code;
    
    NSDate *startDate;
    NSDate *endDate;
    
    CGPoint cgPointTruth;
    CGPoint cgPointAnswer;
    double  doubleTruth;
    double  doubleAnswer;
    
    
    double location_error;
    double elapsed_time;
public:
    record(){
        snapshot_id     = 0;
        isAnswered      = false;
        code            = @"";
        startDate       = nil;
        endDate         = nil;
        cgPointTruth    = CGPointMake(0, 0);
        cgPointAnswer   = CGPointMake(0, 0);
        
        doubleTruth     = 0;
        doubleAnswer    = 0;
        location_error  = 0;
        elapsed_time    = 0;
    };
    
    void start();
    void end();
    void display();
    NSArray* genSavableRecord();
};

//------------------------------
// Pool object
//------------------------------

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

//------------------------------
// Test Manager
//------------------------------
enum TestManagerMode {OFF, DEVICESTUDY, OSXSTUDY, AUTHORING, REVIEW};

class TestManager{
public:
    
    //-----------------
    // Parameters
    //-----------------
    TestManagerMode testManagerMode;
        
    //-----------------
    // Connection to other components
    //-----------------
    compassMdl *model;
    
    // The following two are initialized via dependency injection
    // (via the viewController itself)
#ifdef __IPHONE__
    iOSViewController *rootViewController;
#else
    DesktopViewController *rootViewController;
#endif
    
    //**********************
    // Test Generation Related Parameters
    //**********************
    
    // Test generation parameters
    // These parameters specify where the generated tests should go
    NSString *test_foldername;          //e.g., study0
    NSString *test_kml_filename;        //e.g., t_locations.kml
    NSString *test_location_filename;   //e.g., temp.locations
    NSString *alltest_vector_filename;     //e.g., allTestVectors.tests
    NSString *practice_filename;
    NSString *test_snapshot_prefix;     //e.g., snapshot-participant0.kml
    NSString *record_filename;
    
    //---------------
    // map and vector
    //---------------
    // A map holds all the IDs and (x, y) coordinates
    map<string, vector<int>> location_dict;
    // This map is for code to ID lookup
    map<string, int> location_code_to_id;
    // Stores all test vectors (each participant has a test vector)
    vector<vector<string>> all_test_vectors;
    // Stores all snapshot vectors (each participant has a snapshot vector)
    vector<vector<snapshot>> all_snapshot_vectors;
    vector<record> record_vector;
    vector<data> t_data_array; // This structure holds the generated locationss
    
    //---------------
    // Parameters for close, far boundaries
    //---------------
    
    // watch_boundaries and phone_boundaries layout
    //              close       |   far
    // [0]desktop  [float, float]  | [float, float]
    // [1]mobile   [float, float]  | [float, float]
    vector<vector<pair<float, float>>> watch_boundaries;
    vector<vector<pair<float, float>>> phone_boundaries;
    
    // Why watch_boundaries and phone_boundaries are float?
    // because device_height/2 could contain fractions
    
    float close_begin_x;
    float close_end_x;
    float far_begin_x;
    float far_end_x;
    int close_n;    // # of locations in the close category
    int far_n;      // # of locations in the far category

    // Structure to keep track of the number of each type of test
    map<string, int> task_type_counter;
    
    //---------------
    // Random number generation
    //---------------
    int seed;
    std::mt19937  generator;
    
    
    //**********************
    // User Study Related Parameters
    //**********************
    
    // Number of users
    int participant_n;
    int participant_id;

    //---------------
    // Counters
    //---------------
    int test_counter;
    double iOSAnswer;
    
    int localize_test_support_n; //TODO: should try to get rid of this
    
    BOOL isRecordAutoSaved;
    
public:
    //----------------
    // Methods
    //----------------
    
    static TestManager* shareTestManager();
    int initTestManager();
    
    //**********************
    // Test Generation Related Methods
    //**********************
    
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
    
    void saveTestLocationsToKML();
    
    //---------------
    // Test vector generation
    //---------------
    
    void generateAllTestVectors(
        vector<string> device_list,
        vector<string> visualization_list,
        vector<string> task_list);
    
    void saveLocationCSV();
    void saveAllTestVectorCSV();
    
    // I will need a snapshot generator too
    void generateSnapShots();
    vector<snapshot> generateSnapShotsFromTestvector(vector<string> test_vector);
    void saveSnapShotsToKML();
    void generateCustomSnapshotFromVectorName(NSString* custom_vector_filename);
    
    // Prepare test directory
    void setupOutputFolder();
    
    
    //---------------
    // Manual test authoring
    //---------------
    void toggleAuthoringMode(bool state);
    void calculateMultipleLocationsDisplayRegion();
    
    // Helper functions
    MKCoordinateRegion calculateCoordRegionFromTwoPoints
    (vector<data> &data_array, int dataID1, int dataID2);
    vector<int> findTwoFurthestLocationIDs(vector<data> &data_array,
                                           vector<int> location_ids);
    
    //**********************
    // Study Related Methods
    //**********************
    void toggleStudyMode(bool state, bool instructPartner);
    
    void initTestEnv(TestManagerMode mode, bool instructPartner);
    void cleanupTestEnv(TestManagerMode mode, bool instructPartner);
    
    void resetTestManager();
    
    void showNextTest(); // Show the next test
    void showPreviousTest();
    void showTestNumber(int test_id);
    void updateUITestMessage(); // Update the message on the interface

    // Speical test environment configuration
    void applyDevConfigurations();
    void applyPracticeConfigurations();
    void applyStudyConfigurations();
    
    // Start and end the test
    void verifyThenStart();
    void startTest();
    void endTest(CGPoint openGLPoint, double doubleAnswer);
    
    void saveRecord(); // Save test record to a file
};

#endif /* defined(__Compass_transparent___TestManager__) */
