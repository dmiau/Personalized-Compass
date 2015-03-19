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

#include "TaskSpec.h"
using namespace std;

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
    CGPoint cgPointOpenGL; // This record the xy coordinates seen from renderer
    CGPoint cgPointAnswer;
    double  doubleTruth;
    double  doubleAnswer;
    
    CGPoint cgSupport1;     // There could be two additional points.
    CGPoint cgSupport2;     // (for the triangulate and locate+ tasks)
    double  display_radius;
    
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
        cgPointOpenGL   = CGPointMake(0, 0);
        
        cgSupport1      = CGPointMake(0, 0);
        cgSupport2      = CGPointMake(0, 0);
        display_radius  = 0;
        
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

template <class type> class pool{
public:
    string name;
    int counter;
    
    // content:
    // {{{1, 2}, {2, 1}},
    // {{2, 1}, {1, 2}}}
    vector< vector<vector<type>> > content;
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
    pool(vector<type> conditions, POOLMODE mode, int leaf_n);
    
    // Next should return the following in sequence
    // {1, 2}, {2, 1},   {2, 1}, {1, 2}
    // Note that next should be able to go through the boundary of cells.
    // so vector<string>
    vector<type> next();
};

//------------------------------
// Test Manager
//------------------------------
enum TestManagerMode {OFF, DEVICESTUDY, OSXSTUDY, AUTHORING, REVIEW};

class TestManager{
public:
    
    //-----------------
    // User Study Related Parameters
    //-----------------
    TestManagerMode testManagerMode;
    
    // Number of users
    int participant_n;
    int participant_id;
    
    //---------------
    // Counters
    //---------------
    int test_counter;
    double iOSAnswer;
    
    BOOL isRecordAutoSaved;
    BOOL isLocked;
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
    
    NSMutableDictionary* testSpecDictionary;
    // This dictionary contains the specifications loaded from testSpec.plist
    
    // Test generation parameters
    // These parameters specify where the generated tests should go
    NSString *test_foldername;          //e.g., study0
    NSString *test_kml_filename;        //e.g., t_locations.kml
    NSString *test_location_filename;   //e.g., temp.locations
    NSString *alltest_vector_filename;     //e.g., allTestVectors.tests
    NSString *practice_filename;
    NSString *test_snapshot_prefix;     //e.g., snapshot-participant0.kml
    NSString *record_filename;
    NSString *test_specs_filename;          //e.g., testSpec.plist
    
    //---------------
    // test generation specification
    //---------------
    vector<DeviceType> device_list;
    vector<VisualizationType> visualization_list;
    vector<TaskType> task_list;
    vector<DataSetType> data_set_list;

    vector<TaskType> phone_task_list;
    vector<TaskType> watch_task_list;

    //---------------
    // map and vector
    //---------------
    
    /*
    code: 
    phone:pcompass:locate
    phone:wedge:locate
     
    watch:pcompass:locate
    watch:wedge:locate
     
    In reality, each task most likely associates with a device only.
     */
    map<string, TaskSpec> taskSpec_dict;
    map<DataSetType, vector<snapshot>> practice_snapshot_dict;
    
    // A map holds all the IDs and (x, y) coordinates
    vector<pair<string, vector<int>>> code_xy_vector;
    
    // Stores all test vectors (each participant has a test vector)
    vector<vector<string>> all_test_vectors;
    // Stores all snapshot vectors (each participant has a snapshot vector)
    vector<vector<snapshot>> all_snapshot_vectors;
    vector<snapshot> practice_snapshot_vector; // To store the practice snapshots
    vector<record> record_vector;
    vector<data> t_data_array; // This structure holds the generated locationss

    map<string, int> snapshotDistributionInfo;
    map<string, int> chapterInfo;
    // Contains the information of test_category/number_of_tests
    vector<int> testCountWithinCategory;
    vector<string> testSequenceVector;
    
    //---------------
    // Random number generation
    //---------------
    int seed;
    std::mt19937  generator;
public:
    //----------------
    // Methods
    //----------------
    
    static TestManager* shareTestManager();
    int initTestManager();
    
    //**********************
    // Test Generation Related Methods
    //**********************
    
    // Load test spec plist
    void loadTestSpecPlist();
    
    // Methods to generate tests    
    int generateTests();
    
    //---------------
    // Test vector generation
    //---------------
#ifndef __IPHONE__
    void generateAllTestVectors(
        vector<DeviceType> device_list,
        vector<VisualizationType> visualization_list,
        vector<TaskType> task_list);
#endif
    void saveLocationVector();
    void saveAllTestVectorCSV();
    
    void saveSnapShotsToKML();
    void configureSnapshots(vector<snapshot> &snapshot_vector);
    
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
    bool verifyAnswerQuality();
    void startTest();
    void collectGroundTruth();
    void endTest(CGPoint openGLPoint, double doubleAnswer);
    
    void saveRecord(NSString *out_file, bool forced); // Save test record to a file
    
    // Display test information
    void updateSessionInformation();
    
};

//-----------------
// Tools
//-----------------
string extractCode(NSString* snapshot_name);
string extractUerVisibleCode(NSString* snapshot_name);

#endif /* defined(__Compass_transparent___TestManager__) */
