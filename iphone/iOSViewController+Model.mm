//
//  iOSViewController+Menu.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/18/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Model.h"

@implementation iOSViewController (Model)


- (IBAction)toggleLandmarkLock:(id)sender {
    UISwitch* mySwitch = (UISwitch*) sender;
    if ([mySwitch isOn] == YES){
        self.model->lockLandmarks = true;
    }else{
        self.model->lockLandmarks = false;
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
@end
