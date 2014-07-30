//
//  iOSViewController+SnapShot.m
//  Compass[transparent]
//
//  Created by dmiau on 7/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+SnapShot.h"

@implementation iOSViewController (SnapShot)

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
    self.model->snapshot_array.push_back(mySnapshot);
    return true;
}

- (bool)displaySnapshot: (int) id
{
    snapshot mySnapshot = self.model->snapshot_array[id];
    
    self.model->location_filename = mySnapshot.kmlFilename;
    self.model->reloadFiles();
    
    
#ifdef __IPAD__
    // Not sure why, but the following lines are needed for iPad
    self.model->camera_pos.latitude = mySnapshot.coordinateRegion.center.latitude;
    self.model->camera_pos.longitude = mySnapshot.coordinateRegion.center.longitude;
#else
    [self.mapView setRegion: mySnapshot.coordinateRegion animated:YES];
#endif
    [self updateMapDisplayRegion];
    [self updateLocationVisibility];
    self.model->updateMdl();
    self.mapView.camera.heading = -mySnapshot.orientation;
    return true;
}
- (bool)saveSnapshotArray{
    return true;
}

- (bool)loadSanpshotArray{
    return true;
}

@end
