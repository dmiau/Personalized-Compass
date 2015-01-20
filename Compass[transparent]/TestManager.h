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

#ifndef __IPHONE__
#import <Cocoa/Cocoa.h>
#else
#import <UIKit/UIKit.h>
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
    NSString *name;
public:
    param(){
        type = NULL;
        isEnabled = false;
        name = @"";
    };
};

class test{
public:
    
    CPVisualizationType visualization;
    CPDeviceType device;
    int test_id;
    int snapshot_id;
    NSString *name;
    NSString *instructions;
    NSString *sectionMsg;
    bool isEnabled;
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
    
    vector<param> enabled_visualization_vector;
    vector<param> enabled_device_vector;
    
    vector<test> test_vector;
    
    int visualization_counter;
    int test_counter;
public:
    static TestManager* shareTestManager();
    int initTestManager();
    int generateTests();
};

#endif /* defined(__Compass_transparent___TestManager__) */
