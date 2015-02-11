//
//  TestManager-RunStudy.cpp
//  Compass[transparent]
//
//  Created by Daniel on 2/11/15.
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
// Setup the environment for the next test
//------------------
void TestManager::showPreviousTest(){
    
    // Do NOT execute this method if test_counter is already 0
    if (test_counter == 0)
        return;
    
    model->lockLandmarks = false;
    test_counter = test_counter - 1;
    
    [rootViewController displaySnapshot:test_counter withStudySettings:YES];
    model->lockLandmarks = true;
}

//------------------
// Setup the environment for the next test
//------------------
void TestManager::showNextTest(){
    
    // Do NOT execute this method if test_counter is already the max
    if (test_counter == (model->snapshot_array.size() - 1))
        return;
    
    model->lockLandmarks = false;
    test_counter = test_counter + 1;

//    // Set up the environment
//    if (snapshot_id == (int)self.model->snapshot_array.size())
//    {
//        if (self.demoManager->device_counter !=
//            self.demoManager->enabled_device_vector.size()-1)
//        {
//            snapshot_id =0;
//            [self setupEnvForTest:self.demoManager->
//             enabled_device_vector[++self.demoManager->device_counter].type];
//        }else{
//            --snapshot_id;
//        }
//    }
    
    [rootViewController displaySnapshot:test_counter withStudySettings:YES];
    model->lockLandmarks = true;
}

