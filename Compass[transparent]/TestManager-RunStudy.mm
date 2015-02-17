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
    
    // Need to turn off map interactions in the study mode
    [rootViewController enableMapInteraction:NO];
    
    if (mode == CONTROL){
        //------------------
        // iOS
        //------------------
        testManagerMode = CONTROL;
        
        rootViewController.UIConfigurations[@"UIAcceptsPinCreation"] =
        [NSNumber numberWithBool:NO];
        
        // The following lines has no effect on OSX
        // sendPackage is only functional when called on iOS
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
        
        rootViewController.UIConfigurations[@"UIAcceptsPinCreation"] =
        [NSNumber numberWithBool:NO];
        
#ifndef __IPHONE__
        // Turn off iOS syncing
        rootViewController.iOSSyncFlag = false;
#endif
        [rootViewController toggleBlankMapMode:YES];
        
        
        // Create one record for each snapshot
        record_vector.clear();
        for (int i = 0; i < model->snapshot_array.size(); ++i){
            record t_record;
            record_vector.push_back(t_record);
        }
        
        // Disable all visualizations
        model->configurations[@"personalized_compass_status"] = @"off";
        [rootViewController setFactoryCompassHidden:YES];
        model->configurations[@"wedge_status"] = @"off";
        
        [rootViewController sendMessage:@"OK"];
    }
}

void TestManager::cleanupTestEnv(){
    //---------------
    // Turn off the study mode
    //---------------
    testManagerMode = OFF;
    
    [rootViewController enableMapInteraction:YES];
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
// Show test by ID
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
        
    }else if (testManagerMode == COLLECT){
        
        [rootViewController toggleBlankMapMode:YES];
#ifndef __IPHONE__
        // Populate the record structure
        // The disabled annotation is the answer
        
        snapshot t_snapshot = model->snapshot_array[test_id];
        for (int i = 0; i < t_snapshot.is_answer_list.size(); ++i){
            if (t_snapshot.is_answer_list[i] == 0){
                int loc_id = t_snapshot.selected_ids[i];

                CLLocationCoordinate2D coord =
                CLLocationCoordinate2DMake
                (model->data_array[loc_id].latitude,
                 model->data_array[loc_id].longitude);
                
                CGPoint t_point = [rootViewController.mapView
                                   convertCoordinate:coord
                                   toPointToView:rootViewController.compassView];
                record_vector[test_id].ground_truth = t_point;
                break;
            }
        }
#endif
    }
    
    [rootViewController displaySnapshot:test_counter
                      withStudySettings:testManagerMode];
}


//------------------
// Start the test
//------------------
void TestManager::startTest(){
    record_vector[test_counter].start();
}