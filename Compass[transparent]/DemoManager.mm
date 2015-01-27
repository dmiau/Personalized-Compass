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
// Demo Manager singleton initializations
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
// Demo Manager initializations
//--------------
int DemoManager::initDemoManager(){
    visualization_vector.clear();
    device_vector.clear();
    visualization_counter = 0;
    device_counter = -1; //-1 means initialization
    
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
    
    // Generate a set of inti tests
    updateDemoList();
    return 0;
}

int DemoManager::updateDemoList(){
    compassMdl* model = compassMdl::shareCompassMdl();
    
    // Specify the types of visualizations available
    enabled_visualization_vector.clear();
    for (int i = 0; i < visualization_vector.size(); ++i){
        if (visualization_vector[i].isEnabled){
            enabled_visualization_vector.push_back
            (visualization_vector[i]);
        }
    }

    // Specify the types of devices available
    enabled_device_vector.clear();
    for (int i = 0; i < device_vector.size(); ++i){
        if (device_vector[i].isEnabled){
            enabled_device_vector.push_back
            (device_vector[i]);
        }
    }
    
    // Reset the device counter
    device_counter = -1;
    return 0;
}