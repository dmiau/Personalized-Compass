//
//  iOSViewController+Toolbar.m
//  Compass[transparent]
//
//  Created by dmiau on 6/23/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Toolbar.h"
#import "iOSSettingViewController.h"

@implementation iOSViewController (Toolbar)
#pragma mark ------Toolbar Items------
- (void) setFactoryCompassHidden: (BOOL) flag {
    NSArray *mapSubViews = self.mapView.subviews;
    
    for (UIView *view in mapSubViews) {
        // Checks if the view is of class MKCompassView
        if ([view isKindOfClass:NSClassFromString(@"MKCompassView")]) {
            [view setHidden:flag];
            //            // Removes view from mapView
            //            [view removeFromSuperview];
        }
    }
}
//------------------
// Show pcomass in big size
//------------------
- (IBAction)toggleExplrMode:(id)sender {
    
    static BOOL explr_mode = false;
    // need to do a deep copy
    // http://www.cocoanetics.com/2009/09/deep-copying-dictionaries/
    
    static NSDictionary* cache_configurations =
    [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject: self.renderer->model->configurations]];
    
    if (!explr_mode){
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
        
        [self.glkView setNeedsDisplay];
        explr_mode = true;
    }else{
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
        
        explr_mode = false;
        [self.glkView setNeedsDisplay];
    }
}

//------------------
// Show the menu view
//------------------
- (IBAction)toggleMenu:(id)sender {
    if ([[self menuView] isHidden])
        [[self menuView] setHidden:NO];
    else{
        [[self menuView] setHidden:YES];
        

        if (self.needUpdateDisplayRegion)
            [self updateMapDisplayRegion];
    }
}

- (IBAction)toggleTypeMenu:(id)sender {
    if ([[self typeSelectorView] isHidden])
        [[self typeSelectorView] setHidden:NO];
    else
        [[self typeSelectorView] setHidden:YES];
}

- (IBAction)refreshApp:(id)sender {
    [self initMapView];
}

- (IBAction)toggleDebugView:(id)sender {
    if ([[self debugView] isHidden]){
        [[self debugView] setHidden:NO];
        
        // populate the debug view
//        // add a textview to the debug view
//        UITextView *textView = [[UITextView alloc] initWithFrame:
//                                self.debugView.bounds];
//        textView.text = @"Hello World!\n";
//        [textView setFont:[UIFont systemFontOfSize:25]];
//        textView.editable = NO;
//        [self.debugView addSubview:textView];
        
    }else{
        [[self debugView] setHidden:YES];
    }
}
@end
