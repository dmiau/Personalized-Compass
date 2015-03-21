//
//  TestManager-Authoring.cpp
//  Compass[transparent]
//
//  Created by Daniel on 2/12/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include "TestManager.h"

#ifdef __IPHONE__
// iOS
#import "iOSViewController.h"
#else
// desktop
#import "DesktopViewController.h"
#endif

//------------------
// Test authoring mode
//------------------
void TestManager::toggleAuthoringMode(bool state){
    if (state){
        //-----------------
        // Authoring mode is on
        //-----------------
        
        // Set the orientation to 0, and disable rotation
        rootViewController.mapView.camera.heading = 0;
        testManagerMode = AUTHORING;
        // Manual
        model->configurations[@"filter_type"] = @"MANUAL";
        rootViewController.UIConfigurations[@"UIAcceptsPinCreation"] =
        [NSNumber numberWithBool:YES];
    }else{
        //-----------------
        // Authoring mode is off
        //-----------------
        // Save the file?
        testManagerMode = OFF;
        rootViewController.UIConfigurations[@"UIAcceptsPinCreation"] =
        [NSNumber numberWithBool:NO];
        model->configurations[@"filter_type"] = @"K_ORIENTATIONS";
//        [rootViewController saveKMLwithType: LOCATION];
//        [rootViewController saveKMLwithType: SNAPSHOT];
        
        // Fill in OSX CoordRegion if possible
        calculateMultipleLocationsDisplayRegion();
    }
    
    [rootViewController.mapView setRotateEnabled:!state];
    rootViewController.UIConfigurations[@"UIAcceptsPinCreation"]=
    [NSNumber numberWithBool:state];
    
}