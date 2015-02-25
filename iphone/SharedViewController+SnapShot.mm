//
//  SharedViewController+SnapShot.m
//  Compass[transparent]
//
//  Created by dmiau on 7/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//
#import "xmlParser.h"

#ifdef __IPHONE__
//-------------------
// iOS
//-------------------
#import "iOSViewController.h"
@implementation iOSViewController (SnapShot)

#else

//-------------------
// Desktop (osx)
//-------------------
#import "DesktopViewController.h"
@implementation DesktopViewController (SnapShot)
#endif

//@property vector<snapshot> snapshot_array;
- (bool)takeSnapshot{
    
    // Go back to home first
    self.mapView.region = self.model->homeCoordinateRegion;
    self.mapView.camera.heading = 0;
    
    
    snapshot mySnapshot;
    // Get the center coordinates
    mySnapshot.coordinateRegion = self.mapView.region;
    
    // Get the orientation
    mySnapshot.orientation = self.model->camera_pos.orientation;
    
    // Need to save the file name too
    mySnapshot.kmlFilename = self.model->location_filename;
    mySnapshot.date_str =
    [NSDateFormatter localizedStringFromDate:[NSDate date]
                                   dateStyle:NSDateFormatterShortStyle
                                   timeStyle:NSDateFormatterFullStyle];
    mySnapshot.selected_ids = self.model->indices_for_rendering;
    mySnapshot.is_answer_list = self.model->indices_for_rendering; // Just to initialize
    
    // Capture the enable/disable status
    for (int i = 0; i < self.model->indices_for_rendering.size(); ++i){
        int lid = self.model->indices_for_rendering[i];
        if (self.model->data_array[lid].isAnswer){
            mySnapshot.is_answer_list[i] = 1;
        }else{
            mySnapshot.is_answer_list[i] = 0;
        }
    }
    
    mySnapshot.name = @"authored_snapshot";
    if (self.testManager->testManagerMode == AUTHORING){
        //--------------
        // Test authoring mode
        //--------------
        string prefix = "";
        
        // Log device type and visualization type
        if (self.renderer->watchMode){
            mySnapshot.deviceType = WATCH;
            prefix = prefix + "watch:";
        }else{
            mySnapshot.deviceType = PHONE;
            prefix = prefix + "phone:";
        }
        
        if ([self.model->configurations[@"wedge_status"]
             isEqualToString:@"on"]){
            mySnapshot.visualizationType = VIZWEDGE;
            prefix = prefix + "wedge:";
        }else{
            mySnapshot.visualizationType = VIZPCOMPASS;
            prefix = prefix + "pcompass:";
        }
     
#ifdef __IPHONE__
        prefix = prefix + "t" +
        to_string(1+self.taskSegmentControl.selectedSegmentIndex);
#endif
        // Update a new name
        mySnapshot.name = [NSString stringWithUTF8String: prefix.c_str()];
    }
    
    self.model->snapshot_array.push_back(mySnapshot);
    
    //--------------
    // Configure the environment so we can author the next test
    //--------------
    if (self.testManager->testManagerMode == AUTHORING){
        // Disable all landmarks
        for (int i = 0; i < self.model->data_array.size(); ++i) {
            self.model->data_array[i].isEnabled = false;
        }
        [self renderAnnotations];
        self.model->updateMdl();
#ifdef __IPHONE__
        [self.glkView setNeedsDisplay];
#endif
    }
    return true;
}

//------------------
// displaySnapshot loads and displays a snapshot
// when setup_viz_flag is on, the visualization settings
// at the time when the snap was taken will be loaded too
//------------------
- (bool)displaySnapshot: (int) snapshot_id
      withStudySettings: (TestManagerMode) mode
{

    if (mode != OFF){
        self.testManager->test_counter = snapshot_id;
    }
    
    //-----------
    // Set up snapshot parameters
    //-----------
    snapshot mySnapshot = self.model->snapshot_array[snapshot_id];
    
    if (![mySnapshot.kmlFilename isEqualToString: self.model->location_filename]){
        self.model->location_filename = mySnapshot.kmlFilename;
        readLocationKml(self.model, self.model->location_filename);
    }
    
    if (mySnapshot.selected_ids.size() == 0){
        // If no landmarks are specified, let the model to decide which
        // landmark to show (use the K_ORIENTATIONS method)
        
        self.model->configurations[@"filter_type"] = @"K_ORIENTATIONS";
    }else{
        //-----------------
        // Reload landmark selection status
        //-----------------
        for (int i = 0; i < self.model->data_array.size(); ++i){
            self.model->data_array[i].isEnabled = false;
        }
        
        // Need to configure the answer status
        for (int i = 0; i < mySnapshot.selected_ids.size(); ++i){
            int data_id = mySnapshot.selected_ids[i];
            if (data_id >= self.model->data_array.size()){
                [self displayPopupMessage:[NSString stringWithFormat:
                                           @"Data ID: %d does not exist in %@",
                                           data_id, self.model->location_filename]];
            }else{
                self.model->data_array[data_id].isEnabled = true;
                if (mySnapshot.is_answer_list[i] == 0){
                    self.model->data_array[data_id].isAnswer = false;
                }else{
                    self.model->data_array[data_id].isAnswer = true;
                }
            }
        }
        
        self.model->configurations[@"filter_type"] = @"MANUAL";
    }
    
#ifdef __IPHONE__
    [self updateMapDisplayRegion:mySnapshot.coordinateRegion withAnimation:NO];
#else
    if (mySnapshot.osx_coordinateRegion.span.latitudeDelta > 0){
        // Display the desktop of osx_coordinateRegion if the desktop version
        // is available.
        [self updateMapDisplayRegion:mySnapshot.osx_coordinateRegion withAnimation:NO];
    }else{
        [self updateMapDisplayRegion:mySnapshot.coordinateRegion withAnimation:NO];
    }
#endif
    
    [self renderAnnotations];
    //-----------------
    // Set up viz and device
    //-----------------
    if (mode == DEVICESTUDY){
        //--------------------
        // Phone (iOS)
        //--------------------
        
        //--------------------
        // The device is in the control mode
        // visualization needs to be set up correctly
        //--------------------
        [self setupVisualization:mySnapshot.visualizationType];
        
        self.renderer->isInteractiveLineEnabled=false;
        // Set up differently, depending on the snapshot code
        if ([mySnapshot.name rangeOfString:@"t1"].location != NSNotFound)
        {
            self.renderer->isCrossEnabled = false;
        }else if ([mySnapshot.name rangeOfString:@"t2"].location != NSNotFound)
        {
            self.renderer->isCrossEnabled = true;
        }else if ([mySnapshot.name rangeOfString:@"t3"].location != NSNotFound){
            self.renderer->isCrossEnabled = true;
            
            self.renderer->isInteractiveLineEnabled=true;
            self.renderer->interactiveLineRadian   = 0;
        }
        
        //--------------------
        // Check device setup
        //--------------------
        if (mySnapshot.deviceType == WATCH){
            if (!self.renderer->watchMode){
                [self displayPopupMessage:@"Please change to the watch mode."];
            }
        }else{
            if (self.renderer->watchMode){
                [self displayPopupMessage:@"Please change to the phone mode."];
            }
        }
        
    }else if (mode == OSXSTUDY){
        //--------------------
        // Desktop (OSX)
        //--------------------
        [self sendMessage:[NSString stringWithFormat:@"%d", snapshot_id]];
            self.renderer->isCrossEnabled = false;
        // Set up differently, depending on the snapshot code
        if ([mySnapshot.name rangeOfString:@"t1"].location != NSNotFound)
        {
            [self showLocateCollectMode:mySnapshot];
        }else if ([mySnapshot.name rangeOfString:@"t2"].location != NSNotFound)
        {
            [self showLocalizeCollectMode:mySnapshot];
        }else if ([mySnapshot.name rangeOfString:@"t3"].location != NSNotFound){
            [self showOrientCollectMode:mySnapshot];
        }else if ([mySnapshot.name rangeOfString:@"t4"].location != NSNotFound){
            [self showLocalizeCollectMode:mySnapshot];
            self.renderer->isCrossEnabled = true;
        }
    }else if (mode == OFF){
        //--------------------
        // Normal mode
        //--------------------
        self.model->configurations[@"wedge_correction_x"]
        = [NSNumber numberWithFloat: 1];
//        [self scaleiOSMapForDesktopMode:mySnapshot];
        [self setupVisualization:mySnapshot.visualizationType];
    }

    self.mapView.camera.heading = -mySnapshot.orientation;
    [self updateLocationVisibility];
    self.model->updateMdl();
    
    if (mode != OFF){
        self.testManager->updateUITestMessage();
    }
    
#ifndef __IPHONE__
    // Desktop
    [self.compassView display];
#else
    // iOS
    [self.glkView setNeedsDisplay];
#endif
    return true;
}

//----------------------
// Set up the environment to collect the answer for the locate test
//----------------------
- (void)showLocateCollectMode: (snapshot) mySnapshot{
    [self enableMapInteraction:NO];    
    self.renderer->isCrossEnabled = false;
    // Emulate the iOS enironment if on the desktop
    // (if it is in the control mode)
#ifndef __IPHONE__
    [self changeAnnotationDisplayMode:@"None"];
    [self setupVisualization:mySnapshot.visualizationType];
    self.renderer->emulatediOS.is_enabled = true;
    self.renderer->emulatediOS.is_mask_enabled = true;

    switch (mySnapshot.deviceType) {
        case PHONE:
            self.model->configurations[@"wedge_correction_x"]
            = [NSNumber numberWithFloat: 2];
            self.renderer->emulatediOS.changeDeviceType(PHONE);
            break;
        case WATCH:
            self.model->configurations[@"wedge_correction_x"]
            = [NSNumber numberWithFloat: 5.78];
            self.renderer->emulatediOS.changeDeviceType(SQUAREWATCH);
            break;
        default:
            break;
    }
    
    // Scale the map correctly, and shift the eiOS
    [self scaleiOSMapForDesktopMode:mySnapshot];
    [self shiftEmulatorAndMapForLocateCollectMode];
#endif
}

-(void)scaleiOSMapForDesktopMode: (snapshot)mySnapshot{
#ifndef __IPHONE__
    MKCoordinateSpan scaledSpan =
    [self scaleCoordinateSpanForSnapshot:mySnapshot];
    
    MKCoordinateRegion osxCoordRegion = MKCoordinateRegionMake
    (mySnapshot.coordinateRegion.center, scaledSpan);
    [self updateMapDisplayRegion:osxCoordRegion withAnimation:NO];
#endif
}

- (void)shiftEmulatorAndMapForLocateCollectMode{
#ifndef __IPHONE__
    // There could be a bug somewhere.
    // Also need to set up the positions of the em iOS
    // and the compass
    CGPoint shift;
    shift.x = -self.renderer->view_width/2 +
    self.renderer->emulatediOS.width/2;
    shift.y = 0;
    [self shiftTestingEnvironmentBy:shift];
#endif
}

//----------------------
// Set up the environment to collect the answer for the localize test
//----------------------
- (void)showLocalizeCollectMode: (snapshot) mySnapshot{
    [self enableMapInteraction:NO];
#ifndef __IPHONE__
    [self setupVisualization:VIZNONE];
    self.renderer->emulatediOS.is_enabled = FALSE;
    self.renderer->emulatediOS.is_mask_enabled = FALSE;
    
    // Need to display the region correctly
    [self changeAnnotationDisplayMode:@"Study"];
    if (mySnapshot.osx_coordinateRegion.span.latitudeDelta > 0){
        [self updateMapDisplayRegion:mySnapshot.osx_coordinateRegion withAnimation:NO];
    }else{
        [self updateMapDisplayRegion:mySnapshot.coordinateRegion withAnimation:NO];
    }

    // Need to display the pins correctly
    // All pins should be displayed in this case

#endif
}

//----------------------
// Set up the environment to collect the answer for the locate plus test
//----------------------
- (void)showLocatePlusCollectMode: (snapshot) mySnapshot{
    [self enableMapInteraction:NO];
}

//----------------------
// Set up the environment to collect the answer for the orient test
//----------------------
- (void)showOrientCollectMode: (snapshot) mySnapshot{
    [self enableMapInteraction:NO];
#ifndef __IPHONE__
    [self setupVisualization:VIZNONE];
    self.renderer->emulatediOS.is_enabled = FALSE;
    self.renderer->emulatediOS.is_mask_enabled = FALSE;
    
    // Need to display the region correctly
    [self changeAnnotationDisplayMode:@"None"];
    [self updateMapDisplayRegion:mySnapshot.coordinateRegion withAnimation:NO];
#endif
}

//----------------------
// Set up visualization
//----------------------
- (void)setupVisualization: (VisualizationType) visualizationType{
    switch(visualizationType)
    {
        case VIZPCOMPASS:
            // Turn off the personalized compass and the conventional compass
            self.model->configurations[@"personalized_compass_status"] = @"on";
            [self setFactoryCompassHidden:YES];
            
            // Turn off the wedge
            self.model->configurations[@"wedge_status"] = @"off";
            break;
        case VIZWEDGE:
            // Turn off the personalized compass and the conventional compass
            self.model->configurations[@"personalized_compass_status"] = @"off";
            [self setFactoryCompassHidden:YES];
            
            // Turn off the wedge
            self.model->configurations[@"wedge_status"] = @"on";
            
            
            if (!self.renderer->watchMode){
                self.model->configurations[@"wedge_style"] = @"modified-orthographic";
            }else{
                self.model->configurations[@"wedge_style"] = @"modified-perspective";
            }
            break;
        case VIZOVERVIEW:
            // Do nothing
            break;
        case VIZNONE:
            self.model->configurations[@"personalized_compass_status"] = @"off";
            [self setFactoryCompassHidden:YES];
            self.model->configurations[@"wedge_status"] = @"off";
            break;
        default:
            cout << "Default" <<endl;
    }
}
@end
