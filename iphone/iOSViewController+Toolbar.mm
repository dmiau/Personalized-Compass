//
//  iOSViewController+Toolbar.m
//  Compass[transparent]
//
//  Created by dmiau on 6/23/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController.h"
#import "iOSSettingViewController.h"

@implementation iOSViewController (Toolbar)

#pragma mark ------Toolbar construction------
//-----------------------
// Construct Debug toolbar
//-----------------------
- (void)constructDebugToolbar:(NSString*) mode{
    
    NSArray* title_list = @[@"[View]", @"[Mdl]", @"[Compass]", @"[Debug]"];
    NSArray* selector_list =
    @[@"toggleViewPanel:", @"toggleModelPanel:",
      @"toggleWatchPanel:", @"toggleDebugView:"];
    
    NSMutableArray* toolbar_items =[[NSMutableArray alloc] init];

    //--------------
    // Add buttons
    //--------------
    for (int i = 0; i < [title_list count]; ++i){
        SEL my_selector = NSSelectorFromString(selector_list[i]);
        
        if ([title_list[i] isEqualToString:@"[Debug]"]){
            UIBarButtonItem *flexItem = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                         target:nil action:nil];
            [toolbar_items addObject:flexItem];
        }
        
        
        UIBarButtonItem *anItem = [[UIBarButtonItem alloc]
                                             initWithTitle:title_list[i]
                                             style:UIBarButtonItemStyleBordered                                             target:self
                                             action:my_selector];
        [toolbar_items addObject:anItem];
    }
    
    //--------------
    // Add the bookmark button
    //--------------
    
#ifdef __IPAD__
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                 target:nil action:nil];
    [toolbar_items addObject:flexItem];
#endif
    
    UIBarButtonItem *anItem = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                               target:self
                               action:@selector(segueToTabController:)];
    [toolbar_items addObject:anItem];
    
    //--------------
    // Set toolboar style
    //--------------
    
    [self.toolbar setItems: toolbar_items];
    //            [self.toolbar setBarStyle:UIBarStyleDefault];
    self.toolbar.backgroundColor = [UIColor clearColor];
    self.toolbar.opaque = NO;
    [self.toolbar setTranslucent:YES];
    
    [self.toolbar setBackgroundImage:[UIImage new]
                  forToolbarPosition:UIBarPositionAny
                          barMetrics:UIBarMetricsDefault];
    //            [self.toolbar setShadowImage:[UIImage new]
    //                      forToolbarPosition:UIToolbarPositionAny];
    [self.toolbar setNeedsDisplay];
    
}




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
// Close all panels
//------------------

- (void) hideAllPanels{
    NSArray* dialog_array = @[self.viewPanel, self.modelPanel
                              , self.watchPanel, self.debugPanel];
    for (UIView* aView in dialog_array){
        [aView setHidden:YES];
        
    }
}

//------------------
// Compass (Watch) Panel
//------------------
- (IBAction)toggleWatchPanel:(id)sender {

    if ([[self watchPanel] isHidden]){
        [self hideAllPanels];
        [[self watchPanel] setHidden:NO];
        
        //--------------
        // Reconfigure the panel
        //--------------
        if ([self.model->configurations[@"personalized_compass_status"]
             isEqualToString:@"on"])
        {
            self.compassSegmentControl.selectedSegmentIndex = 1;
        }else if (self.conventionalCompassVisible){
            self.compassSegmentControl.selectedSegmentIndex = 2;
        }else{
            self.compassSegmentControl.selectedSegmentIndex = 0;
        }
        
        //Configure mode
        if (self.renderer->watchMode == false)
        {
            self.compassModeSegmentControl.selectedSegmentIndex = 0;
        }else if (self.renderer->watchMode == true){
            self.compassModeSegmentControl.selectedSegmentIndex = 2;
        }
        
        self.compassInteractionSwitch.on =
        [self.UIConfigurations[@"UICompassInteractionEnabled"] boolValue];
        
        self.compassCenterLockSwitch.on =
        [self.UIConfigurations[@"UICompassCenterLocked"] boolValue];
    }else{
        [[self watchPanel] setHidden:YES];
    }
}

//------------------
// Model Panel
//------------------
- (IBAction)toggleModelPanel:(id)sender {

    if ([[self modelPanel] isHidden]){
        [self hideAllPanels];
        [[self modelPanel] setHidden:NO];
        
        //--------------
        // Reconfigure the panel
        //--------------
        if ([self.model->configurations[@"prefilter_param"]
             isEqualToString:@"NONE"])
        {
            self.dataSegmentControl.selectedSegmentIndex = 0;
        }else if ([self.model->configurations[@"prefilter_param"]
                   isEqualToString:@"CLUSTER"]){
            self.dataSegmentControl.selectedSegmentIndex = 1;
        }else{
            self.dataSegmentControl.selectedSegmentIndex = 2;
        }
        
        if ([self.model->configurations[@"filter_type"]
             isEqualToString:@"K_ORIENTATIONS"])
        {
            self.filterSegmentControl.selectedSegmentIndex = 0;
        }else if ([self.model->configurations[@"filter_type"]
                   isEqualToString:@"NONE"]){
            self.filterSegmentControl.selectedSegmentIndex = 1;
        }else{
            self.filterSegmentControl.selectedSegmentIndex = 2;
        }
        
        //Configure lock
        if (self.model->lockLandmarks){
            // Disable controls if the lock is on
            self.dataSegmentControl.enabled = false;
            self.filterSegmentControl.enabled = false;
        }else{
            self.dataSegmentControl.enabled = true;
            self.filterSegmentControl.enabled = true;
        }
        self.landmarkLock.on = self.model->lockLandmarks;
        
    }else{
        [[self modelPanel] setHidden:YES];
    }
}

//------------------
// View Panel
//------------------

- (IBAction)toggleViewPanel:(id)sender {

    if ([[self viewPanel] isHidden]){
        [self hideAllPanels];
        [[self viewPanel] setHidden:NO];
        
        
        //--------------
        // Reconfigure the panel
        //--------------
        if ([self.model->configurations[@"personalized_compass_status"]
             isEqualToString:@"on"])
        {
            self.overviewSegmentControl.selectedSegmentIndex = 2;
        }else if (![self.overviewMapView isHidden]){
            self.overviewSegmentControl.selectedSegmentIndex = 1;
        }else{
            self.overviewSegmentControl.selectedSegmentIndex = 0;
        }
        
        // Configure wedge status
        if ([self.model->configurations[@"wedge_status"]
             isEqualToString:@"on"])
        {
            if ([self.model->configurations[@"wedge_style"]
                 isEqualToString:@"modified-perspective"])
                self.wedgeSegmentControl.selectedSegmentIndex = 3;
            else if ([self.model->configurations[@"wedge_style"]
                      isEqualToString:@"modified-orthographic"])
                self.wedgeSegmentControl.selectedSegmentIndex = 2;
            else
                self.wedgeSegmentControl.selectedSegmentIndex = 1;
        }else{
            self.wedgeSegmentControl.selectedSegmentIndex = 0;
        }

        // Configure the scale slider
        float scale = [self.model->configurations[@"overview_map_scale"]
                        floatValue];
        self.scaleSlider.value = scale;
        self.scaleIndicator.text = [NSString stringWithFormat:@"%2.1f",
                                    scale];
    }else
        [[self viewPanel] setHidden:YES];
}

//-----------------
// Debug panel
//-----------------
- (IBAction)toggleDebugView:(id)sender {
    if ([[self debugPanel] isHidden]){
        [self hideAllPanels];
        [[self debugPanel] setHidden:NO];
        
        // Update the information on the debug pane
        [self updateDebugPanel];
    }else{
        [[self debugPanel] setHidden:YES];
    }
}

- (IBAction)refreshApp:(id)sender {
    [self initMapView];
}

- (void)segueToTabController:(id)sender{
    [self performSegueWithIdentifier:@"Go2TabBarController" sender:nil];
}
@end
