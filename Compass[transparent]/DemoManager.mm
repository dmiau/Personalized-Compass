//
//  DemoManager.cpp
//  Compass[transparent]
//
//  Created by dmiau on 7/31/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#include "DemoManager.h"
#import "compassModel.h"

//--------------
// Test Manager singleton initializations
//--------------
DemoManager* DemoManager::shareDemoManager(){
    static DemoManager* instance = NULL;
    
    if (!instance){ // Only allow one instance of class to be generated
        instance = new DemoManager;
        instance->initDemoManager();
    }
    return instance;
};

//--------------
// Test Manager initializations
//--------------
int DemoManager::initDemoManager(){
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
    
    vector<CPDeviceType> device_enums = {CPPhone, CPWatch};

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

int DemoManager::generateTests(){
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
                myTest.device = (CPDeviceType)enabled_device_vector[i].type;
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