//
//  iOSViewController+CompassPanel.m
//  Compass[transparent]
//
//  Created by dmiau on 7/16/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+CompassPanel.h"

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
            
            // Change compass ctr
            for (int i = 0; i<2; ++i){
                self.renderer->model->configurations[@"compass_centroid"][i] =
                [NSNumber numberWithFloat:0];
            }
            self.renderer->model->configurations[@"compass_scale"] =
            [NSNumber numberWithFloat:0.3];

            break;
    }
    [self toggleWatchMask];    
    self.renderer->loadParametersFromModelConfiguration();
    [self updateModelCompassCenterXY];
    [self.glkView setNeedsDisplay];
}

- (void) toggleWatchMask{
    
    float radius = [self.model->configurations[@"watch_radius"] floatValue];
    
    if (self.renderer->watchMode){
        double fwidth = self.glkView.frame.size.width;
        double fheight = self.glkView.frame.size.height;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.mapView.bounds.size.width, self.mapView.bounds.size.height) cornerRadius:0];
        
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:
                                    CGRectMake(fwidth/2-radius, fheight/2-radius,2*radius, 2*radius) cornerRadius:radius];
        [path appendPath:circlePath];
        [path setUsesEvenOddFillRule:YES];
        
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.path = path.CGPath;
        fillLayer.fillRule = kCAFillRuleEvenOdd;
        fillLayer.fillColor = [UIColor blackColor].CGColor;
        fillLayer.opacity = 1;
        [self.glkView.layer addSublayer:fillLayer];
        self.view.backgroundColor = [UIColor blackColor];
    }else{
        self.view.backgroundColor = [UIColor clearColor];
        self.glkView.layer.sublayers = nil;
    }
}


//------------------
// Select compass type
//------------------
- (IBAction)compassSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    
    if ([label isEqualToString:@"Conventional"]){
        self.conventionalCompassVisible = YES;
        //        [self.glkView setHidden:YES];
        self.model->configurations[@"personalized_compass_status"] = @"off";
        [self setFactoryCompassHidden:NO];
    }else if ([label isEqualToString:@"Personalized"]){
        self.conventionalCompassVisible = NO;
        self.model->configurations[@"personalized_compass_status"] = @"on";
        [self setFactoryCompassHidden:YES];
    }else{
        self.conventionalCompassVisible = NO;
        self.model->configurations[@"personalized_compass_status"] = @"off";
        //        [self.glkView setHidden:YES];
        [self setFactoryCompassHidden:YES];
    }
    [self.glkView setNeedsDisplay];
}


- (IBAction)compassLocationSegmentControl:(id)sender {
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    [self changeCompassLocationTo:label];
}


- (void) changeCompassLocationTo: (NSString*) label{
    // Need to perform a deep copy
    static bool cached_flag = false;
    static NSArray *defaultCentroidParams;
    static CGRect default_rect;
    
    if (!cached_flag){
        defaultCentroidParams =
        [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject: self.renderer->model->configurations[@"compass_centroid"]]];
        default_rect = self.glkView.frame;
        cached_flag = true;
    }
    
    //---------------
    // iPhone case
    //---------------
#ifndef __IPAD__
    if ([label isEqualToString:@"Default"]){
        self.model->configurations[@"compass_centroid"] = defaultCentroidParams;
    }else if ([label isEqualToString:@"UR"]){
        self.model->configurations[@"compass_centroid"][0] =
        [NSNumber numberWithInt:90];
        self.model->configurations[@"compass_centroid"][1] =
        [NSNumber numberWithInt:180];
    }else if ([label isEqualToString:@"Center"]){
        self.model->configurations[@"compass_centroid"][0] =
        [NSNumber numberWithInt:0];
        self.model->configurations[@"compass_centroid"][1] =
        [NSNumber numberWithInt:0];
    }else if ([label isEqualToString:@"BL"]){
        self.model->configurations[@"compass_centroid"][0] =
        [NSNumber numberWithInt:-70];
        self.model->configurations[@"compass_centroid"][1] =
        [NSNumber numberWithInt:-150];
    }
#endif
    
#ifdef __IPAD__
    //---------------
    // iPad case
    //---------------
    if ([label isEqualToString:@"Default"]){
        self.model->configurations[@"compass_centroid"] = defaultCentroidParams;
        self.glkView.frame = default_rect;
    }else if ([label isEqualToString:@"UR"]){
        self.model->configurations[@"compass_centroid"][0] =
        [NSNumber numberWithInt:80];
        self.model->configurations[@"compass_centroid"][1] =
        [NSNumber numberWithInt:100];
        
        self.model->configurations[@"compass_centroid"] = defaultCentroidParams;
        self.glkView.frame = default_rect;
        
    }else if ([label isEqualToString:@"Center"]){
        self.model->configurations[@"compass_centroid"][0] =
        [NSNumber numberWithInt:0];
        self.model->configurations[@"compass_centroid"][1] =
        [NSNumber numberWithInt:0];
        
        self.glkView.frame = CGRectMake(176, 314,
                                        default_rect.size.width,
                                        default_rect.size.height);
    }else if ([label isEqualToString:@"BL"]){
        self.model->configurations[@"compass_centroid"][0] =
        [NSNumber numberWithInt:-70];
        self.model->configurations[@"compass_centroid"][1] =
        [NSNumber numberWithInt:-150];
        
        self.glkView.frame = CGRectMake(0, 514,
                                        default_rect.size.width,
                                        default_rect.size.height);
    }
    
#endif
    
    // Need to update compass center (this is important!)
    [self updateModelCompassCenterXY];
    
    // The order is important
    self.renderer->loadParametersFromModelConfiguration();
    [self updateModelCompassCenterXY];
    [self.glkView setNeedsDisplay];
}




//------------------
// Label Control
//------------------
- (IBAction)labelSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            //-----------
            // None
            //-----------
            self.renderer->label_flag = false;
            break;
        case 1:
            //-----------
            // Abbreviation
            //-----------
            self.renderer->label_flag = true;
            break;
        case 2:
            //-----------
            // Full
            //-----------
            self.renderer->label_flag = true;
            break;
        default:
            throw(runtime_error("Undefined control, update needed"));
            break;
            
    }
}

@end
