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

- (bool)displaySnapshot: (int) id{
    snapshot mySnapshot = self.model->snapshot_array[id];
    [self.mapView setRegion: mySnapshot.coordinateRegion animated:YES];
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
