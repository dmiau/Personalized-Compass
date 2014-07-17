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
- (IBAction)toggleWatchPanel:(id)sender {
    if ([[self watchPanel] isHidden]){
        [[self viewPanel] setHidden:YES];
        [[self watchPanel] setHidden:NO];
    }else{
        [[self watchPanel] setHidden:YES];
    }
}

//------------------
// Show the menu view
//------------------
- (IBAction)toggleModelPanel:(id)sender {
    if ([[self modelPanel] isHidden]){
        [[self viewPanel] setHidden:YES];
        [[self modelPanel] setHidden:NO];
    }else{
        [[self modelPanel] setHidden:YES];
        
        if (self.needUpdateDisplayRegion)
            [self updateMapDisplayRegion];
    }
}

- (IBAction)toggleViewPanel:(id)sender {
    if ([[self viewPanel] isHidden]){
        [[self modelPanel] setHidden:YES];        
        [[self viewPanel] setHidden:NO];
    }else
        [[self viewPanel] setHidden:YES];
}


- (IBAction)toggleDebugView:(id)sender {
    if ([[self debugPanel] isHidden]){
        [[self debugPanel] setHidden:NO];
        self.debugTextView.text = self.renderer->debugString;
    }else{
        [[self debugPanel] setHidden:YES];
    }
}

- (IBAction)refreshApp:(id)sender {
    [self initMapView];
}
@end
