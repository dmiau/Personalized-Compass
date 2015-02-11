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
void TestManager::initTestEnv(TestManagerMode mode){
    testManagerMode = mode;
    showTestNumber(0);
    
    if (mode == CONTROL){
        NSDictionary *myDict = @{@"Type" : @"Instruction",
                                 @"Command" : @"SetupEnv"
                                 };
        [rootViewController sendPackage: myDict];
    }
}

//------------------
// Setup the environment for the next test
//------------------
void TestManager::showPreviousTest(){
    
    // Do NOT execute this method if test_counter is already 0
    if (test_counter == 0)
        return;

    test_counter = test_counter - 1;
    showTestNumber(test_counter);
}

//------------------
// Setup the environment for the next test
//------------------
void TestManager::showNextTest(){
    
    // Do NOT execute this method if test_counter is already the max
    if (test_counter == (model->snapshot_array.size() - 1))
        return;

    test_counter = test_counter + 1;
    showTestNumber(test_counter);
}

//------------------
// Run test by ID
//------------------
void TestManager::showTestNumber(int test_id){
    // Do NOT execute this method if test_counter is already 0
    if (test_id < 0 || test_id >= model->snapshot_array.size() ){
        return;
    }else{
            test_counter = test_id;
    }
    
    model->lockLandmarks = false;
    [rootViewController displaySnapshot:test_counter withStudySettings:YES];
    model->lockLandmarks = true;
}