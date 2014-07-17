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
            self.renderer->watchMode = false;
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
            self.renderer->watchMode = false;
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
            self.renderer->watchMode = true;
            // Change background color to black
            for (int i = 0; i<3; ++i){
                self.renderer->model->configurations[@"bg_color"][i] =
                [NSNumber numberWithFloat:0];
            }
            self.renderer->model->configurations[@"bg_color"][3] =
            [NSNumber numberWithFloat:255];
            
            // Change compass ctr
            for (int i = 0; i<2; ++i){
                self.renderer->model->configurations[@"compass_centroid"][i] =
                [NSNumber numberWithFloat:0];
            }
            self.renderer->model->configurations[@"compass_scale"] =
            [NSNumber numberWithFloat:0.8];

            break;
    }
    [self toggleWatchMask];    
    self.renderer->loadParametersFromModelConfiguration();
    [self updateModelCompassCenterXY];
    [self.glkView setNeedsDisplay];
}

- (void) toggleWatchMask{
    
    if (self.renderer->watchMode){
        double fwidth = self.glkView.frame.size.width;
        double fheight = self.glkView.frame.size.height;
        double radius = 0.8 * fwidth/2;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.mapView.bounds.size.width, self.mapView.bounds.size.height) cornerRadius:0];
        
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:
                                    CGRectMake(fwidth/2-radius, fheight/2-radius,2*radius, 2*radius) cornerRadius:radius];
        [path appendPath:circlePath];
        [path setUsesEvenOddFillRule:YES];
        
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.path = path.CGPath;
        fillLayer.fillRule = kCAFillRuleEvenOdd;
        fillLayer.fillColor = [UIColor grayColor].CGColor;
        fillLayer.opacity = 1;
        [self.glkView.layer addSublayer:fillLayer];
    }else{
        self.glkView.layer.sublayers = nil;
    }
}

@end
