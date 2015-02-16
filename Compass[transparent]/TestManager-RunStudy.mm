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

#pragma mark ---------------start up/clean up---------------
//------------------
// Setup the environment for the next test
//------------------
void TestManager::initTestEnv(TestManagerMode mode){
    testManagerMode = mode;
    showTestNumber(0);
    
    if (mode == CONTROL){
        //------------------
        // iOS
        //------------------
        testManagerMode = CONTROL;
        NSDictionary *myDict = @{@"Type" : @"Instruction",
                                 @"Command" : @"SetupEnv",
                                 @"Parameter" : model->snapshot_filename
                                 };
        [rootViewController sendPackage: myDict];
    }else if (mode == COLLECT){
        //------------------
        // Desktop
        //------------------
        testManagerMode = COLLECT;
        // Turn off iOS syncing
        rootViewController.iOSSyncFlag = false;
        [rootViewController toggleBlankMapMode:YES];
        
        // Need to turn off map interactions too
        
        
        // Create one record for each snapshot
        record_vector.clear();
        for (int i = 0; i < model->snapshot_array.size(); ++i){
            record t_record;
            record_vector.push_back(t_record);
        }
        
        [rootViewController sendMessage:@"OK"];
    }
}

void TestManager::cleanupTestEnv(){
    //---------------
    // Turn off the study mode
    //---------------
    testManagerMode = OFF;
    rootViewController.UIConfigurations[@"UIToolbarMode"]
    = @"Development";
    
    model->lockLandmarks = false;
    model->configurations[@"filter_type"] = @"K_ORIENTATIONS";
    model->updateMdl();
    
    record_vector.clear();
}


void TestManager::toggleStudyMode(bool state){
    if (state){
        //---------------
        // Turn on the study mode
        //---------------
        initTestEnv(CONTROL);
        rootViewController.UIConfigurations[@"UIToolbarMode"]
        = @"Study";
    }else{
        cleanupTestEnv();
    }
    rootViewController.UIConfigurations[@"UIToolbarNeedsUpdate"]
    = [NSNumber numberWithBool:true];
    updateUI();
}

void TestManager::updateUI(){
    
#ifdef __IPHONE__
    // Currently only implemented in iOS
    rootViewController.counter_button.title =
    [NSString stringWithFormat: @"%d/%lu", test_counter+1,
     model->snapshot_array.size()];
#endif
}

#pragma mark ---------------test flow control---------------
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
    if (testManagerMode == CONTROL){
        NSDictionary *myDict = @{@"Type" : @"Instruction",
                                 @"Command" : @"LoadSnapshot",
                                 @"Parameter" : [NSNumber numberWithInt:test_id]
                                 };
        [rootViewController sendPackage: myDict];
    }
    
    [rootViewController displaySnapshot:test_counter withStudySettings:YES];
    
    
}
