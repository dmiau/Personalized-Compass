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
        self.renderer->compass_scale = self.renderer->compass_scale + 0.1;
    }else{
        // Zoom In case
        self.renderer->compass_scale = self.renderer->compass_scale - 0.1;
    }
}

- (IBAction)moveCompass:(id)sender {
    // Get the sender title
    NSString *title = [(NSMenuItem *)sender title];
    float step_size =
    [self.model->configurations[@"traslation_step"] floatValue];
    
    if ([title rangeOfString:@"Right"].location != NSNotFound){
        // Zoom In case
        self.renderer->compass_centroid.x =
        self.renderer->compass_centroid.x + step_size;
    }else if ([title rangeOfString:@"Left"].location != NSNotFound){
        // Zoom In case
        self.renderer->compass_centroid.x =
        self.renderer->compass_centroid.x - step_size;
    }else if ([title rangeOfString:@"Up"].location != NSNotFound){
        // Zoom In case
        self.renderer->compass_centroid.y =
        self.renderer->compass_centroid.y + step_size;
    }else if ([title rangeOfString:@"Down"].location != NSNotFound){
        // Zoom In case
        self.renderer->compass_centroid.y =
        self.renderer->compass_centroid.y - step_size;
    }
    
    // Provide the centroid of compass to the model
    self.model->compassCenterXY =
    [self.mapView convertPoint: NSMakePoint(self.compassView.frame.size.width/2,
                                            self.compassView.frame.size.height/2)
                      fromView:self.compassView];
    
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
@end
