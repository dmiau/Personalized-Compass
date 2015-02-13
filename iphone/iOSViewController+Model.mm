//
//  iOSViewController+Menu.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/18/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Model.h"

@implementation iOSViewController (Model)

//---------------
// The "home" button is clicked
//---------------
- (IBAction)goHome:(id)sender {
    self.mapView.region = self.model->homeCoordinateRegion;
    self.mapView.camera.heading = 0;
}

//---------------
// Set the current location as home
//---------------
- (IBAction)setCurrentAsHome:(id)sender {
    self.model->homeCoordinateRegion = self.mapView.region;
}

- (IBAction)toggleLandmarkLock:(id)sender {
    UISwitch* mySwitch = (UISwitch*) sender;
    if ([mySwitch isOn] == YES){
        self.model->lockLandmarks = true;
        self.dataSegmentControl.enabled = false;
        self.filterSegmentControl.enabled = false;
    }else{
        self.model->lockLandmarks = false;
        self.dataSegmentControl.enabled = true;
        self.filterSegmentControl.enabled = true;
    }

}

- (IBAction)filterTypeSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    
    if ([label isEqualToString:@"kOrientation"]){
        self.model->configurations[@"filter_type"] = @"K_ORIENTATIONS";
    }else if ([label isEqualToString:@"None"]){
        self.model->configurations[@"filter_type"] = @"NONE";
    }else{
        // Manual
        self.model->configurations[@"filter_type"] = @"MANUAL";
    }
    self.model->updateMdl();
    [self.glkView setNeedsDisplay];
}

- (IBAction)dataPrefilterSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    int idx = [segmentedControl selectedSegmentIndex];
    switch (idx) {
        case 0:
            self.model->configurations[@"prefilter_param"] =
            @"NONE";
            break;
        case 1:
            self.model->configurations[@"prefilter_param"] =
            @"CLUSTER";
            break;
        case 2:
            self.model->configurations[@"prefilter_param"] =
            @"CLOSEST";
            break;
        default:
            
            break;
    }
    self.model->updateMdl();
    [self.glkView setNeedsDisplay];
}

@end
