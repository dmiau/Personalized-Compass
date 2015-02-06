//
//  DesktopViewController+Compass.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 4/4/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+Compass.h"

@implementation DesktopViewController (Compass)

- (IBAction)zoomCompass:(id)sender {
    // Get the sender title
    NSString *title = [(NSMenuItem *)sender title];
    
    if ([title rangeOfString:@"Out"].location == NSNotFound){
        // Zoom In case
        self.renderer->incrementCompassRadisByFactor(0.1);
    }else{
        // Zoom In case
        self.renderer->incrementCompassRadisByFactor(-0.1);
    }
}

- (IBAction)moveCompass:(id)sender {
    // Get the sender title
    NSString *title = [(NSMenuItem *)sender title];
    float step_size =
    [self.model->configurations[@"traslation_step"] floatValue];
    
    recVec compassXY = self.renderer->compass_centroid;

    if ([title rangeOfString:@"Right"].location != NSNotFound){
        compassXY.x = compassXY.x + step_size;
    }else if ([title rangeOfString:@"Left"].location != NSNotFound){
        compassXY.x = compassXY.x - step_size;
    }else if ([title rangeOfString:@"Up"].location != NSNotFound){
        compassXY.y = compassXY.y + step_size;
    }else if ([title rangeOfString:@"Down"].location != NSNotFound){
        compassXY.y = compassXY.y - step_size;
    }

    self.model->configurations[@"compass_centroid"][0] =
    [NSNumber numberWithInt:compassXY.x];
    self.model->configurations[@"compass_centroid"][1] =
    [NSNumber numberWithInt:compassXY.y];

    // The order is important
    self.renderer->loadParametersFromModelConfiguration();
    
    if (![self.UIConfigurations[@"UICompassCenterLocked"] boolValue]){
        [self updateModelCompassCenterXY];
    }
//    [self.compassView setNeedsDisplay:YES];
    [self.compassView display];
}

- (IBAction)toggleLabel:(id)sender {
    // Get the sender title
    NSString *title = [(NSMenuItem *)sender title];
    
    if ([title rangeOfString:@"Hide"].location != NSNotFound){
        self.renderer->label_flag = false;
        [(NSMenuItem *)sender setTitle:@"Show Labels"];
    }else{
        self.renderer->label_flag = true;
        [(NSMenuItem *)sender setTitle:@"Hide Labels"];
    }
}


- (IBAction)tiltCompass:(id)sender{
    // Get the sender title
    NSString *title = [(NSMenuItem *)sender title];
    
    if ([title rangeOfString:@"Up"].location != NSNotFound){
        self.model->tilt = self.model->tilt + 1;
    }else{
        self.model->tilt = self.model->tilt - 1;
    }
}

- (void) setFactoryCompassHidden: (BOOL) flag {
    [self mapView].showsCompass =!flag;
}
@end
