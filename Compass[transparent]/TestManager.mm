//
//  TestManager.cpp
//  Compass[transparent]
//
//  Created by Daniel on 1/20/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include "TestManager.h"
#import "compassModel.h"

//--------------
// Test Manager singleton initializations
//--------------
TestManager* TestManager::shareTestManager(){
    static TestManager* instance = NULL;
    
    if (!instance){ // Only allow one instance of class to be generated
        instance = new TestManager;
        instance->initTestManager();
    }
    return instance;
};

//--------------
// Test Manager initializations
//--------------
int TestManager::initTestManager(){
    
    model = compassMdl::shareCompassMdl();
    
    visualization_vector.clear();
    device_vector.clear();
    visualization_counter = 0;
    test_counter = -1; //-1 means initialization
    testManagerMode = CONTROL;
    
    vector<VisualizationType> visualization_enums
    = {VIZNONE, VIZPCOMPASS, VIZWEDGE, VIZOVERVIEW};
    NSArray* visualization_strings =
    @[@"None", @"PComp", @"Wedge", @"OverV"];
    
    for (int i = 0; i < visualization_enums.size(); ++i){
        param myParam;
        myParam.type = visualization_enums[i];
        myParam.isEnabled = true;
        myParam.name = visualization_strings[i];
        visualization_vector.push_back(myParam);
    }
    
    vector<DeviceType> device_enums = {PHONE, WATCH};
    
    NSArray* device_strings = @[@"Phone", @"Watch"];
    for (int i = 0; i < device_enums.size(); ++i){
        param myParam;
        myParam.type = device_enums[i];
        myParam.isEnabled = true;
        myParam.name = device_strings[i];
        device_vector.push_back(myParam);
    }
    
    // Initialize random number generation
    seed = 12345;
    std::mt19937 temp(seed);
    generator = temp;
    
    // Initialize default output filenames
    test_foldername     = @"study0";
    test_kml_filename   = @"t_locations.kml";
    test_location_filename  = @"temp.locations";
    alltest_vector_filename = @"allTestVectors.tests";
    test_snapshot_prefix = @"snapshot-participant";
    
    return 0;
}

//--------------
// Prepare the output environment
//--------------
void TestManager::setupOutputFolder(){
    NSString *out_folder_path = [model->desktopDropboxDataRoot
                                 stringByAppendingString:test_foldername];
    if (![[NSFileManager defaultManager] fileExistsAtPath:out_folder_path])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:out_folder_path withIntermediateDirectories:NO attributes:nil error:&error];
        NSLog(@"%@ created", out_folder_path);
    }
}

//--------------
// Test Generation
//--------------
int TestManager::generateTests(){
    
    //--------------
    // Initialize boundaries
    //--------------
    initializeDeviceBoundaries();
    
    enabled_visualization_vector.clear();
    for (int i = 0; i < visualization_vector.size(); ++i){
        if (visualization_vector[i].isEnabled){
            enabled_visualization_vector.push_back
            (visualization_vector[i]);
        }
    }
    
    enabled_device_vector.clear();
    for (int i = 0; i < device_vector.size(); ++i){
        if (device_vector[i].isEnabled){
            enabled_device_vector.push_back
            (device_vector[i]);
        }
    }

    //=====================
    // Test Parameters
    //=====================
    vector<string> device_list = {"phone", "watch"};
    vector<string> visualization_list = {"pcompass", "wedge"};
    vector<string> task_list = {"t1", "t2", "t3"};
    vector<string> distance_list = {"c", "f"};
    
    // Generate the location pool
    vector<string> location_list; location_list.clear();
    
    int location_n = 10; // number of locations per distance class
    // Initial location list
    for (int i = 0; i < location_n; ++i){
        
        string dist_subfix = distance_list[0];
        if (i >= (float)location_n/2){
            dist_subfix = distance_list[1];
        }
        location_list.push_back(to_string(i)+dist_subfix);
    }
    
    //=====================
    // Generate location vector
    //=====================
    map<string, vector<int>> t_location_dict = generateLocationVector();
    
    //=====================
    // Generate Test Vectors
    //=====================
    generateAllTestVectors(device_list, visualization_list, task_list,
                       distance_list, location_list);

    //=====================
    // Save the files
    //=====================
    generateSnapShots();
    saveSnapShotsToKML();
        
    // Reset the test counter
    test_counter = -1;
    return 0;
}
