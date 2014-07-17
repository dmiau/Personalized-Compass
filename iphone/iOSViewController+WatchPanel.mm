//
//  iOSViewController+WatchPanel.m
//  Compass[transparent]
//
//  Created by dmiau on 7/16/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+WatchPanel.h"

@implementation iOSViewController (WatchPanel)

- (IBAction)watchModeSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    // need to do a deep copy
    // http://www.cocoanetics.com/2009/09/deep-copying-dictionaries/
    static NSDictionary* cache_configurations =
    [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject: self.renderer->model->configurations]];
    
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            //-----------
            // Normal
            //-----------
            for (int i = 0; i<4; ++i){
                self.renderer->model->configurations[@"bg_color"][i] =
                cache_configurations[@"bg_color"][i];
            }
            
            // revert
            // Change compass ctr
            for (int i = 0; i<2; ++i){
                self.renderer->model->configurations[@"compass_centroid"][i] =
                cache_configurations[@"compass_centroid"][i];
            }
            self.renderer->model->configurations[@"compass_scale"] =
            cache_configurations[@"compass_scale"];
            break;
        case 1:
            //-----------
            // Explorer Mode
            //-----------
            // Change background color
            for (int i = 0; i<4; ++i){
                self.renderer->model->configurations[@"bg_color"][i] =
                [NSNumber numberWithFloat:255];
            }
            // Change compass ctr
            for (int i = 0; i<2; ++i){
                self.renderer->model->configurations[@"compass_centroid"][i] =
                [NSNumber numberWithFloat:0];
            }
            self.renderer->model->configurations[@"compass_scale"] =
            [NSNumber numberWithFloat:0.9];
            break;
        case 2:
            //-----------
            // Watch Mode
            //-----------
            // Change background color
            for (int i = 0; i<4; ++i){
                self.renderer->model->configurations[@"bg_color"][i] =
                [NSNumber numberWithFloat:255];
            }
            // Change compass ctr
            for (int i = 0; i<2; ++i){
                self.renderer->model->configurations[@"compass_centroid"][i] =
                [NSNumber numberWithFloat:0];
            }
            self.renderer->model->configurations[@"compass_scale"] =
            [NSNumber numberWithFloat:0.9];
            break;
    }
    
    self.renderer->loadParametersFromModelConfiguration();
    [self updateModelCompassCenterXY];
    [self.glkView setNeedsDisplay];
}
@end
