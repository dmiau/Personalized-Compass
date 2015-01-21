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
// Demo Manager singleton initializations
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
// Demo Manager initializations
//--------------
int TestManager::initTestManager(){
    visualization_vector.clear();
    device_vector.clear();
    visualization_counter = 0;
    test_counter = -1; //-1 means initialization
    
    vector<CPVisualizationType> visualization_enums
    = {CPNone, CPPCompass, CPWedge, CPOverview};
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
    
    // Generate a set of inti tests
    generateTests();
    return 0;
}

int TestManager::generateTests(){
    compassMdl* model = compassMdl::shareCompassMdl();
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
    
    //---------------------
    // Generate a list of tests
    //---------------------
    int test_id_counter = 0;
    test_vector.clear();
    for (int i = 0; i < enabled_device_vector.size(); ++i){
        
        //        for (int j = 0; j < enabled_visualization_vector.size(); ++j){
        
        //            for (int k =0; k < model->snapshot_array.size(); ++k){
        test myTest;
        
        //                myTest.visualization = (CPVisualizationType)enabled_visualization_vector[j].type;
        myTest.device = (DeviceType)enabled_device_vector[i].type;
        //                myTest.snapshot_id = k;
        myTest.test_id = test_id_counter;
        test_vector.push_back(myTest);
        test_id_counter += test_id_counter;
        //            }
        //        }
        
    }
    
    // Reset the test counter
    test_counter = -1;
    return 0;
}