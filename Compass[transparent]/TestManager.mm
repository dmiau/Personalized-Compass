//
//  TestManager.cpp
//  Compass[transparent]
//
//  Created by dmiau on 7/31/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#include "TestManager.h"

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
    visualization_vector.clear();
    device_vector.clear();
    
    vector<CPVisualizationType> visualization_names
    = {CPNone, CPPCompass, CPWedge, CPOverview};
    NSArray* visualization_strings =
    @[@"None", @"PComp", @"Wedge", @"OverV"];
    
    visualization_for_test = visualization_names;
    for (int i = 0; i < visualization_names.size(); ++i){
        param myParam;
        myParam.type = visualization_names[i];
        myParam.isEnabled = true;
        visualization_vector.push_back(myParam);
        visualizationEnum2String[visualization_names[i]] =
        visualization_strings[i];
    }
    
    vector<CPDeviceType> device_names = {CPPhone, CPWatch};
    device_vector_for_test = device_names;
    NSArray* device_strings =
    @[@"Phone", @"Watch"];
    for (int i = 0; i < device_names.size(); ++i){
        param myParam;
        myParam.type = device_names[i];
        myParam.isEnabled = true;
        device_vector.push_back(myParam);
        deviceEnum2String[device_names[i]] = device_strings[i];
    }    
    return 0;
}