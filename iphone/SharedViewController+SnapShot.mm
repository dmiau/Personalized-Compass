//
//  SharedViewController+SnapShot.m
//  Compass[transparent]
//
//  Created by dmiau on 7/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

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
    mySnapshot.name = @"debug_snapshot";
    mySnapshot.date_str =
    [NSDateFormatter localizedStringFromDate:[NSDate date]
                                   dateStyle:NSDateFormatterShortStyle
                                   timeStyle:NSDateFormatterFullStyle];
    mySnapshot.selected_ids = self.model->indices_for_rendering;
    self.model->snapshot_array.push_back(mySnapshot);
    return true;
}

//------------------
// displaySnapshot loads and displays a snapshot
// when setup_viz_flag is on, the visualization settings
// at the time when the snap was taken will be loaded too
//------------------
- (bool)displaySnapshot: (int) snapshot_id withStudySettings: (bool) study_settings_flag
{
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
    
    snapshot mySnapshot = self.model->snapshot_array[snapshot_id];
    
    self.model->location_filename = mySnapshot.kmlFilename;
    self.model->reloadFiles();
    
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
    
    // Not sure why, but the following lines are needed for iPad
    self.model->camera_pos.latitude = mySnapshot.coordinateRegion.center.latitude;
    self.model->camera_pos.longitude = mySnapshot.coordinateRegion.center.longitude;

    [self updateMapDisplayRegion:NO];
    self.mapView.region = mySnapshot.coordinateRegion;
    
    // Not sure why setRegion does not work well...
//    [self.mapView setRegion: mySnapshot.coordinateRegion animated:YES];    
    
    self.model->updateMdl();

    
    //-----------------
    // Set up viz and device
    //-----------------
    if (setup_viz_flag){
        if (self.testManager->testManagerMode == CONTROL){
            // Emulate the iOS enironment if on the desktop
            // (if it is in the control mode)
#ifndef __IPHONE__
            self.renderer->emulatediOS.is_enabled = true;
            self.renderer->emulatediOS.is_mask_enabled = true;
            
            
            // Also need to set up the positions of the em iOS
            // and the compass
            
            
            
#endif
        }

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
#ifndef __IPHONE__
        // Desktop
        [self.compassView display];
#else
        // iOS
        [self.glkView setNeedsDisplay];
#endif
    }
    
//    else{
//
//#ifndef __IPHONE__
//        // Turn off all the visualization and device settings, at least on desktop
//        
//        // Turn off the personalized compass and the conventional compass
//        self.model->configurations[@"personalized_compass_status"] = @"off";
//        [self setFactoryCompassHidden:YES];
//        
//        // Turn off the wedge
//        self.model->configurations[@"wedge_status"] = @"off";
//        
//        [self.compassView display];
//#endif
//    }

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
    
    
    // Render annotation
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    [self renderAnnotations];
    
    [self updateLocationVisibility];

    self.mapView.camera.heading = -mySnapshot.orientation;
    return true;
}
@end
