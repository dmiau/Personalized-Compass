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
- (bool)displaySnapshot: (int) id withVizSettings: (bool) setup_viz_flag
{
    snapshot mySnapshot = self.model->snapshot_array[id];
    
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

    
    // Render annotation
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    [self renderAnnotations];
    
    [self updateLocationVisibility];

    self.mapView.camera.heading = -mySnapshot.orientation;
    return true;
}
@end
