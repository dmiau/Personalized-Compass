//
//  iOSViewController+Menu.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/18/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Menu.h"

@implementation iOSViewController (Menu)

- (IBAction)togglePCompass:(id)sender {
    UISwitch* mySwitch = (UISwitch*) sender;
    if ([mySwitch isOn] == YES){
        self.model->configurations[@"personalized_compass_status"] = @"on";
    }else{
        self.model->configurations[@"personalized_compass_status"] = @"off";
    }
}

- (IBAction)toggleWedge:(id)sender {
    UISwitch* mySwitch = (UISwitch*) sender;
    if ([mySwitch isOn] == YES){
     self.model->configurations[@"wedge_status"] = @"on";
    }else{
     self.model->configurations[@"wedge_status"] = @"off";
    }
}

- (IBAction)toggleLandmarkLock:(id)sender {
    UISwitch* mySwitch = (UISwitch*) sender;
    if ([mySwitch isOn] == YES){
        self.model->lockLandmarks = true;
    }else{
        self.model->lockLandmarks = false;
    }

}
@end
