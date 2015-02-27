//
//  DesktopViewController+SnapShotcapture.m
//  Compass[transparent]
//
//  Created by Daniel on 2/27/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//
#import "xmlParser.h"

#ifdef __IPHONE__
//-------------------
// iOS
//-------------------
#import "iOSViewController.h"
@implementation iOSViewController (SnapShotcapture)

#else

//-------------------
// Desktop (osx)
//-------------------
#import "DesktopViewController.h"
@implementation DesktopViewController (SnapShotcapture)
#endif

- (bool)takeSnapshot{
    
    if (self.testManager->testManagerMode == AUTHORING){
        // Go back to home first
        self.mapView.region = self.model->homeCoordinateRegion;
        self.mapView.camera.heading = 0;
    }
    
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
    mySnapshot.is_answer_list.clear();
    // Just to initialize
    for (int i = 0; i < mySnapshot.selected_ids.size(); ++i){
        mySnapshot.is_answer_list.push_back(0);
    }
    
    // Capture the enable/disable status
    for (int i = 0; i < self.model->indices_for_rendering.size(); ++i){
        int lid = self.model->indices_for_rendering[i];
        if (self.model->data_array[lid].isAnswer){
            mySnapshot.is_answer_list[i] = 1;
        }else{
            mySnapshot.is_answer_list[i] = 0;
        }
    }
    
    
    
    mySnapshot.name = @"mySnapshot";
    if (self.testManager->testManagerMode == AUTHORING){
        //--------------
        // Test authoring mode
        //--------------
        mySnapshot.name = @"authored_snapshot";
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


@end