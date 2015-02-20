//
//  TestManager.cpp
//  Compass[transparent]
//
//  Created by Daniel on 1/20/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include "TestManager.h"

#ifndef __IPHONE__
#import "DesktopViewController.h"
#else
#import "iOSViewController.h"
#endif

#import "compassRender.h"

using namespace std;

//--------------
// Test Spec Class
//--------------
void TestSpec::initialize(){

    // Initial location_string_list
    int trial_counter = 0;
    vector<string> dist_subfix = {"a", "b"};
    for (int i = 0; i < boundary_spec_list.size(); ++i){
        for (int j = 0; j < boundary_spec_list[i].count; ++j){
            trial_string_list.push_back(to_string(trial_counter) + dist_subfix[i]);
            ++trial_counter;
        }
    }
    
    shuffled_order.clear();
    // Computer a random order
    // At this point we know this task contains trial_counter trials
    for (int i = 0; i < trial_counter; ++i){
        shuffled_order.push_back(i);
    }    
    random_shuffle(shuffled_order.begin(), shuffled_order.end());
}

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
    test_counter = 0;
    testManagerMode = OFF;
    
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
    
    //----------------
    // Parameters for each type of test
    //----------------
    localize_test_support_n = 2;
    
    // Initialize random number generation
    seed = 12345;
    std::mt19937 temp(seed);
    generator = temp;
    
    // Initialize default output filenames
    test_foldername     = @"study0";
    test_kml_filename   = @"studyLocations.kml";
    test_location_filename  = @"temp.locations";
    alltest_vector_filename = @"allTestVectors.tests";
    test_snapshot_prefix = @"snapshot-participant";
    record_filename = @"study0.record";
    
    return 0;
}


//--------------
// Reset the test manager
//--------------
void TestManager::resetTestManager(){
    test_counter = 0;
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
    generateLocationVector();
    
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
        
    return 0;
}

//---------------
// Initialize watch_boundaries and phone_boundaries
//---------------
void TestManager::initializeDeviceBoundaries(){
    
    float em_width, em_height;
    float ios_width, ios_height;
    
    double close_begin, close_end;
    double far_begin, far_end;
    
    //         close_n steps    far_n steps
    // -------|------------|---|---------------|
    // close_begin  close_end far_begin     far_end
    
    
    // In the study, there are two devices (environments) to be tested: phone and watch
    // However, in the locate task, phone and watch might be tested on a desktop
    // So this can be a bit confusing.
    // Here will call phone and watch as devices
    // desktop and ios as platform
    
    //------------
    // Phone
    //------------
    vector<float> two_heights;
#ifndef __IPHONE__
    em_width = rootViewController.renderer->emulatediOS.width;
    em_height = rootViewController.renderer->emulatediOS.height;
    ios_width = rootViewController.renderer->emulatediOS.true_ios_width;
    ios_height = rootViewController.renderer->emulatediOS.true_ios_height;
    two_heights = {em_height, ios_height};
#else
    two_heights = {302, 503};
#endif
    
    
    // First populate the desktop, second populate the ios
    for (int i = 0; i < two_heights.size(); ++i){
        float platform_height = two_heights[i];
        close_begin = platform_height/2 * close_begin_x;
        close_end = platform_height/2 * close_end_x;
        
        far_begin = platform_height/2 * far_begin_x;
        far_end = platform_height/2 * far_end_x;
        
        // Need to initialize the vector
        vector<pair<float, float>> temp =
        {pair<float, float>(close_begin, close_end), pair<float, float>(far_begin, far_end)};
        
        phone_boundaries.push_back(temp);
    }
    
    //------------
    // Watch (may need to change the parameters here)
    //------------
#ifndef __IPHONE__
    em_width = rootViewController.renderer->emulatediOS.width;
    em_height = rootViewController.renderer->emulatediOS.height;
    ios_width = rootViewController.renderer->emulatediOS.true_ios_width;
    ios_height = rootViewController.renderer->emulatediOS.true_ios_height;
    two_heights = {em_height, ios_height};
#else
    two_heights = {302, 503};
#endif
    // First populate the desktop, second populate the ios
    for (int i = 0; i < two_heights.size(); ++i){
        float platform_height = two_heights[i];
        close_begin = platform_height/2 * close_begin_x;
        close_end = platform_height/2 * close_end_x;
        
        far_begin = platform_height/2 * far_begin_x;
        far_end = platform_height/2 * far_end_x;
        
        // Need to initialize the vector
        vector<pair<float, float>> temp =
        {pair<float, float>(close_begin, close_end), pair<float, float>(far_begin, far_end)};
        watch_boundaries.push_back(temp);
    }
}
