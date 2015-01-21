//
//  DemoManager.h
//  Compass[transparent]
//
//  Created by dmiau on 7/31/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#ifndef __Compass_transparent___DemoManager__
#define __Compass_transparent___DemoManager__

// TestManager and DemoManager share some common resources
#import "TestManager.h"
#include <iostream>
#include <vector>
#include <map>

#ifndef __IPHONE__
#import <Cocoa/Cocoa.h>
#else
#import <UIKit/UIKit.h>
#endif

using namespace std;

//---------------
// Demo Manager
//---------------
class DemoManager{
public:
    vector<param> visualization_vector;
    vector<param> device_vector;
    
    vector<param> enabled_visualization_vector;
    vector<param> enabled_device_vector;
    
    // The following counters are used to indicate which device and visualization
    // to configure.
    int visualization_counter;
    int device_counter;
public:
    static DemoManager* shareDemoManager();
    int initDemoManager();
    int updateDemoList();
};


#endif /* defined(__Compass_transparent___DemoManager__) */
