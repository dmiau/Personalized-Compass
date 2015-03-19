//
//  TestManager-InitCleanUp.mm
//  Compass[transparent]
//
//  Created by Daniel on 3/14/15.
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

#pragma mark ---------------start up/clean up---------------

//------------------
// Toggle test manager
//------------------
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


//------------------
// Setup the environment for the next test
//------------------
void TestManager::initTestEnv(TestManagerMode mode, bool instructPartner){
    testManagerMode = mode;
    rootViewController.renderer->isNorthIndicatorOn = false;
    test_counter = 0; // Reset the test counter
    iOSAnswer = 10000;
    isLocked = NO;
    
    // Need to turn off map interactions in the study mode
    [rootViewController enableMapInteraction:NO];
    [rootViewController changeAnnotationDisplayMode:@"None"];
    
    //----------------------------
    // Visualization Parameters
    //----------------------------
    model->configurations[@"style_type"] = @"REAL_RATIO";
    
    
    //-----------
    // Do a forced reload of the snapshot files
    //-----------
    if (readSnapshotKml(rootViewController.model)!= EXIT_SUCCESS)
    {
        [rootViewController displayPopupMessage:
         [NSString stringWithFormat:@"Failed to read %@",
          rootViewController.model->snapshot_filename]];
        return;
    }
    
    snapshot mySnapshot = model->snapshot_array[0];
    //-----------
    // Do a forced reload of the location files
    //-----------
    model->location_filename = mySnapshot.kmlFilename;
    readLocationKml(model, model->location_filename);
    
    
    //----------------------------
    // - Create one record for each snapshot
    // - Collect the snapshot categorical information
    //----------------------------
    record_vector.clear();
    snapshotDistributionInfo.clear();
    testCountWithinCategory.clear();
    testSequenceVector.clear();
    chapterInfo.clear();
    int count_within_category = 1;
    int chapter_count = 1;
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
        // Collect test information
        //-------------
        snapshot mySnapshot = model->snapshot_array[i];
        string code = extractCode(mySnapshot.name);
        
        if (snapshotDistributionInfo.find(code) == snapshotDistributionInfo.end()){
            snapshotDistributionInfo[code] = 1;
            count_within_category = 1;
            testCountWithinCategory.push_back(count_within_category);
            testSequenceVector.push_back(code);
            
            if (![mySnapshot.name hasSuffix:@"t"]){
                chapterInfo[code] = chapter_count++;
            }
            
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
        
        // Show text message before the very first
        [rootViewController displayInformationText];
        rootViewController.isStudyMode = [NSNumber numberWithBool:NO];        
#endif
    }
    updateSessionInformation();
    updateUITestMessage();
    showTestNumber(0);
}

//-------------------
// Clean up the environment
//-------------------
void TestManager::cleanupTestEnv(TestManagerMode mode, bool instructPartner){
    rootViewController.renderer->isNorthIndicatorOn = true;
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
        
        // Show text message after the last test
        [rootViewController displayInformationText];
        
        [rootViewController.nextTestButton setEnabled:NO];

        [rootViewController.confirmButton setEnabled:NO];
        rootViewController.isPracticingMode = [NSNumber numberWithBool:NO];
        rootViewController.isDistanceEstControlAvailable =
        [NSNumber numberWithBool:NO];
        
        if (isRecordAutoSaved){
            rootViewController.testManager->saveRecord(
                                                       [rootViewController.model->desktopDropboxDataRoot
                                                        stringByAppendingPathComponent:
                                                        record_filename]
                                                       , true);
        }else{
            rootViewController.testManager->saveRecord(
                                                       [rootViewController.model->desktopDropboxDataRoot
                                                        stringByAppendingPathComponent:
                                                        @"testEndBackup.dat"]
                                                       , true);
        }
        if (instructPartner){
            [rootViewController sendMessage: @"End"];
        }
        
        rootViewController.mapView.layer.borderColor =
        [NSColor clearColor].CGColor;
        rootViewController.mapView.layer.borderWidth
        = 0.0f;
        rootViewController.isStudyMode = [NSNumber numberWithBool:NO];
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
    updateSessionInformation();
    updateUITestMessage();
}


bool hasEnding (std::string const &fullString, std::string const &ending) {
    if (fullString.length() >= ending.length()) {
        return (0 == fullString.compare (fullString.length() - ending.length(), ending.length(), ending));
    } else {
        return false;
    }
}


//---------------
// Update session information
//---------------
void TestManager::updateSessionInformation()
{
    //------------------
    // Update Admin session text
    //------------------
    
    string test_sequence = "";
    for (int i = 0; i < testSequenceVector.size(); ++i){
        int count = snapshotDistributionInfo[testSequenceVector[i]];
        test_sequence = test_sequence +
        testSequenceVector[i] + ": " + to_string(count) + "\n";
    }
    
    
    int ans_counter = 0;
    for (int i = 0; i < record_vector.size(); ++i){
        if (record_vector[i].isAnswered){
            ++ans_counter;
        }
    }
    string answerMsg = to_string(ans_counter) + " out of " +
    to_string((int)record_vector.size()) + " answered.";
    
    string fileMsg;
    fileMsg = "DBRoot: \n" + string([model->desktopDropboxDataRoot UTF8String]) + "\n" +
    "Location file: " + string([model->location_filename UTF8String]) + "\n" +
    "Snapshot file: " + string([model->snapshot_filename UTF8String]) + "\n" +
    "Record file: " + string([record_filename UTF8String]) + "\n\n";
    
    string admin_string;
    admin_string = test_sequence + "\n" + answerMsg + "\n\n" + fileMsg;

    [[NSUserDefaults standardUserDefaults]
     setObject:[NSString stringWithUTF8String:admin_string.c_str()]
     forKey:@"AdminSessionInfo"];
    
    //------------------
    // Update User session text
    //------------------
    
    // Assume the layout of testSequenceVector is fixed
    string user_string;
    if (testSequenceVector.size() >= 20){
        user_string = "A Day in the City\n\n";
        
        
        // Note the test sequence string is reset here
        if (NSStringToVisualizationType
            ([NSString stringWithUTF8String:testSequenceVector[5].c_str()]) == VIZPCOMPASS)
        {
            test_sequence = "Technique C\nPractices\n";
        }else{
            test_sequence = "Technique W\nPractices\n";
        }
        
        for (int i = 0; i < 5; ++i){
            
            // Skip the practice tasks
            if (hasEnding(testSequenceVector[i+5], ":t"))
                continue;
            TestCodeInterpreter codeInterpreter(testSequenceVector[i+5]);
            
            test_sequence = test_sequence + "Chapter " + to_string(i+1) + ": " +
            codeInterpreter.genTitle() + "\n";
        }
        
        test_sequence = test_sequence + "\n--- Intermission ---\n\n";
        if (NSStringToVisualizationType
            ([NSString stringWithUTF8String:testSequenceVector[10].c_str()]) == VIZPCOMPASS)
        {
            test_sequence = test_sequence + "Technique C\nPractices\n";
        }else{
            test_sequence = test_sequence + "Technique W\nPractices\n";
        }
        for (int i = 0; i < 5; ++i){
            
            // Skip the practice tasks
            if (hasEnding(testSequenceVector[i+15], ":t"))
                continue;
            TestCodeInterpreter codeInterpreter(testSequenceVector[i+15]);
            
            test_sequence = test_sequence + "Chapter " + to_string(i+6) + ": " +
            codeInterpreter.genTitle() + "\n";
        }
        test_sequence = test_sequence + "\n--- The End ---\n\n";
        
        user_string = user_string + test_sequence;
    }else{
        user_string = string("testSequenceVector is empty.\n") +
        string("TestManager needs to be initialized");
    }
    
    [[NSUserDefaults standardUserDefaults]
     setObject:[NSString stringWithUTF8String:user_string.c_str()]
                                              forKey:@"UserSessionInfo"];
    
    [[NSUserDefaults standardUserDefaults]
     setObject:[NSString stringWithUTF8String:user_string.c_str()]
     forKey:@"DisplayedSessionInfo"];
}