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
void TestManager::initTestEnv(TestManagerMode mode, bool instructPartner){
    testManagerMode = mode;
    // Need to turn off map interactions in the study mode
    [rootViewController enableMapInteraction:NO];
    [rootViewController changeAnnotationDisplayMode:@"None"];

    
    //----------------------------
    // Visualization Parameters
    //----------------------------
    model->configurations[@"style_type"] = @"REAL_RATIO";
    
    //----------------------------
    // Create one record for each snapshot
    //----------------------------
    record_vector.clear();
    for (int i = 0; i < model->snapshot_array.size(); ++i){
        record t_record;
        
        // Need to initialize id and code
        t_record.snapshot_id = i;
        t_record.code = model->snapshot_array[i].name;
        record_vector.push_back(t_record);
    }

    //----------------------------
    // Device Specific Settings
    //----------------------------
    if (mode == DEVICESTUDY){
        //------------------
        // iOS
        //------------------
        rootViewController.UIConfigurations[@"UIAcceptsPinCreation"] =
        [NSNumber numberWithBool:NO];
        
        if (instructPartner){
            // The following lines has no effect on OSX
            // sendPackage is only functional when called on iOS
            NSDictionary *myDict = @{@"Type" : @"Instruction",
                                     @"Command" : @"SetupEnv",
                                     @"Parameter" : model->snapshot_filename
                                     };
            [rootViewController sendPackage: myDict];
        }
    }else if (mode == OSXSTUDY){
        //------------------
        // Desktop
        //------------------       
        rootViewController.UIConfigurations[@"UIAcceptsPinCreation"] =
        [NSNumber numberWithBool:YES];
        [rootViewController toggleBlankMapMode:YES];
#ifndef __IPHONE__
        // Turn off iOS syncing
        rootViewController.iOSSyncFlag = false;
        [rootViewController.nextTestButton setEnabled:YES];
        [rootViewController.previousTestButton setEnabled:YES];
#endif
        
        // Disable all visualizations
        model->configurations[@"personalized_compass_status"] = @"off";
        [rootViewController setFactoryCompassHidden:YES];
        model->configurations[@"wedge_status"] = @"off";
        
        [rootViewController sendMessage:@"OK"];
    }
    updateUITestMessage();
    showTestNumber(0);
#ifndef __IPHONE__
    startTest();
#endif
}

//-------------------
// Clean up the environment
//-------------------
void TestManager::cleanupTestEnv(TestManagerMode mode, bool instructPartner){
    rootViewController.renderer->isCrossEnabled = false;
    rootViewController.renderer->isInteractiveLineEnabled=false;
    model->configurations[@"style_type"] = @"BIMODAL";
    
    if (mode == DEVICESTUDY){
        if (instructPartner){
            // The following lines has no effect on OSX
            // sendPackage is only functional when called on iOS
            NSDictionary *myDict = @{@"Type" : @"Instruction",
                                     @"Command" : @"End"
                                     };
            [rootViewController sendPackage: myDict];
        }
    }else if (mode == OSXSTUDY){
#ifndef __IPHONE__
        [rootViewController.nextTestButton setEnabled:NO];
        [rootViewController.previousTestButton setEnabled:NO];
        [rootViewController.showAnswerButton setEnabled:NO];
        
        if (isRecordAutoSaved)
            rootViewController.testManager->saveRecord();
        if (instructPartner){
            [rootViewController sendMessage: @"End"];
        }
#endif
    }
    
    //---------------
    // Turn off the study mode
    //---------------
    testManagerMode = OFF;
    [rootViewController toggleBlankMapMode:NO];
    [rootViewController enableMapInteraction:YES];
    rootViewController.UIConfigurations[@"UIToolbarMode"]
    = @"Development";
    [rootViewController changeAnnotationDisplayMode:@"All"];
    model->lockLandmarks = false;
    model->configurations[@"filter_type"] = @"K_ORIENTATIONS";
    model->updateMdl();
    updateUITestMessage();
    [rootViewController toggleBlankMapMode:NO];
}


void TestManager::toggleStudyMode(bool state, bool instructPartner){
    
    TestManagerMode mode;
#ifdef __IPHONE__
    mode = DEVICESTUDY;
#else
    mode = OSXSTUDY;
#endif
    
    if (state){
        //---------------
        // Turn on the study mode
        //---------------
        initTestEnv(mode, instructPartner);
        rootViewController.UIConfigurations[@"UIToolbarMode"]
        = @"Study";
    }else{
        cleanupTestEnv(mode, instructPartner);
    }
    rootViewController.UIConfigurations[@"UIToolbarNeedsUpdate"]
    = [NSNumber numberWithBool:true];
}

void TestManager::updateUITestMessage(){
    
#ifdef __IPHONE__
    //---------------
    // iPhone
    //---------------
    if (testManagerMode == OFF){
        rootViewController.counter_button.title =
        @"StudyMode OFF";
    }else{
        rootViewController.counter_button.title =
        [NSString stringWithFormat: @"%d/%lu", test_counter+1,
         model->snapshot_array.size()];
    }
#else
    //---------------
    // OSX, Desktop
    //---------------
    
    if (testManagerMode == OFF){
        rootViewController.testMessageTextField.stringValue =
        @"Enable StudyMode from iOS";
    }else{
        rootViewController.testMessageTextField.stringValue =
        [NSString stringWithFormat:@"%@, %d/%lu",
         model->snapshot_array[test_counter].name,
         test_counter+1, model->snapshot_array.size()];
    }
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
        // Before jumping into a new test, end the previous (unanswered) test
        // The timer of the answered test is stopped in the endTest method
        if (!record_vector[test_counter].isAnswered){
            record_vector[test_counter].end();
        }
        test_counter = test_id;
    }
    if (testManagerMode == DEVICESTUDY){
//        NSDictionary *myDict = @{@"Type" : @"Instruction",
//                                 @"Command" : @"LoadSnapshot",
//                                 @"Parameter" : [NSNumber numberWithInt:test_id]
//                                 };
//        [rootViewController sendPackage: myDict];
        
    }else if (testManagerMode == OSXSTUDY){

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
                record_vector[test_id].cgPointTruth = t_point;
                break;
            }
        }
#endif
    }
    
    [rootViewController displaySnapshot:test_counter
                      withStudySettings:testManagerMode];
#ifndef __IPHONE__
    startTest();
#endif
}

//------------------
// Start the test
//------------------
void TestManager::verifyThenStart(){
    
}

//------------------
// Start the test
//------------------
void TestManager::startTest(){
    record_vector[test_counter].start(); // start the time
    
    
#ifndef __IPHONE__
    snapshot mySnapshot = model->snapshot_array[test_counter];

    int data_id = mySnapshot.selected_ids[0];
    // Calculat the ground truth based on task type
    if ([mySnapshot.name rangeOfString:@"t1"].location != NSNotFound){
        //-----------------
        // Locate test
        //-----------------
        CGPoint openGLPoint = [rootViewController calculateOpenGLPointFromMapCoord:
        CLLocationCoordinate2DMake
        (model->data_array[data_id].latitude, model->data_array[data_id].longitude)];
        record_vector[test_counter].cgPointTruth = openGLPoint;
        
        double x, y;
        x = openGLPoint.x - rootViewController.renderer->emulatediOS.centroid_in_opengl.x;
        y = openGLPoint.y - rootViewController.renderer->emulatediOS.centroid_in_opengl.y;
        
        double dist = sqrt(x * x + y * y);
        record_vector[test_counter].doubleTruth = (double)dist /
        (double) rootViewController.renderer->emulatediOS.width;
    }else if ([mySnapshot.name rangeOfString:@"t2"].location != NSNotFound){
        //-----------------
        // Localize test
        //-----------------
        
        CGPoint openGLPoint = [rootViewController calculateOpenGLPointFromMapCoord:
                               mySnapshot.coordinateRegion.center];
        record_vector[test_counter].cgPointTruth = openGLPoint;
        
        double x, y;
        x = openGLPoint.x- rootViewController.renderer->emulatediOS.centroid_in_opengl.x;
        y = openGLPoint.y- rootViewController.renderer->emulatediOS.centroid_in_opengl.y;
        double dist = sqrt(x*x + y*y);
        record_vector[test_counter].doubleTruth = dist;
    }else if ([mySnapshot.name rangeOfString:@"t3"].location != NSNotFound){
        iOSAnswer = 10000;
        //-----------------
        // Orient test
        //-----------------
        CGPoint openGLPoint = [rootViewController calculateOpenGLPointFromMapCoord:
                               CLLocationCoordinate2DMake
                               (model->data_array[data_id].latitude, model->data_array[data_id].longitude)];
        record_vector[test_counter].cgPointTruth = openGLPoint;
        
        record_vector[test_counter].doubleTruth =
        atan2(openGLPoint.y, openGLPoint.x) /M_PI * 180;
    }
#endif
}

//------------------
// End the test
//------------------
void TestManager::endTest(CGPoint openGLPoint, double doubleAnswer){

    record_vector[test_counter].end(); // Log the time
    record_vector[test_counter].isAnswered = true;
    snapshot mySnapshot = model->snapshot_array[test_counter];
   
    // Log the location
    record_vector[test_counter].cgPointAnswer = openGLPoint;
    record_vector[test_counter].doubleAnswer  = doubleAnswer;
    [rootViewController sendMessage:@"NEXT"];
}

//------------------
// Special Environment Configurations
//------------------
void TestManager::applyDevConfigurations(){
    rootViewController.renderer->label_flag = true;
    
#ifndef __IPHONE__
    rootViewController.showAnswerButton.hidden = NO;
    rootViewController.showAnswerButton.enabled = YES;
    rootViewController.distEstimationTextField.enabled = YES;
#endif
    
    rootViewController.mapView.layer.borderColor =
    [NSColor redColor].CGColor;
    rootViewController.mapView.layer.borderWidth
    = 2.0f;
}

void TestManager::applyPracticeConfigurations(){
    rootViewController.renderer->label_flag = false;
    isRecordAutoSaved = NO;
    
#ifndef __IPHONE__
    rootViewController.showAnswerButton.hidden = NO;
    rootViewController.showAnswerButton.enabled = YES;
    rootViewController.distEstimationTextField.enabled = YES;
#endif
    
    rootViewController.mapView.layer.borderColor =
    [NSColor blueColor].CGColor;
    rootViewController.mapView.layer.borderWidth
    = 2.0f;
}

void TestManager::applyStudyConfigurations(){
    rootViewController.renderer->label_flag = false;
    isRecordAutoSaved = YES;
#ifndef __IPHONE__
    // Hide the answer button
    rootViewController.showAnswerButton.hidden = YES;
#endif
    rootViewController.mapView.layer.borderColor =
    [NSColor clearColor].CGColor;
    rootViewController.mapView.layer.borderWidth
    = 0.0f;
}










