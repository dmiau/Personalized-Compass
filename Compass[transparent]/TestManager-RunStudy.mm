//
//  TestManager-RunStudy.cpp
//  Compass[transparent]
//
//  Created by Daniel on 2/11/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include "TestManager.h"
#include "xmlParser.h"
#import "snapshotParser.h"

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
    
    
    //-----------
    // Do a forced preload of the location files
    //-----------
    if (readSnapshotKml(rootViewController.model)!= EXIT_SUCCESS)
    {
        [rootViewController displayPopupMessage:
         [NSString stringWithFormat:@"Failed to read %@",
          rootViewController.model->snapshot_filename]];
        return;
    }
    
    snapshot mySnapshot = model->snapshot_array[0];
    // Do not reload the location if it is already loaded
    model->location_filename = mySnapshot.kmlFilename;
    readLocationKml(model, model->location_filename);

    
    //----------------------------
    // - Create one record for each snapshot
    // - Collect the snapshot categorical information
    //----------------------------
    record_vector.clear();
    snapshotDistributionInfo.clear();
    testCountWithinCategory.clear();
    int count_within_category = 1;
    for (int i = 0; i < model->snapshot_array.size(); ++i){
        
        //-------------
        // Create a record
        //-------------
        record t_record;
        
        // Need to initialize id and code
        t_record.snapshot_id = i;
        t_record.code = model->snapshot_array[i].name;
        record_vector.push_back(t_record);
        
        //-------------
        // Create a record
        //-------------
        snapshot mySnapshot = model->snapshot_array[i];
        string code = extractCode(mySnapshot.name);
        
        if (snapshotDistributionInfo.find(code) == snapshotDistributionInfo.end()){
            snapshotDistributionInfo[code] = 1;
            count_within_category = 1;
            testCountWithinCategory.push_back(count_within_category);
        }else{
            snapshotDistributionInfo[code] = snapshotDistributionInfo[code]+1;
            testCountWithinCategory.push_back(++count_within_category);
        }
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
#ifndef __IPHONE__
        //------------------
        // Desktop
        //------------------
        
        // Remove all the annotations
        [rootViewController.mapView removeAnnotations:
         rootViewController.mapView.annotations];
        
        rootViewController.UIConfigurations[@"UIAcceptsPinCreation"] =
        [NSNumber numberWithBool:YES];
        [rootViewController toggleBlankMapMode:YES];

        // Turn off iOS syncing
        rootViewController.iOSSyncFlag = false;
        applyStudyConfigurations();
        
        // Disable all visualizations
        model->configurations[@"personalized_compass_status"] = @"off";
        [rootViewController setFactoryCompassHidden:YES];
        model->configurations[@"wedge_status"] = @"off";
        
        if (instructPartner){
            [rootViewController sendMessage:model->snapshot_filename];
        }else{
            [rootViewController sendMessage:@"OK"];
        }
#endif
    }
    updateUITestMessage();
    showTestNumber(0);
}

//-------------------
// Clean up the environment
//-------------------
void TestManager::cleanupTestEnv(TestManagerMode mode, bool instructPartner){
    rootViewController.renderer->cross.isVisible = false;
    rootViewController.renderer->isInteractiveLineVisible=false;
    rootViewController.renderer->isInteractiveLineEnabled=false;
    model->configurations[@"style_type"] = @"BIMODAL";

#ifdef __IPHONE__
    [rootViewController.scaleView removeFromSuperview];
    [rootViewController.watchScaleView removeFromSuperview];
#endif
    
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
        [rootViewController.confirmButton setEnabled:NO];
        rootViewController.isShowAnswerAvailable = [NSNumber numberWithBool:NO];
        rootViewController.isDistanceEstControlAvailable =
        [NSNumber numberWithBool:NO];
        
        if (isRecordAutoSaved)
            rootViewController.testManager->saveRecord(
            [rootViewController.model->desktopDropboxDataRoot
             stringByAppendingPathComponent:
             record_filename]
            );
        if (instructPartner){
            [rootViewController sendMessage: @"End"];
        }
        
        rootViewController.mapView.layer.borderColor =
        [NSColor clearColor].CGColor;
        rootViewController.mapView.layer.borderWidth
        = 0.0f;
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


//-------------------
// Update test message
//-------------------
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
        rootViewController.testInformationMessage =
        @"Enable StudyMode from iOS";
    }else{
        
        string code = extractCode(model->snapshot_array[test_counter].name);
        
        rootViewController.testInformationMessage =
        [NSString stringWithFormat:@"%@, %d/%d\n%@, %d/%lu",
         [NSString stringWithUTF8String:code.c_str()],
         testCountWithinCategory[test_counter],
         snapshotDistributionInfo[code],
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
    showTestNumber(test_counter -1);
}

//------------------
// Setup the environment for the next test
//------------------
void TestManager::showNextTest(){
    
    // Do NOT execute this method if test_counter is already the max
    if (test_counter == (model->snapshot_array.size() - 1))
        return;
    showTestNumber(test_counter + 1);
}

//------------------
// Show test by ID
//------------------
void TestManager::showTestNumber(int test_id){
    int current_id = test_counter;
    
    // Do NOT execute this method if test_counter is already 0
    if (test_id < 0 || test_id >= model->snapshot_array.size() ){
        return;
    }

    [rootViewController displaySnapshot:test_id
                      withStudySettings:testManagerMode];
    test_counter = test_id;
#ifndef __IPHONE__
    //-----------------
    // Need to do some checking before updating the counter
    //-----------------
    snapshot currentSnapshot = model->snapshot_array[current_id];
    snapshot nextSnapshot = model->snapshot_array[test_id];
    
    if ( NSStringToTaskType(currentSnapshot.name) !=
        NSStringToTaskType(nextSnapshot.name)
        ||(test_counter == 0))
    {
        [rootViewController displayTestInstructionsByTask:
         NSStringToTaskType(nextSnapshot.name)];
    }else{
        startTest();
        
        if (!rootViewController.isShowAnswerAvailable)
        {
            [rootViewController.previousTestButton setEnabled:NO];
            [rootViewController.nextTestButton setEnabled:NO];
        }
    }

#endif
}

bool TestManager::verifyAnswerQuality(){
    
    snapshot mySnapshot = model->snapshot_array[test_counter];
    
    int data_id = mySnapshot.selected_ids[0];
    
    //------------------------
    // Calculat the ground truth based on task type
    //------------------------
    if (([mySnapshot.name rangeOfString:toNSString(LOCATE)].location != NSNotFound))
    {
        //-----------------
        // Locate test
        //-----------------
        
        
    }else if ([mySnapshot.name rangeOfString:toNSString(DISTANCE)].location != NSNotFound)
    {
    
    }else if ([mySnapshot.name rangeOfString:toNSString(TRIANGULATE)].location != NSNotFound)
    {
        //-----------------
        // Localize test
        //-----------------

    }else if ([mySnapshot.name rangeOfString:toNSString(ORIENT)].location != NSNotFound)
    {
        iOSAnswer = 10000;
        //-----------------
        // Orient test
        //-----------------

    }else if ([mySnapshot.name rangeOfString:toNSString(LOCATEPLUS)].location != NSNotFound)
    {
        //-----------------
        // Locate plus
        //-----------------

    }
    return true;
}


//------------------
// Start the test
//------------------
void TestManager::startTest(){
#ifndef __IPHONE__
    record_vector[test_counter].start(); // start the time
    snapshot mySnapshot = model->snapshot_array[test_counter];

    int data_id = mySnapshot.selected_ids[0];
    
    //------------------------
    // Calculat the ground truth based on task type
    //------------------------
    if (([mySnapshot.name rangeOfString:toNSString(LOCATE)].location != NSNotFound)
        ||([mySnapshot.name rangeOfString:toNSString(DISTANCE)].location != NSNotFound))
    {
        //-----------------
        // Locate test
        //-----------------
        CGPoint openGLPoint = [rootViewController calculateOpenGLPointFromMapCoord:
        CLLocationCoordinate2DMake
        (model->data_array[data_id].latitude, model->data_array[data_id].longitude)];
        
        double x, y;
        x = openGLPoint.x - rootViewController.renderer->emulatediOS.centroid_in_opengl.x;
        y = openGLPoint.y - rootViewController.renderer->emulatediOS.centroid_in_opengl.y;

        // Note, we should log the (x, y) based on the centroid of the emulated iOS
        record_vector[test_counter].cgPointTruth = CGPointMake(x, y);
        
        double dist = sqrt(x * x + y * y);
        record_vector[test_counter].doubleTruth = (double)dist /
        (double) rootViewController.renderer->emulatediOS.width;
    }else if ([mySnapshot.name rangeOfString:toNSString(TRIANGULATE)].location != NSNotFound){
        //-----------------
        // Localize test
        //-----------------
        
        CGPoint openGLPoint = [rootViewController calculateOpenGLPointFromMapCoord:
                               mySnapshot.coordinateRegion.center];
        record_vector[test_counter].cgPointTruth = openGLPoint;
        record_vector[test_counter].doubleTruth = 0;
    }else if ([mySnapshot.name rangeOfString:toNSString(ORIENT)].location != NSNotFound){
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
    }else if ([mySnapshot.name rangeOfString:toNSString(LOCATEPLUS)].location != NSNotFound){
        //-----------------
        // Locate plus
        //-----------------
        int ans_id =0;
        // Find out the answer ID
        for (int i = 0; i < mySnapshot.selected_ids.size(); ++i){
            if (mySnapshot.is_answer_list[i] == 1)
                ans_id = mySnapshot.selected_ids[i];
        }
        
        CGPoint openGLPoint = [rootViewController calculateOpenGLPointFromMapCoord:
                               CLLocationCoordinate2DMake
                               (model->data_array[ans_id].latitude,
                                model->data_array[ans_id].longitude)];
        record_vector[test_counter].cgPointTruth = openGLPoint;
        record_vector[test_counter].doubleTruth = 0;
    }
#endif
}

//------------------
// End the test
//------------------
void TestManager::endTest(CGPoint openGLPoint, double doubleAnswer){

    record_vector[test_counter].end(); // Log the time
    record_vector[test_counter].isAnswered = true;   
    // Log the location
    record_vector[test_counter].cgPointAnswer = openGLPoint;
    record_vector[test_counter].doubleAnswer  = doubleAnswer;
    [rootViewController sendMessage:@"NEXT"];
}

//------------------
// Development Configurations
//------------------
void TestManager::applyDevConfigurations(){
//    rootViewController.renderer->label_flag = true;
    isRecordAutoSaved = NO;
    applyPracticeConfigurations();
    
    rootViewController.mapView.layer.borderColor =
    [NSColor redColor].CGColor;
    rootViewController.mapView.layer.borderWidth
    = 2.0f;
}

//------------------
// Practice Configurations
//------------------
void TestManager::applyPracticeConfigurations(){

    isRecordAutoSaved = NO;
    
#ifndef __IPHONE__
    rootViewController.isShowAnswerAvailable = [NSNumber numberWithBool:YES];
    rootViewController.isDistanceEstControlAvailable =
    [NSNumber numberWithBool:YES];
    [rootViewController.nextTestButton setEnabled:YES];
    [rootViewController.previousTestButton setEnabled:YES];
    [rootViewController.confirmButton setEnabled:YES];
#endif
    
    rootViewController.mapView.layer.borderColor =
    [NSColor blueColor].CGColor;
    rootViewController.mapView.layer.borderWidth
    = 2.0f;
}

//------------------
// Study Configurations
//------------------
void TestManager::applyStudyConfigurations(){
    isRecordAutoSaved = YES;
#ifndef __IPHONE__
    // Hide the answer button
    rootViewController.isShowAnswerAvailable = [NSNumber numberWithBool:NO];
    rootViewController.isDistanceEstControlAvailable =
    [NSNumber numberWithBool:YES];
    [rootViewController.nextTestButton setEnabled:NO];
    [rootViewController.previousTestButton setEnabled:NO];
    [rootViewController.confirmButton setEnabled:YES];
#endif
    rootViewController.mapView.layer.borderColor =
    [NSColor clearColor].CGColor;
    rootViewController.mapView.layer.borderWidth
    = 0.0f;
}










