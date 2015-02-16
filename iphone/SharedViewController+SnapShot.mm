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
        to_string(self.taskSegmentControl.selectedSegmentIndex);
#endif
        // Update a new name
        mySnapshot.name = [NSString stringWithUTF8String: prefix.c_str()];
    }
    
    self.model->snapshot_array.push_back(mySnapshot);
    
    //--------------
    // Set up the environment to author the next test
    //--------------
    if (self.testManager->testManagerMode == AUTHORING){
        // Disable all landmarks
        for (int i = 0; i < self.model->data_array.size(); ++i) {
            self.model->data_array[i].isEnabled = false;
        }
        [self renderAnnotations];
    }
    return true;
}

//------------------
// displaySnapshot loads and displays a snapshot
// when setup_viz_flag is on, the visualization settings
// at the time when the snap was taken will be loaded too
//------------------
- (bool)displaySnapshot: (int) snapshot_id withStudySettings: (bool) study_settings_flag
{

    if (self.testManager->testManagerMode == CONTROL){
        self.testManager->test_counter = snapshot_id;
    }
    
    //-----------
    // Set up the parameters
    //-----------
    // Default values
    bool pin_flag = true;
    bool setup_viz_flag = false;
    
    if (study_settings_flag){
        setup_viz_flag = true;
        
        if (self.testManager->testManagerMode == CONTROL){
            pin_flag = false;
        }
    }

    
    //-----------
    // Set up snapshot parameters
    //-----------
    
    
    
    
    snapshot mySnapshot = self.model->snapshot_array[snapshot_id];
    
    if (mySnapshot.kmlFilename != self.model->location_filename){
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
        for(vector<int>::iterator it = mySnapshot.selected_ids.begin();
            it != mySnapshot.selected_ids.end(); ++it)
        {
            self.model->data_array[*it].isEnabled = true;
        }
        self.model->configurations[@"filter_type"] = @"MANUAL";
    }
    
//    // Not sure why, but the following lines are needed for iPad
//    self.model->camera_pos.latitude = mySnapshot.coordinateRegion.center.latitude;
//    self.model->camera_pos.longitude = mySnapshot.coordinateRegion.center.longitude;
//
//    [self updateMapDisplayRegion:NO];

//    self.mapView.region = mySnapshot.coordinateRegion;

    [self updateMapDisplayRegion:mySnapshot.coordinateRegion withAnimation:NO];
    
    //-----------------
    // Set up viz and device
    //-----------------
    if (setup_viz_flag){


        switch(mySnapshot.visualizationType)
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
                self.model->configurations[@"wedge_style"] = @"modified-orthographic";
                break;
            case VIZOVERVIEW:
                // Do nothing
                break;
            case VIZNONE:
                // Do nothing                
                break;
            default:
                cout << "Default" <<endl;
        }
        
        if (self.testManager->testManagerMode == CONTROL){
            // Emulate the iOS enironment if on the desktop
            // (if it is in the control mode)
#ifndef __IPHONE__
            self.renderer->emulatediOS.is_enabled = true;
            self.renderer->emulatediOS.is_mask_enabled = true;
            
            
            // Also need to set up the positions of the em iOS
            // and the compass
            CGPoint shift;
            shift.x = -self.renderer->view_width/2 + 100;
            shift.y = 0;
            [self shiftTestingEnvironmentBy:shift];
#endif
        }
    }
    
    //-----------------
    // Set up pin appearance
    //-----------------
    
    if (pin_flag){
        // Show pins
        [self changeAnnotationDisplayMode:@"Enabled"];
    }else{
        // Do not show pins
        [self changeAnnotationDisplayMode:@"None"];
    }
    
    self.mapView.camera.heading = -mySnapshot.orientation;
    
    // Render annotation
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    [self renderAnnotations];
    
    [self updateLocationVisibility];
    
    self.model->updateMdl();
    
    if (self.testManager->testManagerMode == CONTROL){
        self.testManager->updateUI();
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
@end
