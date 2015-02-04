//
//  ConfigurationsWindowController+model.m
//  Compass[transparent]
//
//  Created by Daniel on 1/14/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "ConfigurationsWindowController.h"

@implementation ConfigurationsWindowController (model)

- (IBAction)toggleLandmarkLock:(NSButton*)sender {
    
    if ([sender state] == NSOnState){
        self.model->lockLandmarks = true;
        self.dataSegmentControl.enabled = false;
        self.filterSegmentControl.enabled = false;
    }else{
        self.model->lockLandmarks = false;
        self.dataSegmentControl.enabled = true;
        self.filterSegmentControl.enabled = true;
    }
    [self.rootViewController updateMainGUI];
}

- (IBAction)filterTypeSegmentControl:(NSSegmentedControl*)segmentedControl {
    
    NSString *label = [segmentedControl
                       labelForSegment: [segmentedControl selectedSegment]];
    
    if ([label isEqualToString:@"kOrientation"]){
        self.model->configurations[@"filter_type"] = @"K_ORIENTATIONS";
    }else if ([label isEqualToString:@"None"]){
        self.model->configurations[@"filter_type"] = @"NONE";
    }else{
        // Manual
        self.model->configurations[@"filter_type"] = @"MANUAL";
    }
    
    [self.rootViewController updateMainGUI];
}

- (IBAction)dataPrefilterSegmentControl:(NSSegmentedControl*)segmentedControl {
    int idx = [segmentedControl selectedSegment];
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
    
    [self.rootViewController updateMainGUI];
}
@end
