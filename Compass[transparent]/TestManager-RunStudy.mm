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
#include "testCodeInterpreter.h"

#ifdef __IPHONE__
// iOS
#import "iOSViewController.h"
#else
// desktop
#import "DesktopViewController.h"
#endif

//-------------------
// Update test message
//-------------------
void TestManager::updateUITestMessage(){
    
    TestCodeInterpreter codeInterpreter(model->snapshot_array[test_counter].name);
    string code = extractCode(model->snapshot_array[test_counter].name);
    
    
    NSString* testStatus =@"N/A";
    if (testManagerMode != OFF){
        NSString* testStatus =
        [NSString stringWithFormat:@"%@, %d/%d\n%@, %d/%lu",
         [NSString stringWithUTF8String:code.c_str()],
         testCountWithinCategory[test_counter],
         snapshotDistributionInfo[code],
         model->snapshot_array[test_counter].name,
         test_counter+1, model->snapshot_array.size()];
        [[NSUserDefaults standardUserDefaults] setObject:testStatus forKey:@"TestStatus"];
    }
    
    NSString* prefix;
    if ([model->snapshot_array[test_counter].name hasSuffix:@"t"])
        prefix = @"Practice:";
    else
        prefix = @"Trial:";
#ifdef __IPHONE__
    //---------------
    // iPhone
    //---------------
    if (testManagerMode == OFF){
        rootViewController.counter_button.title =
        @"StudyMode OFF";
    }else{
        rootViewController.counter_button.title =
        [NSString stringWithFormat: @"%@ %d/%d", prefix,
         testCountWithinCategory[test_counter],
         snapshotDistributionInfo[code]];
    }
#else
    //---------------
    // OSX, Desktop
    //---------------
    
    if (testManagerMode == OFF){
        rootViewController.testInformationMessage =
        @"Enable StudyMode from iOS";
    }else{
        //-----------------
        // User visible string
        //-----------------
        string userVisibleCode = extractUerVisibleCode(model->snapshot_array[test_counter].name);
        rootViewController.testInformationMessage =
        [NSString stringWithFormat:@"%@ \n\n(%@ %d out of %d)",
        [NSString stringWithUTF8String:
         codeInterpreter.genTaskInstruction().c_str()],
         prefix,
         testCountWithinCategory[test_counter],
         snapshotDistributionInfo[code]];
    }
#endif
}

#pragma mark ---------------test flow control---------------
//------------------
// Setup the environment for the next test
//------------------
void TestManager::showPreviousTest(){
    
    // Do NOT execute this method if test_counter is already 0
    if (test_counter == 0){
        return;
    }

    showTestNumber(test_counter -1);
}

//------------------
// Setup the environment for the next test
//------------------
void TestManager::showNextTest(){
    // Do NOT execute this method if test_counter is already the max
    if (test_counter == (model->snapshot_array.size() - 1))
    {
        return;
    }
    showTestNumber(test_counter + 1);
}

//------------------
// Show test by ID
//------------------
void TestManager::showTestNumber(int test_id){
    
#ifdef __IPHONE__
    // Make sure the answer is not shown
    [rootViewController toggleAnswersVisibility:NO];
#endif
    
    int current_id = test_counter;
    
    // Do NOT execute this method if test_counter is out of the bound
    if (test_id < 0 || test_id >= model->snapshot_array.size() ){
        return;
    }
    
    [rootViewController displaySnapshot:test_id
                      withStudySettings:testManagerMode];
    test_counter = test_id;
#ifndef __IPHONE__
    //-----------------
    // Need to do some checking before updating the counter
    // The instructions need to be shown when entering a new task
    //-----------------
    snapshot currentSnapshot = model->snapshot_array[current_id];
    snapshot nextSnapshot = model->snapshot_array[test_id];
    
    if ( NSStringToTaskType(currentSnapshot.name) !=
        NSStringToTaskType(nextSnapshot.name)
        ||(test_counter == 0))
    {
        [rootViewController displayTestInstructionsByCode: nextSnapshot.name];
    }else{
        rootViewController.studyIntAnswer = [NSNumber numberWithInt:0];
        startTest();
        
        if (!rootViewController.isPracticingMode)
        {

            [rootViewController.nextTestButton setEnabled:NO];
        }
    }
    
    // Do a forced backup
    saveRecord([rootViewController.model->desktopDropboxDataRoot
                stringByAppendingPathComponent:
                @"midTestBackup.dat"], YES);
#endif
    updateUITestMessage();
}

bool TestManager::verifyAnswerQuality(){
    
    snapshot mySnapshot = model->snapshot_array[test_counter];
    
    int data_id = mySnapshot.selected_ids[0];
    
    record myRecord = record_vector[test_counter];
    if (!myRecord.isAnswered){
        [rootViewController displayPopupMessage:
         @"Please answer before proceeding to the next test."];
        return false;
    }
    
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
//        iOSAnswer = 10000;
        //-----------------
        // Orient test
        //-----------------
        if (iOSAnswer > 1000){
            [rootViewController displayPopupMessage:
             @"Please answer before proceeding to the next test."];
            return false;
        }
        
        
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
        (double) rootViewController.renderer->emulatediOS.width * 2;
        
        // Log the information as seen from compass renderer
        record_vector[test_counter].cgPointOpenGL =
        model->data_array[data_id].openGLPoint;
        
    }else if ([mySnapshot.name rangeOfString:toNSString(TRIANGULATE)].location != NSNotFound){
        //-----------------
        // Triangulate test
        //-----------------
        
        CGPoint openGLPoint = [rootViewController calculateOpenGLPointFromMapCoord:
                               mySnapshot.coordinateRegion.center];
        record_vector[test_counter].cgPointTruth = openGLPoint;
        record_vector[test_counter].doubleTruth = 0;
        
        // Fill out the informaiton of two additional points
        CLLocationCoordinate2D coord;
        coord = CLLocationCoordinate2DMake(
                rootViewController.model->data_array[mySnapshot.selected_ids[0]].latitude,
                rootViewController.model->data_array[mySnapshot.selected_ids[0]].longitude);
        CGPoint cgData1 = [rootViewController calculateOpenGLPointFromMapCoord:
                               coord];
        record_vector[test_counter].cgSupport1 = cgData1;
        
        coord = CLLocationCoordinate2DMake(
                rootViewController.model->data_array[mySnapshot.selected_ids[1]].latitude,
                rootViewController.model->data_array[mySnapshot.selected_ids[1]].longitude);
        
        CGPoint cgData2 = [rootViewController calculateOpenGLPointFromMapCoord:
                               coord];
        record_vector[test_counter].cgSupport2 = cgData2;
        
        record_vector[test_counter].display_radius =
        sqrt(pow(cgData1.x - cgData2.x, 2) + pow(cgData1.y - cgData2.y, 2))/2;
        
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
        int nonans_id = 0;
        // Find out the answer ID
        for (int i = 0; i < mySnapshot.selected_ids.size(); ++i){
            if (mySnapshot.is_answer_list[i] == 1)
                ans_id = mySnapshot.selected_ids[i];
            else
                nonans_id = mySnapshot.selected_ids[i];
        }
        
        CGPoint openGLPoint = [rootViewController calculateOpenGLPointFromMapCoord:
                               CLLocationCoordinate2DMake
                               (model->data_array[ans_id].latitude,
                                model->data_array[ans_id].longitude)];
        record_vector[test_counter].cgPointTruth = openGLPoint;
        record_vector[test_counter].doubleTruth = 0;
        
        
        // Fill out the informaiton of two additional points
        CGPoint cgData1 = [rootViewController calculateOpenGLPointFromMapCoord:
                           mySnapshot.coordinateRegion.center];
        record_vector[test_counter].cgSupport1 = cgData1;
        CLLocationCoordinate2D coord;
        coord = CLLocationCoordinate2DMake(
                                           rootViewController.model->data_array[nonans_id].latitude,
                                           rootViewController.model->data_array[nonans_id].longitude);
        
        CGPoint cgData2 = [rootViewController calculateOpenGLPointFromMapCoord:
                           coord];
        record_vector[test_counter].cgSupport2 = cgData2;
        record_vector[test_counter].display_radius =
        sqrt(pow(cgData1.x - cgData2.x, 2) + pow(cgData1.y - cgData2.y, 2));
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
#ifndef __IPHONE__
    rootViewController.isPracticingMode = [NSNumber numberWithBool:YES];
    [rootViewController.nextTestButton setEnabled:YES];

    [rootViewController.confirmButton setEnabled:YES];
#endif
    isRecordAutoSaved = NO;    
    rootViewController.mapView.layer.borderColor =
    [NSColor blueColor].CGColor;
    rootViewController.mapView.layer.borderWidth
    = 2.0f;
}

//------------------
// Study Configurations
//------------------
void TestManager::applyStudyConfigurations(){
#ifndef __IPHONE__
    // Hide the answer button
    rootViewController.isPracticingMode = [NSNumber numberWithBool:NO];
    [rootViewController.nextTestButton setEnabled:NO];
    [rootViewController.confirmButton setEnabled:YES];
#endif
    isRecordAutoSaved = YES;
    rootViewController.mapView.layer.borderColor =
    [NSColor clearColor].CGColor;
    rootViewController.mapView.layer.borderWidth
    = 0.0f;
}










