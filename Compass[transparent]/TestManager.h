//
//  TestManager.h
//  Compass[transparent]
//
//  Created by dmiau on 7/31/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#ifndef __Compass_transparent___TestManager__
#define __Compass_transparent___TestManager__

#include <iostream>
#include <vector>
#include <map>

#ifndef __IPHONE__
#import <Cocoa/Cocoa.h>
#else
#import <UIKit/UIKit.h>
#import "filesystem.h"
#endif

using namespace std;

//-----------
// Enum definition
//-----------
typedef enum{
    CPNone,
    CPPCompass,
    CPWedge,
    CPOverview
}CPVisualizationType;

typedef enum{
    CPPhone,
    CPWatch
}CPDeviceType;


class param{
public:
    int type;
    bool  isEnabled;
public:
    param(){
        type = nil;
        isEnabled = false;
    };
};

class test{
public:
    CPVisualizationType visualization;
    CPDeviceType device;
public:
    test(){
        visualization = CPPCompass;
        device = CPPhone;
    };
};

//---------------
// Test Manager
//---------------
class TestManager{
public:
    vector<param> visualization_vector;
    vector<param> device_vector;
    
    NSArray* visualization_strings;
    NSArray* device_strings;
    
    vector<CPVisualizationType> visualization_for_test;
    vector<CPDeviceType> device_vector_for_test;
    map<CPVisualizationType, NSString*> visualizationEnum2String;
    map<CPDeviceType, NSString*> deviceEnum2String;
public:
    static TestManager* shareTestManager();
    int initTestManager();
    int generateTests();
};


#endif /* defined(__Compass_transparent___TestManager__) */
